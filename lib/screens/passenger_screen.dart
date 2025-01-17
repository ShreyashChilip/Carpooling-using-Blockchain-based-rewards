import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'detailedRideView.dart'; // Import the detailed ride view screen
import '../base_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../database_helper.dart'; // Make sure this import is present

class PassengerScreen extends StatelessWidget {
  final String username;
  final String uname;
  PassengerScreen({required this.username, required this.uname});

  // Helper function to check if the ride is expired
  bool isRideExpired(String departureDate, String departureTime) {
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    try {
      final rideDateTime = dateFormat.parse('$departureDate $departureTime');
      return rideDateTime.isBefore(now);
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      username: username,
      title: 'Passenger Dashboard',
      child: FutureBuilder<List<Map<String, dynamic>>>( 
        future: DatabaseHelper.instance.getRideDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No available rides.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            );
          }

          List<Map<String, dynamic>> rideDetails = snapshot.data!;

          // Sort rides by departure time (ascending)
          rideDetails.sort((a, b) {
            final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
            final departureA = dateFormat.parse(
                '${a['departure_date']} ${a['departure_time']}');
            final departureB = dateFormat.parse(
                '${b['departure_date']} ${b['departure_time']}');
            return departureA.compareTo(departureB);
          });

          return ListView.builder(
            itemCount: rideDetails.length,
            itemBuilder: (context, index) {
              final ride = rideDetails[index];

              // Extract data from the ride map
              String startLocation = ride['start_location'] ?? 'N/A';
              String endLocation = ride['end_location'] ?? 'N/A';
              String vehicleType = ride['vehicle_type'] ?? 'N/A';
              String vacantSpace = ride['vehicle_space'] ?? 'N/A';
              String vehicleNo = ride['vehicle_no'] ?? 'N/A';
              String departureDate = ride['departure_date'] ?? 'N/A';
              String departureTime = ride['departure_time'] ?? 'N/A';
              String listedBy = ride['listed_by'] ?? 'N/A';
              String mapLink = ride['map_link'] ?? 'N/A';
              String distanceKm = ride['distance_km'] ?? 'N/A';

              // Check if the ride is expired
              bool expired = isRideExpired(departureDate, departureTime);

              return Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: expired ? Colors.grey[300] : Colors.white, // Gray if expired
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Highlight the most important details
                      Text(
                        'Ride ${index + 1}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: expired ? Colors.grey : Colors.black,
                        ),
                      ),
                      SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(color: Colors.black, fontSize: 14),
                          children: [
                            TextSpan(
                                text: 'From: ',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            TextSpan(text: startLocation),
                          ],
                        ),
                      ),
                      SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(color: Colors.black, fontSize: 14),
                          children: [
                            TextSpan(
                                text: 'To: ',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            TextSpan(text: endLocation),
                          ],
                        ),
                      ),
                      SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(color: Colors.black, fontSize: 14),
                          children: [
                            TextSpan(
                                text: 'Vehicle: ',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            TextSpan(text: vehicleType),
                          ],
                        ),
                      ),
                      SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(color: Colors.black, fontSize: 14),
                          children: [
                            TextSpan(
                                text: 'Spaces: ',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            TextSpan(text: vacantSpace),
                          ],
                        ),
                      ),
                      SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(color: Colors.black, fontSize: 14),
                          children: [
                            TextSpan(
                                text: 'Vehicle No: ',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            TextSpan(text: vehicleNo),
                          ],
                        ),
                      ),
                      SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(color: Colors.black, fontSize: 14),
                          children: [
                            TextSpan(
                                text: 'Departure: ',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            TextSpan(
                                text: '$departureDate at $departureTime'),
                          ],
                        ),
                      ),
                      SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(color: Colors.black, fontSize: 14),
                          children: [
                            TextSpan(
                                text: 'Driver: ',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            TextSpan(text: listedBy),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: expired
                              ? null
                              : () {
                                  // Navigate to the detailed ride view screen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailedRideView(
                                        ride: ride, // Pass the ride details to the next screen
                                      ),
                                    ),
                                  );
                                },
                          child: Text(expired ? 'Expired' : 'View Details'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                expired ? Colors.grey : Colors.blue,
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
