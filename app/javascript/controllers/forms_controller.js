import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["passwordInput", "passwordImage", "distance", "tracked"];
  static values = {
    pawurl: String,
    pawoffurl: String,
  };

  connect() {
    if (document.getElementById("new_dog_park_form")) {
      this.addNewAddressEvent();
    }
  }

  // Used with playdate#new mostly, in instances when a user is ALSO creating a new dogpark
  addNewAddressEvent() {
    const dogParkRadioBtns = document.querySelectorAll(".dog-park-radio");
    const newDogParkForm = document.getElementById("new_dog_park_form");

    // The 'required' fields should not be required if this sub-form isn't even visible
    // But should be, if the field is visible!
    const requireToggles = document.querySelectorAll(".require-toggle");
    requireToggles.forEach((field) => (field.required = false));

    dogParkRadioBtns.forEach((radio) => {
      radio.addEventListener("change", function () {
        newDogParkForm.style.display = this.value === "new" ? "block" : "none";
        requireToggles.forEach(
          (field) => (field.required = this.value === "new" ? "true" : false)
        );
      });
    });
  }

  // Used with playdate#index and dogpark#index to auto-submit forms if filters are changed
  submitForm() {
    this.element.submit();
  }

  // Used with various cases in which the user must have a dog selected (e.g. new Content)
  submitFormWithRequireDog(event) {
    const checkboxes = document.querySelectorAll("input[type='checkbox']");
    let atLeastOneChecked = checkboxes.length == 0; // Allows the EDIT button to still work

    checkboxes.forEach((checkbox) => {
      if (checkbox.checked) {
        atLeastOneChecked = true;
      }
    });

    if (!atLeastOneChecked) {
      event.preventDefault();
      alert("Please select at least one dog.");
    } else {
      // Show overlay manually
      const overlay = document.getElementById("uploadOverlay");
      overlay?.classList.remove("hidden");
      document.body.classList.add("upload-blocked");
    }
  }

  // Used with registrations or sessions to hide/show passwords
  toggleHideShowPassword() {
    if (this.passwordInputTarget.type === "password") {
      this.passwordInputTarget.type = "text";
      this.passwordImageTarget.src = this.pawoffurlValue;
    } else {
      this.passwordInputTarget.type = "password";
      this.passwordImageTarget.src = this.pawurlValue;
    }
  }
}
