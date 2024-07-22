import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sippa/widget_view/field.dart';
import 'controllers/auth_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => const LoginPage());
  const LoginPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void onLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authControllerProvider.notifier).login(
          email: emailController.text,
          password: passwordController.text,
          context: context,
          ref: ref);
    }
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
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 60),
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
                    child: CustomTextField(
                      keyboardType: TextInputType.emailAddress,
                      controller: emailController,
                      labelText: 'Email',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email tidak boleh kosong';
                        }
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                        if (!emailRegex.hasMatch(value)) {
                          return 'Masukkan email yang valid';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: CustomTextField(
                      obscureText: true,
                      controller: passwordController,
                      labelText: 'Password',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password tidak boleh kosong';
                        }
                        if (value.length < 8) {
                          return 'Password harus minimal 8 karakter';
                        }
                        return null;
                      },
                      icon: true,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: onLogin,
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
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
