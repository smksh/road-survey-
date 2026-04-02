
RoadSurvey App 🛣️
Hey! This is my RoadSurvey project. Its an Android appliation built using Flutter for real-time pot hole detection and reporting.
Basically, the app captures images of the road, gets your GPS cordinates, and sends the data to a backend server so they can process it and estimate the materials needed to fix it.

Features
Real-time camera preview (finally got this working!)

GPS location capture (Latitude & Longitude)

Image upload to backend server

Survey submission system

Clean government-style UI (tried my best here)

Tech Stack
Flutter (Frontend)

Camera API

Geolocator

HTTP Multipart Requests (this took forever to figure out lol)

FastAPI (Backend - planed for later)

Project Structure
lib/
├── main.dart
├── splash_screen.dart
├── menu_screen.dart
└── survey_screen.dart

How to Run
Install Flutter on your pc

Clone this repo

Run flutter pub get

Plug in your phone and run flutter run (the gradle build might take a while the first time)
