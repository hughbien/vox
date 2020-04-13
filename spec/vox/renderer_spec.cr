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
  config = Config.parse("root_dir: #{root}")
  renderer = Renderer.new(config)

  before_all do
    FileUtils.mkdir_p(File.dirname(layout))
    File.write(layout, "<html>{{{body}}} fingerprint:{{fingerprint.renderer-layout}}</html>")
    Fingerprint.prints["renderer-layout"] = "layout-value"
    Fingerprint.prints["renderer-page"] = "page-value"
  end

  before_each do
    uuid = UUID.random
    File.write(src_md, "---\nkey: #{uuid}\n---\n*{{page.key}}*\nfingerprint:{{fingerprint.renderer-page}}")
    File.write(src_html, "---\nkey2: #{uuid}\n---\n<b>{{page.key2}}</b>\nfingerprint:{{fingerprint.renderer-page}}")
    FileUtils.rm_rf(File.dirname(target)) if Dir.exists?(File.dirname(target))
  end

  after_all do
    FileUtils.rm_rf(root)
    Fingerprint.prints.delete("renderer-layout")
    Fingerprint.prints.delete("renderer-page")
  end

  describe "#render" do
    it "renders source markdown into target HTML" do
      renderer.render(src_md)
      html = File.read(target)
      html.should contain("<em>#{uuid.to_s}</em>")
      html.should contain("fingerprint:page-value")
      html.should contain("fingerprint:layout-value")
      html.should contain("<html>")
      html.should contain("</html>")
    end

    it "renders source HTML into target HTML" do
      renderer.render(src_html)
      html = File.read(target)
      html.should contain("<b>#{uuid.to_s}</b>")
      html.should contain("fingerprint:page-value")
      html.should contain("fingerprint:layout-value")
      html.should contain("<html>")
      html.should contain("</html>")
    end
  end
end
