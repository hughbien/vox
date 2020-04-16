require "../vox"
require "file_utils"
require "common_marker"
require "crustache"

class Vox::Renderer
  EXTENSIONS = ["table", "strikethrough", "autolink", "tagfilter", "tasklist"]
  OPTIONS = ["unsafe"]

  @config : Config
  @database : Database
  @front : FrontMatter
  @blog : Blog

  delegate src_dir, target_dir, to: @config

  def initialize(@config, @database, @front, @blog)
  end

  # TODO: handle file not found errors, optimize mustache args heap usage
  def render(src : String)
    _, source = FrontMatter.split_file(src) # TODO: add FrontMatter method that doesn't parse YAML
    @front.resolve_links(src) # TODO: can this be moved? Must be resolved after all pages are added to frontmatter
    page = @front.pages_by_source[src].as_h
    return if page.has_key?("published") && !page["published"].as_bool

    args = {
      "blog" => @blog.on? ? {"posts" => @blog.posts} : nil,
      "db" => @database.db,
      "page" => page,
      "pages" => @front.pages,
      "prints" => Fingerprint.prints
    }
    args.compact!

    target = fetch_target(page, src)
    make_target_dir(target)

    body = File.extname(src) == ".md" ?
      render_markdown(source, args) :
      render_mustache(source, args)
    File.write(
      target,
      File.extname(target) == ".html" ? render_layout(body, page) : body
    )
    target
  end

  # TODO: extract to module
  private def fetch_target(page : Hash(YAML::Any, YAML::Any), src : String)
    target = page["target"].as_s? if page.has_key?("target")
    if target
      File.join(target_dir, target)
    elsif @blog.includes?(src)
      @blog.fetch_target(src).sub(/\.md$/, ".html")
    else
      src.sub(src_dir, target_dir).sub(/\.md$/, ".html")
    end
  end

  private def make_target_dir(target : String)
    FileUtils.mkdir_p(File.dirname(target))
  end

  private def render_mustache(template : String, arguments)
    Crustache.render(Crustache.parse(template), arguments)
  end

  private def render_markdown(markdown : String, arguments)
    CommonMarker.new(
      render_mustache(markdown, arguments),
      options: OPTIONS,
      extensions: EXTENSIONS
    ).to_html
  end

  # TODO: support non-HTML layouts like XML/JSON
  private def render_layout(body : String, page : Hash(YAML::Any, YAML::Any))
    layout_args, layout_source = FrontMatter.split_file(@config.layout_for("html"))
    args = {
      "body" => body,
      "blog" => @blog.on? ? {"posts" => @blog.posts} : nil,
      "db" => @database.db,
      "layout" => layout_args,
      "page" => page,
      "pages" => @front.pages,
      "prints" => Fingerprint.prints
    }
    args.compact!
    render_mustache(layout_source, args)
  end
end
