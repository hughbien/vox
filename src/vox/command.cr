require "../vox"
require "file_utils"
require "option_parser"

class Vox::Command
  def initialize(@args : Array(String) = ARGV, @io : IO = STDOUT)
  end

  def run
    quit = false
    config = Config.parse_file("config.yml")

    parser = OptionParser.parse(@args) do |parser|
      parser.banner = "Usage: vox [options]"

      parser.on("-h", "--help", "print this help message") { print_help(parser); quit = true }
      parser.on("-v", "--version", "print version") { print_version; quit = true }
      parser.on("-c", "--clean", "remove target directory") { remove_target_dir(config); quit = true }
    end

    return if quit
    return print_help(parser) if @args.size > 0

    renderer = Renderer.new(config)
    copy = Copy.new(config)
    minify = Minify.new(config)
    fingerprint = Fingerprint.new(config)

    Dir.glob(File.join(config.src_dir, "assets/*")).each do |asset|
      fingerprint.run(copy.run(asset))
    end

    target_css = Dir.glob(File.join(config.src_dir, "css/*.css")).map do |css|
      renderer.render(css).not_nil!
    end
    all_css = minify.run(target_css.not_nil!, remove_sources: true).not_nil!
    fingerprint.run(all_css)

    target_js = Dir.glob(File.join(config.src_dir, "js/*.js")).map do |js|
      renderer.render(js).not_nil!
    end
    all_js = minify.run(target_js, remove_sources: true).not_nil!
    fingerprint.run(all_js)

    Dir.glob(File.join(config.src_dir, "*.md"), File.join(config.src_dir, "*.html")).each do |md_file|
      renderer.render(md_file)
    end
  end

  private def print_help(parser : OptionParser)
    @io.puts(parser)
  end

  private def print_version
    @io.puts(VERSION)
  end

  private def remove_target_dir(config)
    FileUtils.rm_rf(config.target_dir)
  end
end
