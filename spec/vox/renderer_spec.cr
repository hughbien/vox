require "../spec_helper"
require "uuid"

include Vox

describe Vox::Renderer do
  root = File.join(__DIR__, "../../tmp")
  src_md = File.join(root, "src/source.md")
  src_html = File.join(root, "src/source.html")
  layout = File.join(root, "src/layouts/site.html")
  target = File.join(root, "target/source.html")

  uuid = UUID.random
  renderer = Renderer.new(root)

  before_all do
    FileUtils.mkdir_p(File.dirname(layout))
    File.write(layout, "<html>{{{body}}}</html>")
  end

  before_each do
    uuid = UUID.random
    File.write(src_md, "*#{uuid.to_s}*")
    File.write(src_html, "<b>#{uuid.to_s}</b>")
    FileUtils.rm_rf(File.dirname(target)) if Dir.exists?(File.dirname(target))
  end

  after_all do
    FileUtils.rm_rf(root)
  end

  describe "#render" do
    it "renders source markdown into target HTML" do
      renderer.render(src_md)
      html = File.read(target)
      html.should contain("<em>#{uuid.to_s}</em>")
      html.should contain("<html>")
      html.should contain("</html>")
    end

    it "renders source HTML into target HTML" do
      renderer.render(src_html)
      html = File.read(target)
      html.should contain("<b>#{uuid.to_s}</b>")
      html.should contain("<html>")
      html.should contain("</html>")
    end
  end
end
