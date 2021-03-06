require "../spec_helper"
require "uuid"

include Vox

describe Vox::Bundle do
  root = File.expand_path(File.join(__DIR__, "../../tmp"))
  js_src1 = File.join(root, "src/js/first.js")
  js_src2 = File.join(root, "src/js/second.js")
  css_src1 = File.join(root, "src/css/first.css")
  css_src2 = File.join(root, "src/css/second.css")

  js_target = File.join(root, "target/js/all.js")
  css_target = File.join(root, "target/css/all.css")

  config = Config.parse("root: #{root}")
  bundle = Bundle.new(config)

  before_each do
    FileUtils.mkdir_p(File.dirname(js_src1))
    FileUtils.mkdir_p(File.dirname(css_src1))

    File.write(js_src1, "// comment removed\nvar js1 = true")
    File.write(js_src2, "/* comment removed */\nvar js2 = false")

    File.write(css_src1, "/* comment removed */\na.css1 { font-weight: bold; }")
    File.write(css_src2, "/* comment removed */\na.css2 { font-style: italic; }")
  end

  after_each do
    FileUtils.rm_rf(root)
  end

  describe "#run" do
    it "minifies js" do
      bundle.run([js_src1, js_src2]).should eq(js_target)
      File.exists?(js_src1).should be_true
      File.exists?(js_src2).should be_true
      File.exists?(css_target).should be_false

      js = File.read(js_target)
      js.includes?("var js1=true").should be_true
      js.includes?("var js2=false").should be_true
      js.includes?("comment").should be_false
    end

    it "minifies css" do
      bundle.run([css_src1, css_src2]).should eq(css_target)
      File.exists?(css_src1).should be_true
      File.exists?(css_src2).should be_true
      File.exists?(js_target).should be_false

      css = File.read(css_target)
      css.includes?("a.css1{font-weight:bold}").should be_true
      css.includes?("a.css2{font-style:italic}").should be_true
      css.includes?("comment").should be_false
    end

    it "raises when trying to remove source from outside target" do
      expect_raises(Error, /Bundle can only remove source in target dir/) do
        bundle.run([js_src1, js_src2], remove_sources: true)
      end
    end

    it "removes original sources" do
      js_min1 = File.join(root, "target/one.js")
      js_min2 = File.join(root, "target/two.js")
      FileUtils.mkdir_p(File.join(root, "target"))
      File.write(js_min1, "var js1=true")
      File.write(js_min2, "var js2=true")

      bundle.run([js_min1, js_min2], remove_sources: true).should eq(js_target)
      File.exists?(js_min1).should be_false
      File.exists?(js_min2).should be_false
      File.exists?(js_target).should be_true
    end

    it "does nothing with zero sources" do
      bundle.run(Array(String).new).should be_nil
      File.exists?(js_target).should be_false
      File.exists?(css_target).should be_false
    end

    it "raises error for unsupported files" do
      expect_raises(Error, "Don't know how to minify .txt") do
        bundle.run(["unsupported.txt"])
      end
    end
  end
end
