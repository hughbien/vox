require "./vox/**"

module Vox
  VERSION = {{ `shards version "#{__DIR__}"`.chomp.stringify }}

  class Error < Exception; end
end
