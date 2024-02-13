import { Controller } from "@hotwired/stimulus";

export default class extends Controller {

  // When user selects a dog image, adds (or removes) clicked class
  select(event) {
    const dog = event.target;

    dog.parentElement.classList.toggle("clicked");
  }

}