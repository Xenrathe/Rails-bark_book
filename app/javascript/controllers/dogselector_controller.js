import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["checkbox"];

  // When user selects a dog image, adds (or removes) clicked class
  select(event) {
    const dog = event.target;

    dog.parentElement.classList.toggle("clicked");
  }

  selectAndSubmit(event) {
    this.select(event);

    // Need to manually alter checked status here or the form submission precedes it
    this.checkboxTarget.checked = !this.checkboxTarget.checked;

    const form = this.element.closest("form");
    form.requestSubmit(); //Don't use regular submit or it won't work nice with Turbo
  }

}