import 'dart:io';
import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../utils/validation_helper.dart';
import '../../widgets/form/labeled_text_field.dart';
import '../../widgets/form/password_field.dart';
import '../../widgets/custom_button.dart';

class ProfileForm extends StatelessWidget {
  final TextEditingController namaController;
  final TextEditingController emailController;
  final TextEditingController passLamaController;
  final TextEditingController passBaruController;
  final TextEditingController passBaru2Controller;

  final bool obs1;
  final bool obs2;
  final bool obs3;

  final VoidCallback toggleObs1;
  final VoidCallback toggleObs2;
  final VoidCallback toggleObs3;

  final User profile;
  final File? pickedImage;
  final VoidCallback onSubmit;
  final VoidCallback onPickImage;
  final bool isSaving;

  const ProfileForm({
    super.key,
    required this.namaController,
    required this.emailController,
    required this.passLamaController,
    required this.passBaruController,
    required this.passBaru2Controller,
    required this.obs1,
    required this.obs2,
    required this.obs3,
    required this.toggleObs1,
    required this.toggleObs2,
    required this.toggleObs3,
    required this.profile,
    required this.pickedImage,
    required this.onPickImage,
    required this.onSubmit,
    required this.isSaving,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(height: 50),
          Center(
            child: ElevatedButton(
              onPressed: onPickImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text("Ganti Foto"),
            ),
          ),
          LabeledTextField(
            label: 'Nama Lengkap',
            controller: namaController,
            icon: Icons.person,
            validator: (v) => ValidationHelper.validateNotEmpty(v, "Nama"),
          ),

          LabeledTextField(
            label: 'Email',
            controller: emailController,
            icon: Icons.email,
            validator: (v) => ValidationHelper.validateEmail(v),
          ),

          PasswordField(
            label: "Password Lama",
            controller: passLamaController,
            obscure: obs1,
            toggleObscure: toggleObs1,
            validator: (v) => ValidationHelper.validateMultiple(v, [
              (val) => ValidationHelper.validatePasswordOnEmailChange(
                val,
                profile.email,
                emailController.text,
              ),
              (val) {
                if (passBaruController.text.isNotEmpty &&
                    (val == null || val.isEmpty)) {
                  return "Password lama harus diisi";
                }
                return null;
              },
              (val) => ValidationHelper.validateOptionalMinLength(
                val,
                8,
                "Password lama",
              ),
            ]),
          ),
          SizedBox(height: 8),
          PasswordField(
            label: "Password Baru",
            controller: passBaruController,
            obscure: obs2,
            toggleObscure: toggleObs2,
            validator: (v) => ValidationHelper.validateOptionalMinLength(
              v,
              8,
              "Password Baru",
            ),
          ),
          SizedBox(height: 8),
          PasswordField(
            label: "Ulangi Password Baru",
            controller: passBaru2Controller,
            obscure: obs3,
            toggleObscure: toggleObs3,
            validator: (v) => ValidationHelper.validateMultiple(v, [
              (val) => ValidationHelper.validateOptionalMinLength(
                val,
                8,
                "Ulangi Password Baru",
              ),
              (val) {
                if (val != passBaruController.text) {
                  return "Password baru tidak sama";
                }
                return null;
              },
            ]),
          ),

          SizedBox(height: 20),
          CustomButton(
            isLoading: isSaving,
            text: "Edit Profil",
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}
