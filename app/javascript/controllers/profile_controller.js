import { Controller } from "@hotwired/stimulus";
import { getCookie } from './cookies';

//Used to control the user profile in the User show view
export default class extends Controller {
  static targets = ["tab", "addressForm", "tabTitle", "customBarkRadio", "uploadBarkDiv"];

  connect() {
    this.toggleUploadOptions;

    const targetTabId = getCookie('profile_tab');
    if (targetTabId) {
      this.switchToTab(targetTabId);
    }
  }

  //Called via a link, gets tab name and calls switchToTab
  changeTab(event) {
    event.preventDefault();

    //The event.target can be imprecise depending on what user clicked
    let linkElement = event.target;
    while (linkElement && linkElement.tagName != 'A'){
      linkElement = linkElement.parentElement;
    }

    // Call switchToTab
    const targetTabId = linkElement.getAttribute('href').substring(1);
    this.switchToTab(targetTabId);
  }

  //Actually does the tab switching
  switchToTab(targetTabId) {
    // Hide all tab contents
    this.tabTargets.forEach(function(tabContent) {
      tabContent.style.display = 'none';
    });

    // De-select current link button
    document.querySelector('.selected').classList.remove('selected');
    document.getElementById(targetTabId).style.display = 'block';
    document.getElementById(`${targetTabId}-link`).classList.add("selected");

    //Update tab title
    switch (targetTabId) {
      case 'dogs-tab':
        this.tabTitleTarget.textContent = 'Dogs';
        break;
      case 'dog-parks-tab':
        this.tabTitleTarget.textContent = 'Dog Parks';
        break;
      case 'details-tab':
        this.tabTitleTarget.textContent = 'Details';
        break;
      case 'posts-tab':
      default:
        this.tabTitleTarget.textContent = 'Posts';
        break;
    }

    //Set a cookie to remember tab, expires in a week
    const expirationDate = new Date();
    expirationDate.setDate(expirationDate.getDate() + 7);
    const expires = expirationDate.toUTCString();
    document.cookie = `profile_tab=${targetTabId}; expires=${expires}; path=/`
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