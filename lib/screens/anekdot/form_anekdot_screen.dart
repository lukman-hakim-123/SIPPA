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
import '../../widgets/common/snackbar_helper.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/my_double_tap_exit.dart';
import '../../widgets/form/custom_image_picker.dart';
import '../../widgets/form/custom_input_field.dart';

class FormAnekdotScreen extends ConsumerStatefulWidget {
  final AnekdotModel? anekdot;
  final User? murid;

  const FormAnekdotScreen({super.key, this.anekdot, this.murid});

  @override
  ConsumerState<FormAnekdotScreen> createState() => _FormAnekdotScreenState();
}

class _FormAnekdotScreenState extends ConsumerState<FormAnekdotScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nilaiAgamaController = TextEditingController();
  final _jatiDiriController = TextEditingController();
  final _literasiController = TextEditingController();
  final _umpanBalikController = TextEditingController();
  final _tanggalController = TextEditingController();
  final _kegiatanController = TextEditingController();
  final _tujuanController = TextEditingController();

  File? _pickedImage;
  bool _isSubmitting = false;

  bool get isEdit => widget.anekdot != null;

  @override
  void initState() {
    super.initState();

    if (isEdit) {
      final a = widget.anekdot!;
      _nilaiAgamaController.text = a.nilaiAgama;
      _jatiDiriController.text = a.jatiDiri;
      _literasiController.text = a.literasi;
      _umpanBalikController.text = a.rekomendasi;
      _tanggalController.text = a.tanggal;
      _kegiatanController.text = a.kegiatan;
      _tujuanController.text = a.tujuan;
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

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => _pickedImage = File(file.path));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _tanggalController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  Future<void> _handleSubmit(WidgetRef ref) async {
    if (!_formKey.currentState!.validate()) return;

    if (!isEdit && _pickedImage == null) {
      SnackbarHelper.show(context, "Foto belum dipilih");
      return;
    }

    final profile = ref.read(userProvider).value;
    if (profile == null) {
      SnackbarHelper.show(context, "Profile belum dimuat");
      return;
    }

    setState(() => _isSubmitting = true);

    final base = AnekdotModel(
      id: isEdit ? widget.anekdot!.id : '',
      imageId: isEdit ? widget.anekdot!.imageId : '',
      sekolah: isEdit ? profile.sekolah : widget.murid!.sekolah,
      kelompok: isEdit ? profile.kelompok : widget.murid!.kelompok,
      kegiatan: _kegiatanController.text,
      tujuan: _tujuanController.text,
      tanggal: _tanggalController.text,
      nilaiAgama: _nilaiAgamaController.text,
      jatiDiri: _jatiDiriController.text,
      literasi: _literasiController.text,
      rekomendasi: _umpanBalikController.text,
      uid: profile.id,
      muridId: isEdit ? widget.anekdot!.muridId : widget.murid!.id,
      tanggapan: '',
    );

    final notifier = ref.read(anekdotProvider.notifier);

    isEdit
        ? notifier.updateAnekdot(base, widget.anekdot!, _pickedImage)
        : notifier.createAnekdot(base, _pickedImage!);
  }

  void _listenAnekdotState(
    AsyncValue<List<AnekdotModel>>? previous,
    AsyncValue<List<AnekdotModel>> next,
  ) {
    next.when(
      loading: () {},
      error: (e, _) {
        if (_isSubmitting) {
          SnackbarHelper.show(context, "Gagal menyimpan: $e");
          setState(() => _isSubmitting = false);
        }
      },
      data: (list) {
        if (!_isSubmitting) return;

        SnackbarHelper.show(
          context,
          isEdit
              ? "Data anekdot berhasil diperbarui"
              : "Data anekdot berhasil ditambahkan",
        );

        setState(() => _isSubmitting = false);

        if (isEdit) {
          final updated = list.firstWhere(
            (g) => g.id == widget.anekdot!.id,
            orElse: () => widget.anekdot!,
          );
          context.go('/detailAnekdot', extra: updated.id);
        } else {
          context.go('/anekdot');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final anekdotUrl = ref.read(anekdotProvider.notifier).getPublicImageUrl;
    final state = ref.watch(anekdotProvider);

    ref.listen<AsyncValue<List<AnekdotModel>>>(
      anekdotProvider,
      _listenAnekdotState,
    );

    return MyDoubleTapExit(
      child: Scaffold(
        appBar: CustomAppBar(
          title: isEdit ? "Edit Anekdot" : "Tambah Anekdot",
          showBack: true,
          onBack: () => context.go(
            isEdit ? '/detailAnekdot' : '/anekdot',
            extra: isEdit ? widget.anekdot!.id : null,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CustomImagePicker(
                  pickedImage: _pickedImage,
                  isEdit: isEdit,
                  imageUrl: isEdit ? anekdotUrl(widget.anekdot!.imageId) : null,
                  onPick: _pickImage,
                ),
                const SizedBox(height: 10),
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
                  onPressed: state.isLoading || _isSubmitting
                      ? null
                      : () => _handleSubmit(ref),
                  isLoading: _isSubmitting,
                  text: isEdit ? "Edit Data Anekdot" : "Tambah Data Anekdot",
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
