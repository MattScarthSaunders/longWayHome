Long Way Home

This app is a route finding app created during the Northcoders bootcamp as a final group project in which we were required to explore new tech.

You will need the latest version of flutter installed to use the app.

Run 'flutter pub get' to install all necessary packages.

Initialise firebase auth using flutterfire CLI and the command 'flutterfire configure' and set up a project for use with the app. You will need email/password authentication selected.

You will also need to provide an API key for open route service. In the /lib folder, create an 'apikeys.dart' file, and ensure it has a line of:
const openrouteservicekey = "yourAPIKeyhere";

This app is android only, so you will need to either run an android emulator, or attach and android phone with dev mode enabled.

To use the app:

Sign up, then log in.
Use the route planner to place a start and end point, or use postcodes and the 'set' buttons. Wait for the initial route and points of interest to load. Plot the final route, and away you go!
You can save the routes you generate to your profile, and reload them/delete them from the profile page.
To see what the points of interest are, tap/click on them on the map to see a popup with their name.
