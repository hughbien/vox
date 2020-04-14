require "../vox"
require "yaml"

class Vox::AssetConfig
  include YAML::Serializable

  getter src : Array(String)
  getter target : String
  getter minify : Bool = true
  getter fingerprint : Bool = true

  def initialize(@src, @target)
  end

  def self.defaults
    [
      AssetConfig.new(["glob:**/*.css"], "all.css"),
      AssetConfig.new(["glob:**/*.js"], "all.js")
    ]
  end
end

class Vox::Config
  include YAML::Serializable

  @[YAML::Field(key: "root")]
  getter root_dir : String = "."

  @[YAML::Field(key: "src")]
  getter src_dir : String = "src"

  @[YAML::Field(key: "target")]
  getter target_dir : String = "target"

  getter layout : String = "_layout.{{ext}}"
  getter before : String?
  getter after : String?

  getter includes : Array(String) = Array(String).new
  getter excludes : Array(String) = Array(String).new

  getter render_exts : Array(String) = Array(String).new
  getter render_excludes : Array(String) = Array(String).new

  getter fingerprint_exts : Array(String) = Array(String).new
  getter fingerprint_excludes : Array(String) = Array(String).new

  getter assets : Array(Vox::AssetConfig) = Vox::AssetConfig.defaults

  # Should use .parse or .parse_file instead. This initialization method is for specs.
  def initialize(
    @root_dir = ".",
    @src_dir = "src",
    @target_dir = "target",
    @layout = "_layout.{{ext}}"
  )
    normalized!
  end

  def normalized!
    @root_dir = File.expand_path(@root_dir)
    @src_dir = File.expand_path(File.join(@root_dir, @src_dir))
    @target_dir = File.expand_path(File.join(@root_dir, @target_dir))
    self
  end

  # TODO: handle invalid YAML
  def self.parse(text)
    from_yaml(text).normalized!
  end

  def self.parse_file(path)
    File.exists?(path) ? parse(File.read(path)) : parse("")
  end
end
