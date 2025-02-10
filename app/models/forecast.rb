class Forecast < ApplicationRecord
  validates :zip_code, presence: true
  validates :temperature, presence: true

  attr_accessor :from_cache

  # Store extended forecast as JSON in SQLite
  serialize :extended_forecast, coder: JSON

  # Find forecasts cached within last 30 mins for a zip code
  def self.cached_by_zip(zip_code)
    forecast = find_by(
      "zip_code = ? AND created_at >= ?",
      zip_code,
      30.minutes.ago
    )

    # Flag if we found it in cache
    forecast&.from_cache = true

    forecast
  end

  def cache_status
    from_cache ? 'cached' : 'fresh'
  end
end
