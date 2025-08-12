// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sippa/add_user/controller/user_controller.dart';
import 'package:sippa/common/error.dart';
import 'package:sippa/common/loading.dart';
import 'package:sippa/constant/appwrite.dart';

import 'package:sippa/models/user.dart';
import 'package:sippa/widget_view/appbar.dart';
import 'package:sippa/widget_view/drawer.dart';
import 'package:sippa/widget_view/field.dart';

import '../auth/controllers/auth_controller.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  static route({required User? userDetails}) => MaterialPageRoute(
      builder: (context) => EditProfilePage(userDetails: userDetails));

  final User? userDetails;
  const EditProfilePage({
    super.key,
    this.userDetails,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  int _selectedIndex = 9;

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final rePasswordController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  File? _image;
  // static const int maxFileSize = 2 * 1024 * 1024;
  String? _errorMessage;
  final bool _obscureText = true;
  bool _isNewImage = false;

  @override
  void initState() {
    super.initState();
    emailController.text = '';
    nameController.text = '';
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
      // final fileSize = await file.length();

      setState(() {
        _image = file;
        _isNewImage = true;

        _errorMessage = null;
      });
    } else {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  void onSaveChanges() async {
    if (_formKey.currentState!.validate()) {
      ref.read(authControllerProvider.notifier).updateUser(
          image: _image,
          email: emailController.text,
          nama: nameController.text,
          password: passwordController.text,
          context: context,
          ref: ref);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserDetailAsyncValue = ref.watch(currentUserDetailsProvider);
    final latestUsersAsyncValue = ref.watch(getLatestUsersProvider);
    final isLoading = ref.watch(authControllerProvider);

    return currentUserDetailAsyncValue.when(
        data: (userDetails) {
          if (userDetails == null) {
            return const Center(child: Loader());
          }
          User copyOfUser = userDetails;
          latestUsersAsyncValue.when(
              data: (data) {
                if (data.events.contains(
                    'databases.*.collections.${AppwriteConstants.collectionUserId}.documents.${userDetails.id}.update')) {
                  copyOfUser = User.fromMap(data.payload);
                }
              },
              error: (error, st) => ErrorText(error: error.toString()),
              loading: () => const Loader());
          final imageId = copyOfUser.imageId;
          nameController.text = copyOfUser.nama;
          emailController.text = copyOfUser.email;
          return Scaffold(
            appBar: const CustomAppBar(
              title: 'Edit Profil',
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
                      child: GestureDetector(
                        onTap: _pickImage,
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
                                : ref.watch(getUserImageProvider(imageId)).when(
                                      data: (imageData) {
                                        if (imageData != null) {
                                          return Image.memory(
                                            imageData,
                                            fit: BoxFit.cover,
                                          );
                                        } else {
                                          return Image.asset(
                                            'assets/images/pp_kosong.jpg',
                                            fit: BoxFit.cover,
                                          );
                                        }
                                      },
                                      loading: () => const Loader(),
                                      error: (_, __) => const Center(
                                        child: Icon(Icons.error,
                                            color: Colors.white),
                                      ),
                                    ),
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
                      child: const Text('Ganti Foto Profil'),
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
                        labelText: 'Password Lama atau Baru',
                        controller: passwordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password tidak boleh kosong';
                          }
                          if (value.length < 8) {
                            return 'Password harus minimal 8 karakter';
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
                        labelText: 'Konfirmasi Password',
                        controller: rePasswordController,
                        validator: (value) {
                          if (value != passwordController.text) {
                            return 'Passwords tidak cocok';
                          }
                          if (value == null || value.isEmpty) {
                            return 'Konfirmasi password tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                    ),
                    isLoading
                        ? const Loader()
                        : ElevatedButton(
                            onPressed: () {
                              onSaveChanges();
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  const Color(0xff104993)),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6.0),
                                ),
                              ),
                              fixedSize: MaterialStateProperty.all(
                                  const Size.fromHeight(45)),
                            ),
                            child: Container(
                              width: double.infinity,
                              alignment: Alignment.center,
                              child: const Text("Simpan Perubahan",
                                  style: TextStyle(
                                      fontFamily: 'inter',
                                      color: Colors.white)),
                            ),
                          ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            drawer: CustomDrawer(
              selectedIndex: _selectedIndex,
              onItemSelected: _onItemSelected,
            ),
          );
        },
        error: (error, st) => ErrorText(error: error.toString()),
        loading: () => const Loader());
  }
}
