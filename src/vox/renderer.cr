require "../vox"
require "file_utils"
require "common_marker"

class Vox::Renderer
  EXTENSIONS = ["table", "strikethrough", "autolink", "tagfilter", "tasklist"]
  OPTIONS = ["unsafe"]

  def initialize(root_dir)
    @root_dir = File.expand_path(root_dir)
    @src_dir = File.join(@root_dir, "src")
    @target_dir = File.join(@root_dir, "target")
  end

  def render(src : String)
    target = default_target(src)
    make_target_dir(target)
    File.write(target, render_markdown(File.read(src)))
  end

  private def default_target(src : String)
    File.expand_path(src).sub(@src_dir, @target_dir).sub(/\.md$/, ".html")
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
