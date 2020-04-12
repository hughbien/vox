require "../vox"
require "yaml"

module Vox::FrontMatter
  extend self

  EMPTY_YAML = Hash(YAML::Any, YAML::Any).new

  # TODO: handle carriage returns, whitespace after dashes, invalid YAML
  def split(text)
    return {EMPTY_YAML, text} unless text =~ /^---\n/

    text = text.split("\n", 2).last
    yaml, text = text.split(/\n---\n/, 2)
    {YAML.parse(yaml).as_h, text}
  end

  # TODO: handle file not found error
  def split_file(path)
    split(File.read(path))
  end
end
