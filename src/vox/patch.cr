require "../vox"
require "yaml"
require "crustache"

struct YAML::Any
  def has_key?(str)
    self.as_h?.try { |hash| hash.has_key?(str) }
  end
end

class Crustache::Context(T)
  def lookup(key)
    value = previous_def(key)
    return value unless value.is_a?(YAML::Any)
    if hash = value.as_h?
      hash
    elsif array = value.as_a?
      array
    else
      value
    end
  end
end

