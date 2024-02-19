import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.element.addEventListener("change", this.validateMaxFiles.bind(this));
  }

  validateMaxFiles(event) {
    const maxFiles = this.data.get("maxFiles");
    if (event.target.files.length > maxFiles) {
      event.preventDefault();
      alert(`You can only upload a maximum of ${maxFiles} files.`);
    }
  }
}