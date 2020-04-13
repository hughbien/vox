require "../vox"
require "file_utils"

enum Vox::MinifyStrategy
  UglifyJS
  UglifyCSS
  Cat

  # TODO: handle filenames with space, file not found errors
  def run(sources : Array(String), target : String)
    case self
    when .uglify_js?
      `uglifyjs #{sources.join(" ")} > #{target}`
    when .uglify_css?
      `uglifycss #{sources.join(" ")} > #{target}`
    when .cat?
      `cat #{sources.join(" ")} > #{target}`
    end
  end

  def self.from_extname(extname : String)
    if extname == ".js" && Minify.has_uglify_js?
      UglifyJS
    elsif extname == ".css" && Minify.has_uglify_css?
      UglifyCSS
    elsif { ".css", ".js" }.includes?(extname)
      Cat
    else
      raise Error.new("Don't know how to minify #{extname}")
    end
  end

  def self.default_target(config : Config, extname : String)
    File.expand_path(
      File.join(config.target_dir, extname[1..-1], "all#{extname}")
    )
  end
end

class Vox::Minify
  @config : Config

  @@has_uglify_js : Bool | Nil
  @@has_uglify_css : Bool | Nil

  def initialize(@config)
  end

  def run(sources : Array(String), remove_sources = false)
    return if sources.empty?

    sources = sources.map { |source| File.expand_path(source) }
    extname = File.extname(sources.first)
    strategy = MinifyStrategy.from_extname(extname)
    target = MinifyStrategy.default_target(@config, extname)
    FileUtils.mkdir_p(File.dirname(target))
    strategy.run(sources, target)

    if remove_sources
      sources.each do |source|
        raise Error.new("Minify can only remove source in target dir: #{source}") unless source.starts_with?(@config.target_dir)
      end
      FileUtils.rm(sources)
    end
    target
  end

  def self.has_uglify_js?
    return @@has_uglify_js unless @@has_uglify_js.nil?

    `which uglifyjs`
    @@has_uglify_js = $?.success?
  end

  def self.has_uglify_css?
    return @@has_uglify_css unless @@has_uglify_css.nil?

    `which uglifycss`
    @@has_uglify_css = $?.success?
  end
end
