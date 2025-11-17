import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/user.dart';
import '../../providers/admin_provider.dart';
import '../../utils/validation_helper.dart';
import '../../widgets/avatar_picker.dart';
import '../../widgets/common/snackbar_helper.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/labeled_text_field.dart';
import '../../widgets/my_double_tap_exit.dart';
import '../../widgets/password_field.dart';

class FormAdminScreen extends ConsumerStatefulWidget {
  final User? admin;
  const FormAdminScreen({super.key, this.admin});

  @override
  ConsumerState<FormAdminScreen> createState() => _FormAdminScreenState();
}

class _FormAdminScreenState extends ConsumerState<FormAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _sekolahController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ulangiPasswordController = TextEditingController();
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _pickedImage = File(pickedFile.path));
    }
  }

  void _handleAdminState(AsyncValue<List<User>> state, bool isEdit) {
    state.when(
      data: (listAdmin) {
        if (!_isSubmitting) return;
        setState(() => _isSubmitting = false);
        SnackbarHelper.show(
          context,
          isEdit ? 'Admin berhasil diperbarui' : 'Admin berhasil ditambahkan',
        );
        context.go(isEdit ? '/detailAdmin' : '/admin', extra: widget.admin?.id);
      },
      error: (e, _) {
        if (!_isSubmitting) return;
        setState(() => _isSubmitting = false);
        SnackbarHelper.show(context, 'Gagal menyimpan: $e');
      },
      loading: () {},
    );
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    final isEdit = widget.admin != null;
    setState(() => _isSubmitting = true);

    if (isEdit) {
      final updatedAdmin = User(
        kelompok: '',
        id: widget.admin!.id,
        email: widget.admin!.email,
        imageId: widget.admin!.imageId,
        levelUser: 1,
        nama: _namaController.text,
        sekolah: _sekolahController.text,
      );
      ref
          .read(adminProvider.notifier)
          .updateAdmin(updatedAdmin, widget.admin!, _pickedImage);
    } else {
      ref
          .read(adminProvider.notifier)
          .createAdmin(
            _namaController.text,
            _emailController.text,
            _passwordController.text,
            _sekolahController.text,
            _pickedImage,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final url = ref.read(adminProvider.notifier).getPublicImageUrl;
    final isEdit = widget.admin != null;

    ref.listen<AsyncValue<List<User>>>(
      adminProvider,
      (_, next) => _handleAdminState(next, isEdit),
    );

    return MyDoubleTapExit(
      child: Scaffold(
        appBar: CustomAppBar(
          title: isEdit ? 'Edit Admin' : 'Tambah Admin',
          showBack: true,
          onBack: () => context.go(
            isEdit ? '/detailAdmin' : '/admin',
            extra: widget.admin,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                AvatarPicker(
                  pickedImage: _pickedImage,
                  imageUrl: isEdit ? url(widget.admin!.imageId) : null,
                  isEdit: isEdit,
                  onPickImage: _pickImage,
                ),
                const SizedBox(height: 10),
                LabeledTextField(
                  icon: Icons.person,
                  label: 'Nama Admin',
                  controller: _namaController,
                  validator: (v) =>
                      ValidationHelper.validateNotEmpty(v, 'Nama Admin'),
                ),
                LabeledTextField(
                  icon: Icons.email,
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  readOnly: isEdit,
                  validator: ValidationHelper.validateEmail,
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
                      if (v != _passwordController.text)
                        return 'Password tidak sama';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                LabeledTextField(
                  icon: Icons.school,
                  label: 'Sekolah',
                  controller: _sekolahController,
                  validator: (v) =>
                      ValidationHelper.validateNotEmpty(v, 'Sekolah'),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: isEdit ? 'Edit Data Admin' : 'Tambah Data Admin',
                  isLoading: _isSubmitting,
                  onPressed: adminState.isLoading || _isSubmitting
                      ? null
                      : _onSubmit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
