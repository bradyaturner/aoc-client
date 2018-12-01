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

class AOCClient
  BASE_URL = "adventofcode.com"
  include DateHelper

  def initialize(app_name, version)
    @app_name = app_name
    @version = version
    @secrets = load_private_data
    @http = Net::HTTP.new(BASE_URL, 443)
    @http.use_ssl = true
  end

  def load_private_data
    JSON.parse File.read("./aoc_data.json")
  end

  def authenticated_request(path)
    req = Net::HTTP::Get.new path
    req['Cookie'] = @secrets["session_cookie"]
    req['User-Agent'] = "#{@app_name}-#{@version}"
    res = @http.request(req)
    res.body
  end

  def get_leaderboard(year=current_year, id=@secrets["leaderboard_id"])
    authenticated_request "/#{year}/leaderboard/private/view/#{id}.json"
  end

  def get_input_data(day=current_day, year=current_year)
    authenticated_request "/#{year}/day/#{day}/input"
  end
end
