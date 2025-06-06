import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:report_app/screens/auth/login_screen.dart';

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
            title: const Text(
              'Home',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            backgroundColor: Colors.white,
            drawerIconColor: Colors.black,
          ),
        ),
        slider: const _CustomDrawer(),
        child: Scaffold(
          backgroundColor: ThemeData().canvasColor,
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // ✅ Logo centrado
              Center(child: Image.asset('assets/logo.png', height: 60)),
              const SizedBox(height: 24),

              const Text(
                "Safety Tips",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(tip, textAlign: TextAlign.center),
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
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white,
                            child: SvgPicture.asset(
                              category['icon'] ?? '',
                              width: 30,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            category['name'] ?? '',
                            style: const TextStyle(fontSize: 12),
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

              Column(
                children:
                    reports.map((report) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const Icon(
                            Icons.report,
                            color: Colors.indigo,
                          ),
                          title: Text(report["title"] ?? ""),
                          subtitle: Text(report["description"] ?? ""),
                        ),
                      );
                    }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomDrawer extends StatelessWidget {
  const _CustomDrawer();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Column(
      children: [
        const SizedBox(height: 40),

        // Logo centrado
        Center(
          child: Image.asset(
            'assets/logo.png', // asegúrate de que este sea tu logo
            height: 60,
          ),
        ),

        const SizedBox(height: 20),

        // Foto del usuario logueado
        CircleAvatar(
          radius: 40,
          backgroundImage:
              user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : const AssetImage('assets/default_user.png')
                      as ImageProvider,
        ),

        const SizedBox(height: 12),

        // Texto de bienvenida
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            "Welcome, ${user?.displayName ?? 'User'}!",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 24),

        _drawerItem(context, Icons.notifications, "Notifications", () {}),
        _drawerItem(context, Icons.settings, "Settings", () {}),
        _drawerItem(context, Icons.location_on, "In-Person Help", () {}),
        _drawerItem(context, Icons.logout, "Logout", () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Confirm Logout'),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
          );

          if (confirm == true) {
            await FirebaseAuth.instance.signOut();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
        }),
      ],
    );
  }

  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo),
      title: Text(label),
      onTap: onTap,
    );
  }
}
