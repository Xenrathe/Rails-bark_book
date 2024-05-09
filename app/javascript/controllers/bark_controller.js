import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["count"];

  // When pressing the 'bark' button outside of settings menu (e.g. at content or dog)
  bark(event) {
    const bark_url = this.element.dataset.url;
    let barkcount = Number(this.countTarget.dataset.count);

    // Max barks is 50 per user. So for performance-sake simply prevent form submission 
    if (barkcount >= 50) {
      event.preventDefault();
    }
    //Otherwise update the counts CLIENT-SIDE, so that the server doesn't have to render any new views
    else {
      let totalbarks = Number(this.countTarget.dataset.total);
      let totalusers = Number(this.countTarget.dataset.users);

      if (barkcount == 0){
        totalusers += 1;
      }
      totalbarks += 1;
      barkcount += 1;

      // Update the HTML element
      this.countTarget.dataset.count = barkcount;
      this.countTarget.dataset.total = totalbarks;
      this.countTarget.dataset.users = totalusers;
      this.countTarget.innerHTML = `${totalbarks} barks from ${totalusers} users`
    }
    
    // Play the bark sound unless the user has muted it
    if (bark_url == 'mute') {
      return;
    }

    this.play(bark_url);
  }

  // When pressing the 'test bark' button in the User settings
  test(event){
    event.preventDefault();
    var muteSoundRadio = document.getElementById('mute-sound');
    var customSoundRadio = document.getElementById('custom_sound');

    if (muteSoundRadio.checked) {
      // If Mute Sound is selected, do nothing
      return;
    }

    var selectedSoundUrl = '';

    // Determine the selected sound based on the radio button
    if (customSoundRadio.checked) {
      selectedSoundUrl = customSoundRadio.dataset.soundurl;
    } 
    else {
      // Get the value of the selected radio button
      var selectedRadio = document.querySelector('[name="user[bark_sound]"]:checked');
      if (selectedRadio) {
        selectedSoundUrl = selectedRadio.dataset.soundurl;
      }
    }

    this.play(selectedSoundUrl);
  }

  play(bark_url) {
    // Play the selected sound if not empty
    if (bark_url) {
      var audio = new Audio(bark_url);
      audio.volume = 0.5;
      audio.play();
    }
  }
}