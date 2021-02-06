require "../vox"
require "yaml"

enum Vox::AssetEncode
  None
  Base64
end

class Vox::AssetConfig
  include YAML::Serializable

  getter src : Array(String)
  getter encode : Vox::AssetEncode = Vox::AssetEncode::None

  def normalized!(config)
    @src = Vox::Config.normalize_paths(config.src_dir, @src)
    self
  end
end

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
    @target = File.expand_path(File.join(config.target_dir, @target))
    self
  end
end

class Vox::RSSConfig
  include YAML::Serializable

  getter title : String
  getter description : String
  getter target : String = "rss.xml"
  getter limit : Int64? # leave blank for unlimited

  def normalized!(config, list_config)
    @target = File.expand_path(File.join(list_config.target, "rss.xml"))
    raise Error.new("URL config is required for RSS feeds") if config.url.nil?
    self
  end
end

enum Vox::ListPrefix
  None
  Date
  Position

  def matches?(str)
    case self
    when .none?
      true
    when .date?
      str =~ /^\d{4}-\d{2}-\d{2}-/
    when .position?
      str =~ /^\d+-/
    end
  end
end

class Vox::ListConfig
  include YAML::Serializable

  getter id : String # TODO: validate id for mustache
  getter src : Array(String)
  getter target : String
  getter prefix : Vox::ListPrefix = Vox::ListPrefix::None
  getter prefix_include : Bool = false
  getter reverse : Bool = false
  getter rss : RSSConfig?

  def normalized!(config)
    @id = @id.strip.sub(/\.|\s/, "_")
    @src = Vox::Config.normalize_paths(config.src_dir, @src)
    @target = File.expand_path(File.join(config.target_dir, @target))
    @rss.try(&.normalized!(config, self))

    self
  end

  def includes?(source : String)
    src.includes?(source) && prefix.matches?(File.basename(source))
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

  getter database : String = "db.yml"

  # optional, only used for RSS feeds
  getter url : String?

  # if set to true, adds trailing slash to path
  getter trailing_slash : Bool = false

  # private, use layout_for instead
  private getter layout : String = "_layout.{{ext}}"

  getter before : String?
  getter after : String?

  getter includes : Array(String) = Array(String).new
  getter excludes : Array(String) = Array(String).new

  getter render_exts : Array(String) = ["md", "html"]
  getter render_excludes : Array(String) = Array(String).new

  getter fingerprint_exts : Array(String) = ["jpg", "jpeg", "png", "gif"]
  getter fingerprint_excludes : Array(String) = Array(String).new

  getter bundles : Array(Vox::BundleConfig) = Vox::BundleConfig.defaults
  getter lists : Array(Vox::ListConfig) = Array(Vox::ListConfig).new
  getter assets : Array(Vox::AssetConfig) = Array(Vox::AssetConfig).new

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
    @database = File.expand_path(File.join(@root_dir, @database))
    @layout = File.expand_path(File.join(@src_dir, @layout))
    self
  end

  def normalized_post!
    @includes = Config.normalize_paths(@src_dir, @includes)
    @excludes = Config.normalize_paths(@src_dir, @excludes)
    @render_excludes = Config.normalize_paths(@src_dir, @render_excludes)
    @fingerprint_excludes = Config.normalize_paths(@target_dir, @fingerprint_excludes)

    @bundle_sources = Array(String).new
    @bundles.each do |bundle|
      bundle.normalized!(self)
      @bundle_sources.not_nil!.concat(bundle.src)
    end

    @lists.each { |list| list.normalized!(self) }
    @assets.each { |asset| asset.normalized!(self) }
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
    ext = File.extname(file)
    !ext.empty? && @render_exts.includes?(ext[1..-1]) && !@render_excludes.includes?(file)
  end

  # TODO: handle dotfiles/no extension files
  def fingerprint?(file)
    ext = File.extname(file)
    !ext.empty? && @fingerprint_exts.includes?(ext[1..-1]) && !@fingerprint_excludes.includes?(file)
  end

  def execute_before
    execute(@before.not_nil!) unless @before.nil?
  end

  def execute_after
    execute(@after.not_nil!) unless @after.nil?
  end

  private def execute(command : String)
    output = `#{command}`
    print(output) unless output.empty?
  rescue error : Exception
    raise Error.new("Executing `#{command}` failed: #{error}")
  end

  def self.normalize_paths(src_dir, paths)
    paths.map do |path|
      if path.starts_with?("glob:")
        Dir.glob(File.join(src_dir, path[5..-1])).map { |p| File.expand_path(p) }.sort
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
