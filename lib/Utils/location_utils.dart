import 'dart:async';

import 'ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:place_picker_google/place_picker_google.dart';

import '../constants.dart';

class LocationUtils {

  static Future<LocationResult?> pickLocation(BuildContext context, String location) async {
    bool hasPermission = await requestLocationPermission(context);

    if (!hasPermission) {
      return null;
    }

    LatLng initialLocation;

    if (location.isNotEmpty) {
      try {
        List<String> latLng = location.split(',');
        double lat = double.parse(latLng[0].trim());
        double lng = double.parse(latLng[1].trim());
        initialLocation = LatLng(lat, lng);
      } catch (e) {
        print("Invalid location format: $e");
        initialLocation = await _getCurrentLocation();
      }
    } else {
      initialLocation = await _getCurrentLocation();
    }

    if (context.mounted) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }

    Completer<LocationResult?> completer = Completer<LocationResult?>();

    try {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return Scaffold(
                appBar: AppBar(
                  title: Text("Pick Location"),
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.of(context).pop();
                      completer.complete(null);
                    },
                  ),
            ),
              body: PlacePicker(
              apiKey: K.googleMapsAPIKey,
              initialLocation: initialLocation,
              onPlacePicked: (LocationResult result) {
                completer.complete(result);
                Navigator.of(context).pop();
              }
            ),
            );
          }
        ),
      );
    } catch (e) {
      print("Error opening PlacePicker: $e");
      return null;
    }

    return completer.future;
  }

  static Future<bool> requestLocationPermission(BuildContext context) async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        UIUtils.showErrorDialog(context, 'Error fetching location', 'Please enable location permissions in settings');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      UIUtils.showErrorDialog(context, 'Error fetching location', 'Please enable location permissions in settings');
      return false;
    }

    return true;
  }


  static Future<LatLng> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print("Error getting current location: $e");
      return const LatLng(37.7749, -122.4194); // Default to San Francisco
    }
  }
}
