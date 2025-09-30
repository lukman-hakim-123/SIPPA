import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/user.dart';
import '../../providers/guru_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/validation_helper.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/my_double_tap_exit.dart';

class FormGuruScreen extends ConsumerStatefulWidget {
  final User? guru;
  const FormGuruScreen({super.key, this.guru});

  @override
  ConsumerState<FormGuruScreen> createState() => _FormGuruScreenState();
}

class _FormGuruScreenState extends ConsumerState<FormGuruScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
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
    if (widget.guru != null) {
      _namaController.text = widget.guru!.nama;
      _emailController.text = widget.guru!.email;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
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
    final guruState = ref.watch(guruProvider);
    final url = ref.read(guruProvider.notifier).getPublicImageUrl;
    final isEdit = widget.guru != null;

    ref.listen<AsyncValue<List<User>>>(guruProvider, (_, state) {
      state.when(
        data: (listguru) {
          if (_isSubmitting) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: CustomText(
                  text: isEdit
                      ? 'Data guru berhasil diperbarui'
                      : 'Data guru berhasil ditambahkan',
                  color: Colors.white,
                ),
              ),
            );
            setState(() => _isSubmitting = false);

            if (isEdit) {
              final updatedguru = listguru.firstWhere(
                (g) => g.id == widget.guru!.id,
                orElse: () => widget.guru!,
              );
              context.go('/detailGuru', extra: updatedguru);
            } else {
              context.go('/guru');
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
            text: isEdit ? 'Edit Guru' : 'Tambah Guru',
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
            onPressed: () => context.go('/guru'),
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
                            : isEdit && widget.guru!.imageId.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  url(widget.guru!.imageId),
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
                    CustomText(text: 'Nama Guru', fontWeight: FontWeight.bold),
                  ],
                ),
                const SizedBox(height: 4.0),
                CustomTextFormField(
                  controller: _namaController,
                  hintText: 'Nama Guru',
                  validator: (value) =>
                      ValidationHelper.validateNotEmpty(value, 'Nama Guru'),
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
                                    widget.guru!.email,
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
                const SizedBox(height: 24),
                CustomButton(
                  onPressed: guruState.isLoading || _isSubmitting
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            if (!isEdit && _pickedImage == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: CustomText(
                                    text: 'Foto belum dipilih',
                                    color: Colors.white,
                                  ),
                                ),
                              );
                              return;
                            }
                            setState(() => _isSubmitting = true);
                            final profile = ref.read(userProvider).value;
                            if (profile == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: CustomText(
                                    text: 'Profile belum dimuat',
                                    color: Colors.white,
                                  ),
                                ),
                              );
                              return;
                            }
                            if (isEdit) {
                              final User updatedModel = User(
                                id: widget.guru!.id,
                                email: widget.guru!.email,
                                imageId: widget.guru!.imageId,
                                levelUser: 2,
                                nama: _namaController.text,
                                sekolah: profile.sekolah,
                                kelompok: profile.kelompok,
                              );
                              ref
                                  .read(guruProvider.notifier)
                                  .updateGuru(
                                    updatedModel,
                                    widget.guru!,
                                    _pickedImage,
                                  );
                            } else {
                              ref
                                  .read(guruProvider.notifier)
                                  .createGuru(
                                    _namaController.text,
                                    _emailController.text,
                                    _passwordLamaController.text,
                                    profile.sekolah,
                                    profile.kelompok,
                                    _pickedImage!,
                                  );
                            }
                          }
                        },
                  isLoading: _isSubmitting,
                  text: isEdit ? 'Edit Data Guru' : 'Tambah Data Guru',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
