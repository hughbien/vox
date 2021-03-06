require "../spec_helper"

include Vox

describe Vox::FrontMatter do
  describe ".split" do
    it "returns front matter and content" do
      yaml, content = FrontMatter.split(
        <<-CONTENT
        ---
        key: value
        ---
        Hello, World!
        CONTENT
      )
      yaml.should eq({"key" => "value"})
      content.should eq("Hello, World!")
    end

    it "returns empty front matter" do
      yaml, content = FrontMatter.split("No Front Matter :(")
      yaml.should eq(FrontMatter::EMPTY_YAML)
      content.should eq("No Front Matter :(")
    end

    it "reads empty front matter" do
      yaml, content = FrontMatter.split(
        <<-CONTENT
        ---
        ---
        No Front Matter :(
        CONTENT
      )
      yaml.should eq(FrontMatter::EMPTY_YAML)
      content.should eq("No Front Matter :(")
    end

    it "handles unclosed front matter" do
      yaml, content = FrontMatter.split(
        <<-CONTENT
        ---
        No Front Matter :(
        CONTENT
      )
      yaml.should eq(FrontMatter::EMPTY_YAML)
      content.should eq("No Front Matter :(")
    end

    it "handles invalid YAML" do
      expect_raises(Error, /Invalid YAML/) do
        FrontMatter.split(
          <<-CONTENT
          ---
          invaid-yaml
          ---
          This is not a valid file!
          CONTENT
        )
      end
    end
  end

  describe ".split_file" do
    it "reads file to split text" do
      file = File.tempfile
      File.write(file.path,
        <<-CONTENT
        ---
        name: John
        ---
        Hello, Jane!
        CONTENT
      )

      yaml, content = FrontMatter.split_file(file.path)
      yaml.should eq({"name" => "John"})
      content.should eq("Hello, Jane!")
      file.delete
    end
  end
end
