require "../spec_helper"

include Vox

describe Vox::Config do
  root_dir = File.expand_path(File.join(__DIR__, "..", ".."))
  custom_root_dir = File.join(root_dir, "root")

  describe "#initialize" do
    it "sets directories" do
      config = Config.new(YAML.parse("root_dir: root"))
      config.root_dir.should eq(custom_root_dir)
      config.src_dir.should eq(File.join(custom_root_dir, "src"))
      config.target_dir.should eq(File.join(custom_root_dir, "target"))
    end

    it "defaults root to current directory" do
      config = Config.new(YAML.parse("key: value"))
      config.root_dir.should eq(root_dir)
      config.src_dir.should eq(File.join(root_dir, "src"))
      config.target_dir.should eq(File.join(root_dir, "target"))
    end
  end

  describe ".parse" do
    it "handles empty text" do
      Config.parse("").root_dir.should eq(root_dir)
      Config.parse("  \n  \n  \n").root_dir.should eq(root_dir)
    end

    it "returns parsed config" do
      config = Config.parse("root_dir: root")
      config.root_dir.should eq(custom_root_dir)
    end
  end

  describe ".parse_file" do
    config_file = File.tempfile

    before_each do
      File.write(config_file.path, "root_dir: root")
    end

    after_all do
      config_file.delete
    end

    it "handles non-existing file" do
      Config.parse_file("non-existing.yml").root_dir.should eq(root_dir)
    end

    it "returns parsed config" do
      Config.parse_file(config_file.path).root_dir.should eq(custom_root_dir)
    end
  end
end
