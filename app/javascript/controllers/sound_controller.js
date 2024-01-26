import { Controller } from "@hotwired/stimulus";

export default class extends Controller {

  // When pressing the 'bark' button outside of settings menu (e.g. at content or dog)
  bark() {
    const bark_url = this.element.dataset.url;
    
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