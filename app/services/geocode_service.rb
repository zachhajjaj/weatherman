class GeocodeService
  include HTTParty
  base_uri 'https://maps.googleapis.com/maps/api'

  def initialize
    @api_key = ENV['GOOGLE_PLACES_API_KEY']
  end

  def get_coordinates(address)
    response = self.class.get('/geocode/json', query: {
      address: address,
      key: @api_key
    })

    return nil unless response.success?

    data = response.parsed_response
    return nil unless data['status'] == 'OK'

    location = data.dig('results', 0, 'geometry', 'location')
    address_components = data.dig('results', 0, 'address_components')

    # Try to get zip from address, fallback to reverse geocoding
    zip_code = extract_zip_code(address_components) ||
               fetch_nearest_zip_code(location['lat'], location['lng'])

    {
      latitude: location['lat'],
      longitude: location['lng'],
      zip_code: zip_code,
      formatted_address: data.dig('results', 0, 'formatted_address')
    }
  end

  private

  def extract_zip_code(components)
    return nil unless components
    postal_code = components.find { |c| c['types'].include?('postal_code') }
    postal_code&.dig('long_name')
  end

  def fetch_nearest_zip_code(lat, lng)
    # Find closest zip code using reverse geocoding
    response = self.class.get('/geocode/json', query: {
      latlng: "#{lat},#{lng}",
      key: @api_key,
      result_type: 'postal_code'
    })

    return nil unless response.success?

    data = response.parsed_response
    return nil unless data['status'] == 'OK'

    components = data.dig('results', 0, 'address_components')
    extract_zip_code(components)
  end
end
