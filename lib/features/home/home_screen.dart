import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:report_app/features/reports/in_person_help.dart';
import 'package:report_app/features/settings/settings_screen.dart';
import 'package:report_app/screens/auth/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:report_app/providers/profile_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<SliderDrawerState> _sliderDrawerKey =
      GlobalKey<SliderDrawerState>();

  final tips = [
    'Stay calm in emergency situations.',
    'Call 911 if necessary.',
    'Do not try to handle conflicts on your own.',
    'Join neighborhood meetings to enhance community safety.',
    'Avoid excessive noise in residential areas.',
    'Report potholes as soon as you see them.',
    'Participate in neighborhood cleanup campaigns.',
    'Report malfunctioning traffic lights promptly.',
    'Do not block driveways with your vehicle.',
    'Report broken streetlights to improve nighttime safety.',
    'Walk or bike instead of driving to reduce traffic.',
    'Do not litter in public areas; help keep your city clean.',
    'Make sure your pets don’t leave waste in public areas.',
  ];

  final categories = [
    {'name': 'Theft', 'icon': 'assets/icons/robo.svg'},
    {'name': 'Accident', 'icon': 'assets/icons/accidente.svg'},
    {'name': 'Fire', 'icon': 'assets/icons/incendio.svg'},
    {'name': 'Vandalism', 'icon': 'assets/icons/vandalismo.svg'},
  ];

  final reports = [
    {
      'title': 'Theft on 5th Street',
      'description': 'Reported theft at 10:00 AM on 5th Street.',
    },
    {
      'title': 'Accident on Main Avenue',
      'description': 'Multiple car crash reported at 3:00 PM.',
    },
    {
      'title': 'Fire in Central Park',
      'description': 'Fire contained by firefighters at 6:00 PM.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SliderDrawer(
        key: _sliderDrawerKey,
        appBar: SliderAppBar(
          config: SliderAppBarConfig(
            title: Text(
              'Home',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            backgroundColor:
                Theme.of(context).colorScheme.surface, // <-- Cambia aquí
            drawerIconColor:
                Theme.of(context).colorScheme.primary, // <-- Cambia aquí
          ),
        ),
        slider: const _CustomDrawer(),
        child: Scaffold(
          backgroundColor:
              Theme.of(context).colorScheme.background, // <-- Cambia aquí
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // ✅ Logo centrado
              Center(
                child: Image.asset(
                  'assets/logo.png',
                  height: 60,
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : null, // Logo blanco en dark mode si tienes versión monocromática
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Safety Tips",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Safety Tips (CarouselSlider)
              CarouselSlider(
                options: CarouselOptions(
                  height: 100,
                  autoPlay: true,
                  enlargeCenterPage: true,
                ),
                items:
                    tips.map((tip) {
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ), // Borde blanco
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              tip,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),

              const SizedBox(height: 16),
              const Text(
                "Categories",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Categories
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return Container(
                      margin: const EdgeInsets.only(right: 16),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ), // Borde blanco
                            ),
                            child: CircleAvatar(
                              radius: 28,
                              backgroundColor:
                                  Theme.of(context).colorScheme.surface,
                              child: SvgPicture.asset(
                                category['icon'] ?? '',
                                width: 30,
                                colorFilter: ColorFilter.mode(
                                  Theme.of(context).colorScheme.primary,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            category['name'] ?? '',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),
              const Text(
                "Recent Reports",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('reports')
                        .orderBy('createdAt', descending: true)
                        .limit(5)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final reports = snapshot.data!.docs;

                  return Column(
                    children:
                        reports.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final title =
                              data['title']?.toString() ?? 'Sin título';
                          final description =
                              data['description']?.toString() ??
                              'Sin descripción';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(title),
                              subtitle: Text(description),
                              trailing: IconButton(
                                icon: const Icon(Icons.info_outline),
                                onPressed:
                                    () => showDialog(
                                      context: context,
                                      builder:
                                          (_) => ReportDetailModal(report: doc),
                                    ),
                              ),
                            ),
                          );
                        }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReportDetailModal extends StatelessWidget {
  final QueryDocumentSnapshot report;

  const ReportDetailModal({required this.report, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = report.data() as Map<String, dynamic>;
    final timestamp =
        (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    final lat = data['location']?['lat'] ?? 0.0;
    final lng = data['location']?['lng'] ?? 0.0;

    return Dialog(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (data['image_url'] != null)
              Image.network(
                data['image_url'],
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 12),
            Text(
              data['title'] ?? 'Sin título',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Categoría: ${data['category'] ?? 'N/A'}"),
            Text("Estado: ${data['status'] ?? 'N/A'}"),
            Text("Descripción: ${data['description'] ?? 'N/A'}"),
            Text("Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(timestamp)}"),
            const SizedBox(height: 16),
            const Text(
              "Ubicación:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(lat, lng),
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId("report_location"),
                    position: LatLng(lat, lng),
                  ),
                },
                zoomControlsEnabled: false,
                liteModeEnabled: true,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cerrar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomDrawer extends StatelessWidget {
  const _CustomDrawer();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;

        return Column(
          children: [
            const SizedBox(height: 40),
            Center(child: Image.asset('assets/logo.png', height: 60)),
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 40,
              backgroundImage:
                  user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : const AssetImage('assets/default_user.png')
                          as ImageProvider,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                "Welcome, ${user?.displayName ?? 'User'}!",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            _drawerItem(context, Icons.notifications, "Notifications", () {}),
            _drawerItem(context, Icons.settings, "Settings", () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
            }),
            _drawerItem(context, Icons.location_on, "In-Person Help", () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => InPersonHelpScreen()));
            }),
            _drawerItem(context, Icons.logout, "Logout", () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Cerrar sesión'),
                      content: const Text(
                        '¿Estás seguro de que deseas cerrar sesión?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                            Provider.of<ProfileProvider>(
                              context,
                              listen: false,
                            ).reset();
                            await FirebaseAuth.instance.signOut();
                            Future.microtask(() {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) => LoginScreen(),
                                ),
                                (route) => false,
                              );
                            });
                          },
                          child: const Text('Log Out'),
                        ),
                      ],
                    ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      onTap: onTap,
    );
  }
}
