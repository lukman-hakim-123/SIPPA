import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/cp.dart';
import '../../models/user.dart';
import '../../providers/cp_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/validation_helper.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/my_double_tap_exit.dart';

class FormCpScreen extends ConsumerStatefulWidget {
  final CpModel? cp;
  final User? murid;
  const FormCpScreen({super.key, this.cp, this.murid});

  @override
  ConsumerState<FormCpScreen> createState() => _FormCpScreenState();
}

class _FormCpScreenState extends ConsumerState<FormCpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tujuanController = TextEditingController();
  final _konteksController = TextEditingController();
  final _agamaController = TextEditingController();
  final _jatiDiriController = TextEditingController();
  final _literasiController = TextEditingController();
  final _tanggalController = TextEditingController();
  final _umpanBalikController = TextEditingController();

  bool _isSubmitting = false;
  bool _isDone = false;

  @override
  void initState() {
    super.initState();
    if (widget.cp != null) {
      _agamaController.text = widget.cp!.agama;
      _jatiDiriController.text = widget.cp!.jatidiri;
      _literasiController.text = widget.cp!.literasi;
      _umpanBalikController.text = widget.cp!.rekomendasi;
      _tanggalController.text = widget.cp!.tanggal;
      _konteksController.text = widget.cp!.konteks;
      _tujuanController.text = widget.cp!.tujuan;
      _isDone = widget.cp!.isDone;
    }
  }

  @override
  void dispose() {
    _agamaController.dispose();
    _jatiDiriController.dispose();
    _literasiController.dispose();
    _umpanBalikController.dispose();
    _tanggalController.dispose();
    _konteksController.dispose();
    _tujuanController.dispose();
    super.dispose();
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
    final cpState = ref.watch(cpProvider);
    final isEdit = widget.cp != null;

    ref.listen<AsyncValue<List<CpModel>>>(cpProvider, (_, state) {
      state.when(
        data: (listCP) {
          if (_isSubmitting) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: CustomText(
                  text: isEdit
                      ? 'Data berhasil diperbarui'
                      : 'Data berhasil ditambahkan',
                  color: Colors.white,
                ),
              ),
            );
            setState(() => _isSubmitting = false);

            if (isEdit) {
              final updated = listCP.firstWhere(
                (g) => g.id == widget.cp!.id,
                orElse: () => widget.cp!,
              );
              context.go('/detailCp', extra: updated.id);
            } else {
              context.go('/cp');
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
            text: isEdit
                ? 'Edit Capaian Pembelajaran'
                : 'Tambah Capaian Pembelajaran',
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
          backgroundColor: AppColors.primary,
          elevation: 0.0,
          automaticallyImplyLeading: false,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go('/cp'),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  controller: _konteksController,
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
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isDone = false;
                        });
                      },
                      child: Row(
                        children: [
                          Radio(
                            value: false,
                            groupValue: _isDone,
                            onChanged: (value) {
                              setState(() {
                                _isDone = value!;
                              });
                            },
                          ),
                          const CustomText(text: 'Belum Muncul'),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isDone = true;
                        });
                      },
                      child: Row(
                        children: [
                          Radio(
                            value: true,
                            groupValue: _isDone,
                            onChanged: (value) {
                              setState(() {
                                _isDone = value!;
                              });
                            },
                          ),
                          const CustomText(text: 'Sudah Muncul'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                CustomText(
                  text: 'Nilai Agama dan Budi Pekerti',
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 4),

                CustomTextFormField(
                  controller: _agamaController,
                  minLines: 2,
                  hintText: 'agama Agama dan Budi Pekerti',
                  validator: (value) => ValidationHelper.validateNotEmpty(
                    value,
                    'agama Agama dan Budi Pekerti',
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
                  onPressed: cpState.isLoading || _isSubmitting
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
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
                              final CpModel updatedModel = CpModel(
                                id: widget.cp!.id,
                                sekolah: profile.sekolah,
                                kelompok: profile.kelompok,
                                tujuan: _tujuanController.text,
                                tanggal: _tanggalController.text,
                                literasi: _literasiController.text,
                                uid: profile.id,
                                muridId: widget.cp!.muridId,
                                tanggapan: '',
                                konteks: _konteksController.text,
                                isDone: _isDone,
                                agama: _agamaController.text,
                                jatidiri: _jatiDiriController.text,
                                rekomendasi: _umpanBalikController.text,
                              );
                              ref
                                  .read(cpProvider.notifier)
                                  .updateCp(updatedModel);
                            } else {
                              final CpModel cp = CpModel(
                                tujuan: _tujuanController.text,
                                tanggal: _tanggalController.text,
                                literasi: _literasiController.text,
                                kelompok: widget.murid!.kelompok,
                                uid: profile.id,
                                id: '',
                                muridId: widget.murid!.id,
                                tanggapan: '',
                                sekolah: widget.murid!.sekolah,
                                konteks: _konteksController.text,
                                isDone: _isDone,
                                agama: _agamaController.text,
                                jatidiri: _jatiDiriController.text,
                                rekomendasi: _umpanBalikController.text,
                              );

                              ref.read(cpProvider.notifier).createCp(cp);
                            }
                          }
                        },
                  isLoading: _isSubmitting,
                  text: isEdit ? 'Edit Data' : 'Tambah Data',
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
