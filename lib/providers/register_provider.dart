import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class RegisterProvider extends ChangeNotifier {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  void toggleObscurePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleObscureConfirmPassword() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void setSuccess(String? message) {
    _successMessage = message;
    notifyListeners();
  }

  Future<User?> registerWithEmail({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    setLoading(true);
    setError(null);
    setSuccess(null);
    try {
      if (password != confirmPassword) {
        setError('Passwords do not match');
        setLoading(false);
        return null;
      }
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      await credential.user?.updateDisplayName('$firstName $lastName');
      await FirebaseFirestore.instance.collection('users').doc(credential.user?.uid).set({
        'uid': credential.user?.uid,
        'email': email.trim(),
        'displayName': '$firstName $lastName',
        'provider': 'email',
        'createdAt': FieldValue.serverTimestamp(),
      });
      await credential.user?.sendEmailVerification();
      setSuccess('Registro exitoso. Revisa tu correo para verificar tu cuenta.');
      setLoading(false);
      await FirebaseAuth.instance.signOut(); // Importante: cerrar sesión tras registro
      return credential.user;
    } on FirebaseAuthException catch (e) {
      setError(e.message ?? 'Registration error');
      setLoading(false);
      return null;
    }
  }

  Future<User?> registerWithGoogle() async {
    setLoading(true);
    setError(null);
    setSuccess(null);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setLoading(false);
        return null;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
        'uid': userCredential.user?.uid,
        'email': userCredential.user?.email,
        'displayName': userCredential.user?.displayName,
        'photoURL': userCredential.user?.photoURL,
        'provider': 'google',
        'createdAt': FieldValue.serverTimestamp(),
      });
      setLoading(false);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      setError(e.message ?? 'Google registration error');
      setLoading(false);
      return null;
    }
  }
}