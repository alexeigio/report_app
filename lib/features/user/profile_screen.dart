import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  static const String defaultImageUrl = "https://st3.depositphotos.com/15648834/17930/v/450/depositphotos_179308454-stock-illustration-unknown-person-silhouette-glasses-profile.jpg";


  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  bool isGoogleUser = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController? _nameController;
  TextEditingController? _emailController;
  bool _editing = false;

  get defaultImageUrl => null;

  @override
  void initState() {
    super.initState();
    isGoogleUser = user?.providerData.any((p) => p.providerId == 'google.com') ?? false;
  }

  Future<void> _pickAndUploadImage({required bool fromCamera}) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
    );
    if (picked != null && user != null) {
      final ref = FirebaseStorage.instance.ref().child('profile_pics/${user!.uid}.jpg');
      await ref.putFile(File(picked.path));
      final url = await ref.getDownloadURL();
      await user!.updatePhotoURL(url);
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({'photoUrl': url,});
      setState(() {});
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(fromCamera: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Elegir de galería'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(fromCamera: false);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDoc() async {
    return FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'name': _nameController!.text.trim(),
        'email': _emailController!.text.trim(),
      });
      await user!.updateDisplayName(_nameController!.text.trim());
      await user!.updateEmail(_emailController!.text.trim());
      setState(() {
        _editing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Profile')),
        body: const Center(child: Text('No user logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: getUserDoc(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!.data();
          if (data == null) {
            return const Center(child: Text('No user data found'));
          }

          // Inicializa los controladores solo una vez
          _nameController ??= TextEditingController(text: data['name'] ?? user!.displayName ?? "");
          _emailController ??= TextEditingController(text: data['email'] ?? user!.email ?? "");

          return Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                            isGoogleUser
                              ? (user!.photoURL ?? ProfileScreen.defaultImageUrl)
                              : (data['photoUrl'] ?? ProfileScreen.defaultImageUrl),
                          ),
                          radius: 50,
                          child: (isGoogleUser && user!.photoURL == null) || (!isGoogleUser && data['photoUrl'] == null)
                              ? const Icon(Icons.person, size: 50)
                              : null,
                        ),
                        if (!isGoogleUser)
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: _showPhotoOptions,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Nombre
                    TextFormField(
                      controller: _nameController,
                      enabled: !isGoogleUser && _editing,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 8),
                    // Correo
                    TextFormField(
                      controller: _emailController,
                      enabled: !isGoogleUser && _editing,
                      decoration: const InputDecoration(labelText: 'Correo'),
                      validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    // Botones
                    if (!isGoogleUser)
                      _editing
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: _saveProfile,
                                child: const Text('Guardar'),
                              ),
                              const SizedBox(width: 16),
                              OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _editing = false;
                                    _nameController!.text = data['name'] ?? user!.displayName ?? "";
                                    _emailController!.text = data['email'] ?? user!.email ?? "";
                                  });
                                },
                                child: const Text('Cancelar'),
                              ),
                            ],
                          )
                        : ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _editing = true;
                              });
                            },
                            child: const Text('Editar'),
                          ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}