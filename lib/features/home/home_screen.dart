import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tips = [
      'Stay calm in emergency situations.',
      'Call 911 if necessary.',
      'Do not try to handle conflicts on your own.',
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Citizen Reports'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 120.0,
              autoPlay: true,
              enlargeCenterPage: true,
            ),
            items: tips.map((tip) {
              return Card(
                color: Colors.indigoAccent,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      tip,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20.0),
          SizedBox(
            height: 100.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 80.0,
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 30.0,
                          backgroundColor: Colors.indigo,
                          child: SvgPicture.asset(
                            category['icon']!,
                            color: Colors.white,
                            width: 30.0,
                            height: 30.0,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          category['name']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12.0),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20.0),
          const Text(
            'Recent Reports',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10.0),
          ...reports.map((report) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text(report['title']!),
                subtitle: Text(report['description']!),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
