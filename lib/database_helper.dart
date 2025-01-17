import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  late FirebaseFirestore _firestore;

  DatabaseHelper._init() {
    _firestore = FirebaseFirestore.instance;
  }

  // Insert ride details into Firestore
  Future<void> insertRideDetails(Map<String, dynamic> ride) async {
    try {
      await _firestore.collection('ride_details').add(ride);
    } catch (e) {
      print('Error adding ride details: $e');
    }
  }

  // Insert user into Firestore
  Future<void> insertUser(Map<String, dynamic> user) async {
    try {
      await _firestore.collection('users').add(user);
    } catch (e) {
      print('Error adding user: $e');
    }
  }

  // Fetch user by username
  Future<Map<String, dynamic>?> getUser(String username) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  // Fetch all ride details from Firestore
  Future<List<Map<String, dynamic>>> getRideDetails() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('ride_details').get();
      List<Map<String, dynamic>> rideDetailsList = [];

      for (var doc in snapshot.docs) {
        rideDetailsList.add(doc.data() as Map<String, dynamic>);
      }

      return rideDetailsList;
    } catch (e) {
      print('Error fetching ride details: $e');
      return [];
    }
  }

  // Fetch uname of a given username
  Future<String?> getUname(String username) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var data = snapshot.docs.first.data() as Map<String, dynamic>;
        return data['uname']; // Assuming 'uname' is a field in your Firestore document
      } else {
        print('User not found');
        return null;
      }
    } catch (e) {
      print('Error fetching uname: $e');
      return null;
    }
  }

  // Add user to Firestore after validating if the username already exists
  Future<bool> addUser(String username, String password, String uname) async {
    try {
      // Check if username already exists
      var existingUser = await getUser(username);
      if (existingUser != null) {
        print('Username already exists.');
        return false; // Username already exists, return false
      }

      // Add new user to Firestore
      await _firestore.collection('users').add({
        'username': username,
        'password': password,
        'uname': uname, // You can store other user-related fields here
      });

      print('User added successfully');
      return true; // Return true when user is added successfully
    } catch (e) {
      print('Error adding user: $e');
      return false; // Return false if there was an error
    }
  }
}
