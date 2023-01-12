# Long Way Home - Group Project

Download the .apk from my portfolio site here: https://mattscarthsaunders.netlify.app/

## About

This app is a route finding app created during the Northcoders bootcamp as a final group project in which we were required to explore new tech and practice working in an 'agile' manner.

## Run Locally

You will need version 3.3.9 or greater of Flutter installed to use the app.

To install all necessary packages, run:

    flutter pub get

Initialise firebase auth using flutterfire CLI and the command:

    flutterfire configure

and set up a project for use with the app. You will need email/password authentication selected in the project.

You will also need to provide an API key for open route service. In the /lib folder, create an 'apikeys.dart' file, and ensure it has a line of:

    const openrouteservicekey = "yourAPIKeyhere";

This app is android only, so you will need to either run an android emulator, or attach and android phone with dev mode enabled.

## Using the App

Sign up, then log in.

You will need to grant location permissions to proceed.

The app will track your location on the map, and you can recenter it using the target/GPS button in the top right. You can also use the zoom in/out buttons there if you prefer them to gestures.

Use the route planner to place a start and end point, or use postcodes and the 'set' buttons. Wait for the initial route and points of interest to load. Plot the final route, and away you go!

You can save the routes you generate to your profile, and reload them/delete them from the profile page.

To see what the points of interest are, tap/click on them on the map to see a popup with their name.
