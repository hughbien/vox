require "../vox"
require "file_utils"

class Vox::Copy
  @config : Config

  def initialize(@config)
  end

  # TODO: handle non-existing file
  def run(src : String)
    src = File.expand_path(src)
    target = default_target(src)

    make_target_dir(target)
    FileUtils.cp(src, target)
    target
  end

  private def make_target_dir(target : String)
    FileUtils.mkdir_p(File.dirname(target))
  end

  private def default_target(src : String)
    src.sub(@config.src_dir, @config.target_dir)
  end
end
