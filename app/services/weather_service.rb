class WeatherService
  include HTTParty
  base_uri 'https://api.openweathermap.org/data/2.5'

  def initialize
    @api_key = ENV['WEATHER_API_KEY']
  end

  def get_forecast(latitude, longitude)
    # Grab both current conditions and extended forecast
    current = get_current_weather(latitude, longitude)
    return nil unless current

    extended = get_extended_forecast(latitude, longitude)
    return nil unless extended

    current.merge(extended_forecast: extended)
  end

  private

  def get_current_weather(latitude, longitude)
    response = self.class.get('/weather', query: {
      lat: latitude,
      lon: longitude,
      appid: @api_key,
      units: 'imperial'
    })

    return nil unless response.success?

    data = response.parsed_response
    {
      temperature: data.dig('main', 'temp'),
      temp_min: data.dig('main', 'temp_min'),
      temp_max: data.dig('main', 'temp_max'),
      description: data.dig('weather', 0, 'description'),
      icon: data.dig('weather', 0, 'icon')
    }
  end

  def get_extended_forecast(latitude, longitude)
    response = self.class.get('/forecast', query: {
      lat: latitude,
      lon: longitude,
      appid: @api_key,
      units: 'imperial'
    })

    return nil unless response.success?

    # Group by day and get high/low temps
    data = response.parsed_response
    data['list'].group_by do |forecast|
      Time.at(forecast['dt']).to_date
    end.map do |date, forecasts|
      {
        date: date,
        temp_max: forecasts.map { |f| f.dig('main', 'temp_max') }.max,
        temp_min: forecasts.map { |f| f.dig('main', 'temp_min') }.min,
        description: forecasts.first.dig('weather', 0, 'description'),
        icon: forecasts.first.dig('weather', 0, 'icon')
      }
    end.first(5) # Just next 5 days
  end
end
