require "../vox"
require "file_utils"
require "common_marker"
require "crinja"

class Vox::Renderer
  EXTENSIONS = ["table", "strikethrough", "autolink", "tagfilter", "tasklist"]
  OPTIONS = ["unsafe"]

  alias RenderType = String | Hash(String, Asset::Entry) | Hash(String, Fingerprint::Entry) | Hash(YAML::Any, YAML::Any) | Array(Hash(YAML::Any, YAML::Any))

  @config : Config
  @database : Database
  @front : FrontMatter
  @list : List

  delegate src_dir, target_dir, to: @config

  def initialize(@config, @database, @front, @list)
  end

  # TODO: handle file not found errors, optimize crinja args heap usage
  def render(src : String)
    _, source = FrontMatter.split_file(src) # TODO: add FrontMatter method that doesn't parse YAML
    @front.resolve_links(src) # TODO: can this be moved? Must be resolved after all pages are added to frontmatter
    page = @front.pages_by_source[src].as_h
    return if page.has_key?("published") && !page["published"].as_bool

    args = Hash(String, RenderType).new
    args["assets"] = Asset.assets
    args["db"] = @database.db
    args["page"] = page
    args["pages"] = @front.pages
    args["prints"] = Fingerprint.prints
    @list.add_render_args(args)

    target = fetch_target(page, src)
    is_html = File.extname(target) == ".html"
    skip_layout = page.has_key?("layout") && !page["layout"].as_s? && !page["layout"].as_bool # layout : false
    make_target_dir(target)

    body = File.extname(src) == ".md" ?
      render_markdown(source, args) :
      render_crinja(source, args)
    File.write(
      target,
      is_html && !skip_layout ? render_layout(body, page) : body
    )
    @list.write_rss_item(src, page, body) if is_html && @list.includes?(src)
    target
  end

  # TODO: extract to module
  private def fetch_target(page : Hash(YAML::Any, YAML::Any), src : String)
    target = page["target"].as_s? if page.has_key?("target")
    if target
      File.join(target_dir, target)
    elsif @list.includes?(src)
      @list.fetch_target(src)
    else
      src.sub(src_dir, target_dir).sub(/\.md$/, ".html")
    end
  end

  private def make_target_dir(target : String)
    FileUtils.mkdir_p(File.dirname(target))
  end

  private def render_crinja(template : String, arguments)
    Crinja.render(template, arguments)
  end

  private def render_markdown(markdown : String, arguments)
    CommonMarker.new(
      render_crinja(markdown, arguments),
      options: OPTIONS,
      extensions: EXTENSIONS
    ).to_html
  end

  # TODO: support non-HTML layouts like XML/JSON
  private def render_layout(body : String, page : Hash(YAML::Any, YAML::Any))
    layout_file = page.has_key?("layout") ?
      File.join(@config.src_dir, page["layout"].as_s) :
      @config.layout_for("html")
    layout_args, layout_source = FrontMatter.split_file(layout_file)

    args = Hash(String, RenderType).new
    args["assets"] = Asset.assets
    args["body"] = body
    args["db"] = @database.db
    args["layout"] = layout_args
    args["page"] = page
    args["pages"] = @front.pages
    args["prints"] = Fingerprint.prints
    @list.add_render_args(args)
    render_crinja(layout_source, args)
  end
end
