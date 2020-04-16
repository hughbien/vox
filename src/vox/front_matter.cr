require "../vox"
require "yaml"

class Vox::FrontMatter
  EMPTY_YAML = Hash(YAML::Any, YAML::Any).new

  getter pages : Hash(YAML::Any, YAML::Any) = Hash(YAML::Any, YAML::Any).new

  def initialize(@config : Config, @blog : Blog)
  end

  def add(sources : Array(String))
    sources.each do |source|
      yaml, _text = FrontMatter.split_file(source)
      @blog.add_post(source, yaml) if @blog.includes?(source)

      parts = source.sub(@config.src_dir, "")[1..-1].split("/")
      current = @pages
      parts[0...-1].each do |part|
        if !current.has_key?(part)
          current[YAML::Any.new(part)] = YAML::Any.new(Hash(YAML::Any, YAML::Any).new)
        end
        current = current[YAML::Any.new(part)].as_h
      end
      current[YAML::Any.new(parts.last.gsub(".", "_"))] = YAML::Any.new(yaml)
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
