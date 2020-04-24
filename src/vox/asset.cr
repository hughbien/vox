require "../vox"
require "yaml"
require "base64"

class Vox::Asset
  alias Entry = String | Hash(String, Entry)
  @@assets = Hash(String, Entry).new

  def initialize(@config : Config)
  end

  def read
    @config.assets.each do |asset_config|
      asset_config.src.each do |source_file|
        data = File.read(source_file)
        add_asset(
          source_file,
          asset_config.encode.base64? ? Base64.encode(data) : data
        )
      end
    end
  end

  def self.assets
    @@assets
  end

  # TODO: handle special characters in path name; also needs refactoring
  private def add_asset(path : String, data : String)
    parts = path.sub(@config.src_dir, "")[1..-1].split("/")
    current = @@assets
    parts[0...-1].each do |part|
      if !current.has_key?(part)
        current[part] = Hash(String, Entry).new
      end
      current = current[part].as(Hash(String, Entry))
    end
    current[parts.last.gsub(".", "_")] = data
  end
end
