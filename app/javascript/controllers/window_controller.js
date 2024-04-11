import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["imageContainer", "image", "contentContainer"];

  connect() {
    if (this.hasImageContainerTarget) {
      this.imageContainerTarget.addEventListener("click", this.closeImageContainer.bind(this));
    }
      
    // Pagination - load more of X whenever user scrolls to the bottom
    // Has a 500 ms timeout
    if (this.hasContentContainerTarget) {
      this.throttleTimeout = null;
      window.addEventListener("scroll", this.scrollTimer.bind(this));
    }
  }

  disconnect() {
    if (this.hasContentContainerTarget) {
      window.removeEventListener("scroll", this.scrollTimer.bind(this));
    }
  }

  //SCROLLING TO LOAD MORE CONTENT - 500ms timeout
  scrollTimer() {
    if (!this.throttleTimeout) {
      this.throttleTimeout = setTimeout(() => {
        this.throttleTimeout = null;
        if (window.innerHeight + window.scrollY + 10 >= this.contentContainerTarget.offsetHeight) {
          this.loadMoreContent();
        }
      }, 500);
    }
  }

  loadMoreContent() {
    var currentPage = parseInt(document.querySelector("#current-page").value);

    //Update the URL to get the next page
    var url = window.location.href;
    var searchParams = new URLSearchParams(url);
    searchParams.set('page', currentPage + 1);
    var updatedUrl = `${url.split('?')[0]}?${searchParams.toString()}`;

    fetch(updatedUrl)
      .then((response) => response.text())
      .then((data) => {
        if (data != "Empty")
        {
          currentPage += 1;
          this.contentContainerTarget.insertAdjacentHTML('beforeend', data);
          document.querySelector("#current-page").value = currentPage;
        }
      })
      .catch((error) => {
        console.error('Error loading more content:', error);
      });
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