import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sippa/widget_view/appbar.dart';
import 'package:sippa/widget_view/field.dart';
import '../auth/controllers/auth_controller.dart';

class AddGuruPage extends ConsumerStatefulWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const AddGuruPage());
  const AddGuruPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddGuruPageState();
}

class _AddGuruPageState extends ConsumerState<AddGuruPage> {
  final List<String> kelompokOptions = ['A', 'B', 'C', 'D', 'E', 'F'];
  String? selectedKelompok;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void onSignup() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authControllerProvider.notifier).signupguru(
          email: emailController.text,
          password: passwordController.text,
          nama: nameController.text,
          kelompok: selectedKelompok!,
          context: context);
    }
  }

  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Tambah Guru',
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 22),
                    child: CustomTextField(
                      labelText: "Nama",
                      controller: nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 22),
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Kelompok',
                      ),
                      value: selectedKelompok,
                      onChanged: (value) {
                        setState(() {
                          selectedKelompok = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Pilih kelompok';
                        }
                        return null;
                      },
                      items: kelompokOptions.map((String option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 22),
                    child: CustomTextField(
                      keyboardType: TextInputType.emailAddress,
                      labelText: 'Email',
                      controller: emailController,
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
                    padding: const EdgeInsets.only(bottom: 22),
                    child: CustomTextField(
                      obscureText: _obscureText,
                      icon: true,
                      labelText: 'Password',
                      controller: passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password tidak boleh kosong';
                        }
                        if (value.length < 6) {
                          return 'Password harus minimal 6 karakter';
                        }
                        return null;
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: onSignup,
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
                      child: const Text("Tambah Guru",
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
