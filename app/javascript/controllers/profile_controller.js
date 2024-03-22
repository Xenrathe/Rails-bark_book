import { Controller } from "@hotwired/stimulus";

//Used to control the user profile in the User show view
export default class extends Controller {
  static targets = ["tab", "addressForm", "customBarkRadio", "uploadBarkDiv"];

  connect() {
    this.toggleUploadOptions;
  }

  //Switches amongst the four tabs
  changeTab(event) {
    event.preventDefault();

    //The event.target can be imprecise depending on what user clicked
    let linkElement = event.target;
    while (linkElement && linkElement.tagName != 'A'){
      linkElement = linkElement.parentElement;
    }

    // Hide all tab contents
    this.tabTargets.forEach(function(tabContent) {
      tabContent.style.display = 'none';
    });

    // De-select current link button
    document.querySelector('.selected').classList.remove('selected');

    // Show the selected tab content and add selected to the link
    const targetTabId = linkElement.getAttribute('href').substring(1);
    document.getElementById(targetTabId).style.display = 'block';
    linkElement.classList.add("selected");
  }

  //Hides or shows the New Address form
  hideShowAddress() {
    console.log(this.addressFormTarget);
    this.addressFormTarget.style.display = this.addressFormTarget.style.display == 'block' ? 'none' : 'block';
  }

  //Dealing with the bark audio
  toggleUploadOptions() {

    // Check if the custom_sound radio button is checked
    if (this.customBarkRadioTarget.checked) {
      this.uploadBarkDivTarget.style.display = 'block'; // Show the upload-sound-options div
    } else {
      this.uploadBarkDivTarget.style.display = 'none'; // Hide the upload-sound-options div
    }
  }
}