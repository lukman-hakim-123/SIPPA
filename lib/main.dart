import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth/controllers/auth_controller.dart';
import 'auth/login_page.dart';
import 'common/error.dart';
import 'common/loading.dart';
import 'anekdot/anekdot_page.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ref.watch(currentUserAccountProvider).when(
            data: (user) {
              if (user != null) {
                return const AnekdotPage();
              }
              return const LoginPage();
            },
            error: (error, st) => ErrorPage(
              error: error.toString(),
            ),
            loading: () {
              const LoadingPage();
              return null;
            },
          ),
    );
  }
}
// note
// Navigator.of(context).pushNamed('name')