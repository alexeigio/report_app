import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:report_app/features/dashboard/dashboard_screen.dart';
import 'package:report_app/firebase_options.dart';
import 'package:report_app/providers/login_provider.dart';
import 'package:report_app/providers/register_provider.dart';
import 'package:report_app/providers/forgot_password_provider.dart';
import 'package:report_app/providers/profile_provider.dart';
import 'package:report_app/providers/theme_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/reports/report_incident_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => RegisterProvider()),
        ChangeNotifierProvider(create: (_) => ForgotPasswordProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()), 
      ],
      child: MyApp(),
    ),
  );
}

final themeNotifier = ThemeNotifier();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Citizen Report App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),
          darkTheme: ThemeData.dark(),
          themeMode: mode,
          initialRoute: '/onboarding',
          routes: {
            '/': (context) => LoginScreen(),
            '/onboarding': (context) => const OnboardingScreen(),
            '/dashboard': (context) => const DashboardScreen(),
            '/home': (context) => const HomeScreen(),
            '/register': (context) => const RegisterScreen(),
            '/report': (context) => const ReportIncidentScreen(), 
          },
        );
      },
    );
  }
}