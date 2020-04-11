require "../vox"

class Vox::Command
  def run
    src_path = File.join(".", "src")
    md_files = Dir.glob(File.join(src_path, "*.md"))
    md_files.each do |md_file|
      Renderer.new(".").render(md_file)
    end
  end
end
