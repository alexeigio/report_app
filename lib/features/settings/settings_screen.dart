import 'package:flutter/material.dart';
import '../../main.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListTile(
        leading: const Icon(Icons.brightness_6),
        title: const Text('Dark Mode'),
        trailing: ValueListenableBuilder<ThemeMode>(
          valueListenable: themeNotifier,
          builder: (context, mode, _) {
            return Switch(
              value: mode == ThemeMode.dark,
              onChanged: (val) => themeNotifier.toggleTheme(),
            );
          },
        ),
      ),
    );
  }
}