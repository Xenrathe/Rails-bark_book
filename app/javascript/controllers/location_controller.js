import { Controller } from "@hotwired/stimulus";
import { getCookie } from "controllers/cookies";

export default class extends Controller {
  static targets = ["latitude", "longitude", "form", "button"];

  connect() {

    // used for automatically requesting location if user turns 'share location' to on
    const locationRequestFlag = document.getElementById('location-request-flag');
    if (locationRequestFlag) {
      const locationCookie = getCookie('user_location');
      if (locationCookie == null) {
        this.getUserLocationAndSubmitForm();
      }
    }

    // only reveal button if user hasn't already given permissions
    navigator.permissions.query({ name: 'geolocation' }).then((result) => {
      if (result.state !== 'granted') {
        this.buttonTarget.style.display = '';
      }
    });
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
