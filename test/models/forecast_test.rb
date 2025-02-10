require "test_helper"

class ForecastTest < ActiveSupport::TestCase
  # Make sure we require the basics
  test "needs zip and temp" do
    forecast = Forecast.new
    assert_not forecast.valid?
    assert_not_nil forecast.errors[:zip_code]
    assert_not_nil forecast.errors[:temperature]
  end

  # Check if caching works
  test "finds recent forecast in cache" do
    assert_equal forecasts(:recent), Forecast.cached_by_zip("20500")
  end

  # Don't use old data
  test "ignores old forecast" do
    assert_nil Forecast.cached_by_zip("22201")
  end
end
