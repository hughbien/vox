require "../vox"
require "yaml"

class Vox::Database
  @config : Config

  def initialize(@config)
  end

  # TODO: handle invalid YAML
  def read
    if File.exists?(@config.database)
      contents = File.read(@config.database)
      return YAML.parse(contents).as_h unless contents =~ /^\s*$/
    end

    Hash(YAML::Any, YAML::Any).new
  end
end
