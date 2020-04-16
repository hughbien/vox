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
    date = fetch_date(src)
    published = Time.local >= date
    list_config = fetch_config_from_src(src).not_nil!

    page[YAML::Any.new("published")] = YAML::Any.new(published) unless page.has_key?("published")
    page[YAML::Any.new("date")] = YAML::Any.new(date.to_s("%m/%d/%Y")) unless page.has_key?("date")
    page[YAML::Any.new("path")] = YAML::Any.new(fetch_path(src, list_config)) unless page.has_key?("path")
    return unless published

    pages = @lists[list_config.id]
    if pages.size > 0
      last = pages.last
      last[YAML::Any.new("next")] = YAML::Any.new(page) unless last.has_key?("next")
      page[YAML::Any.new("prev")] = YAML::Any.new(last) unless page.has_key?("prev")
    end
    pages << page
  end

  def add_render_args(args)
    @lists.each do |id, pages|
      args[id] = pages
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
    old_basename = File.basename(src)
    new_basename = old_basename.sub(DATE_REGEX, "")

    src.sub(File.dirname(src), list_config.target).sub(/#{old_basename}$/, new_basename)
  end

  # TODO: handle path suffix (multiple?)
  private def fetch_path(src : String, list_config : ListConfig)
    fetch_target(src, list_config).sub(list_config.target, "").sub(/.md$/, "/")
  end

  # TODO: date formatting in config (multiple?)
  private def fetch_date(src : String)
    date_str = File.basename(src)[0..9]
    Time.parse(date_str, "%Y-%m-%d", Time::Location.local)
  end
end
