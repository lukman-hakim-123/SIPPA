import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/user.dart';
import '../../providers/murid_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/validation_helper.dart';
import '../../widgets/form/avatar_picker.dart';
import '../../widgets/common/snackbar_helper.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/form/labeled_text_field.dart';
import '../../widgets/my_double_tap_exit.dart';
import '../../widgets/form/password_field.dart';

class FormMuridScreen extends ConsumerStatefulWidget {
  final User? murid;
  const FormMuridScreen({super.key, this.murid});

  @override
  ConsumerState<FormMuridScreen> createState() => _FormMuridScreenState();
}

class _FormMuridScreenState extends ConsumerState<FormMuridScreen> {
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
    if (widget.murid != null) {
      _namaController.text = widget.murid!.nama;
      _kelasController.text = widget.murid!.kelompok;
      _emailController.text = widget.murid!.email;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _kelasController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ulangiPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _pickedImage = File(pickedFile.path));
    }
  }

  void _handleMuridState(AsyncValue<List<User>> state, bool isEdit) {
    state.when(
      data: (listMurid) {
        if (!_isSubmitting) return;
        setState(() => _isSubmitting = false);
        SnackbarHelper.show(
          context,
          isEdit ? 'Murid berhasil diperbarui' : 'Murid berhasil ditambahkan',
        );
        final id = widget.murid?.id;
        context.go(isEdit ? '/detailMurid' : '/murid', extra: id);
      },
      error: (err, _) {
        if (!_isSubmitting) return;
        setState(() => _isSubmitting = false);
        SnackbarHelper.show(context, 'Gagal menyimpan: $err');
      },
      loading: () {},
    );
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final isEdit = widget.murid != null;
    if (!isEdit && _pickedImage == null) {
      SnackbarHelper.show(context, 'Foto belum dipilih');
      return;
    }

    final profile = ref.read(userProvider).value;
    if (profile == null) {
      SnackbarHelper.show(context, 'Profile belum dimuat');
      return;
    }

    setState(() => _isSubmitting = true);

    if (isEdit) {
      final updatedMurid = User(
        id: widget.murid!.id,
        email: widget.murid!.email,
        imageId: widget.murid!.imageId,
        levelUser: 3,
        nama: _namaController.text,
        sekolah: profile.sekolah,
        kelompok: profile.levelUser == 1 || profile.levelUser == 0
            ? _kelasController.text
            : profile.kelompok,
      );
      ref
          .read(muridProvider.notifier)
          .updateMurid(updatedMurid, widget.murid!, _pickedImage);
    } else {
      ref
          .read(muridProvider.notifier)
          .createMurid(
            _namaController.text,
            _emailController.text,
            _passwordController.text,
            profile.sekolah,
            profile.kelompok,
            _pickedImage!,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final muridState = ref.watch(muridProvider);
    final url = ref.read(muridProvider.notifier).getPublicImageUrl;
    final isEdit = widget.murid != null;

    final profile = ref.watch(userProvider).value;
    if (profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    ref.listen<AsyncValue<List<User>>>(
      muridProvider,
      (_, state) => _handleMuridState(state, isEdit),
    );

    return MyDoubleTapExit(
      child: Scaffold(
        appBar: CustomAppBar(
          title: isEdit ? 'Edit Murid' : 'Tambah Murid',
          showBack: true,
          onBack: () => context.go(
            isEdit ? '/detailMurid' : '/murid',
            extra: isEdit ? widget.murid!.id : null,
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
                  imageUrl: isEdit && widget.murid!.imageId != ''
                      ? url(widget.murid!.imageId)
                      : null,
                  isEdit: isEdit,
                  onPickImage: _pickImage,
                ),
                const SizedBox(height: 10),
                LabeledTextField(
                  icon: Icons.person,
                  label: 'Nama Murid',
                  controller: _namaController,
                  validator: (v) =>
                      ValidationHelper.validateNotEmpty(v, 'Nama Murid'),
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
                if (isEdit &&
                    (profile.levelUser == 1 || profile.levelUser == 0)) ...[
                  LabeledTextField(
                    icon: Icons.school,
                    label: 'Kelas',
                    controller: _kelasController,
                    validator: (value) =>
                        ValidationHelper.validateNotEmpty(value, 'Kelas'),
                  ),
                ],
                CustomButton(
                  onPressed: muridState.isLoading || _isSubmitting
                      ? null
                      : _onSubmit,
                  isLoading: _isSubmitting,
                  text: isEdit ? 'Edit Data Murid' : 'Tambah Data Murid',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
