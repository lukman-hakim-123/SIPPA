import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sippa/auth/signup_page.dart';

import 'controllers/auth_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => const LoginPage());
  const LoginPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void onLogin() {
    ref.read(authControllerProvider.notifier).login(
        email: emailController.text,
        password: passwordController.text,
        context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Masuk',
              style: TextStyle(fontFamily: 'inter', color: Colors.white)),
          backgroundColor: const Color(0xff104993),
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.only(
            right: 31,
            left: 31,
            bottom: 40,
          ),
          child: Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 60,
                ),
                const CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage('assets/icons/sippa.png'),
                ),
                const Text(
                  'Sistem Informasi Pertumbuhan dan Perkembangan Anak',
                  style: TextStyle(
                    fontFamily: 'inter',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 35),
                Padding(
                  padding: const EdgeInsets.only(bottom: 22),
                  child: TextField(
                    keyboardType: TextInputType.emailAddress,
                    controller: emailController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), labelText: 'Email'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: TextField(
                    obscureText: true,
                    controller: passwordController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), labelText: 'Password'),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    onLogin();
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(const Color(0xff104993)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                    ),
                    fixedSize:
                        MaterialStateProperty.all(const Size.fromHeight(45)),
                  ),
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: const Text("Masuk",
                        style: TextStyle(
                            fontFamily: 'inter', color: Colors.white)),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextButton(
                    onPressed: () {
                      Navigator.push(context, SignupPage.route());
                    },
                    child: Text('signup'))
              ],
            ),
          ),
        )));
  }
}
