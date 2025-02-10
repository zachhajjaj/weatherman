require "test_helper"

class GeocodeServiceTest < ActiveSupport::TestCase
  test "finds location" do
    # Fake the google response
    stub_request(:get, /maps.googleapis.com/)
      .with(query: hash_including({}))
      .to_return(
        status: 200,
        headers: { 'Content-Type' => 'application/json' },
        body: {
          status: "OK",
          results: [{
            geometry: { location: { lat: 38.89, lng: -77.03 } },
            formatted_address: "White House",
            address_components: [
              { types: ["postal_code"], long_name: "20500" }
            ]
          }]
        }.to_json
      )

    # Check if coordinates are right
    result = GeocodeService.new.get_coordinates("White House")
    assert_equal 38.89, result[:latitude]
    assert_equal(-77.03, result[:longitude])
    assert_equal "20500", result[:zip_code]
  end

  # Make sure bad addresses don't break things
  test "handles errors" do
    stub_request(:get, /maps.googleapis.com/).to_return(status: 500)
    assert_nil GeocodeService.new.get_coordinates("Bad Address")
  end
end
