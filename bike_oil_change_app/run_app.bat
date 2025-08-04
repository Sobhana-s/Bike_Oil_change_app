@echo off
echo Building and running Bike Oil Change App...
cd c:\bike_oil_change_app
flutter pub get
echo Dependencies installed!
echo.
echo To run the app, use one of these commands:
echo.
echo For Android (if connected):
echo flutter run
echo.
echo For Chrome (web version):
echo flutter run -d chrome
echo.
echo For Windows:
echo flutter run -d windows
echo.
pause
