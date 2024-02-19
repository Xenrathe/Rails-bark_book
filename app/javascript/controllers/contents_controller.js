import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["fileupload", "imgpreview"]

  connect() {
    this.fileuploadTarget.addEventListener("change", this.imagesUpload.bind(this));
  }

  imagesUpload(event) {
    const maxFiles = event.target.dataset.maxfiles;
    if (event.target.files.length > maxFiles) {
      this.imgpreviewTarget.innerHTML = ""; // Clear previous previews
      event.target.value = null;
      alert(`You can only upload a maximum of ${maxFiles} files.`);
    }
    else {
      this.previewImages(Array.from(event.target.files));
    }
  }

  previewImages(files) {
    this.imgpreviewTarget.innerHTML = ""; // Clear previous previews

    files.forEach(file => {
      const reader = new FileReader();

      reader.onload = () => {
        const img = document.createElement("img");
        img.src = reader.result;
        img.classList.add("preview-image");
        this.imgpreviewTarget.appendChild(img);
      };

      reader.readAsDataURL(file);
    });
  }
}