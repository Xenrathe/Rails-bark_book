import { Controller } from "@hotwired/stimulus";

export default class extends Controller {

  connect() {
    this.addNewAddressEvent();
  }

  addNewAddressEvent() {
    const dogParkRadioBtns = document.querySelectorAll('.dog-park-radio');
    const newDogParkForm = document.getElementById('new_dog_park_form');

    // The 'required' fields should not be required if this sub-form isn't even visible
    // But should be, if the field is visible!
    const requireToggles = document.querySelectorAll('.require-toggle');
    requireToggles.forEach((field) => field.required = false);

    dogParkRadioBtns.forEach(radio => {
      radio.addEventListener('change', function() {
        newDogParkForm.style.display = this.value === 'new' ? 'block' : 'none';
        requireToggles.forEach((field) => field.required = this.value === 'new' ? 'true' : false);
      });
    })
  }
}