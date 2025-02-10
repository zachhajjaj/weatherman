class ForecastsController < ApplicationController
  def index
  end

  def create
    location = GeocodeService.new.get_coordinates(params[:address])

    unless location
      return render_error("Couldn't find that location. Mind trying again?")
    end

    # Check our cache first
    if cached = Forecast.cached_by_zip(location[:zip_code])
      return render_forecast(cached)
    end

    # Get fresh weather data
    weather = WeatherService.new.get_forecast(
      location[:latitude],
      location[:longitude]
    )

    unless weather
      return render_error("Weather service is taking a break. Please try again soon!")
    end

    # Save the new forecast
    forecast = Forecast.create!(
      weather.merge(
        zip_code: location[:zip_code],
        latitude: location[:latitude],
        longitude: location[:longitude],
        address: location[:formatted_address]
      )
    )

    render_forecast(forecast)
  rescue StandardError => e
    Rails.logger.error("Forecast error: #{e.message}")
    render_error("Something went wrong. Give it another shot!")
  end

  private

  def render_forecast(forecast)
    render turbo_stream: turbo_stream.update(
      "forecast_result",
      partial: "forecast",
      locals: { forecast: forecast }
    )
  end

  def render_error(message)
    render turbo_stream: turbo_stream.update(
      "forecast_result",
      partial: "shared/error",
      locals: { message: message }
    )
  end
end
