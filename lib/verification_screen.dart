import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VerificationScreen extends StatefulWidget {
  final String username;

  VerificationScreen({required this.username});

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _aadhaarController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
  XFile? _aadhaarImage;
  XFile? _licenseImage;

  bool _isLoading = false;

  // Pick image function
  Future<void> _pickImage(String type) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    setState(() {
      if (pickedFile != null) {
        if (type == 'aadhaar') {
          _aadhaarImage = pickedFile;
        } else if (type == 'license') {
          _licenseImage = pickedFile;
        }
      }
    });
  }

  // Upload image to Firebase Storage and return the download URL
  Future<String> _uploadImageToStorage(XFile image, String type) async {
    try {
      Reference ref = FirebaseStorage.instance.ref().child('verification_images/$this.username/$type');
      UploadTask uploadTask = ref.putFile(File(image.path));
      
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Function for submitting verification
  void _submitVerification() async {
    setState(() {
      _isLoading = true;
    });

    // Manually check if all details are provided
    if (_phoneController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _aadhaarController.text.isEmpty ||
        _licenseController.text.isEmpty ||
        _aadhaarImage == null ||
        _licenseImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill all fields and upload necessary documents.'),
        backgroundColor: Colors.red,
      ));
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Upload images to Firebase Storage and get URLs
      String aadhaarImageUrl = await _uploadImageToStorage(_aadhaarImage!, 'aadhaar');
      String licenseImageUrl = await _uploadImageToStorage(_licenseImage!, 'license');

      // Now, save the form data along with the image URLs in Firestore
      await FirebaseFirestore.instance.collection('user_verifications').add({
        'username': widget.username,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'aadhaar': _aadhaarController.text,
        'license': _licenseController.text,
        'aadhaar_image_url': aadhaarImageUrl,
        'license_image_url': licenseImageUrl,
        'verification_status': 'pending',
        'created_at': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Verification Submitted! Await admin review.'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('An error occurred: $e'),
        backgroundColor: Colors.red,
      ));
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile Verification')),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Card(
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text('Verification Process', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('Submit the required documents for verification'),
                      SizedBox(height: 32),

                      // Phone Number
                      TextField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 16),

                      // Email Address
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 16),

                      // Aadhaar Number
                      TextField(
                        controller: _aadhaarController,
                        decoration: InputDecoration(
                          labelText: 'Aadhaar Number',
                          prefixIcon: Icon(Icons.credit_card),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 16),

                      // Upload Aadhaar Card Image
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => _pickImage('aadhaar'),
                            child: Text('Upload Aadhaar Card'),
                          ),
                          SizedBox(width: 10),
                          if (_aadhaarImage != null)
                            Flexible(child: Image.file(File(_aadhaarImage!.path), width: 100, height: 100)),
                        ],
                      ),
                      SizedBox(height: 16),

                      // Driver's License Number
                      TextField(
                        controller: _licenseController,
                        decoration: InputDecoration(
                          labelText: 'Driver\'s License Number',
                          prefixIcon: Icon(Icons.card_travel),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Upload Driver's License Image
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => _pickImage('license'),
                            child: Text('Upload Driver\'s License'),
                          ),
                          SizedBox(width: 10),
                          if (_licenseImage != null)
                            Flexible(child: Image.file(File(_licenseImage!.path), width: 100, height: 100)),
                        ],
                      ),
                      SizedBox(height: 24),

                      // Submit Verification Button
                      ElevatedButton(
                        onPressed: _submitVerification,
                        child: Text('Submit Verification'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Loading spinner while submitting
          if (_isLoading)
            Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
