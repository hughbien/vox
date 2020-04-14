require "../vox"
require "yaml"

class Vox::BundleConfig
  include YAML::Serializable

  getter src : Array(String)
  getter target : String
  getter minify : Bool = true
  getter fingerprint : Bool = true

  def initialize(@src, @target)
  end

  def self.defaults
    [
      BundleConfig.new(["glob:**/*.css"], "all.css"),
      BundleConfig.new(["glob:**/*.js"], "all.js")
    ]
  end

  def normalized!(config)
    @src = Vox::Config.normalize_paths(config.src_dir, @src)
    @target = File.expand_path(File.join(config.target_dir, target))
    self
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

  # private, use layout_for instead
  private getter layout : String = "_layout.{{ext}}"

  getter before : String?
  getter after : String?

  getter includes : Array(String) = Array(String).new
  getter excludes : Array(String) = Array(String).new

  getter render_exts : Array(String) = Array(String).new
  getter render_excludes : Array(String) = Array(String).new

  getter fingerprint_exts : Array(String) = Array(String).new
  getter fingerprint_excludes : Array(String) = Array(String).new

  getter bundles : Array(Vox::BundleConfig) = Vox::BundleConfig.defaults

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
    @layout = File.expand_path(File.join(@src_dir, @layout))

    @includes = Config.normalize_paths(@src_dir, @includes)
    @excludes = Config.normalize_paths(@src_dir, @excludes)
    @render_excludes = Config.normalize_paths(@src_dir, @render_excludes)
    @fingerprint_excludes = Config.normalize_paths(@target_dir, @fingerprint_excludes)

    @bundle_sources = Array(String).new
    @bundles.each do |bundle|
      bundle.normalized!(self)
      @bundle_sources.not_nil!.concat(bundle.src)
    end

    self
  end

  # TODO: handle no layout exists, cache results per ext
  def layout_for(ext : String)
    ext = ext.starts_with?(".") ? ext[1..-1] : ext
    @layout.sub("{{ext}}", ext)
  end

  def exclude?(file)
    return false if @includes.includes?(file)
    return true if @excludes.includes?(file)
    return true if File.basename(file).starts_with?("_")
  end

  def bundle?(file)
    @bundle_sources && @bundle_sources.not_nil!.includes?(file)
  end

  # TODO: handle dotfiles/no extension files
  def render?(file)
    @render_exts.includes?(File.extname(file)[1..-1]) && !@render_excludes.includes?(file)
  end

  # TODO: handle dotfiles/no extension files
  def fingerprint?(file)
    @fingerprint_exts.includes?(File.extname(file)[1..-1]) && !@fingerprint_excludes.includes?(file)
  end

  def self.normalize_paths(src_dir, paths)
    paths.map do |path|
      if path.starts_with?("glob:")
        Dir.glob(File.join(src_dir, path[5..-1])).map { |p| File.expand_path(p) }
      else
        File.expand_path(File.join(src_dir, path))
      end
    end.flatten
  end

  # TODO: handle invalid YAML
  def self.parse(text)
    from_yaml(text).normalized!
  end

  def self.parse_file(path)
    File.exists?(path) ? parse(File.read(path)) : parse("")
  end
end
