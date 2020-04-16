require "../vox"
require "digest/md5"

class Vox::Fingerprint
  @config : Config

  alias Entry = String | Hash(String, Entry)
  @@prints = Hash(String, Entry).new

  def initialize(@config)
  end

  # TODO: raise error if target does not exist
  def run(target : String)
    target = File.expand_path(target)
    raise Error.new("Fingerprint can only be done in target dir: #{target}") unless target.starts_with?(@config.target_dir)

    new_target = new_target_path(target, checksum(target))
    FileUtils.mv(target, new_target)
    new_target
  end

  def self.prints
    @@prints
  end

  private def checksum(path : String)
    fingerprint = Digest::MD5.hexdigest(File.read(path))
    add_print(path, fingerprint)
    fingerprint
  end

  # TODO: handle special characters in path name; also needs refactoring
  private def add_print(path : String, fingerprint : String)
    parts = path.sub(@config.target_dir, "")[1..-1].split("/")
    current = @@prints
    parts[0...-1].each do |part|
      if !current.has_key?(part)
        current[part] = Hash(String, Entry).new
      end
      current = current[part].as(Hash(String, Entry))
    end
    current[parts.last.gsub(".", "_")] = fingerprint
  end

  private def new_target_path(target : String, fingerprint : String)
    ext = File.extname(target)
    if ext.empty?
      "#{target}.#{fingerprint}"
    else
      ext = ext[1..-1]
      target.sub(/#{ext}$/, "#{fingerprint}.#{ext}")
    end
  end
end
