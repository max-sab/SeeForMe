# SeeForMe
SeeForMe is an app that developed to help people with sight disabilities to overcome some of the problems.

## Main features

#### - Text recognition
  User can point camera on text and listen to the content
#### - Color recognition
  Still, using pointing on the color user will get the closest name of the color amongst 20 previously picked (look into db file). Color is being recognized by loking for the smallest color distance using DELTA E76 formula in LAB colorspace
#### - Voice commands
  Easy access to the functionality implemented by voice commands. Just tap on the mic button
#### - Custom gesture commands
  Custom gestures added for easier use by people with sight disabilities. Save to database is implemented by tapping twice after the results received. To receive the result, long tap gesture is used. Going back is swipe from the screen edge
 
## Technology stack

#### - Vision 
  Vision is Apple framework used for implementing Computer Vision algorithms. In this app, used for text recognition.
 
#### - Speech
  Speech is also an Apple framework that's used for speech recognition. In SeeForMe, used for identifying user's speech
  
#### - SQLite
  SQLite - RDMS, used in the app to store saved colors and texts
