import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["imageContainer", "image"];

  connect() {
    this.imageContainerTarget.addEventListener("click", this.closeImageContainer.bind(this));
  }

  openImageContainer(event) {
    this.imageContainerTarget.style.display = "flex";
    const originalURL = event.target.dataset.originalUrl;

    this.updateImage(originalURL);
  }

  closeImageContainer(event) {
    if (event.target !== this.imageTarget) {
      this.imageContainerTarget.style.display = "none";
    }
  }

  updateImage(imageURL) {
    this.imageTarget.setAttribute("src", imageURL);
  }
}