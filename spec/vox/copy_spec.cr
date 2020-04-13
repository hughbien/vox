require "../spec_helper"
require "uuid"

include Vox

describe Vox::Copy do
  root = File.expand_path(File.join(__DIR__, "../../tmp"))
  src = File.join(root, "src/nested/source.txt")
  target = File.join(root, "target/nested/source.txt")

  config = Config.parse("root_dir: #{root}")
  copy = Copy.new(config)

  before_each do
    FileUtils.mkdir_p(File.dirname(src))
    File.write(src, UUID.random)
  end

  after_each do
    FileUtils.rm_rf(root)
  end

  describe "#copy" do
    it "copies file" do
      copy.run(src).should eq(target)
      File.read(target).should eq(File.read(src)) 
    end
  end
end
