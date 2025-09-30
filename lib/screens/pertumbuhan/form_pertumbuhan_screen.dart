import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/pertumbuhan.dart';
import '../../models/user.dart';
import '../../providers/pertumbuhan_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/validation_helper.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/my_double_tap_exit.dart';

class FormPertumbuhanScreen extends ConsumerStatefulWidget {
  final PertumbuhanModel? pertumbuhan;
  final User? murid;
  const FormPertumbuhanScreen({super.key, this.pertumbuhan, this.murid});

  @override
  ConsumerState<FormPertumbuhanScreen> createState() =>
      _FormPertumbuhanScreenState();
}

class _FormPertumbuhanScreenState extends ConsumerState<FormPertumbuhanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tinggiController = TextEditingController();
  final _beratController = TextEditingController();
  final _lingkarController = TextEditingController();
  final _fisikController = TextEditingController();
  final _tanggalController = TextEditingController();
  final _umpanBalikController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.pertumbuhan != null) {
      _lingkarController.text = widget.pertumbuhan!.kepala.toString();
      _fisikController.text = widget.pertumbuhan!.fisik;
      _umpanBalikController.text = widget.pertumbuhan!.rekomendasi;
      _tanggalController.text = widget.pertumbuhan!.tanggal;
      _beratController.text = widget.pertumbuhan!.berat.toString();
      _tinggiController.text = widget.pertumbuhan!.tinggi.toString();
    }
  }

  @override
  void dispose() {
    _lingkarController.dispose();
    _fisikController.dispose();
    _umpanBalikController.dispose();
    _tanggalController.dispose();
    _beratController.dispose();
    _tinggiController.dispose();
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
    final pertumbuhanState = ref.watch(pertumbuhanProvider);
    final isEdit = widget.pertumbuhan != null;

    ref.listen<AsyncValue<List<PertumbuhanModel>>>(pertumbuhanProvider, (
      _,
      state,
    ) {
      state.when(
        data: (listPertumbuhan) {
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
              final updated = listPertumbuhan.firstWhere(
                (g) => g.id == widget.pertumbuhan!.id,
                orElse: () => widget.pertumbuhan!,
              );
              context.go('/detailPertumbuhan', extra: updated.id);
            } else {
              context.go('/pertumbuhan');
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
            text: isEdit ? 'Edit Pertumbuhan Anak' : 'Tambah Pertumbuhan Anak',
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
            onPressed: () => context.go('/pertumbuhan'),
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
                  text: 'Tinggi Badan (cm)',
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 4),
                CustomTextFormField(
                  controller: _tinggiController,
                  keyboardType: TextInputType.number,
                  hintText: 'Tinggi Badan (cm)',
                  suffix: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: CustomText(
                      text: "cm",
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  validator: (value) =>
                      ValidationHelper.validateMultiple(value, [
                        (val) => ValidationHelper.validateNotEmpty(
                          value,
                          'Tinggi Badan',
                        ),
                        (val) => ValidationHelper.validateNumberOnly(
                          value,
                          'Tinggi Badan',
                        ),
                      ]),
                ),
                const SizedBox(height: 10),
                CustomText(
                  text: 'Berat Badan (kg)',
                  fontWeight: FontWeight.bold,
                ),
                CustomTextFormField(
                  controller: _beratController,
                  keyboardType: TextInputType.number,
                  hintText: 'Berat Badan (kg)',
                  suffix: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: CustomText(
                      text: "kg",
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  validator: (value) =>
                      ValidationHelper.validateMultiple(value, [
                        (val) => ValidationHelper.validateNotEmpty(
                          value,
                          'Berat Badan',
                        ),
                        (val) => ValidationHelper.validateNumberOnly(
                          value,
                          'Berat Badan',
                        ),
                      ]),
                ),
                const SizedBox(height: 10),
                CustomText(text: 'Lingkar Kepala', fontWeight: FontWeight.bold),
                const SizedBox(height: 4),

                CustomTextFormField(
                  controller: _lingkarController,
                  keyboardType: TextInputType.number,
                  suffix: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: CustomText(
                      text: "cm",
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  hintText: 'Lingkar Kepala (cm)',
                  validator: (value) =>
                      ValidationHelper.validateMultiple(value, [
                        (val) => ValidationHelper.validateNotEmpty(
                          value,
                          'Lingkar Kepala',
                        ),
                        (val) => ValidationHelper.validateNumberOnly(
                          value,
                          'Lingkar Kepala',
                        ),
                      ]),
                ),
                const SizedBox(height: 10),

                CustomText(
                  text: 'Deskripsi Fisik',
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 4),

                CustomTextFormField(
                  controller: _fisikController,
                  hintText: 'Deskripsi Fisik',
                  minLines: 2,
                  validator: (value) => ValidationHelper.validateNotEmpty(
                    value,
                    'Deskripsi Fisik',
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
                  onPressed: pertumbuhanState.isLoading || _isSubmitting
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
                              final PertumbuhanModel
                              updatedModel = PertumbuhanModel(
                                id: widget.pertumbuhan!.id,
                                sekolah: profile.sekolah,
                                kelompok: profile.kelompok,
                                tinggi:
                                    int.tryParse(_tinggiController.text) ?? 0,
                                tanggal: _tanggalController.text,
                                uid: profile.id,
                                muridId: widget.pertumbuhan!.muridId,
                                tanggapan: '',
                                berat: int.tryParse(_beratController.text) ?? 0,
                                kepala:
                                    int.tryParse(_lingkarController.text) ?? 0,
                                fisik: _fisikController.text,
                                rekomendasi: _umpanBalikController.text,
                              );
                              ref
                                  .read(pertumbuhanProvider.notifier)
                                  .updatePertumbuhan(updatedModel);
                            } else {
                              final PertumbuhanModel
                              pertumbuhan = PertumbuhanModel(
                                tinggi:
                                    int.tryParse(_tinggiController.text) ?? 0,
                                tanggal: _tanggalController.text,
                                kelompok: widget.murid!.kelompok,
                                uid: profile.id,
                                id: '',
                                muridId: widget.murid!.id,
                                tanggapan: '',
                                sekolah: widget.murid!.sekolah,
                                berat: int.tryParse(_beratController.text) ?? 0,
                                kepala:
                                    int.tryParse(_lingkarController.text) ?? 0,
                                fisik: _fisikController.text,
                                rekomendasi: _umpanBalikController.text,
                              );

                              ref
                                  .read(pertumbuhanProvider.notifier)
                                  .createPertumbuhan(pertumbuhan);
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
