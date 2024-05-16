import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["fileupload", "imgpreview", "video"]
  resizeHandler = this.videoResizer.bind(this);

  connect() {
    if (this.hasImgpreviewTarget && this.hasFileUploadTarget) {
      this.fileuploadTarget.addEventListener("change", this.imagesUpload.bind(this));
    }
    else if (this.hasVideoTarget) {
      this.videoResizer();
      window.addEventListener("resize", this.resizeHandler);
    }
  }

  disconnect() {
    window.removeEventListener("resize", this.resizeHandler);
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
    this.imgpreviewTarget.style.border = "none";

    if (files.length > 0){
      this.imgpreviewTarget.style.border = "1px solid black";
    }

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

  videoResizer() {
    const video = this.videoTarget;
    const coreContentParent = video.closest('.core-content');
    const aspectRatio = video.dataset.aspectRatio;

    const maxWidth = coreContentParent.clientWidth - 40;
    const maxHeight = window.innerHeight * 0.9; //aka 90vh

    const widthLimiting = maxWidth / maxHeight < aspectRatio;

    if (widthLimiting) {
      video.style.width = maxWidth + 'px';
      video.style.height = 'auto';
    }
    else {
      video.style.width = 'auto';
      video.style.height = maxHeight + 'px';
    }
  }
}