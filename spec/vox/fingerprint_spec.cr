require "../spec_helper"
require "digest/md5"
require "uuid"

include Vox

describe Vox::Fingerprint do
  root = File.expand_path(File.join(__DIR__, "../../tmp"))
  target = File.join(root, "target/js/target.js")

  uuid = UUID.random
  md5 = Digest::MD5.hexdigest(uuid.to_s)
  config = Config.parse("root: #{root}")
  fingerprint = Fingerprint.new(config)

  before_each do
    FileUtils.mkdir_p(File.dirname(target))
    File.write(target, uuid)
  end

  after_each do
    Fingerprint.prints.delete("js")
  end

  after_all do
    FileUtils.rm_rf(root)
  end

  describe "#run" do
    it "raises when performed outside of target directory" do
      expect_raises(Error, /Fingerprint can only be done in target dir:/) do
        fingerprint.run("src/js/source.js")
      end
    end

    it "adds md5 fingerprint to target file name" do
      new_target = File.join(root, "target/js/target.#{md5}.js")
      fingerprint.run(target).should eq(new_target)

      File.exists?(target).should be_false
      File.exists?(new_target).should be_true
      File.read(new_target).should eq(uuid.to_s)
    end

    it "adds fingerprint to Fingerprint.prints" do
      fingerprint.run(target)
      Fingerprint.prints["js"]["target_js"].should eq(md5)
    end
  end

  describe ".prints" do
    it "returns all fingerprints" do
      Fingerprint.prints.empty?.should be_true
      Fingerprint.prints["js"] = md5
      Fingerprint.prints["js"].should eq(md5)
    end
  end
end
