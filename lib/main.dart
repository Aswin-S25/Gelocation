// Importing necessary packages
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:syncfusion_flutter_maps/maps.dart';


void main() {
  runApp(const MyApp());
}

// MyApp widget, the root of your application
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

// State class for MyApp widget
class _MyAppState extends State<MyApp> {
  int currentZoomLevel = 10;

  // Method to fetch current location asynchronously
  Future<LocationData?> _currentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    Location location = Location();

    // Check if location service is enabled, if not request user to enable it
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    // Check if location permission is granted, if not request user for permission
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }
    // Return current location data
    return await location.getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Map Example'),
        ),
        // FutureBuilder to build UI based on asynchronous snapshot data
        body: FutureBuilder<LocationData?>(
          future: _currentLocation(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              final LocationData currentLocation = snapshot.data!;
              // Directionality widget for defining text direction
              return Directionality(
                textDirection: TextDirection.ltr,
                child: SfMaps(
                  layers: [
                    // Map tile layer for displaying map tiles
                    MapTileLayer(
                      // Setting initial focal latitude and longitude
                      initialFocalLatLng: MapLatLng(
                        currentLocation.latitude!,
                        currentLocation.longitude!,
                      ),
                      initialZoomLevel: 15, // Initial zoom level
                      initialMarkersCount: 1, // Initial markers count
                      // Zoom and pan behavior settings
                      zoomPanBehavior: MapZoomPanBehavior(
                        enableDoubleTapZooming: true,
                        enablePanning: true,
                        enableMouseWheelZooming: true,
                        maxZoomLevel: 20,
                        minZoomLevel: 1,
                        focalLatLng: MapLatLng(
                          currentLocation.latitude!,
                          currentLocation.longitude!,
                        ),
                        zoomLevel: currentZoomLevel.toDouble(),
                      ),
                      // URL template for map tiles
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      // Marker builder for customizing markers on the map
                      markerBuilder: (BuildContext context, int index) {
                        return MapMarker(
                          latitude: currentLocation.latitude!,
                          longitude: currentLocation.longitude!,
                          size: const Size(20, 20),
                          child: Icon(
                            Icons.location_on,
                            color: Colors.red[800],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            }
            // Display a loading indicator while fetching location data
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
