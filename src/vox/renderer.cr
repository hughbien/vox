require "../vox"
require "file_utils"
require "common_marker"
require "crustache"

class Vox::Renderer
  EXTENSIONS = ["table", "strikethrough", "autolink", "tagfilter", "tasklist"]
  OPTIONS = ["unsafe"]

  @config : Config

  delegate src_dir, target_dir, layouts_dir, to: @config

  def initialize(@config)
  end

  # TODO: handle file not found errors, optimize mustache args heap usage
  def render(src : String)
    target = default_target(src)
    make_target_dir(target)
    page, source = FrontMatter.split_file(src)
    args = {
      "page" => page,
      "fingerprint" => Fingerprint.prints
    }

    body = File.extname(src) == ".md" ?
      render_markdown(source, args) :
      render_html(source, args)
    File.write(
      target,
      render_mustache(
        File.read(default_layout),
        {"body" => body, "fingerprint" => Fingerprint.prints, "page" => page}
      )
    )
    target
  end

  private def make_target_dir(target : String)
    FileUtils.mkdir_p(File.dirname(target))
  end

  private def default_target(src : String)
    File.expand_path(src).sub(src_dir, target_dir).sub(/\.md$/, ".html")
  end

  private def default_layout
    File.join(layouts_dir, "site.html")
  end

  private def render_mustache(template : String, arguments)
    Crustache.render(Crustache.parse(template), arguments)
  end

  private def render_html(html : String, arguments)
    render_mustache(html, arguments)
  end

  private def render_markdown(markdown : String, arguments)
    CommonMarker.new(
      render_mustache(markdown, arguments),
      options: OPTIONS,
      extensions: EXTENSIONS
    ).to_html
  end
end
