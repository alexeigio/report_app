import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  Future<void> _register() async {
    try {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')),
        );
        return;
      }

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      await userCredential.user?.sendEmailVerification();

      String fullName =
          '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';
      await userCredential.user!.updateDisplayName(fullName);
      await userCredential.user!.reload();
      final updatedUser = _auth.currentUser;

      // AGREGA ESTA LÍNEA para guardar en Firestore:
      await saveUserToFirestore(
        updatedUser!,
        provider: "email",
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        photoUrl: null,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario registrado. Revisa tu correo para verificar la cuenta.'),
          duration: Duration(seconds: 2),
        ),
      );

      // Espera un momento y regresa al login
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.pop(context);

    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Error al registrar')),
      );
    }
  }

  Future<void> _registerWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      // Extraer nombre y apellido del displayName de Google
      String? displayName = user?.displayName ?? '';
      String firstName = '';
      String lastName = '';
      if (displayName.contains(' ')) {
        firstName = displayName.split(' ').first;
        lastName = displayName.split(' ').skip(1).join(' ');
      } else {
        firstName = displayName;
        lastName = '';
      }

      await saveUserToFirestore(
        user!,
        provider: "google",
        firstName: firstName,
        lastName: lastName,
        photoUrl: user.photoURL,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrado con Google correctamente.')),
      );
      if (mounted) Navigator.pop(context);

    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Error al registrar con Google')),
      );
    }
  }

  // Modifica saveUserToFirestore para aceptar más campos:
  Future<void> saveUserToFirestore(
    User user, {
    required String provider,
    String? firstName,
    String? lastName,
    String? photoUrl,
  }) async {
    try {
      print('Intentando guardar usuario en Firestore: ${user.uid}');
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final userDoc = await userRef.get();
      if (!userDoc.exists) {
        await userRef.set({
          'uid': user.uid,
          'email': user.email,
          'firstName': firstName ?? '',
          'lastName': lastName ?? '',
          'provider': provider,
          'photoUrl': photoUrl ?? user.photoURL ??
              "https://st3.depositphotos.com/15648834/17930/v/450/depositphotos_179308454-stock-illustration-unknown-person-silhouette-glasses-profile.jpg",
          'createdAt': FieldValue.serverTimestamp(),
        });
        print('Usuario guardado en Firestore');
      } else {
        print('El usuario ya existe en Firestore');
      }
    } catch (e) {
      print('Error al guardar usuario en Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 32),
                  child: Image.asset(
                    'assets/logo.png',
                    height: 80,
                  ),
                ),
              ),
              // Title
              Text(
                'Register Account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Text(
                    'to ',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'HR Attendee',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Hello there, register to continue',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              // First Name
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  hintText: 'Enter First Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Last Name
              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  hintText: 'Enter Last Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Email
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'Enter Email Address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              // Password
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Confirm Password
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  hintText: 'Confirm Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Register Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _register,
                  child: Text(
                    'Register',
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Or continue with
              Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'Or continue with social account',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),
              // Google Button (aún sin implementar)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  icon: Image.asset(
                    'assets/google_icon.png',
                    height: 24,
                  ),
                  label: Text(
                    'Google',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  onPressed: _registerWithGoogle,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}