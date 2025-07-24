import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["imageContainer", "image", "contentContainer", "loading"];

  connect() {
    this.currentPage = 1;
    this.isLoading = false;

    if (this.hasImageContainerTarget) {
      this.imageContainerTarget.addEventListener(
        "click",
        this.closeImageContainer.bind(this)
      );
    }

    // Pagination - load more of X whenever user scrolls to the bottom
    // Has a 500 ms timeout
    if (this.hasContentContainerTarget) {
      this.throttleTimeout = null;
      this.boundScrollTimer = this.scrollTimer.bind(this);
      window.addEventListener("scroll", this.boundScrollTimer);
    }
  }

  disconnect() {
    if (this.hasContentContainerTarget) {
      window.removeEventListener("scroll", this.boundScrollTimer);
    }
  }

  //SCROLLING TO LOAD MORE CONTENT - 500ms timeout
  //Also requires element to be visible (the User#Show has multiple tabs, only one of which should scroll)
  scrollTimer() {
    if (!this.throttleTimeout) {
      this.throttleTimeout = setTimeout(() => {
        this.throttleTimeout = null;
        if (
          window.innerHeight + window.scrollY + 10 >=
            this.contentContainerTarget.offsetHeight &&
          this.isElementVisible(this.contentContainerTarget)
        ) {
          this.loadMoreContent();
        }
      }, 500);
    }
  }

  delay(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }

  loadMoreContent() {
    if (this.loading) return;
    this.loading = true;

    //Update the URL to get the next page
    var url = new URL(window.location.href);
    url.searchParams.set("page", this.currentPage + 1);

    //show loading animation
    if (this.hasLoadingTarget) {
      this.loadingTargets.at(-1).classList.remove("invisible");
    }

    fetch(url.toString())
      .then((response) => response.text())
      .then((data) => {
        // Hide loading animation
        if (this.hasLoadingTarget) {
          this.loadingTargets.at(-1).classList.add("hidden");
        }

        if (data != "Empty") {
          this.currentPage += 1;
          this.contentContainerTarget.insertAdjacentHTML("beforeend", data);
        } else {
          window.removeEventListener("scroll", this.boundScrollTimer);
        }
      })
      .catch((error) => {
        console.error("Error loading more content:", error);

        // Hide loading animation
        if (this.hasLoadingTarget) {
          this.loadingTargets.at(-1).classList.add("hidden");
        }
      });

    this.loading = false;
  }

  isElementVisible(element) {
    var computedStyle = window.getComputedStyle(element);
    return computedStyle.display !== "none";
  }

  //IMAGE WINDOW FUNCTIONS
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
