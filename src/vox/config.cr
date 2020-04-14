require "../vox"
require "yaml"

class Vox::Config
  EMPTY_YAML = Hash(YAML::Any, YAML::Any).new

  getter root_dir, src_dir, target_dir

  # TODO: handle invalid root dir
  def initialize(config)
    root = config["root_dir"]? ? config["root_dir"].as_s : "."
    @root_dir = File.expand_path(root)
    @src_dir = File.join(@root_dir, "src")
    @target_dir = File.join(@root_dir, "target")
  end

  # TODO: handle invalid YAML
  def self.parse(text)
    text =~ /^\s*$/ ? new(EMPTY_YAML) : new(YAML.parse(text).as_h)
  end

  def self.parse_file(path)
    File.exists?(path) ? parse(File.read(path)) : new(EMPTY_YAML)
  end
end
