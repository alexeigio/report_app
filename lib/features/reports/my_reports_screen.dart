import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 16),
          Center(
            child: Image.asset('assets/my_reports_header.png', height: 60),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('reports')
                      .where('user_id', isEqualTo: userId)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final reports = snapshot.data!.docs;

                if (reports.isEmpty) {
                  return const Center(
                    child: Text('Aún no has creado reportes.'),
                  );
                }

                return ListView.builder(
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    return ReportCard(
                      report: report,
                      onTap:
                          () => showDialog(
                            context: context,
                            builder: (_) => ReportDetailModal(report: report),
                          ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ReportCard extends StatelessWidget {
  final QueryDocumentSnapshot report;
  final VoidCallback onTap;

  const ReportCard({required this.report, required this.onTap, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = report.data() as Map<String, dynamic>;
    final timestamp =
        (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

    final String title = data['title']?.toString() ?? 'Sin título';
    final String category = data['category']?.toString() ?? 'Sin categoría';
    final String? imageUrl = data['image_url']?.toString();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading:
            imageUrl != null
                ? Image.network(
                  imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                )
                : const Icon(Icons.image_not_supported, size: 60),
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Categoría: $category"),
            Text("Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(timestamp)}"),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
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
    final timestamp = (data['createdAt'] as Timestamp).toDate();

    return Dialog(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              data['image_url'],
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 12),
            Text(
              data['title'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Categoría: ${data['category']}"),
            Text("Estado: ${data['status']}"),
            Text("Descripción: ${data['description']}"),
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
                  target: LatLng(
                    data['location']['lat'],
                    data['location']['lng'],
                  ),
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId("report_location"),
                    position: LatLng(
                      data['location']['lat'],
                      data['location']['lng'],
                    ),
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
