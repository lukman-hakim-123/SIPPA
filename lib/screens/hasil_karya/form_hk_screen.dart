import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../models/hk.dart';
import '../../models/user.dart';
import '../../providers/hk_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/validation_helper.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/my_double_tap_exit.dart';

class FormHkScreen extends ConsumerStatefulWidget {
  final HkModel? hk;
  final User? murid;
  const FormHkScreen({super.key, this.hk, this.murid});

  @override
  ConsumerState<FormHkScreen> createState() => _FormHkScreenState();
}

class _FormHkScreenState extends ConsumerState<FormHkScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nilaiController = TextEditingController();
  final _jatiDiriController = TextEditingController();
  final _literasiController = TextEditingController();
  final _rekomendasiController = TextEditingController();
  final _tanggalController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _tujuanController = TextEditingController();
  File? _pickedImage;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.hk != null) {
      _nilaiController.text = widget.hk!.nilai;
      _jatiDiriController.text = widget.hk!.jatiDiri;
      _literasiController.text = widget.hk!.literasi;
      _rekomendasiController.text = widget.hk!.rekomendasi;
      _tanggalController.text = widget.hk!.tanggal;
      _deskripsiController.text = widget.hk!.deskripsi;
      _tujuanController.text = widget.hk!.semester;
    }
  }

  @override
  void dispose() {
    _nilaiController.dispose();
    _jatiDiriController.dispose();
    _literasiController.dispose();
    _rekomendasiController.dispose();
    _tanggalController.dispose();
    _deskripsiController.dispose();
    _tujuanController.dispose();
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

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final formatted = DateFormat('dd-MM-yyyy').format(picked);
      setState(() {
        _tanggalController.text = formatted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hkState = ref.watch(hkProvider);
    final url = ref.read(hkProvider.notifier).getPublicImageUrl;
    final isEdit = widget.hk != null;

    ref.listen<AsyncValue<List<HkModel>>>(hkProvider, (_, state) {
      state.when(
        data: (listHk) {
          if (_isSubmitting) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: CustomText(
                  text: isEdit
                      ? 'Hasil Karya berhasil diperbarui'
                      : 'Hasil Karya berhasil ditambahkan',
                  color: Colors.white,
                ),
              ),
            );
            setState(() => _isSubmitting = false);

            if (isEdit) {
              final updatedHk = listHk.firstWhere(
                (g) => g.id == widget.hk!.id,
                orElse: () => widget.hk!,
              );
              context.go('/detailHk', extra: updatedHk.id);
            } else {
              context.go('/hk');
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
            text: isEdit ? 'Edit Hasil Karya' : 'Tambah Hasil Karya',
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
            onPressed: () => context.go('/hk'),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        color: Colors.grey[300],
                      ),
                      child: _pickedImage != null
                          ? Image.file(
                              _pickedImage!,
                              fit: BoxFit.scaleDown,
                              width: double.infinity,
                              height: double.infinity,
                            )
                          : isEdit && widget.hk!.imageId.isNotEmpty
                          ? Image.network(
                              url(widget.hk!.imageId),
                              fit: BoxFit.scaleDown,
                              width: double.infinity,
                              height: double.infinity,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.broken_image,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                            )
                          : const Icon(
                              Icons.image,
                              size: 50,
                              color: Colors.grey,
                            ),
                    ),
                    const SizedBox(height: 12),
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
                CustomText(text: 'Tanggal', fontWeight: FontWeight.bold),
                const SizedBox(height: 4),
                CustomTextFormField(
                  controller: _tanggalController,
                  hintText: 'Tanggal',
                  readOnly: true,
                  suffixIcon: const Icon(Icons.date_range, color: Colors.grey),
                  onTap: _pickDate,
                  validator: (value) =>
                      ValidationHelper.validateNotEmpty(value, 'Tanggal'),
                ),
                const SizedBox(height: 10),
                CustomText(text: 'Kegiatan', fontWeight: FontWeight.bold),
                CustomTextFormField(
                  controller: _deskripsiController,
                  hintText: 'Kegiatan',
                  minLines: 2,
                  validator: (value) =>
                      ValidationHelper.validateNotEmpty(value, 'Kegiatan'),
                ),
                const SizedBox(height: 10),

                CustomText(
                  text: 'Tujuan Pembelajaran',
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 4),

                CustomTextFormField(
                  controller: _tujuanController,
                  hintText: 'Tujuan Pembelajaran',
                  minLines: 2,
                  validator: (value) => ValidationHelper.validateNotEmpty(
                    value,
                    'Tujuan Pembelajaran',
                  ),
                ),
                const SizedBox(height: 10),

                CustomText(
                  text: 'Nilai Agama dan Budi Pekerti',
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 4),

                CustomTextFormField(
                  controller: _nilaiController,
                  minLines: 2,
                  hintText: 'Nilai Agama dan Budi Pekerti',
                  validator: (value) => ValidationHelper.validateNotEmpty(
                    value,
                    'Nilai Agama dan Budi Pekerti',
                  ),
                ),
                const SizedBox(height: 10),

                CustomText(text: 'Jati Diri', fontWeight: FontWeight.bold),
                const SizedBox(height: 4),

                CustomTextFormField(
                  controller: _jatiDiriController,
                  hintText: 'Jati Diri',
                  minLines: 2,
                  validator: (value) =>
                      ValidationHelper.validateNotEmpty(value, 'Jati Diri'),
                ),
                const SizedBox(height: 10),

                CustomText(
                  text: 'Literasi dan STEAM',
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 4),

                CustomTextFormField(
                  controller: _literasiController,
                  hintText: 'Literasi dan STEAM',
                  minLines: 2,
                  validator: (value) => ValidationHelper.validateNotEmpty(
                    value,
                    'Literasi dan STEAM',
                  ),
                ),
                const SizedBox(height: 10),
                CustomText(text: 'Umpan Balik', fontWeight: FontWeight.bold),
                const SizedBox(height: 4),
                CustomTextFormField(
                  controller: _rekomendasiController,
                  hintText: 'Umpan Balik',
                  minLines: 2,
                  validator: (value) =>
                      ValidationHelper.validateNotEmpty(value, 'Umpan Balik'),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  onPressed: hkState.isLoading || _isSubmitting
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
                              final HkModel updatedModel = HkModel(
                                id: widget.hk!.id,
                                imageId: widget.hk!.imageId,
                                sekolah: profile.sekolah,
                                kelompok: profile.kelompok,
                                deskripsi: _deskripsiController.text,
                                semester: _tujuanController.text,
                                tanggal: _tanggalController.text,
                                nilai: _nilaiController.text,
                                jatiDiri: _jatiDiriController.text,
                                literasi: _literasiController.text,
                                rekomendasi: _rekomendasiController.text,
                                uid: profile.id,
                                muridId: widget.hk!.muridId,
                                tanggapan: '',
                              );
                              ref
                                  .read(hkProvider.notifier)
                                  .updateHk(
                                    updatedModel,
                                    widget.hk!,
                                    _pickedImage,
                                  );
                            } else {
                              final HkModel hk = HkModel(
                                deskripsi: _deskripsiController.text,
                                semester: _tujuanController.text,
                                tanggal: _tanggalController.text,
                                nilai: _nilaiController.text,
                                jatiDiri: _jatiDiriController.text,
                                literasi: _literasiController.text,
                                rekomendasi: _rekomendasiController.text,
                                kelompok: widget.murid!.kelompok,
                                imageId: '',
                                uid: profile.id,
                                id: '',
                                muridId: widget.murid!.id,
                                tanggapan: '',
                                sekolah: widget.murid!.sekolah,
                              );

                              ref
                                  .read(hkProvider.notifier)
                                  .createHk(hk, _pickedImage!);
                            }
                          }
                        },
                  isLoading: _isSubmitting,
                  text: isEdit ? 'Edit Hasil Karya' : 'Tambah Hasil Karya',
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
