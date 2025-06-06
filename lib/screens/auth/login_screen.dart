import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'register_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'forgot_password_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/login_provider.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login(BuildContext context) async {
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    loginProvider.setError(null);
    loginProvider.setLoading(true);
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        loginProvider.setError('Debes verificar tu correo electrónico. Se ha reenviado el correo de verificación.');
        await FirebaseAuth.instance.signOut();
        loginProvider.setLoading(false);
        return;
      }

      loginProvider.setLoading(false);
      Navigator.pushNamed(context, '/dashboard');
    } on FirebaseAuthException catch (e) {
      loginProvider.setError(e.message ?? 'Error al iniciar sesión');
      loginProvider.setLoading(false);
    }
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    loginProvider.setError(null);
    loginProvider.setLoading(true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        loginProvider.setLoading(false);
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      await saveUserToFirestore(userCredential.user!, provider: "google");
      loginProvider.setLoading(false);
      Navigator.pushNamed(context, '/dashboard');
    } on FirebaseAuthException catch (e) {
      loginProvider.setError(e.message ?? 'Error al iniciar sesión con Google');
      loginProvider.setLoading(false);
    }
  }

  Future<void> saveUserToFirestore(
    User user, {
    required String provider,
  }) async {
    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final userDoc = await userRef.get();
      if (!userDoc.exists) {
        await userRef.set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'provider': provider,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      // Puedes manejar errores aquí si lo deseas
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context);

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
              // Welcome Text
              Text(
                'Welcome Back 👋',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Text(
                    'to ',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Report App',
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
                'Hello there, login to continue',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              // Email Field
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: loginProvider.obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      loginProvider.obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      loginProvider.toggleObscurePassword();
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Error message
              if (loginProvider.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    loginProvider.errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Forgot Password ?',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Login Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: loginProvider.isLoading
                      ? null
                      : () => _login(context),
                  child: loginProvider.isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : Text(
                          'Login',
                          style: TextStyle(fontSize: 18, color: Colors.white),
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
              SizedBox(
                width: double.infinity,
                height: 48,
                child: InkWell(
                  onTap: loginProvider.isLoading
                      ? null
                      : () => _signInWithGoogle(context),
                  child: SvgPicture.asset(
                    'assets/google_logo_ctn.svg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Didn't have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Register',
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
