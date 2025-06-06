import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:report_app/providers/profile_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const String defaultImageUrl =
      "https://st3.depositphotos.com/15648834/17930/v/450/depositphotos_179308454-stock-illustration-unknown-person-silhouette-glasses-profile.jpg";

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final user = profileProvider.user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mi Perfil')),
        body: const Center(child: Text('No hay usuario autenticado')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: profileProvider.getUserDoc(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data();
          if (data == null) {
            return const Center(
              child: Text('No se encontraron datos del usuario'),
            );
          }

          profileProvider.initControllers(
            name: data['name'] ?? user.displayName ?? '',
            email: data['email'] ?? user.email ?? '',
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(
                                profileProvider.isGoogleUser
                                    ? (user.photoURL ??
                                        ProfileScreen.defaultImageUrl)
                                    : (data['photoUrl'] ??
                                        ProfileScreen.defaultImageUrl),
                              ),
                              child:
                                  ((profileProvider.isGoogleUser &&
                                              user.photoURL == null) ||
                                          (!profileProvider.isGoogleUser &&
                                              data['photoUrl'] == null))
                                      ? const Icon(Icons.person, size: 50)
                                      : null,
                            ),
                            if (!profileProvider.isGoogleUser)
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed:
                                    profileProvider.loading
                                        ? null
                                        : () {
                                          showModalBottomSheet(
                                            context: context,
                                            builder:
                                                (_) => SafeArea(
                                                  child: Wrap(
                                                    children: [
                                                      ListTile(
                                                        leading: const Icon(
                                                          Icons.camera_alt,
                                                        ),
                                                        title: const Text(
                                                          'Tomar foto',
                                                        ),
                                                        onTap: () {
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                          profileProvider
                                                              .pickAndUploadImage(
                                                                fromCamera:
                                                                    true,
                                                              );
                                                        },
                                                      ),
                                                      ListTile(
                                                        leading: const Icon(
                                                          Icons.photo_library,
                                                        ),
                                                        title: const Text(
                                                          'Elegir de galería',
                                                        ),
                                                        onTap: () {
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                          profileProvider
                                                              .pickAndUploadImage(
                                                                fromCamera:
                                                                    false,
                                                              );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                          );
                                        },
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: profileProvider.nameController,
                          enabled:
                              !profileProvider.isGoogleUser &&
                              profileProvider.editing,
                          decoration: const InputDecoration(
                            labelText: 'Nombre',
                            border: OutlineInputBorder(),
                          ),
                          validator:
                              (v) =>
                                  v == null || v.isEmpty
                                      ? 'Campo requerido'
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: profileProvider.emailController,
                          enabled:
                              !profileProvider.isGoogleUser &&
                              profileProvider.editing,
                          decoration: const InputDecoration(
                            labelText: 'Correo',
                            border: OutlineInputBorder(),
                          ),
                          validator:
                              (v) =>
                                  v == null || v.isEmpty
                                      ? 'Campo requerido'
                                      : null,
                        ),
                        const SizedBox(height: 24),
                        if (profileProvider.message != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              profileProvider.message!,
                              style: TextStyle(
                                color:
                                    profileProvider.success
                                        ? Colors.green
                                        : Colors.red,
                              ),
                            ),
                          ),
                        if (!profileProvider.isGoogleUser)
                          profileProvider.editing
                              ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed:
                                        profileProvider.loading
                                            ? null
                                            : () {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                profileProvider.saveProfile();
                                              }
                                            },
                                    child:
                                        profileProvider.loading
                                            ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                            : const Text('Guardar'),
                                  ),
                                  const SizedBox(width: 16),
                                  OutlinedButton(
                                    onPressed:
                                        profileProvider.loading
                                            ? null
                                            : () {
                                              profileProvider.setEditing(false);
                                              profileProvider.resetControllers(
                                                data,
                                              );
                                            },
                                    child: const Text('Cancelar'),
                                  ),
                                ],
                              )
                              : ElevatedButton(
                                onPressed:
                                    profileProvider.loading
                                        ? null
                                        : () {
                                          profileProvider.setEditing(true);
                                        },
                                child: const Text('Editar'),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
