import { Controller } from "@hotwired/stimulus";

export default class extends Controller {

  // When user is uploading an image (for avatar mostly)
  // This will update the image shown to match their local file
  change(event) {
    const input = event.target;
    const reader = new FileReader();
  
    reader.onload = () => {
      const image = this.element.querySelector(".avatar-image");
      image.src = reader.result;
      image.style.display = "block";
    }

    if (input.files && input.files[0]) {
      reader.readAsDataURL(input.files[0]);
    }
  }

}