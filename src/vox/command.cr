require "../vox"

class Vox::Command
  def run
    config = Config.parse_file(File.join(".", "config.yml"))
    src_path = File.join(".", "src")

    minify = Minify.new(config)
    minify.run(Dir.glob(File.join(src_path, "css/*.css")))
    minify.run(Dir.glob(File.join(src_path, "js/*.js")))

    fingerprint = Fingerprint.new(config)
    fingerprint.run("target/css/all.css")
    fingerprint.run("target/js/all.js")

    renderer = Renderer.new(config)
    Dir.glob(File.join(src_path, "*.md"), File.join(src_path, "*.html")).each do |md_file|
      renderer.render(md_file)
    end
  end
end
