import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["passwordInput", "passwordImage", "distance", "tracked", "fileupload"];
  static values = {
    pawurl: String,
    pawoffurl: String,
  };

  connect() {
    if (document.getElementById("new_dog_park_form")) {
      this.addNewAddressEvent();
    }

    if (this.hasFileuploadTarget) {
      this.fileuploadTarget.addEventListener("change", (event) => this.handleDirectUpload(event));
    }
  }

  validateDirectUpload(input, form) {
    const files = Array.from(input.files);
    const MAX_IMAGE_SIZE = 10 * 1024 * 1024; //10MB
    const MAX_VIDEO_SIZE = 150 * 1024 * 1024; //150 MB
    const MAX_IMAGE_COUNT = 10;

    const isVideoUpload = input.accept && input.accept.includes('video');
    const errors = [];

    if (files.length > MAX_IMAGE_COUNT) {
      if (!errors.includes("Attached images cannot exceed 10 files")) errors.push("Attached images cannot exceed 10 files");
    }

    files.forEach((file) => {
      if (isVideoUpload) {
        if (!file.type.startsWith("video/")) {
          errors.push("Attached video must be a video file");
        }
        if (file.size > MAX_VIDEO_SIZE) {
          errors.push("Attached video cannot be larger than 150MB");
        }
      }
      else {
        if (!file.type.startsWith("image/")) {
          if (!errors.includes("Attached images must be image files")) errors.push("Attached images must be image files");
        }
        if (file.size > MAX_IMAGE_SIZE) {
          if (!errors.includes("Attached images cannot be larger than 10MB")) errors.push("Attached images cannot be larger than 10MB");
        }
      }
    })

    // clear errors
    const submitButton = form.querySelector(`input[type="submit"]`);
    submitButton.disabled = false;
    form.querySelectorAll('.errors').forEach(e => e.remove());

    if (errors.length > 0) {      
      submitButton.disabled = true;

      const errorDiv = document.createElement('div');
      errorDiv.classList.add("errors");
      errorDiv.style.color = "red";
      const errorList = document.createElement('ul');

      errors.forEach((error) => {
        const newItem = document.createElement('li');
        newItem.textContent = error;
        errorList.append(newItem);
      })

      errorDiv.append(errorList);
      form.append(errorDiv);

      return false;
    }
    else {

    }

    return true;
  }

  handleDirectUpload(event) {
    const input = event.target;
    const form = this.element;
  
    if (!this.validateDirectUpload(input, form)) return;
  
    // Setup progress bar if it doesn't exist
    const uploadOverlay = document.querySelector("#uploadOverlay");
    const loadingBar = uploadOverlay.querySelector(".loading-bar");
    const loadingText = uploadOverlay.querySelector(".upload-text");
  
    // Listen for direct-upload events
    input.addEventListener("direct-upload:start", function (event) {
      loadingText.textContent = `Uploading ${event.detail.file.name}`;
    })

    input.addEventListener("direct-upload:progress", function (event) {
      if (event.target === input && event.detail.progress) {
        loadingBar.style.width = `${event.detail.progress}%`;
      }
    });
  
    input.addEventListener("direct-upload:error", function (event) {
      console.error("Upload error", event);
    });
  
    input.addEventListener("direct-upload:end", function (event) {
      console.log("Upload completed", event);
    });
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
