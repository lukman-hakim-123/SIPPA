import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/rubrik.dart';
import '../../models/user.dart';
import '../../providers/rubrik_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/validation_helper.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/my_double_tap_exit.dart';

class FormRubrikScreen extends ConsumerStatefulWidget {
  final RubrikModel? rubrik;
  final User? murid;
  const FormRubrikScreen({super.key, this.rubrik, this.murid});

  @override
  ConsumerState<FormRubrikScreen> createState() => _FormRubrikScreenState();
}

class _FormRubrikScreenState extends ConsumerState<FormRubrikScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tujuanController = TextEditingController();
  final _kegiatanController = TextEditingController();
  final _agamaController = TextEditingController();
  final _jatiDiriController = TextEditingController();
  final _literasiController = TextEditingController();
  final _tanggalController = TextEditingController();
  final _umpanBalikController = TextEditingController();

  bool _isSubmitting = false;
  String skor = '1';

  @override
  void initState() {
    super.initState();
    if (widget.rubrik != null) {
      _agamaController.text = widget.rubrik!.agama;
      _jatiDiriController.text = widget.rubrik!.jatidiri;
      _literasiController.text = widget.rubrik!.literasi;
      _umpanBalikController.text = widget.rubrik!.rekomendasi;
      _tanggalController.text = widget.rubrik!.tanggal;
      _kegiatanController.text = widget.rubrik!.kegiatan;
      _tujuanController.text = widget.rubrik!.tujuan;
      skor = widget.rubrik!.skor;
    }
  }

  @override
  void dispose() {
    _agamaController.dispose();
    _jatiDiriController.dispose();
    _literasiController.dispose();
    _umpanBalikController.dispose();
    _tanggalController.dispose();
    _kegiatanController.dispose();
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
    final rubrikState = ref.watch(rubrikProvider);
    final isEdit = widget.rubrik != null;

    ref.listen<AsyncValue<List<RubrikModel>>>(rubrikProvider, (_, state) {
      state.when(
        data: (listRubrik) {
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
              final updated = listRubrik.firstWhere(
                (g) => g.id == widget.rubrik!.id,
                orElse: () => widget.rubrik!,
              );
              context.go('/detailRubrik', extra: updated.id);
            } else {
              context.go('/rubrik');
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
            text: isEdit ? 'Edit Rubrik' : 'Tambah Rubrik',
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
            onPressed: () => context.go('/rubrik'),
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
                  text: 'Tujuan Pembelajaran',
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 4),
                CustomDropdown<String>(
                  value: skor,
                  items: const [
                    DropdownMenuItem(
                      value: '1',
                      child: Text('Skor 1: Belum Mencapai Tujuan Pembelajaran'),
                    ),
                    DropdownMenuItem(
                      value: '2',
                      child: Text(
                        'Skor 2: Mencapai Tujuan Pembelajaran dengan Bantuan',
                      ),
                    ),
                    DropdownMenuItem(
                      value: '3',
                      child: Text(
                        'Skor 3: Mencapai Tujuan Pembelajaran Secara Mandiri',
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      skor = value!;
                    });
                  },
                  validator: (value) =>
                      ValidationHelper.validateNotEmpty(value, 'Skor'),
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
                  hintText: 'Agama dan Budi Pekerti',
                  validator: (value) => ValidationHelper.validateNotEmpty(
                    value,
                    'Agama dan Budi Pekerti',
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
                  onPressed: rubrikState.isLoading || _isSubmitting
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
                              final RubrikModel updatedModel = RubrikModel(
                                id: widget.rubrik!.id,
                                sekolah: profile.sekolah,
                                kelompok: profile.kelompok,
                                tujuan: _tujuanController.text,
                                tanggal: _tanggalController.text,
                                literasi: _literasiController.text,
                                uid: profile.id,
                                muridId: widget.rubrik!.muridId,
                                tanggapan: '',
                                kegiatan: '',
                                skor: skor,
                                agama: _agamaController.text,
                                jatidiri: _jatiDiriController.text,
                                rekomendasi: _umpanBalikController.text,
                              );
                              ref
                                  .read(rubrikProvider.notifier)
                                  .updateRubrik(updatedModel);
                            } else {
                              final RubrikModel rubrik = RubrikModel(
                                tujuan: _tujuanController.text,
                                tanggal: _tanggalController.text,
                                literasi: _literasiController.text,
                                kelompok: widget.murid!.kelompok,
                                uid: profile.id,
                                id: '',
                                muridId: widget.murid!.id,
                                tanggapan: '',
                                sekolah: widget.murid!.sekolah,
                                kegiatan: '',
                                skor: skor,
                                agama: _agamaController.text,
                                jatidiri: _jatiDiriController.text,
                                rekomendasi: _umpanBalikController.text,
                              );

                              ref
                                  .read(rubrikProvider.notifier)
                                  .createRubrik(rubrik);
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
