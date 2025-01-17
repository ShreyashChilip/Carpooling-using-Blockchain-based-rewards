import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailedRideView extends StatelessWidget {
  final Map<String, dynamic> ride;

  DetailedRideView({required this.ride});

  // Updated function to construct Google Maps link with intermediate locations in between
  String constructGoogleMapsLink(
      String startLocation,
      String endLocation,
      String intermediate1,
      String intermediate2,
      String intermediate3) {
    String baseUrl = "https://www.google.com/maps/dir/?api=1";
    String origin = Uri.encodeComponent(startLocation);
    String destination = Uri.encodeComponent(endLocation);

    // Construct waypoints string
    List<String> waypoints = [];
    if (intermediate1.isNotEmpty) waypoints.add(Uri.encodeComponent(intermediate1));
    if (intermediate2.isNotEmpty) waypoints.add(Uri.encodeComponent(intermediate2));
    if (intermediate3.isNotEmpty) waypoints.add(Uri.encodeComponent(intermediate3));

    String waypointString = waypoints.isNotEmpty
        ? "&waypoints=" + waypoints.join('|')
        : "";

    // Ensure waypoints are inserted in between start and end locations
    return "$baseUrl&origin=$origin$waypointString&destination=$destination";
  }

  void _launchURL(BuildContext context, String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not launch the map link. Please try again.',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String startLocation = ride['start_location'] ?? 'Not specified';
    String endLocation = ride['end_location'] ?? 'Not specified';
    String vehicleType = ride['vehicle_type'] ?? 'Not specified';
    String vacantSpace = ride['vehicle_space'] ?? 'Not specified';
    String vehicleNo = ride['vehicle_no'] ?? 'Not specified';
    String departureDate = ride['departure_date'] ?? 'Not specified';
    String departureTime = ride['departure_time'] ?? 'Not specified';
    String listedBy = ride['listed_by'] ?? 'Not specified';
    String intermediate1 = ride['intermediate_location_1'] ?? '';
    String intermediate2 = ride['intermediate_location_2'] ?? '';
    String intermediate3 = ride['intermediate_location_3'] ?? '';
    String mapLink = 'Unavailable';

    // Construct the map link with start, end, and intermediate locations
    if (startLocation != 'Not specified' && endLocation != 'Not specified') {
      mapLink = constructGoogleMapsLink(
          startLocation, endLocation, intermediate1, intermediate2, intermediate3);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Ride Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.red),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Start Location: $startLocation',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.flag, color: Colors.green),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'End Location: $endLocation',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Intermediate Locations Section
            if (intermediate1.isNotEmpty ||
                intermediate2.isNotEmpty ||
                intermediate3.isNotEmpty) ...[
              Text('Intermediate Locations:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              if (intermediate1.isNotEmpty)
                Text('1. $intermediate1', style: TextStyle(fontSize: 16)),
              if (intermediate2.isNotEmpty)
                Text('2. $intermediate2', style: TextStyle(fontSize: 16)),
              if (intermediate3.isNotEmpty)
                Text('3. $intermediate3', style: TextStyle(fontSize: 16)),
              SizedBox(height: 20),
            ],

            Text('Vehicle: $vehicleType', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Available Spaces: $vacantSpace', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Vehicle No: $vehicleNo', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text(
              'Departure: $departureDate at $departureTime',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text('Listed by: $listedBy', style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () => _launchURL(context, mapLink),
              child: Text('View on Map'),
            ),
          ],
        ),
      ),
    );
  }
}
