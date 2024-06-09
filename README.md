# README

## BarkPups, a social media app just for dogs

### To-do:
* Browser location is never automatic (button push for the various indices)
* Dog location opt-in part of sign-up -> google oauth account creation redirects to a 'finish signing up' page
* More hints at sharing dog location
* Update/test/? buttons need a better 'active' state CSS
* More impressive BARK button (3d stuff?)
* Accessibility audit

### Primary
BarkPups is a social-media website focused on dogs, allowing users to make posts with text, images, and videos. Additionally, it can be used to schedule play-dates at local dog parks.

BarkPups is hosted on fly.io, via a custom domain: https://www.barkpups.com

![Screenshot of Sign-up](https://github.com/Xenrathe/Rails-bark_book/blob/main/GitIntro.jpg?raw=true)

### Web-dev Features
* Responsive design, with breakpoints for mobile, tablet, and PC
* CSS via Dart SASS
* Smart validations and security across all models, with the expectation of malicious actors
* Scalable-design with optimizations to minimize database queries, unnecessary requests to server
* Integration of Google Cloud Storage, for storing and retrieving media
* Integration of Google Maps API, geocoder gem, and JS navigator, to find 'nearby' parks and dogs
* geocoder uses JS navigator (unless user declines to share location) -> primary address (unless user has none) -> IP address
* Integration of OmniAuth 2.0 (currently only Google)
* Integration of Twilio SendGrid for mailing password resets, etc
  
![Screenshot of responsive design](https://github.com/Xenrathe/Rails-bark_book/blob/main/GitResponsive.jpg?raw=true)

### Future additions
* Additional OmniAuth integration
* API access
* Channel / websocket for feed and comments?
* Additional admin functionality
* Better optimization on some of the nearby filtering (dogparks, playdates)

### Image attribution
* Bark Icon by Gregor Cresnar from <a href="https://thenounproject.com/browse/icons/term/bark/" target="_blank" title="bark Icons">Noun Project</a> (CC BY 3.0)
* Park Background by <a href="https://unsplash.com/@megindoors?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash">Meg</a> on <a href="https://unsplash.com/photos/a-picnic-table-in-the-middle-of-a-field-of-flowers-3hyfMlJJ8rU?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash">Unsplash</a>
  

![Screenshot of a Dog Feed](https://github.com/Xenrathe/Rails-bark_book/blob/main/GitDog.jpg?raw=true)