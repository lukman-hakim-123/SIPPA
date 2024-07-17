import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:sippa/webviewhome.dart';
// import 'package:sippa/auth/login.dart';
import 'auth/login_page.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const LoginPage(),
        // '/web': (context) => const WebViewHome()
      },
    );
  }
}

// note
// Navigator.of(context).pushNamed('name')