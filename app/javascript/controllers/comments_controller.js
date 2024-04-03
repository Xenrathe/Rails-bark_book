import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["collapser", "expander", "commentlist"];

  expand() {
    this.expanderTarget.classList.add("hidden");
    this.collapserTarget.classList.remove("hidden");
    this.commentlistTarget.classList.remove("hidden");
  }

  collapse() {
    this.collapserTarget.classList.add("hidden");
    this.expanderTarget.classList.remove("hidden");
    this.commentlistTarget.classList.add("hidden");
  }
}