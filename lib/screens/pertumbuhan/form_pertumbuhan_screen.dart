import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/pertumbuhan.dart';
import '../../models/user.dart';
import '../../providers/pertumbuhan_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/common/snackbar_helper.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/form/custom_input_field.dart';
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

  bool get isEdit => widget.pertumbuhan != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      final p = widget.pertumbuhan!;
      _tinggiController.text = p.tinggi.toString();
      _beratController.text = p.berat.toString();
      _lingkarController.text = p.kepala.toString();
      _fisikController.text = p.fisik;
      _umpanBalikController.text = p.rekomendasi;
      _tanggalController.text = p.tanggal;
    }
  }

  @override
  void dispose() {
    _tinggiController.dispose();
    _beratController.dispose();
    _lingkarController.dispose();
    _fisikController.dispose();
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

    // MODEL BASE
    final base = PertumbuhanModel(
      id: isEdit ? widget.pertumbuhan!.id : '',
      tinggi: int.tryParse(_tinggiController.text) ?? 0,
      berat: int.tryParse(_beratController.text) ?? 0,
      kepala: int.tryParse(_lingkarController.text) ?? 0,
      tanggal: _tanggalController.text,
      fisik: _fisikController.text,
      rekomendasi: _umpanBalikController.text,
      tanggapan: '',
      uid: profile.id,
      sekolah: isEdit ? profile.sekolah : widget.murid!.sekolah,
      kelompok: isEdit ? profile.kelompok : widget.murid!.kelompok,
      muridId: isEdit ? widget.pertumbuhan!.muridId : widget.murid!.id,
    );

    final notifier = ref.read(pertumbuhanProvider.notifier);

    isEdit
        ? notifier.updatePertumbuhan(base)
        : notifier.createPertumbuhan(base);
  }

  void _listenPertumbuhanState(
    AsyncValue<List<PertumbuhanModel>>? previous,
    AsyncValue<List<PertumbuhanModel>> next,
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
              (x) => x.id == widget.pertumbuhan!.id,
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
          SnackbarHelper.show(context, "Gagal menyimpan: $err");
          setState(() => _isSubmitting = false);
        }
      },
      loading: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pertumbuhanProvider);

    ref.listen<AsyncValue<List<PertumbuhanModel>>>(
      pertumbuhanProvider,
      _listenPertumbuhanState,
    );

    return MyDoubleTapExit(
      child: Scaffold(
        appBar: CustomAppBar(
          title: isEdit ? "Edit Pertumbuhan" : "Tambah Pertumbuhan",
          showBack: true,
          onBack: () => context.go(
            isEdit ? '/detailPertumbuhan' : '/pertumbuhan',
            extra: isEdit ? widget.pertumbuhan!.id : null,
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
                  label: "Tinggi Badan (cm)",
                  controller: _tinggiController,
                  keyboardType: TextInputType.number,
                  suffixText: "cm",
                ),
                CustomInputField(
                  label: "Berat Badan (kg)",
                  controller: _beratController,
                  keyboardType: TextInputType.number,
                  suffixText: "kg",
                ),
                CustomInputField(
                  label: "Lingkar Kepala (cm)",
                  controller: _lingkarController,
                  keyboardType: TextInputType.number,
                  suffixText: "cm",
                ),
                CustomInputField(
                  label: "Kondisi Fisik",
                  controller: _fisikController,
                  minLines: 2,
                ),
                CustomInputField(
                  label: "Umpan Balik",
                  controller: _umpanBalikController,
                  minLines: 2,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  onPressed: state.isLoading || _isSubmitting
                      ? null
                      : () => _handleSubmit(ref),
                  isLoading: _isSubmitting,
                  text: isEdit ? "Edit Data" : "Tambah Data",
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
