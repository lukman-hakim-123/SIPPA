import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../models/anekdot.dart';
import '../../models/user.dart';
import '../../providers/anekdot_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/validation_helper.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/my_double_tap_exit.dart';

class FormAnekdotScreen extends ConsumerStatefulWidget {
  final AnekdotModel? anekdot;
  final User? murid;
  const FormAnekdotScreen({super.key, this.anekdot, this.murid});

  @override
  ConsumerState<FormAnekdotScreen> createState() => _FormAnekdotScreenState();
}

class _FormAnekdotScreenState extends ConsumerState<FormAnekdotScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nilaiController = TextEditingController();
  final _jatiDiriController = TextEditingController();
  final _literasiController = TextEditingController();
  final _umpanBalikController = TextEditingController();
  final _tanggalController = TextEditingController();
  final _pengamatanController = TextEditingController();
  final _tujuanController = TextEditingController();
  File? _pickedImage;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.anekdot != null) {
      _nilaiController.text = widget.anekdot!.nilai;
      _jatiDiriController.text = widget.anekdot!.jatiDiri;
      _literasiController.text = widget.anekdot!.literasi;
      _umpanBalikController.text = widget.anekdot!.umpanBalik;
      _tanggalController.text = widget.anekdot!.tanggal;
      _pengamatanController.text = widget.anekdot!.pengamatan;
      _tujuanController.text = widget.anekdot!.tujuan;
    }
  }

  @override
  void dispose() {
    _nilaiController.dispose();
    _jatiDiriController.dispose();
    _literasiController.dispose();
    _umpanBalikController.dispose();
    _tanggalController.dispose();
    _pengamatanController.dispose();
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
    final anekdotState = ref.watch(anekdotProvider);
    final url = ref.read(anekdotProvider.notifier).getPublicImageUrl;
    final isEdit = widget.anekdot != null;

    ref.listen<AsyncValue<List<AnekdotModel>>>(anekdotProvider, (_, state) {
      state.when(
        data: (listAnekdot) {
          if (_isSubmitting) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: CustomText(
                  text: isEdit
                      ? 'Data anekdot berhasil diperbarui'
                      : 'Data anekdot berhasil ditambahkan',
                  color: Colors.white,
                ),
              ),
            );
            setState(() => _isSubmitting = false);

            if (isEdit) {
              final updatedAnekdot = listAnekdot.firstWhere(
                (g) => g.id == widget.anekdot!.id,
                orElse: () => widget.anekdot!,
              );
              context.go('/detailAnekdot', extra: updatedAnekdot.id);
            } else {
              context.go('/anekdot');
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
            text: isEdit ? 'Edit Anekdot' : 'Tambah Anekdot',
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
            onPressed: () => context.go('/anekdot'),
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
                          : isEdit && widget.anekdot!.imageId.isNotEmpty
                          ? Image.network(
                              url(widget.anekdot!.imageId),
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
                  controller: _pengamatanController,
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
                  controller: _umpanBalikController,
                  hintText: 'Umpan Balik',
                  minLines: 2,
                  validator: (value) =>
                      ValidationHelper.validateNotEmpty(value, 'Umpan Balik'),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  onPressed: anekdotState.isLoading || _isSubmitting
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
                              final AnekdotModel updatedModel = AnekdotModel(
                                id: widget.anekdot!.id,
                                imageId: widget.anekdot!.imageId,
                                sekolah: profile.sekolah,
                                kelompok: profile.kelompok,
                                pengamatan: _pengamatanController.text,
                                tujuan: _tujuanController.text,
                                tanggal: _tanggalController.text,
                                nilai: _nilaiController.text,
                                jatiDiri: _jatiDiriController.text,
                                literasi: _literasiController.text,
                                umpanBalik: _umpanBalikController.text,
                                uid: profile.id,
                                muridId: widget.anekdot!.muridId,
                                tanggapan: '',
                              );
                              ref
                                  .read(anekdotProvider.notifier)
                                  .updateAnekdot(
                                    updatedModel,
                                    widget.anekdot!,
                                    _pickedImage,
                                  );
                            } else {
                              final AnekdotModel anekdot = AnekdotModel(
                                pengamatan: _pengamatanController.text,
                                tujuan: _tujuanController.text,
                                tanggal: _tanggalController.text,
                                nilai: _nilaiController.text,
                                jatiDiri: _jatiDiriController.text,
                                literasi: _literasiController.text,
                                umpanBalik: _umpanBalikController.text,
                                kelompok: widget.murid!.kelompok,
                                imageId: '',
                                uid: profile.id,
                                id: '',
                                muridId: widget.murid!.id,
                                tanggapan: '',
                                sekolah: widget.murid!.sekolah,
                              );

                              ref
                                  .read(anekdotProvider.notifier)
                                  .createAnekdot(anekdot, _pickedImage!);
                            }
                          }
                        },
                  isLoading: _isSubmitting,
                  text: isEdit ? 'Edit Data Anekdot' : 'Tambah Data Anekdot',
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
