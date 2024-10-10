import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:to_do_list/firebase_options.dart';
import 'package:to_do_list/screens/login.dart';
import 'package:to_do_list/screens/signup.dart';
import 'package:to_do_list/screens/auth.dart';
import 'package:to_do_list/screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully");
  } catch (e) {
    print("Failed to initialize Firebase: $e");
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List',
      initialRoute: '/', // เปลี่ยน initialRoute
      routes: {
        '/': (context) => AuthScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
