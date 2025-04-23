import { Controller } from "@hotwired/stimulus";
import { getCookie } from "controllers/cookies";

export default class extends Controller {
  static targets = ["latitude", "longitude", "form"];

  connect() {
    // No longer automatically ask
    /*const locationCookie = getCookie('user_location');
    if (locationCookie == null) {
      this.getUserLocationAndSubmitForm();
    }*/
  }

  getUserLocationAndSubmitForm() {
    // Gotta do the binds to prevent the 'this' being lost in the callback
    navigator.geolocation.getCurrentPosition(
      this.successCallback.bind(this),
      this.errorCallback.bind(this)
    );
  }

  successCallback(position) {
    const latitude = position.coords.latitude;
    const longitude = position.coords.longitude;

    // Populate hidden form fields
    this.longitudeTarget.value = longitude;
    this.latitudeTarget.value = latitude;

    // Submit the form, which will go to users#set_location
    this.formTarget.submit();
  }

  errorCallback(error) {
    console.error(error.message);
  }
}
