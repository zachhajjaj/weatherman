import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.initializeAutocomplete()
  }

  initializeAutocomplete() {
    const input = document.getElementById("address-input")
    if (!input) return

    const autocomplete = new google.maps.places.Autocomplete(input, {
      types: ['geocode'],
      componentRestrictions: { country: "us" }
    })

    input.addEventListener('focus', () => {
      input.value = ''
    })
    
  }
} 