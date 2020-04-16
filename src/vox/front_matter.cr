require "../vox"
require "yaml"

class Vox::FrontMatter
  EMPTY_YAML = Hash(YAML::Any, YAML::Any).new

  getter pages : Hash(YAML::Any, YAML::Any) = Hash(YAML::Any, YAML::Any).new
  getter pages_by_source : Hash(String, YAML::Any) = Hash(String, YAML::Any).new

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

      wrapped = YAML::Any.new(yaml)
      current[YAML::Any.new(without_extname(parts.last))] = wrapped
      pages_by_source[source] = wrapped
    end
  end

  def resolve_links(src : String)
    page = @pages_by_source[src].as_h
    return unless page.has_key?("links")

    page[YAML::Any.new("links")] = YAML::Any.new(resolve_links_obj(page["links"]))
  end

  def resolve_links_obj(obj : YAML::Any)
    if array = obj.as_a?
      links = Array(YAML::Any).new
      array.each do |id|
        links << YAML::Any.new(fetch_page_by_id(id.as_s))
      end
      links
    elsif hash = obj.as_h?
      links = Hash(YAML::Any, YAML::Any).new
      hash.each do |key, hash_or_array|
        links[key] = YAML::Any.new(resolve_links_obj(hash_or_array))
      end
      links
    elsif str = obj.as_s?
      fetch_page_by_id(str)
    else
      return obj.raw
    end
  end

  # TODO: handle invalid id format OR non-terminating id OR past-terminating id
  private def fetch_page_by_id(id : String)
    current = @pages
    id.strip.split(".").each do |part|
      current = current[part].as_h
    end
    current
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
