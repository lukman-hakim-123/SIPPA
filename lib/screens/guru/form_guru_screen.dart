import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/user.dart';
import '../../providers/guru_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/validation_helper.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/form/avatar_picker.dart';
import '../../widgets/common/snackbar_helper.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/form/labeled_text_field.dart';
import '../../widgets/my_double_tap_exit.dart';
import '../../widgets/form/password_field.dart';

class FormGuruScreen extends ConsumerStatefulWidget {
  final User? guru;
  const FormGuruScreen({super.key, this.guru});

  @override
  ConsumerState<FormGuruScreen> createState() => _FormGuruScreenState();
}

class _FormGuruScreenState extends ConsumerState<FormGuruScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _kelasController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ulangiPasswordController = TextEditingController();
  File? _pickedImage;
  bool _isSubmitting = false;
  bool _obscure = true;
  bool _obscure2 = true;

  @override
  void initState() {
    super.initState();
    if (widget.guru != null) {
      _namaController.text = widget.guru!.nama;
      _kelasController.text = widget.guru!.kelompok;
      _emailController.text = widget.guru!.email;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _kelasController.dispose();
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

  void _handleGuruState(
    BuildContext context,
    AsyncValue<List<User>> state,
    bool isEdit,
  ) {
    state.when(
      data: (listguru) {
        if (!_isSubmitting) return;

        SnackbarHelper.show(
          context,
          isEdit
              ? 'Data guru berhasil diperbarui'
              : 'Data guru berhasil ditambahkan',
        );

        setState(() => _isSubmitting = false);

        if (isEdit) {
          final updatedguru = listguru.firstWhere(
            (g) => g.id == widget.guru!.id,
            orElse: () => widget.guru!,
          );
          context.go('/detailGuru', extra: updatedguru.id);
        } else {
          context.go('/guru');
        }
      },
      error: (err, _) {
        if (!_isSubmitting) return;
        SnackbarHelper.show(context, "Gagal menyimpan: $err");
        setState(() => _isSubmitting = false);
      },
      loading: () {},
    );
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      final isEdit = widget.guru != null;

      if (!isEdit && _pickedImage == null) {
        SnackbarHelper.show(context, 'Foto belum dipilih');
        return;
      }

      setState(() => _isSubmitting = true);

      final profile = ref.read(userProvider).value;
      if (profile == null) {
        SnackbarHelper.show(context, 'Profile belum dimuat');
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
          kelompok: _kelasController.text,
        );

        ref
            .read(guruProvider.notifier)
            .updateGuru(updatedModel, widget.guru!, _pickedImage);
      } else {
        ref
            .read(guruProvider.notifier)
            .createGuru(
              _namaController.text,
              _emailController.text,
              _passwordController.text,
              profile.sekolah,
              _kelasController.text,
              _pickedImage!,
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final guruState = ref.watch(guruProvider);
    final url = ref.read(guruProvider.notifier).getPublicImageUrl;
    final isEdit = widget.guru != null;

    ref.listen<AsyncValue<List<User>>>(
      guruProvider,
      (previous, next) => _handleGuruState(context, next, isEdit),
    );
    return MyDoubleTapExit(
      child: Scaffold(
        appBar: CustomAppBar(
          title: isEdit ? 'Edit Guru' : 'Tambah Guru',
          showBack: true,
          onBack: () => context.go(
            isEdit ? '/detailGuru' : '/guru',
            extra: isEdit ? widget.guru!.id : null,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                AvatarPicker(
                  pickedImage: _pickedImage,
                  imageUrl: isEdit && widget.guru!.imageId != ''
                      ? url(widget.guru!.imageId)
                      : null,
                  isEdit: isEdit,
                  onPickImage: _pickImage,
                ),
                const SizedBox(height: 10),
                LabeledTextField(
                  icon: Icons.person,
                  label: 'Nama Guru',
                  controller: _namaController,
                  validator: (value) =>
                      ValidationHelper.validateNotEmpty(value, 'Nama Guru'),
                ),

                LabeledTextField(
                  icon: Icons.email,
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  readOnly: isEdit,
                  validator: (value) => ValidationHelper.validateEmail(value),
                ),

                if (!isEdit) ...[
                  PasswordField(
                    label: 'Password',
                    controller: _passwordController,
                    obscure: _obscure,
                    toggleObscure: () => setState(() => _obscure = !_obscure),
                    validator: (v) =>
                        ValidationHelper.validateMinLength(v, 8, 'Password'),
                  ),
                  const SizedBox(height: 12),
                  PasswordField(
                    label: 'Ulangi Password',
                    controller: _ulangiPasswordController,
                    obscure: _obscure2,
                    toggleObscure: () => setState(() => _obscure2 = !_obscure2),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Ulangi Password tidak boleh kosong';
                      }
                      if (v != _passwordController.text) {
                        return 'Password tidak sesuai';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                ],

                LabeledTextField(
                  icon: Icons.school,
                  label: 'Kelas',
                  controller: _kelasController,
                  validator: (value) =>
                      ValidationHelper.validateNotEmpty(value, 'Kelas'),
                ),

                const SizedBox(height: 24),

                CustomButton(
                  onPressed: guruState.isLoading || _isSubmitting
                      ? null
                      : _onSubmit,
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
