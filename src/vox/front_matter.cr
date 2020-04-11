require "../vox"
require "yaml"

module Vox::FrontMatter
  extend self

  EMPTY_YAML = Hash(YAML::Any, YAML::Any).new

  def split(text)
    return {EMPTY_YAML, text} unless text =~ /^---\n/

    text = text.split("\n", 2).last
    yaml, text = text.split(/\n---\n/, 2)
    {YAML.parse(yaml).as_h, text}
  end

  def split_file(path)
    split(File.read(path))
  end
end
