require "live_view"
require "./database"

class MPropSearch < LiveView
  template "views/mprop_search.ecr"

  DEFAULT_MIN = 0_i64
  DEFAULT_MAX = 1_000_000_000_i64

  @results : Granite::Collection(Property)
  @address_search = ""
  @min_bedrooms = DEFAULT_MIN
  @max_bedrooms = DEFAULT_MAX
  @min_bathrooms = DEFAULT_MIN
  @max_bathrooms = DEFAULT_MAX
  @min_area = DEFAULT_MIN
  @max_area = DEFAULT_MAX
  @parking_type_search = ""

  def initialize
    @results = fetch_results
  end

  def mount(socket)
    # Heroku seems to be killing our connections after a minute idle, so let's
    # remind it that we like this client and want to keep it around.
    every(30.seconds) { socket.ping }
  end

  def handle_event(message, data, socket)
    start = Time.now

    case message
    when "change-address" then @address_search = string(data)
    when "change-min-bath" then @min_bathrooms = number(data)
    when "change-max-bath"
      @max_bathrooms = number(data)
      @max_bathrooms = DEFAULT_MAX if @max_bathrooms == 0
    when "change-min-bed" then @min_bedrooms = number(data)
    when "change-max-bed"
      @max_bedrooms = number(data)
      @max_bedrooms = DEFAULT_MAX if @max_bedrooms == 0
    when "change-min-area" then @min_area = number(data)
    when "change-max-area"
      @max_area = number(data)
      @max_area = DEFAULT_MAX if @max_area == 0
    when "change-parking" then @parking_type_search = string(data)
    end

    update(socket) { initialize }

    puts "Updated in #{Time.now - start}"
  end

  def number(json) : Int64
    s = string(json)
    if s == ""
      0_i64
    else
      s.to_i64
    end
  end

  def string(json)
    JSON.parse(json)["value"].as_s
  end

  def fetch_results
    Property.search(
      bedrooms: @min_bedrooms..@max_bedrooms,
      bathrooms: @min_bathrooms..@max_bathrooms,
      area: @min_area..@max_area,
      parking_type: @parking_type_search,
      address: @address_search,
    )
  rescue ex
    pp ex
    raise ex
  end

  struct StringValue
    JSON.mapping value: String
  end
end

server = HTTP::Server.new([
  # Make sure we catch the LiveView socket
  HTTP::WebSocketHandler.new { |socket, context| LiveView.handle socket },
  HTTP::StaticFileHandler.new("public", directory_listing: false),
  HTTP::LogHandler.new,
]) do |context|
  ECR.embed "views/app.ecr", context.response
end

port = (ENV["PORT"]? || 9393).to_i
puts "Listening on #{port}"
server.listen "0.0.0.0", port
