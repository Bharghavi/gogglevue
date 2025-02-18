import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import 'ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:place_picker_google/place_picker_google.dart';

import '../constants.dart';

class LocationUtils {

  static Future<LocationResult?> pickLocation(BuildContext context, GeoPoint? initialGeoPoint) async {
    bool hasPermission = await requestLocationPermission(context);

    if (!hasPermission) {
      return null;
    }

    LatLng? initialLocation;

    if (initialGeoPoint != null) {
      initialLocation = LatLng(initialGeoPoint.latitude, initialGeoPoint.longitude);
    }
    initialLocation ??= await _getCurrentLocation();

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

  static void openGoogleMaps(GeoPoint location) async {
    final double latitude = location.latitude;
    final double longitude = location.longitude;
    final String googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";

    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl), mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not open Google Maps");
    }
  }
}
