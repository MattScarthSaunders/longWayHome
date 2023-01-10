Long Way Home

This app is a route finding app created during the Northcoders bootcamp as a final group project in which we were required to explore new tech.

Run 'flutter pub get' to install all necessary packages.

You will need to set up a firebase auth project and initialise it using flutterfire CLI in order to log in to the app.
You will also need to provide an API key for open route service, and place it as so in the /lib folder, in a file called apikeys.dart:
const openrouteservicekey = "yourAPIKeyhere";

This app is android only, so you will need to either run an android emulator, or attach and android phone with dev mode enabled.

To use the app:

Sign up, then log in.
Use the route planner to place a start and end point, or use postcodes and the 'set' buttons. Wait for the initial route and points of interest to load. Plot the final route, and away you go!
You can save the routes you generate to your profile, and reload them/delete them from the profile page.
To see what the points of interest are, tap/click on them on the map to see a popup with their name.
