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
import '../../widgets/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/my_double_tap_exit.dart';
import '../../widgets/custom_image_picker.dart';
import '../../widgets/custom_input_field.dart';

class FormAnekdotScreen extends ConsumerStatefulWidget {
  final AnekdotModel? anekdot;
  final User? murid;

  const FormAnekdotScreen({super.key, this.anekdot, this.murid});

  @override
  ConsumerState<FormAnekdotScreen> createState() => _FormAnekdotScreenState();
}

class _FormAnekdotScreenState extends ConsumerState<FormAnekdotScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nilaiAgama = TextEditingController();
  final _jatiDiri = TextEditingController();
  final _literasi = TextEditingController();
  final _umpanBalik = TextEditingController();
  final _tanggal = TextEditingController();
  final _kegiatan = TextEditingController();
  final _tujuan = TextEditingController();

  File? _pickedImage;
  bool _isSubmitting = false;

  bool get isEdit => widget.anekdot != null;

  @override
  void initState() {
    super.initState();

    if (isEdit) {
      final a = widget.anekdot!;
      _nilaiAgama.text = a.nilaiAgama;
      _jatiDiri.text = a.jatiDiri;
      _literasi.text = a.literasi;
      _umpanBalik.text = a.umpanBalik;
      _tanggal.text = a.tanggal;
      _kegiatan.text = a.kegiatan;
      _tujuan.text = a.tujuan;
    }
  }

  @override
  void dispose() {
    _nilaiAgama.dispose();
    _jatiDiri.dispose();
    _literasi.dispose();
    _umpanBalik.dispose();
    _tanggal.dispose();
    _kegiatan.dispose();
    _tujuan.dispose();
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
        _tanggal.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  Future<void> _handleSubmit(WidgetRef ref) async {
    if (!_formKey.currentState!.validate()) return;

    if (!isEdit && _pickedImage == null) {
      _showSnack("Foto belum dipilih");
      return;
    }

    final profile = ref.read(userProvider).value;
    if (profile == null) {
      _showSnack("Profile belum dimuat");
      return;
    }

    setState(() => _isSubmitting = true);

    final base = AnekdotModel(
      id: isEdit ? widget.anekdot!.id : '',
      imageId: isEdit ? widget.anekdot!.imageId : '',
      sekolah: isEdit ? profile.sekolah : widget.murid!.sekolah,
      kelompok: isEdit ? profile.kelompok : widget.murid!.kelompok,
      kegiatan: _kegiatan.text,
      tujuan: _tujuan.text,
      tanggal: _tanggal.text,
      nilaiAgama: _nilaiAgama.text,
      jatiDiri: _jatiDiri.text,
      literasi: _literasi.text,
      umpanBalik: _umpanBalik.text,
      uid: profile.id,
      muridId: isEdit ? widget.anekdot!.muridId : widget.murid!.id,
      tanggapan: '',
    );

    final notifier = ref.read(anekdotProvider.notifier);

    isEdit
        ? notifier.updateAnekdot(base, widget.anekdot!, _pickedImage)
        : notifier.createAnekdot(base, _pickedImage!);
  }

  @override
  Widget build(BuildContext context) {
    final anekdotUrl = ref.read(anekdotProvider.notifier).getPublicImageUrl;
    final state = ref.watch(anekdotProvider);

    ref.listen<AsyncValue<List<AnekdotModel>>>(anekdotProvider, (_, next) {
      next.when(
        loading: () {},
        error: (e, _) {
          if (_isSubmitting) {
            _showSnack("Gagal menyimpan: $e");
            setState(() => _isSubmitting = false);
          }
        },
        data: (list) {
          if (!_isSubmitting) return;

          _showSnack(
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
    });

    return MyDoubleTapExit(
      child: Scaffold(
        appBar: AppBar(
          title: CustomText(
            text: isEdit ? "Edit Anekdot" : "Tambah Anekdot",
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          centerTitle: true,
          backgroundColor: AppColors.primary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go('/anekdot'),
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
                  controller: _tanggal,
                  readOnly: true,
                  icon: Icons.date_range,
                  onTap: _pickDate,
                ),
                CustomInputField(
                  label: "Kegiatan",
                  controller: _kegiatan,
                  minLines: 2,
                ),
                CustomInputField(
                  label: "Tujuan Pembelajaran",
                  controller: _tujuan,
                  minLines: 2,
                ),
                CustomInputField(
                  label: "Nilai Agama dan Budi Pekerti",
                  controller: _nilaiAgama,
                  minLines: 2,
                ),
                CustomInputField(
                  label: "Jati Diri",
                  controller: _jatiDiri,
                  minLines: 2,
                ),
                CustomInputField(
                  label: "Literasi dan STEAM",
                  controller: _literasi,
                  minLines: 2,
                ),
                CustomInputField(
                  label: "Umpan Balik",
                  controller: _umpanBalik,
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

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: CustomText(text: msg, color: Colors.white),
      ),
    );
  }
}
