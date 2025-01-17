import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firebase Firestore
import 'passenger_screen.dart';

import '../base_screen.dart';

class DriverScreen extends StatefulWidget {
  final String username;
  final String uname;
  DriverScreen({required this.username, required this.uname});

  @override
  _DriverScreenState createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  final TextEditingController startLocationController = TextEditingController();
  final TextEditingController endLocationController = TextEditingController();
  final TextEditingController vacantSpaceController = TextEditingController();
  final TextEditingController vehicleNoController = TextEditingController();
  final TextEditingController dateTimeController = TextEditingController();
  final TextEditingController intermediateLocation1Controller =
      TextEditingController();
  final TextEditingController intermediateLocation2Controller =
      TextEditingController();
  final TextEditingController intermediateLocation3Controller =
      TextEditingController();
  String? selectedVehicleType;

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to insert ride details into Firestore
  Future<void> insertRideDetails(Map<String, dynamic> ride) async {
    try {
      await _firestore.collection('ride_details').add(ride);
    } catch (e) {
      print('Error adding ride: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      username: widget.username,
      title: 'Driver Dashboard',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Start Location Text Field
              TextField(
                controller: startLocationController,
                decoration: InputDecoration(
                  labelText: 'Start Location *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              SizedBox(height: 16),
              // End Location Text Field
              TextField(
                controller: endLocationController,
                decoration: InputDecoration(
                  labelText: 'End Location *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city),
                ),
              ),
              SizedBox(height: 16),
              // Intermediate Location 1
              TextField(
                controller: intermediateLocation1Controller,
                decoration: InputDecoration(
                  labelText: 'Intermediate Location 1',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              SizedBox(height: 16),
              // Intermediate Location 2
              TextField(
                controller: intermediateLocation2Controller,
                decoration: InputDecoration(
                  labelText: 'Intermediate Location 2',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              SizedBox(height: 16),
              // Intermediate Location 3
              TextField(
                controller: intermediateLocation3Controller,
                decoration: InputDecoration(
                  labelText: 'Intermediate Location 3',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              SizedBox(height: 16),
              // Vehicle Type Dropdown
              DropdownButtonFormField<String>(
                value: selectedVehicleType,
                decoration: InputDecoration(
                  labelText: 'Select Vehicle Type *',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: '2 Wheeler',
                    child: Text('2 Wheeler'),
                  ),
                  DropdownMenuItem(
                    value: '4 Wheeler',
                    child: Text('4 Wheeler'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedVehicleType = value;
                    if (value == '2 Wheeler') {
                      vacantSpaceController.text = '1';
                    } else {
                      vacantSpaceController.clear();
                    }
                  });
                },
              ),
              SizedBox(height: 16),
              // Vacant Spaces Text Field
              TextField(
                controller: vacantSpaceController,
                decoration: InputDecoration(
                  labelText: 'Vacant Spaces *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                enabled: selectedVehicleType != '2 Wheeler',
              ),
              SizedBox(height: 16),
              // Vehicle Number Text Field
              TextField(
                controller: vehicleNoController,
                decoration: InputDecoration(
                  labelText: 'Vehicle No. *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.car_rental),
                ),
                inputFormatters: [
                  UpperCaseTextFormatter(),
                ],
              ),
              SizedBox(height: 16),
              // Departure Date and Time Picker
              TextField(
                controller: dateTimeController,
                decoration: InputDecoration(
                  labelText: 'Departure Date & Time *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null) {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    if (pickedTime != null) {
                      DateTime fullDateTime = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );

                      String formattedDateTime =
                          DateFormat('yyyy-MM-dd HH:mm').format(fullDateTime);

                      setState(() {
                        dateTimeController.text = formattedDateTime;
                      });
                    }
                  }
                },
              ),
              SizedBox(height: 20),
              // Submit Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async {
                  // Validate Fields
                  String vehicleNo = vehicleNoController.text;
                  String dateTimeInput = dateTimeController.text;

                  if (startLocationController.text.isEmpty ||
                      endLocationController.text.isEmpty ||
                      vacantSpaceController.text.isEmpty ||
                      vehicleNo.isEmpty ||
                      dateTimeInput.isEmpty ||
                      selectedVehicleType == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please fill in all the fields marked with *')),
                    );
                    return;
                  }

                  // Split Date and Time
                  List<String> dateTimeParts = dateTimeInput.split(' ');
                  String departureDate = dateTimeParts[0];
                  String departureTime = dateTimeParts[1];

                  // Validate Departure Time
                  DateTime now = DateTime.now();
                  DateTime departureDateTime = DateFormat('yyyy-MM-dd HH:mm')
                      .parse('$departureDate $departureTime');
                  if (departureDateTime.isBefore(now)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Departure time must be later than the current time')),
                    );
                    return;
                  }

                  // Data to be submitted
                  Map<String, dynamic> rideDetails = {
                    "start_location": startLocationController.text,
                    "end_location": endLocationController.text,
                    "vehicle_type": selectedVehicleType,
                    "vehicle_space": vacantSpaceController.text,
                    "vehicle_no": vehicleNo,
                    "departure_date": departureDate,
                    "departure_time": departureTime,
                    "listed_by": widget.uname,
                    "intermediate_location_1": intermediateLocation1Controller.text.isNotEmpty
                        ? intermediateLocation1Controller.text
                        : null,
                    "intermediate_location_2": intermediateLocation2Controller.text.isNotEmpty
                        ? intermediateLocation2Controller.text
                        : null,
                    "intermediate_location_3": intermediateLocation3Controller.text.isNotEmpty
                        ? intermediateLocation3Controller.text
                        : null,
                  };

                  // Insert into Firestore
                  await insertRideDetails(rideDetails);

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ride Listed Successfully!')),
                  );

                  // Redirect to Passenger Screen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PassengerScreen(username: widget.username, uname: widget.uname),
                    ),
                  );
                },
                child: Text('Submit Ride Details'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Formatter to automatically convert text to uppercase
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
