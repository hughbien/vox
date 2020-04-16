require "../vox"

class Vox::Blog
  DATE_REGEX = /^\d{4}-\d{2}-\d{2}-/

  getter posts : Array(Hash(YAML::Any, YAML::Any)) = Array(Hash(YAML::Any, YAML::Any)).new

  def initialize(@config : Config)
  end

  # TODO: customize date.to_s format (multiple?)
  def add_post(src : String, post : Hash(YAML::Any, YAML::Any))
    date = fetch_date(src)
    published = Time.local >= date

    post[YAML::Any.new("published")] = YAML::Any.new(published) unless post.has_key?("published")
    post[YAML::Any.new("date")] = YAML::Any.new(date.to_s("%m/%d/%Y")) unless post.has_key?("date")
    post[YAML::Any.new("path")] = YAML::Any.new(fetch_path(src)) unless post.has_key?("path")
    return unless published

    if @posts.size > 0
      last = @posts.last
      last[YAML::Any.new("next")] = YAML::Any.new(post) unless last.has_key?("next")
      post[YAML::Any.new("prev")] = YAML::Any.new(last) unless post.has_key?("prev")
    end
    @posts << post
  end

  def on?
    !!@config.blog
  end

  def includes?(src : String)
    return false if @config.blog.nil?
    return src.starts_with?(@config.blog.not_nil!.src) &&
      File.basename(src) =~ DATE_REGEX
  end

  def fetch_target(src : String)
    old_basename = File.basename(src)
    new_basename = old_basename.sub(DATE_REGEX, "")

    config = @config.blog.not_nil!
    src.sub(config.src, config.target)
      .sub(/#{old_basename}$/, new_basename)
  end

  # TODO: handle path suffix (multiple?)
  def fetch_path(src : String)
    config = @config.blog.not_nil!
    fetch_target(src).sub(@config.target_dir, "").sub(/.md$/, "/")
  end

  # TODO: date formatting in config (multiple?)
  def fetch_date(src : String)
    date_str = File.basename(src)[0..9]
    Time.parse(date_str, "%Y-%m-%d", Time::Location.local)
  end
end
