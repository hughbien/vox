require "../vox"

class Vox::Command
  def run
    config = Config.parse_file(File.join(".", "config.yml"))
    src_path = File.join(".", "src")

    renderer = Renderer.new(config)
    copy = Copy.new(config)
    minify = Minify.new(config)
    fingerprint = Fingerprint.new(config)

    Dir.glob(File.join(src_path, "assets/*")).each do |asset|
      fingerprint.run(copy.run(asset))
    end

    target_css = Dir.glob(File.join(src_path, "css/*.css")).map do |css|
      renderer.render(css).not_nil!
    end
    all_css = minify.run(target_css.not_nil!, remove_sources: true).not_nil!
    fingerprint.run(all_css)

    target_js = Dir.glob(File.join(src_path, "js/*.js")).map do |js|
      renderer.render(js).not_nil!
    end
    all_js = minify.run(target_js, remove_sources: true).not_nil!
    fingerprint.run(all_js)

    Dir.glob(File.join(src_path, "*.md"), File.join(src_path, "*.html")).each do |md_file|
      renderer.render(md_file)
    end
  end
end
