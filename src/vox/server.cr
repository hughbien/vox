require "../vox"
require "http/server"
require "http/server/handler"

class Vox::ServerHandler
  include HTTP::Handler

  def initialize(@config : Config)
  end

  def call(context)
    return call_next(context) unless context.request.method == "GET"

    path = context.request.path.not_nil!
    file = File.join(@config.target_dir, path)
    index_file = File.join(file, "index.html")
    html_file = "#{file[0...-1]}.html"

    if (File.exists?(file) && !File.directory?(file)) || File.basename(path).includes?(".")
      call_next(context)
    elsif !path.ends_with?("/")
      redirect_to = "#{path}/"
      context.response.headers.add("Location", redirect_to)
      context.response.status_code = 302
    elsif File.exists?(index_file)
      serve_html(index_file, context)
    elsif File.exists?(html_file)
      serve_html(html_file, context)
    else
      call_next(context)
    end
  end

  private def serve_html(file, context)
    context.response.content_type = "text/html"
    context.response.print(File.read(file))
  end
end

class Vox::Server
  def initialize(@config : Config)
  end

  def run
    server = HTTP::Server.new([
      ServerHandler.new(@config),
      HTTP::StaticFileHandler.new(@config.target_dir)
    ])

		address = server.bind_tcp 8080
		puts "Listening on http://#{address}"
		server.listen
  end
end
