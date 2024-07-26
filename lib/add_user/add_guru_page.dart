import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sippa/widget_view/appbar.dart';
import 'package:sippa/widget_view/field.dart';
import '../auth/controllers/auth_controller.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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
  File? _image;
  String? _errorMessage;
  static const int maxFileSize = 2 * 1024 * 1024;
  final ImagePicker picker = ImagePicker();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final fileSize = await file.length();

      if (fileSize > maxFileSize) {
        setState(() {
          _errorMessage =
              'Ukuran file melebihi 2 MB. Silakan pilih file yang lebih kecil.';
          _image = null;
        });
      } else {
        setState(() {
          _image = file;
          _errorMessage = null;
        });
      }
    } else {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  void onSignup() {
    if (_formKey.currentState!.validate()) {
      ref.read(authControllerProvider.notifier).signupguru(
          image: _image,
          email: emailController.text,
          password: passwordController.text,
          nama: nameController.text,
          kelompok: selectedKelompok!,
          context: context);
    }
  }

  final bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Tambah Guru',
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(
          right: 31,
          left: 31,
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 20),
              Center(
                child: Container(
                  margin: const EdgeInsets.all(10),
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey),
                  ),
                  child: ClipOval(
                      child: _image != null
                          ? Image.file(
                              _image!,
                              fit: BoxFit.cover,
                            )
                          : Image.asset('assets/images/pp_kosong.jpg',
                              fit: BoxFit.cover)),
                ),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Pilih Gambar'),
              ),
              const SizedBox(height: 16),
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
                      style:
                          TextStyle(fontFamily: 'inter', color: Colors.white)),
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
