import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/cp.dart';
import '../../models/user.dart';
import '../../providers/cp_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/common/snackbar_helper.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/form/custom_input_field.dart';
import '../../widgets/custom_text.dart';
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
  final _kegiatanController = TextEditingController();
  final _nilaiAgamaController = TextEditingController();
  final _jatiDiriController = TextEditingController();
  final _literasiController = TextEditingController();
  final _tanggalController = TextEditingController();
  final _umpanBalikController = TextEditingController();

  bool _isSubmitting = false;
  bool _isDone = false;

  bool get isEdit => widget.cp != null;

  @override
  void initState() {
    super.initState();
    if (widget.cp != null) {
      _nilaiAgamaController.text = widget.cp!.nilaiAgama;
      _jatiDiriController.text = widget.cp!.jatiDiri;
      _literasiController.text = widget.cp!.literasi;
      _umpanBalikController.text = widget.cp!.rekomendasi;
      _tanggalController.text = widget.cp!.tanggal;
      _kegiatanController.text = widget.cp!.kegiatan;
      _tujuanController.text = widget.cp!.tujuan;
      _isDone = widget.cp!.isDone;
    }
  }

  @override
  void dispose() {
    _nilaiAgamaController.dispose();
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

  Future<void> _handleSubmit(WidgetRef ref) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    final profile = ref.read(userProvider).value;

    if (profile == null) {
      SnackbarHelper.show(context, "Profile belum dimuat");
      return;
    }

    final base = CpModel(
      id: isEdit ? widget.cp!.id : '',
      sekolah: isEdit ? profile.sekolah : widget.murid!.sekolah,
      kelompok: isEdit ? profile.kelompok : widget.murid!.kelompok,
      tujuan: _tujuanController.text,
      tanggal: _tanggalController.text,
      literasi: _literasiController.text,
      uid: profile.id,
      muridId: isEdit ? widget.cp!.muridId : widget.murid!.id,
      tanggapan: '',
      kegiatan: _kegiatanController.text,
      isDone: _isDone,
      nilaiAgama: _nilaiAgamaController.text,
      jatiDiri: _jatiDiriController.text,
      rekomendasi: _umpanBalikController.text,
    );

    final notifier = ref.read(cpProvider.notifier);

    isEdit ? notifier.updateCp(base) : notifier.createCp(base);
  }

  void _listenCpState(
    AsyncValue<List<CpModel>>? previous,
    AsyncValue<List<CpModel>> next,
  ) {
    next.when(
      data: (listCP) {
        if (_isSubmitting) {
          SnackbarHelper.show(
            context,
            isEdit ? 'Data berhasil diperbarui' : 'Data berhasil ditambahkan',
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
          SnackbarHelper.show(context, "Gagal menyimpan: $err");
          setState(() => _isSubmitting = false);
        }
      },
      loading: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final cpState = ref.watch(cpProvider);

    ref.listen<AsyncValue<List<CpModel>>>(cpProvider, _listenCpState);

    return MyDoubleTapExit(
      child: Scaffold(
        appBar: CustomAppBar(
          title: isEdit ? "Edit Capaian Pembelajaran" : "Tambah Capaian",
          showBack: true,
          onBack: () => context.go(
            isEdit ? '/detailCp' : '/cp',
            extra: isEdit ? widget.cp!.id : null,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomInputField(
                  label: "Tanggal",
                  controller: _tanggalController,
                  readOnly: true,
                  icon: Icons.date_range,
                  onTap: _pickDate,
                ),
                CustomInputField(
                  label: "Kegiatan",
                  controller: _kegiatanController,
                  minLines: 2,
                ),
                CustomInputField(
                  label: "Tujuan Pembelajaran",
                  controller: _tujuanController,
                  minLines: 2,
                ),
                CustomText(
                  text: "Status Kemunculan Capaian",
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    _radio(false, "Belum Muncul"),
                    _radio(true, "Sudah Muncul"),
                  ],
                ),
                SizedBox(height: 8),
                CustomInputField(
                  label: "Nilai Agama dan Budi Pekerti",
                  controller: _nilaiAgamaController,
                  minLines: 2,
                ),
                CustomInputField(
                  label: "Jati Diri",
                  controller: _jatiDiriController,
                  minLines: 2,
                ),
                CustomInputField(
                  label: "Literasi dan STEAM",
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
                  onPressed: cpState.isLoading || _isSubmitting
                      ? null
                      : () => _handleSubmit(ref),
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

  Widget _radio(bool value, String label) {
    return InkWell(
      onTap: () => setState(() => _isDone = value),
      child: Row(
        children: [
          Radio(
            value: value,
            groupValue: _isDone,
            onChanged: (_) => setState(() => _isDone = value),
          ),
          CustomText(text: label),
        ],
      ),
    );
  }
}
