require 'date'

module DateHelper
  def current_date
    DateTime.now
  end

  def current_year
    current_date.strftime "%Y"
  end

  def current_day(padded=false)
    padded ? current_date.strftime("%d") : current_date.strftime("%-d")
  end
end

require 'net/http'
require 'logger'

class AOCClient
  BASE_URL = "adventofcode.com"
  AOCCLIENT_LEVEL = Logger::INFO
  include DateHelper

  def initialize(app_name, version, secrets_data)
    @app_name = app_name
    @version = version
    @secrets = secrets_data
    @http = Net::HTTP.new(BASE_URL, 443)
    @http.use_ssl = true
    @logger = Logger.new(STDERR)
    @logger.level = AOCCLIENT_LEVEL
  end

  def authenticated_get(path)
    @logger.info "GET: #{path}"
    req = Net::HTTP::Get.new path
    authenticated_request req
  end

  def authenticated_post(path, data)
    @logger.info "POST: #{path} : #{data.to_json}"
    req = Net::HTTP::Post.new path
    req.set_form_data data
    authenticated_request req
  end

  def authenticated_request(req)
    req['Cookie'] = @secrets["session_cookie"]
    req['User-Agent'] = "#{@app_name}-#{@version}"
    res = @http.request(req)
    res.body
  end

  def get_leaderboard(year=current_year, id=@secrets["leaderboard_id"])
    authenticated_get "/#{year}/leaderboard/private/view/#{id}.json"
  end

  def get_input_data(day=current_day, year=current_year)
    authenticated_get "/#{year}/day/#{day}/input"
  end

  def join_leaderboard(join_key, year=current_year)
    # TODO error checking (would need to parse HTML)
    url = "https://adventofcode.com/#{year}/leaderboard/private/join"
    params = {"join_key" => join_key}
    authenticated_post(url, params)
  end
end
