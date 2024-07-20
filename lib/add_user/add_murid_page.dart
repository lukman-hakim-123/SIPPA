import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sippa/widget_view/appbar.dart';
import 'package:sippa/widget_view/drawer.dart';
import 'package:sippa/widget_view/field.dart';

import '../auth/controllers/auth_controller.dart';

class AddMuridPage extends ConsumerStatefulWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const AddMuridPage());
  const AddMuridPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddMuridPageState();
}

class _AddMuridPageState extends ConsumerState<AddMuridPage> {
  int _selectedIndex = 2;

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final kelompokController = TextEditingController();
  // final passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void onSignup() {
    ref.read(authControllerProvider.notifier).signup(
        email: emailController.text,
        password: passwordController.text,
        nama: nameController.text,
        kelompok: kelompokController.text,
        context: context);
  }

  bool _obscureText = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Tambah Murid',
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
              Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: CustomTextField(
                  labelText: "Nama",
                  controller: nameController,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: CustomTextField(
                  labelText: "Kelompok",
                  controller: kelompokController,
                  forceUppercase: true,
                ),
              ),
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
                padding: const EdgeInsets.only(bottom: 22),
                child: TextField(
                  obscureText: _obscureText,
                  controller: passwordController,
                  decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(_obscureText
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText; // Toggle _obscureText
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                      labelText: 'Password'),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  onSignup();
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
                  child: const Text("Tambah Murid",
                      style:
                          TextStyle(fontFamily: 'inter', color: Colors.white)),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
      )),
      drawer: CustomDrawer(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemSelected,
      ),
    );
  }
}
