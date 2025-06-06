import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class InPersonHelpScreen extends StatelessWidget {
  const InPersonHelpScreen({Key? key}) : super(key: key);

  static const LatLng _location = LatLng(20.5216199, -100.8135048);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("In-Person Help"), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Center(
                child: Image.asset(
                  'assets/in_person_help_header.png',
                  height: 80,
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Presidencia Municipal de Celaya",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Dirección: Portal Independencia 101, Col. Centro, 38000 Celaya, Gto.",
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final Uri phoneUri = Uri(
                            scheme: 'tel',
                            path: '4616187100',
                          );
                          try {
                            await launchUrl(
                              phoneUri,
                              mode: LaunchMode.externalApplication,
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'No se pudo abrir el marcador: $e',
                                ),
                              ),
                            );
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.phone, color: Colors.blue, size: 20),
                            SizedBox(width: 6),
                            Text(
                              "461 618 7100",
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Horario:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text("Lunes: 8 a.m.–4 p.m."),
                      const Text("Martes: 8 a.m.–4 p.m."),
                      const Text("Miércoles: 8 a.m.–4 p.m."),
                      const Text("Jueves: 8 a.m.–4 p.m."),
                      const Text("Viernes: 8 a.m.–4 p.m."),
                      const Text("Sábado: Cerrado"),
                      const Text("Domingo: Cerrado"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SizedBox(
                  height: 300,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: GoogleMap(
                      initialCameraPosition: const CameraPosition(
                        target: _location,
                        zoom: 16,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId('inPersonHelp'),
                          position: _location,
                          infoWindow: const InfoWindow(title: 'In-Person Help'),
                        ),
                      },
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
