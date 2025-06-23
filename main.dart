import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'firebase_options.dart';

import 'screens/login.dart';
import 'screens/register_screen.dart';
import 'screens/personal_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartiCare',
      theme: ThemeData(
        primaryColor: const Color(0xFFFF6B6B),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B6B),
          primary: const Color(0xFFFF6B6B),
        ),
      ),
      home: const AuthWrapper(), // Use AuthWrapper to decide the initial screen
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/personal': (context) => PersonalScreen(
              onSkip: () => Navigator.pushReplacementNamed(context, '/home'),
              onNext: () => Navigator.pushReplacementNamed(context, '/home'),
            ),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if the user is logged in
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is logged in, navigate to the home screen
      return HomeScreen();
    } else {
      // User is not logged in, navigate to the login screen
      return const LoginScreen();
    }
  }
}
