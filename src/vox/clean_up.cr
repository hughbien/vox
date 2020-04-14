require "../vox"
require "file_utils"

class Vox::CleanUp
  def initialize(@config : Config)
  end

  def run
    `find "#{@config.target_dir}" -type d -empty`.split("\n").each do |dir|
      next if dir =~ /^\s*$/
      FileUtils.rmdir(dir)
    end
  end
end
