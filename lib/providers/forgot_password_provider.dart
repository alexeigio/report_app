import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordProvider extends ChangeNotifier {
  bool _loading = false;
  String? _message; 
  bool _success = false;

  bool get loading => _loading;
  String? get message => _message;
  bool get success => _success;

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void setMessage(String? msg, {bool success = false}) {
    _message = msg;
    _success = success;
    notifyListeners();
  }

  Future<void> sendResetEmail(String email) async {
    setLoading(true);
    setMessage(null);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      setMessage('Correo de recuperación enviado.', success: true);
    } on FirebaseAuthException catch (e) {
      setMessage(e.message ?? 'Error al enviar correo');
    } finally {
      setLoading(false);
    }
  }
}