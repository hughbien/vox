require "../vox"
require "file_utils"
require "common_marker"
require "crustache"

class Vox::Renderer
  EXTENSIONS = ["table", "strikethrough", "autolink", "tagfilter", "tasklist"]
  OPTIONS = ["unsafe"]

  @config : Config

  delegate src_dir, target_dir, to: @config

  def initialize(@config)
  end

  # TODO: handle file not found errors, optimize mustache args heap usage
  def render(src : String)
    page, source = FrontMatter.split_file(src)
    args = {
      "page" => page,
      "fingerprint" => Fingerprint.prints
    }
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

  private def fetch_target(page : Hash(YAML::Any, YAML::Any), src : String)
    target = page["target"].as_s? if page.has_key?("target")
    if target
      File.expand_path(File.join(target_dir, target))
    else
      File.expand_path(src).sub(src_dir, target_dir).sub(/\.md$/, ".html")
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
    render_mustache(
      File.read(@config.layout_for("html")),
      {"body" => body, "fingerprint" => Fingerprint.prints, "page" => page}
    )
  end
end
