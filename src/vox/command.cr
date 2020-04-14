require "../vox"
require "file_utils"
require "option_parser"

class Vox::Command
  def initialize(@args : Array(String) = ARGV, @io : IO = STDOUT)
  end

  def run
    config = Config.parse_file("config.yml")
    parser = parse_args(config)

    return unless parser
    return print_help(parser.not_nil!) if @args.size > 0

    renderer = Renderer.new(config)
    copy = Copy.new(config)
    bundle = Bundle.new(config)
    fingerprint = Fingerprint.new(config)
    classify = Classify.new(config)
    classify.add(Dir.glob(File.join(config.src_dir, "**/*"), match_hidden: true))

    # copy non-rendered/bundled assets, eg: images, fonts, .htaccess, etc...
    classify.sources_to_copy.each do |src|
      target = copy.run(src)
      fingerprint.run(target) if classify.fingerprint?(target)
    end

    # bundle assets: css, js, etc...
    classify.sources_to_bundle.each do |pack|
      next if pack.src.empty?
      target_singles = pack.src.map { |single| renderer.render(single).not_nil! }
      target_all = bundle.run(
        target_singles,
        target: pack.target,
        # TODO: add this option!
        # minify: pack.minify,
        remove_sources: true
      ).not_nil!
      fingerprint.run(target_all) if pack.fingerprint
    end

    # render pages: markdown, html, etc...
    classify.sources_to_render.each do |src|
      renderer.render(src)
    end
  end

  private def parse_args(config : Config)
    quit = false
    parser = OptionParser.parse(@args) do |parser|
      parser.banner = "Usage: vox [options]"

      parser.on("-h", "--help", "print this help message") { print_help(parser); quit = true }
      parser.on("-v", "--version", "print version") { print_version; quit = true }
      parser.on("-c", "--clean", "remove target directory") { remove_target_dir(config); quit = true }
    end
    quit ? nil : parser
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
