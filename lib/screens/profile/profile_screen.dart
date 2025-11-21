import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/common/loading.dart';
import '../../widgets/common/snackbar_helper.dart';

import 'profile_header.dart';
import 'profile_form.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final formKey = GlobalKey<FormState>();

  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final passLamaController = TextEditingController();
  final passBaruController = TextEditingController();
  final passBaru2Controller = TextEditingController();

  File? pickedImage;
  bool obs1 = true, obs2 = true, obs3 = true;
  bool isLoaded = false;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (isLoaded) return;
      isLoaded = true;

      final user = await ref.read(authProvider.future);
      if (user != null) {
        ref.read(userProvider.notifier).fetchUser(user.$id);
      }
    });
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final newFile = await File(
        pickedFile.path,
      ).copy('${Directory.systemTemp.path}/profile_$timestamp.jpg');

      setState(() => pickedImage = newFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final profileState = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: authState.when(
        loading: () => Loader(),
        error: (err, _) => Center(child: Text("Error: $err")),
        data: (user) {
          if (user == null) return Center(child: Text("Not logged in"));

          return profileState.when(
            loading: () => Loader(),
            error: (err, _) => Center(child: Text("Error: $err")),
            data: (profile) {
              if (profile == null) {
                return Center(child: Text("Can't fetch profile"));
              }

              // Set value awal
              if (namaController.text.isEmpty) {
                namaController.text = profile.nama;
              }
              if (emailController.text.isEmpty) {
                emailController.text = profile.email;
              }

              final imageUrl = ref
                  .read(userProvider.notifier)
                  .getPublicImageUrl;

              return SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      ProfileHeader(
                        imageUrl: imageUrl(profile.imageId),
                        pickedImage: pickedImage,
                        onBack: () => context.go('/home'),
                      ),
                      ProfileForm(
                        namaController: namaController,
                        emailController: emailController,
                        passLamaController: passLamaController,
                        passBaruController: passBaruController,
                        passBaru2Controller: passBaru2Controller,
                        obs1: obs1,
                        obs2: obs2,
                        obs3: obs3,
                        toggleObs1: () => setState(() => obs1 = !obs1),
                        toggleObs2: () => setState(() => obs2 = !obs2),
                        toggleObs3: () => setState(() => obs3 = !obs3),
                        profile: profile,
                        onPickImage: pickImage,
                        pickedImage: pickedImage,
                        isSaving: isSaving,
                        onSubmit: () async {
                          if (!formKey.currentState!.validate()) return;

                          setState(() => isSaving = true);

                          final result = await ref
                              .read(userProvider.notifier)
                              .updateUserAdvanced(
                                profile,
                                updatedUser: User(
                                  id: profile.id,
                                  nama: namaController.text,
                                  email: emailController.text,
                                  imageId: profile.imageId,
                                  levelUser: profile.levelUser,
                                  sekolah: profile.sekolah,
                                  kelompok: profile.kelompok,
                                ),
                                photoFile: pickedImage,
                                oldPassword: passLamaController.text.isNotEmpty
                                    ? passLamaController.text
                                    : null,
                                newPassword: passBaruController.text.isNotEmpty
                                    ? passBaruController.text
                                    : null,
                              );

                          if (!context.mounted) return;
                          setState(() => isSaving = false);

                          if (result.isSuccess) {
                            SnackbarHelper.show(
                              context,
                              "Profil berhasil diperbarui",
                            );
                          } else {
                            SnackbarHelper.show(
                              context,
                              "Gagal: ${result.errorMessage}",
                            );
                          }

                          passLamaController.clear();
                          passBaruController.clear();
                          passBaru2Controller.clear();
                          setState(() => pickedImage = null);
                        },
                      ),

                      SizedBox(height: 60),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
