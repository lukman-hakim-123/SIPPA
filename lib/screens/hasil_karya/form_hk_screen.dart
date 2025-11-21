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
import '../../widgets/common/snackbar_helper.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/my_double_tap_exit.dart';
import '../../widgets/form/custom_image_picker.dart';
import '../../widgets/form/custom_input_field.dart';

class FormHkScreen extends ConsumerStatefulWidget {
  final HkModel? hk;
  final User? murid;

  const FormHkScreen({super.key, this.hk, this.murid});

  @override
  ConsumerState<FormHkScreen> createState() => _FormHkScreenState();
}

class _FormHkScreenState extends ConsumerState<FormHkScreen> {
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

  bool get isEdit => widget.hk != null;

  @override
  void initState() {
    super.initState();

    if (isEdit) {
      final a = widget.hk!;
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

    final base = HkModel(
      id: isEdit ? widget.hk!.id : '',
      imageId: isEdit ? widget.hk!.imageId : '',
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
      muridId: isEdit ? widget.hk!.muridId : widget.murid!.id,
      tanggapan: '',
    );

    final notifier = ref.read(hkProvider.notifier);
    isEdit
        ? notifier.updateHk(base, widget.hk!, _pickedImage)
        : notifier.createHk(base, _pickedImage!);
  }

  void _listenHkState(
    AsyncValue<List<HkModel>>? previous,
    AsyncValue<List<HkModel>> next,
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
              ? "Data hasil karya berhasil diperbarui"
              : "Data hasil karya berhasil ditambahkan",
        );

        setState(() => _isSubmitting = false);

        if (isEdit) {
          final updated = list.firstWhere(
            (g) => g.id == widget.hk!.id,
            orElse: () => widget.hk!,
          );
          context.go('/detailHk', extra: updated.id);
        } else {
          context.go('/hk');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hkUrl = ref.read(hkProvider.notifier).getPublicImageUrl;
    final state = ref.watch(hkProvider);

    ref.listen<AsyncValue<List<HkModel>>>(hkProvider, _listenHkState);

    return MyDoubleTapExit(
      child: Scaffold(
        appBar: CustomAppBar(
          title: isEdit ? "Edit Hasil Karya" : "Tambah Hasil Karya",
          showBack: true,
          onBack: () => context.go(
            isEdit ? '/detailHk' : '/hk',
            extra: isEdit ? widget.hk!.id : null,
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
                  imageUrl: isEdit ? hkUrl(widget.hk!.imageId) : null,
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
                  text: isEdit ? "Edit Data" : "Tambah Data",
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
