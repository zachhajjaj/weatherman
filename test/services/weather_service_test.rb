require "test_helper"

class WeatherServiceTest < ActiveSupport::TestCase
  test "gets weather data" do
    # Fake the current weather response
    stub_request(:get, /api.openweathermap.org\/data\/2.5\/weather/)
      .with(query: hash_including({}))
      .to_return(
        status: 200,
        headers: { 'Content-Type' => 'application/json' },
        body: {
          main: { temp: 75.5, temp_min: 70.1, temp_max: 80.2 },
          weather: [{ description: "sunny", icon: "01d" }]
        }.to_json
      )

    # Fake the 5 day forecast
    stub_request(:get, /api.openweathermap.org\/data\/2.5\/forecast/)
      .with(query: hash_including({}))
      .to_return(
        status: 200,
        headers: { 'Content-Type' => 'application/json' },
        body: {
          list: 5.times.map do |i|
            {
              dt: (Time.current + i.days).to_i,
              main: { temp_min: 70.0, temp_max: 80.0 },
              weather: [{ description: "sunny", icon: "01d" }]
            }
          end
        }.to_json
      )

    # Make sure we get what we expect
    result = WeatherService.new.get_forecast(38.89, -77.03)
    assert_equal 75.5, result[:temperature]
    assert_equal 5, result[:extended_forecast].length
  end

  # Make sure it doesn't break when api fails
  test "handles errors" do
    stub_request(:get, /api.openweathermap.org/).to_return(status: 500)
    assert_nil WeatherService.new.get_forecast(38.89, -77.03)
  end
end
