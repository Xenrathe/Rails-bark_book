# README

## BarkBook, a social media app just for dogs

## In-Development To-do List:
* DogPark basic functionality
* DogSize enum
* Play_date basic functionality
* Validations on all models

* Navigation 'test' and connectivity

* Pressing bark plays a sound
* Several default bark sounds / bark selection on user profile
* Ability to upload custom bark sound
* User can add / delete / edit addresses on profile
* User can change name on user profile
* Timezone selection on user profile
* Channel / websocket for feed and comments
* Connect to google maps API for dog park / dog event
* Implement a real mailer
* Add cloud storage via google/amazon/microsoft

### Primary:

TableTop Tavern helps connect players and DMs to play tabletop RPGs (Dungeons & Dragons, Pathfinder, Warhammer, Call Of Cthulhu, etc). Users can find adventures with filters based on ruleset, platform (virtual and in-person), as well as min/max level. Additionally, users can create characters that can then sign up to attend each adventure.

Please note that TableTop Tavern is a portfolio showpiece in its current form. It lacks some features and functionality (e.g. a more complete address for in-person hosting) necessary for legitimate deployment and use. Furthermore, it has not yet been modified for mobile use, though that's on my to-do list.

TableTop Tavern is active on fly.io: (https://tabletop-tavern.fly.dev/)

![Screenshot of the index page](https://github.com/Xenrathe/Rails-event_planner/blob/main/TTT-Index.jpg?raw=true)

### Features:
* User registration, login via Devise gem
* Easy-to-use filtering system for adventure list
* Ability to create, edit, and delete adventures
* Ability to create, edit, and delete characters who can 'attend' adventures (via a AdventureAttendance through-model / join-table)
* Validation both client and server-side across all views and models
* Real-time chat-rooms for the participants of each adventure (uses Redis server for production)
* All CSS written by hand
  
![Screenshot of the character creation page](https://github.com/Xenrathe/Rails-event_planner/blob/main/TTT-NewCharacter.jpg?raw=true)

### Future to-do list
* Adjustments for mobile view & responsiveness
* Login via username, not just email
* Add parchment background to adventure show
* Auto-mailer integration
* Clean up / organize CSS
* Adventure SHOW (as creator): reserving seats, removing characters, inviting via email.
* Omni-Auth integration

### Design Brief
This project was created as part of The Odin Project curriculum, expanding on the <a href="https://www.theodinproject.com/lessons/ruby-on-rails-private-events">Private Events</a> project.

### Image Attribution
<a href="https://www.pexels.com/photo/close-up-of-wooden-plank-326311/">Wooden BG</a> on Pexels

<a href="https://mythjourneys.com/gallery/dungeons-and-dragons/free-dnd-character-art/">Free DnD portraits</a> on Mythjourneys

(Other images are AI generated)

![Screenshot of the avatar selection](https://github.com/Xenrathe/Rails-event_planner/blob/main/TTT-AvatarSelection.jpg?raw=true)