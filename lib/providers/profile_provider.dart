import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileProvider extends ChangeNotifier {
  User? user = FirebaseAuth.instance.currentUser;
  bool isGoogleUser = false;
  bool editing = false;
  bool loading = false;
  String? message;
  bool success = false;

  TextEditingController? nameController;
  TextEditingController? emailController;

  ProfileProvider() {
    isGoogleUser = user?.providerData.any((p) => p.providerId == 'google.com') ?? false;
  }

  void setEditing(bool value) {
    editing = value;
    notifyListeners();
  }

  void setLoading(bool value) {
    loading = value;
    notifyListeners();
  }

  void setMessage(String? msg, {bool successMsg = false}) {
    message = msg;
    success = successMsg;
    notifyListeners();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDoc() async {
    return FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
  }

  Future<void> pickAndUploadImage({required bool fromCamera}) async {
    setLoading(true);
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
    );
    if (picked != null && user != null) {
      final ref = FirebaseStorage.instance.ref().child(
        'profile_pics/${user!.uid}.jpg',
      );
      await ref.putFile(File(picked.path));
      final url = await ref.getDownloadURL();
      await user!.updatePhotoURL(url);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({'photoUrl': url});
      setMessage('Foto actualizada', successMsg: true);
    }
    setLoading(false);
    notifyListeners();
  }

  Future<void> saveProfile() async {
    if (nameController == null || emailController == null) return;
    setLoading(true);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
        'name': nameController!.text.trim(),
        'email': emailController!.text.trim(),
      });
      await user!.updateDisplayName(nameController!.text.trim());
      await user!.updateEmail(emailController!.text.trim());
      setEditing(false);
      setMessage('Perfil actualizado', successMsg: true);
    } catch (e) {
      setMessage('Error al actualizar perfil');
    }
    setLoading(false);
  }

  void resetControllers(Map<String, dynamic> data) {
    nameController?.text = data['name'] ?? user!.displayName ?? "";
    emailController?.text = data['email'] ?? user!.email ?? "";
    notifyListeners();
  }
}