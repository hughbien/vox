require "../vox"

class Vox::Command
  def run
    config = Config.parse_file(File.join(".", "config.yml"))
    src_path = File.join(".", "src")
    src_files = Dir.glob(
      File.join(src_path, "*.md"),
      File.join(src_path, "*.html")
    )
    src_files.each do |md_file|
      Renderer.new(config).render(md_file)
    end
  end
end
