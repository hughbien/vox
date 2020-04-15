require "../vox"
require "yaml"

class Vox::Database
  @config : Config
  getter db : Hash(YAML::Any, YAML::Any) = Hash(YAML::Any, YAML::Any).new

  def initialize(@config)
  end

  # TODO: handle invalid YAML
  def read!
    if File.exists?(@config.database)
      contents = File.read(@config.database)
      @db = YAML.parse(contents).as_h unless contents =~ /^\s*$/
    end
    self
  end
end
