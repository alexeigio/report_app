import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ReportProvider extends ChangeNotifier {
  String? title;
  String? description;
  String? selectedCategory;
  LatLng? selectedLocation;
  File? selectedImage;
  bool isAnonymous = false;

  void setTitle(String value) {
    title = value;
    notifyListeners();
  }

  void setDescription(String value) {
    description = value;
    notifyListeners();
  }

  void setCategory(String? value) {
    selectedCategory = value;
    notifyListeners();
  }

  void setLocation(LatLng value) {
    selectedLocation = value;
    notifyListeners();
  }

  void setAnonymous(bool value) {
    isAnonymous = value;
    notifyListeners();
  }

  void setImage(File file) {
    selectedImage = file;
    notifyListeners();
  }

  void reset() {
    title = null;
    description = null;
    selectedCategory = null;
    selectedLocation = null;
    selectedImage = null;
    isAnonymous = false;
    notifyListeners();
  }

  Future<void> submitReport(
    BuildContext context,
    VoidCallback onSuccess,
  ) async {
    try {
      if (title == null ||
          selectedCategory == null ||
          description == null ||
          selectedLocation == null ||
          selectedImage == null) {
        throw Exception("Faltan campos obligatorios");
      }

      final uid = FirebaseAuth.instance.currentUser?.uid;
      final imageRef = FirebaseStorage.instance.ref().child(
        'report_images/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await imageRef.putFile(selectedImage!);
      final imageUrl = await imageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('reports').add({
        'title': title,
        'category': selectedCategory,
        'description': description,
        'location': {
          'lat': selectedLocation!.latitude,
          'lng': selectedLocation!.longitude,
        },
        'image_url': imageUrl,
        'user_id': uid,
        'anonymous': isAnonymous,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      onSuccess();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al guardar: $e")));
    }
  }
}
