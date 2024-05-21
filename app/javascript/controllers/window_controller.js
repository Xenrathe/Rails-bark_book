import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["imageContainer", "image", "contentContainer"];

  connect() {
    this.currentPage = 1;
    if (this.hasImageContainerTarget) {
      this.imageContainerTarget.addEventListener("click", this.closeImageContainer.bind(this));
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
        if (window.innerHeight + window.scrollY + 10 >= this.contentContainerTarget.offsetHeight && 
          this.isElementVisible(this.contentContainerTarget)) {
            this.loadMoreContent();
        }
      }, 500);
    }
  }

  loadMoreContent() {
    //Update the URL to get the next page
    var url = new URL(window.location.href);
    url.searchParams.set('page', this.currentPage + 1);

    fetch(url.toString())
      .then((response) => response.text())
      .then((data) => {
        if (data != "Empty")
        {
          this.currentPage += 1;
          this.contentContainerTarget.insertAdjacentHTML('beforeend', data);
        }
      })
      .catch((error) => {
        console.error('Error loading more content:', error);
      });
  }

  isElementVisible(element) {
    var computedStyle = window.getComputedStyle(element);
    return computedStyle.display !== 'none';
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