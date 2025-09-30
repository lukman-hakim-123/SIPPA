import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/user.dart';
import '../../providers/admin_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/validation_helper.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/my_double_tap_exit.dart';

class FormAdminScreen extends ConsumerStatefulWidget {
  final User? admin;
  const FormAdminScreen({super.key, this.admin});

  @override
  ConsumerState<FormAdminScreen> createState() => _FormAdminScreenState();
}

class _FormAdminScreenState extends ConsumerState<FormAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _sekolahController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordLamaController = TextEditingController();
  final _ulangiPasswordBaruController = TextEditingController();
  File? _pickedImage;
  bool _isSubmitting = false;
  bool _obscure = true;
  bool _obscure2 = true;

  @override
  void initState() {
    super.initState();
    if (widget.admin != null) {
      _namaController.text = widget.admin!.nama;
      _emailController.text = widget.admin!.email;
      _sekolahController.text = widget.admin!.sekolah;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _sekolahController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final newImage = File(pickedFile.path);
      setState(() {
        _pickedImage = newImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final userState = ref.watch(userProvider);
    final adminState = ref.watch(adminProvider);
    final url = ref.read(adminProvider.notifier).getPublicImageUrl;
    final isEdit = widget.admin != null;

    ref.listen<AsyncValue<List<User>>>(adminProvider, (_, state) {
      state.when(
        data: (listadmin) {
          if (_isSubmitting) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: CustomText(
                  text: isEdit
                      ? 'Data admin berhasil diperbarui'
                      : 'Data admin berhasil ditambahkan',
                  color: Colors.white,
                ),
              ),
            );
            setState(() => _isSubmitting = false);

            if (isEdit) {
              final updatedadmin = listadmin.firstWhere(
                (g) => g.id == widget.admin!.id,
                orElse: () => widget.admin!,
              );
              context.go('/detailAdmin', extra: updatedadmin);
            } else {
              context.go('/admin');
            }
          }
        },
        error: (err, _) {
          if (_isSubmitting) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: CustomText(
                  text: 'Gagal menyimpan: $err',
                  color: Colors.white,
                ),
              ),
            );
            setState(() => _isSubmitting = false);
          }
        },
        loading: () {},
      );
    });

    return MyDoubleTapExit(
      child: Scaffold(
        appBar: AppBar(
          title: CustomText(
            text: isEdit ? 'Edit Admin' : 'Tambah Admin',
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
          backgroundColor: AppColors.primary,
          elevation: 0.0,
          automaticallyImplyLeading: false,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go('/admin'),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 53,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        child: _pickedImage != null
                            ? ClipOval(
                                child: Image.file(
                                  _pickedImage!,
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                ),
                              )
                            : isEdit && widget.admin!.imageId.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  url(widget.admin!.imageId),
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white,
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                      ),
                      onPressed: _pickImage,
                      child: CustomText(
                        text: isEdit ? 'Ganti Foto' : 'Tambah Foto',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.person, size: 25.0),
                    CustomText(text: 'Nama Admin', fontWeight: FontWeight.bold),
                  ],
                ),
                const SizedBox(height: 4.0),
                CustomTextFormField(
                  controller: _namaController,
                  hintText: 'Nama Admin',
                  validator: (value) =>
                      ValidationHelper.validateNotEmpty(value, 'Nama Admin'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.email, size: 25.0),
                    CustomText(text: 'Email', fontWeight: FontWeight.bold),
                  ],
                ),
                const SizedBox(height: 4.0),
                CustomTextFormField(
                  controller: _emailController,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  readOnly: isEdit,
                  validator: (value) => ValidationHelper.validateEmail(value),
                ),
                const SizedBox(height: 10),
                isEdit
                    ? Container()
                    : Row(
                        children: [
                          Icon(Icons.lock, size: 25),
                          CustomText(
                            text: 'Password',
                            fontWeight: FontWeight.bold,
                          ),
                        ],
                      ),
                const SizedBox(height: 4),
                isEdit
                    ? Container()
                    : CustomTextFormField(
                        controller: _passwordLamaController,
                        obscureText: _obscure,
                        maxLines: 1,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                        validator: (value) => ValidationHelper.validateMultiple(
                          value,
                          [
                            if (isEdit)
                              (v) =>
                                  ValidationHelper.validatePasswordOnEmailChange(
                                    v,
                                    widget.admin!.email,
                                    _emailController.text,
                                  ),
                            (v) => ValidationHelper.validateNotEmpty(
                              v,
                              'Password',
                            ),
                            (v) => ValidationHelper.validateOptionalMinLength(
                              v,
                              8,
                              'Password',
                            ),
                          ],
                        ),
                      ),
                isEdit ? Container() : const SizedBox(height: 10),
                isEdit
                    ? Container()
                    : Row(
                        children: [
                          Icon(Icons.lock, size: 25),
                          CustomText(
                            text: 'Ulangi Password',
                            fontWeight: FontWeight.bold,
                          ),
                        ],
                      ),
                isEdit ? Container() : const SizedBox(height: 10),
                isEdit
                    ? Container()
                    : CustomTextFormField(
                        controller: _ulangiPasswordBaruController,
                        obscureText: _obscure2,
                        maxLines: 1,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure2 ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () =>
                              setState(() => _obscure2 = !_obscure2),
                        ),
                        validator: (value) =>
                            ValidationHelper.validateMultiple(value, [
                              (v) => ValidationHelper.validateOptionalMinLength(
                                v,
                                8,
                                'Ulangi Password',
                              ),
                              (v) {
                                if (v != _passwordLamaController.text &&
                                    !isEdit) {
                                  return 'Password tidak sama';
                                }
                                return null;
                              },
                            ]),
                      ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Icon(Icons.location_city, size: 25.0),
                    CustomText(
                      text: 'Nama Sekolah',
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),
                CustomTextFormField(
                  controller: _sekolahController,
                  hintText: 'Nama Sekolah',
                  validator: (value) =>
                      ValidationHelper.validateNotEmpty(value, 'Nama Sekolah'),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  onPressed: adminState.isLoading || _isSubmitting
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _isSubmitting = true);
                            if (isEdit) {
                              final User updatedModel = User(
                                id: widget.admin!.id,
                                email: widget.admin!.email,
                                imageId: widget.admin!.imageId,
                                levelUser: 1,
                                nama: _namaController.text,
                                sekolah: _sekolahController.text,
                                kelompok: widget.admin!.kelompok,
                              );
                              ref
                                  .read(adminProvider.notifier)
                                  .updateAdmin(
                                    updatedModel,
                                    widget.admin!,
                                    _pickedImage,
                                  );
                            } else {
                              ref
                                  .read(adminProvider.notifier)
                                  .createAdmin(
                                    _namaController.text,
                                    _emailController.text,
                                    _passwordLamaController.text,
                                    _sekolahController.text,
                                    _pickedImage,
                                  );
                            }
                          }
                        },
                  isLoading: _isSubmitting,
                  text: isEdit ? 'Edit Data Admin' : 'Tambah Data Admin',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
