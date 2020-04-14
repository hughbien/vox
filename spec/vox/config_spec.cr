require "../spec_helper"

include Vox

describe Vox::Config do
  root_dir = File.expand_path(File.join(__DIR__, "..", ".."))
  custom_root_dir = File.join(root_dir, "root")

  describe "#initialize" do
    it "sets instance vars" do
      config = Config.new(
        root_dir: custom_root_dir,
        src_dir: "custom_src",
        target_dir: "custom_target",
        layout: "custom_layout.{{ext}}"
      )
      config.root_dir.should eq(custom_root_dir)
      config.src_dir.should eq(File.join(custom_root_dir, "custom_src"))
      config.target_dir.should eq(File.join(custom_root_dir, "custom_target"))
      config.layout_for(".html").should eq(File.join(config.src_dir, "custom_layout.html"))
    end

    it "sets defaults" do
      config = Config.new
      config.root_dir.should eq(root_dir)
      config.src_dir.should eq(File.join(root_dir, "src"))
      config.target_dir.should eq(File.join(root_dir, "target"))
      config.layout_for("html").should eq(File.join(config.src_dir, "_layout.html"))
    end
  end

  describe ".parse" do
    it "handles empty text" do
      Config.parse("  \n  \n  \n").root_dir.should eq(root_dir)
    end

    it "handles empty text" do
      Config.parse("").root_dir.should eq(root_dir)
      Config.parse("  \n  \n  \n").root_dir.should eq(root_dir)
    end

    it "returns parsed config" do
      config = Config.parse("root: root")
      config.root_dir.should eq(custom_root_dir)
    end
  end

  describe ".parse_file" do
    config_file = File.tempfile

    before_each do
      File.write(config_file.path, "root: root")
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
