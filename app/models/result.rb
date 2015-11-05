class Result
  attr_reader :url, :area_rate
  def initialize(url, area_rate)
    @url = url
    @area_rate = area_rate
  end
end
