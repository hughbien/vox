require "../vox"
require "yaml"

class Vox::FrontMatter
  EMPTY_YAML = Hash(YAML::Any, YAML::Any).new

  getter pages : Hash(YAML::Any, YAML::Any) = Hash(YAML::Any, YAML::Any).new

  def initialize(@config : Config, @blog : Blog)
  end

  # TODO: handle invalid ids (eg spaces)
  def add(sources : Array(String))
    sources.each do |source|
      yaml, _text = FrontMatter.split_file(source)
      @blog.add_post(source, yaml) if @blog.includes?(source)

      parts = if yaml.has_key?("id")
        yaml["id"].as_s.strip.split(".")
      else
        source.sub(@config.src_dir, "")[1..-1].split("/")
      end

      yaml[YAML::Any.new("path")] = YAML::Any.new(fetch_path(yaml, source)) unless yaml.has_key?("path")

      current = @pages
      parts[0...-1].each do |part|
        if !current.has_key?(part)
          current[YAML::Any.new(part)] = YAML::Any.new(Hash(YAML::Any, YAML::Any).new)
        end
        current = current[YAML::Any.new(part)].as_h
      end
      current[YAML::Any.new(without_extname(parts.last))] = YAML::Any.new(yaml)
    end
  end

  # TODO: config option to include extname with underscore
  private def without_extname(basename)
    if basename.includes?(".")
      basename[0...-File.extname(basename).size]
    else
      basename
    end
  end

  # TODO: handle path suffix (multiple?)
  private def fetch_path(page : Hash(YAML::Any, YAML::Any), src : String)
    fetch_target(page, src).sub(@config.target_dir, "").sub(/index.html$/, "").sub(/.html$/, "/")
  end

  # TODO: extract to module
  private def fetch_target(page : Hash(YAML::Any, YAML::Any), src : String)
    target = page["target"].as_s? if page.has_key?("target")
    if target
      File.join(@config.target_dir, target)
    elsif @blog.includes?(src)
      @blog.fetch_target(src).sub(/\.md$/, ".html")
    else
      src.sub(@config.src_dir, @config.target_dir).sub(/\.md$/, ".html")
    end
  end

  # TODO: handle carriage returns, whitespace after dashes, invalid YAML
  def self.split(text)
    return {EMPTY_YAML, text} unless text =~ /^---\n/

    text = text.split("\n", 2).last
    yaml, text = text.split(/\n---\n/, 2)
    {YAML.parse(yaml).as_h, text}
  end

  # TODO: handle file not found error
  def self.split_file(path)
    split(File.read(path))
  end
end
