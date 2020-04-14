require "../vox"

class Vox::Classify
  getter sources_to_copy = Array(String).new
  getter sources_to_minify = {
    "target/all.css" => Array(String).new,
    "target/all.js" => Array(String).new
  }
  getter sources_to_render = Array(String).new

  def initialize(@config : Config)
  end

  # TODO: handle symbolic links
  def add(files : Array(String))
    files.each do |file|
      next if file.strip == ""

      file = File.expand_path(file.strip)
      basename = File.basename(file)
      extname = File.extname(file)

      if basename.starts_with?("_")
        # ignore, layout or partial
      elsif extname == ".css"
        @sources_to_minify["target/all.css"] << file
      elsif extname == ".js"
        @sources_to_minify["target/all.js"] << file
      elsif {".md", ".html"}.includes?(extname)
        @sources_to_render << file
      else
        @sources_to_copy << file
      end
    end
  end

  # TODO: add fingerprint config
  def fingerprint?(path : String)
    true
  end
end
