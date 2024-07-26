import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sippa/add_user/controller/user_controller.dart';
import 'package:sippa/models/user.dart';
import 'package:sippa/widget_view/appbar.dart';
import 'package:sippa/widget_view/field.dart';
import '../auth/controllers/auth_controller.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditMuridPage extends ConsumerStatefulWidget {
  final User user;
  static route(User user) =>
      MaterialPageRoute(builder: (context) => EditMuridPage(user: user));
  const EditMuridPage({super.key, required this.user});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EditMuridPageState();
}

class _EditMuridPageState extends ConsumerState<EditMuridPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  File? _image;
  String? _errorMessage;
  static const int maxFileSize = 2 * 1024 * 1024;
  String? selectedKelompok;
  bool _isNewImage = false;

  @override
  void initState() {
    super.initState();
    emailController.text = widget.user.email;
    nameController.text = widget.user.nama;
    selectedKelompok = widget.user.kelompok; // Initialize the selectedKelompok
  }

  @override
  void dispose() {
    emailController.dispose();
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
          _isNewImage = false;
        });
      } else {
        setState(() {
          _image = file;
          _isNewImage = true;
          _errorMessage = null;
        });
      }
    } else {
      setState(() {
        _errorMessage = null;
        _isNewImage = false;
      });
    }
  }

  void onUpdate() {
    ref.read(muridControllerProvider.notifier).updateMurid(
        image: _image,
        email: emailController.text,
        nama: nameController.text,
        muridId: widget.user.id,
        context: context,
        ref: ref,
        kelompok: selectedKelompok ?? widget.user.kelompok,
        levelUser: widget.user.levelUser,
        imageId: widget.user.imageId);
  }

  @override
  Widget build(BuildContext context) {
    final levelUser = ref.watch(currentUserDetailsProvider).value!.levelUser;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Edit Murid',
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 31),
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
                    child: _isNewImage
                        ? Image.file(_image!, fit: BoxFit.cover)
                        : ref
                            .watch(getUserImageProvider(widget.user.imageId))
                            .when(
                              data: (imageData) {
                                if (imageData != null) {
                                  return Image.memory(
                                    imageData,
                                    fit: BoxFit.cover,
                                  );
                                } else {
                                  return Image.asset(
                                      'assets/images/pp_kosong.jpg',
                                      fit: BoxFit.cover);
                                }
                              },
                              loading: () => const CircularProgressIndicator(),
                              error: (_, __) => const Icon(Icons.error),
                            ),
                  ),
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
                child: const Text('Pilih Foto'),
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
              if (levelUser == 1)
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
                    items: ['A', 'B', 'C', 'D', 'E', 'F'].map((String option) {
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
                  readOnly: true,
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
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    onUpdate();
                  }
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
                  child: const Text("Update Murid",
                      style:
                          TextStyle(fontFamily: 'inter', color: Colors.white)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
