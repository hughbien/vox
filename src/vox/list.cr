require "../vox"

class Vox::List
  DATE_REGEX = /^\d{4}-\d{2}-\d{2}-/
  POSITION_REGEX = /^\d+-/

  getter lists : Hash(String, Array(Hash(YAML::Any, YAML::Any))) = Hash(String, Array(Hash(YAML::Any, YAML::Any))).new

  def initialize(@config : Config)
    @config.lists.each do |list_config|
      @lists[list_config.id] = Array(Hash(YAML::Any, YAML::Any)).new
    end
  end

  # TODO: customize date.to_s format (multiple?)
  def add_page(src : String, page : Hash(YAML::Any, YAML::Any))
    list_config = fetch_config_from_src(src).not_nil!
    pages = @lists[list_config.id]
    position = pages.size + 1
    published = true

    if list_config.prefix.date?
      date = fetch_date(src)
      published = Time.local >= date
      page[YAML::Any.new("published")] = YAML::Any.new(published) unless page.has_key?("published")
      page[YAML::Any.new("date")] = YAML::Any.new(date.to_s("%m/%d/%Y")) unless page.has_key?("date")
    elsif list_config.prefix.position?
      position = fetch_position(src)
    end

    page[YAML::Any.new("id")] = YAML::Any.new(fetch_id(src, list_config)) unless page.has_key?("id")
    page[YAML::Any.new("position")] = YAML::Any.new(position.to_i64) unless page.has_key?("position")
    page[YAML::Any.new("path")] = YAML::Any.new(fetch_path(src, list_config)) unless page.has_key?("path")
    return unless published

    if pages.size > 0
      last = pages.last
      last[YAML::Any.new("next")] = YAML::Any.new(page.clone) unless last.has_key?("next")
      page[YAML::Any.new("prev")] = YAML::Any.new(last.clone) if !page.has_key?("prev") && !last.nil?
    end
    pages << page
  end

  def add_render_args(args)
    @config.lists.each do |list_config|
      id = list_config.id
      pages = @lists[id]
      args[id] = list_config.reverse ? pages.reverse : pages
    end
  end

  def includes?(src : String)
    !fetch_config_from_src(src).nil?
  end

  def fetch_config_from_src(src : String)
    @config.lists.each do |list_config|
      return list_config if list_config.includes?(src)
    end
    return nil
  end

  def fetch_target(src : String, list_config : ListConfig? = nil)
    list_config ||= fetch_config_from_src(src).not_nil!
    target = src.sub(File.dirname(src), list_config.target).sub(/\.md$/, ".html")
    old_basename = File.basename(target)

    if list_config.prefix.date? && !list_config.prefix_include
      new_basename = old_basename.sub(DATE_REGEX, "")
      target.sub(/#{old_basename}$/, new_basename)
    elsif list_config.prefix.position? && !list_config.prefix_include
      new_basename = old_basename.split("-", 2).last
      target.sub(/#{old_basename}$/, new_basename)
    else
      target
    end
  end

  def write_rss_head
    @config.lists.each do |list_config|
      next if list_config.rss.nil?
      rss = list_config.rss.not_nil!
      File.open(rss.target, "w") do |file|
        file.print(
          <<-RSS
            <?xml version="1.0"?>
            <rss version="2.0">
              <channel>
                <title>#{rss.title}</title>
                <link>#{@config.url}</link>
                <description>#{rss.description}</description>
          RSS
        )
      end
    end
  end

  def write_rss_foot
    @config.lists.each do |list_config|
      next if list_config.rss.nil?
      rss = list_config.rss.not_nil!
      File.open(rss.target, "a") do |file|
        file.print(
          <<-RSS
            </channel>
          </rss>
          RSS
        )
      end
    end
  end

  def write_rss_item(src, args, body)
    list_config = fetch_config_from_src(src)
    rss = list_config.try(&.rss)
    return if rss.nil?

    rss = rss.not_nil!
    date = Time.parse(args["date"].as_s, "%m/%d/%Y", Time::Location.local)
    url = @config.url.not_nil!
    url = url.ends_with?("/") ? url : "#{url}/"
    body = body.gsub("href=\"/", "href=\"#{url}")
      .gsub("href='/", "href='#{url}")
      .gsub("src=\"/", "src=\"#{url}")
      .gsub("src='/", "src='#{url}")

    File.open(rss.target, "a") do |file|
      file.print(
        <<-RSS
          <item>
            <title>#{args["title"]}</title>
            <link>#{File.join(url, args["path"].as_s)}</link>
            <pubDate>#{date.to_s("%a, %d %b %Y 12:00:00 %z")}</pubDate>
            <description>#{body}</description>
          </item>
        RSS
      )
    end
  end

  private def fetch_id(src : String, list_config : ListConfig)
    parts = src.sub(@config.src_dir, "")[1..-1].split("/")
    parts[-1] = File.basename(fetch_target(src, list_config)).sub(/.html$/, "").sub(".", "_")
    parts.join(".")
  end

  # TODO: handle path suffix (multiple?)
  private def fetch_path(src : String, list_config : ListConfig)
    fetch_target(src, list_config).
      sub(list_config.target, "").
      sub(/.html$/, @config.trailing_slash ? "/" : "")
  end

  # TODO: date formatting in config (multiple?)
  private def fetch_date(src : String)
    date_str = File.basename(src)[0..9]
    Time.parse(date_str, "%Y-%m-%d", Time::Location.local)
  end

  private def fetch_position(src : String)
    File.basename(src).split("-", 2).first.to_i
  end
end
