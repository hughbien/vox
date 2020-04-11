require "../vox"
require "file_utils"
require "common_marker"
require "crustache"

class Vox::Renderer
  EXTENSIONS = ["table", "strikethrough", "autolink", "tagfilter", "tasklist"]
  OPTIONS = ["unsafe"]

  def initialize(root_dir : String)
    @root_dir = File.expand_path(root_dir)
    @src_dir = File.join(@root_dir, "src")
    @target_dir = File.join(@root_dir, "target")
    @layouts_dir = File.join(@src_dir, "layouts")
  end

  def render(src : String)
    target = default_target(src)
    make_target_dir(target)
    layout = Crustache.parse(File.read(default_layout))
    body = render_markdown(File.read(src))
    File.write(target, Crustache.render(layout, {"body" => body}))
  end

  private def default_target(src : String)
    File.expand_path(src).sub(@src_dir, @target_dir).sub(/\.md$/, ".html")
  end

  private def default_layout
    File.join(@layouts_dir, "site.html")
  end

  private def make_target_dir(target : String)
    FileUtils.mkdir_p(File.dirname(target))
  end

  private def render_markdown(markdown : String)
    CommonMarker.new(
      markdown,
      options: OPTIONS,
      extensions: EXTENSIONS
    ).to_html
  end
end
