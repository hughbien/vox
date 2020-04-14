require "../vox"

class Vox::Classify
  getter sources_to_copy = Array(String).new
  getter sources_to_render = Array(String).new

  def initialize(@config : Config)
  end

  # TODO: handle symbolic links
  def add(files : Array(String))
    files.each do |file|
      next if File.directory?(file)
      file = File.expand_path(file)

      if @config.exclude?(file) || @config.bundle?(file)
        # ignore
      elsif @config.render?(file)
        @sources_to_render << file
      else
        @sources_to_copy << file
      end
    end
  end

  def sources_to_bundle
    @config.bundles
  end

  def fingerprint?(path : String)
    @config.fingerprint?(path)
  end
end
