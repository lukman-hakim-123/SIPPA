import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/rubrik.dart';
import '../../models/user.dart';
import '../../providers/rubrik_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/form/custom_input_field.dart';
import '../../widgets/form/custom_dropdown.dart';
import '../../widgets/common/snackbar_helper.dart';
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
  final _agamaController = TextEditingController();
  final _jatiController = TextEditingController();
  final _literasiController = TextEditingController();
  final _tanggalController = TextEditingController();
  final _umpanBalikController = TextEditingController();

  String skor = "1";
  bool _isSubmitting = false;

  bool get isEdit => widget.rubrik != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      final r = widget.rubrik!;
      _tujuanController.text = r.tujuan;
      _agamaController.text = r.agama;
      _jatiController.text = r.jatidiri;
      _literasiController.text = r.literasi;
      _tanggalController.text = r.tanggal;
      _umpanBalikController.text = r.rekomendasi;
      skor = r.skor;
    }
  }

  @override
  void dispose() {
    _tujuanController.dispose();
    _agamaController.dispose();
    _jatiController.dispose();
    _literasiController.dispose();
    _tanggalController.dispose();
    _umpanBalikController.dispose();
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
      setState(() => _tanggalController.text = formatted);
    }
  }

  Future<void> _handleSubmit(WidgetRef ref) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final profile = ref.read(userProvider).value;
    if (profile == null) {
      SnackbarHelper.show(context, "Profile belum dimuat");
      return;
    }

    final model = RubrikModel(
      id: isEdit ? widget.rubrik!.id : '',
      tujuan: _tujuanController.text,
      tanggal: _tanggalController.text,
      literasi: _literasiController.text,
      rekomendasi: _umpanBalikController.text,
      agama: _agamaController.text,
      jatidiri: _jatiController.text,
      skor: skor,
      tanggapan: "",
      uid: profile.id,
      muridId: isEdit ? widget.rubrik!.muridId : widget.murid!.id,
      sekolah: isEdit ? profile.sekolah : widget.murid!.sekolah,
      kelompok: isEdit ? profile.kelompok : widget.murid!.kelompok,
    );

    final notifier = ref.read(rubrikProvider.notifier);

    isEdit ? notifier.updateRubrik(model) : notifier.createRubrik(model);
  }

  void _listenRubrik(
    AsyncValue<List<RubrikModel>>? previous,
    AsyncValue<List<RubrikModel>> next,
  ) {
    next.when(
      data: (list) {
        if (_isSubmitting) {
          SnackbarHelper.show(
            context,
            isEdit ? "Data berhasil diperbarui" : "Data berhasil ditambahkan",
          );

          setState(() => _isSubmitting = false);

          if (isEdit) {
            final updated = list.firstWhere(
              (x) => x.id == widget.rubrik!.id,
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
          SnackbarHelper.show(context, "Gagal menyimpan: $err");
          setState(() => _isSubmitting = false);
        }
      },
      loading: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rubrikProvider);
    ref.listen<AsyncValue<List<RubrikModel>>>(rubrikProvider, _listenRubrik);

    return MyDoubleTapExit(
      child: Scaffold(
        appBar: CustomAppBar(
          title: isEdit ? "Edit Rubrik" : "Tambah Rubrik",
          showBack: true,
          onBack: () => context.go(
            isEdit ? '/detailRubrik' : '/rubrik',
            extra: isEdit ? widget.rubrik!.id : null,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CustomInputField(
                  label: "Tanggal",
                  controller: _tanggalController,
                  readOnly: true,
                  icon: Icons.date_range,
                  onTap: _pickDate,
                ),
                CustomInputField(
                  label: "Tujuan Pembelajaran",
                  controller: _tujuanController,
                  minLines: 2,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: CustomText(
                    text: 'Skor Penilaian',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                CustomDropdown<String>(
                  value: skor,
                  items: [
                    _customDropdownItem('1', 'Skor 1 - Belum mencapai tujuan'),
                    _customDropdownItem(
                      '2',
                      'Skor 2 - Mencapai tujuan dengan bantuan',
                    ),
                    _customDropdownItem(
                      '3',
                      'Skor 3 - Mencapai tujuan secara mandiri',
                    ),
                  ],
                  onChanged: (v) => setState(() => skor = v!),
                ),
                const SizedBox(height: 8),
                CustomInputField(
                  label: "Agama & Budi Pekerti",
                  controller: _agamaController,
                  minLines: 2,
                ),
                CustomInputField(
                  label: "Jati Diri",
                  controller: _jatiController,
                  minLines: 2,
                ),
                CustomInputField(
                  label: "Literasi & STEAM",
                  controller: _literasiController,
                  minLines: 2,
                ),
                CustomInputField(
                  label: "Umpan Balik",
                  controller: _umpanBalikController,
                  minLines: 2,
                ),

                const SizedBox(height: 24),

                CustomButton(
                  text: isEdit ? "Edit Data" : "Tambah Data",
                  isLoading: _isSubmitting,
                  onPressed: state.isLoading || _isSubmitting
                      ? null
                      : () => _handleSubmit(ref),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DropdownMenuItem<String> _customDropdownItem(String value, String text) {
    return DropdownMenuItem(
      value: value,
      child: CustomText(text: text, softWrap: true, maxLines: 1),
    );
  }
}
