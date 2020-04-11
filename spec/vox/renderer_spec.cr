require "../spec_helper"
require "uuid"

include Vox

describe Vox::Renderer do
  root = File.join(__DIR__, "../../tmp")
  src = File.join(root, "src/source.md")
  target = File.join(root, "target/source.html")

  uuid = UUID.random
  renderer = Renderer.new(root)

  before_all do
    FileUtils.mkdir_p(File.dirname(src))
  end

  before_each do
    uuid = UUID.random
    File.write(src, "*#{uuid.to_s}*")
    FileUtils.rm_rf(File.dirname(target)) if Dir.exists?(File.dirname(target))
  end

  after_all do
    FileUtils.rm_rf(root)
  end

  describe "#render" do
    it "renders source markdown into target HTML" do
      renderer.render(src)
      html = File.read(target)
      html.should contain("<em>#{uuid.to_s}</em>")
    end
  end
end
