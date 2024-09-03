import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sippa/add_user/controller/user_controller.dart';
import 'package:sippa/common/loading.dart';
import 'package:sippa/hasil_karya/controller/hasil_karya_controller.dart';
import 'package:sippa/widget_view/appbar.dart';
import 'package:sippa/widget_view/teks.dart';
import 'package:sippa/models/hk.dart';

class EditHkPage extends ConsumerStatefulWidget {
  static route({required kelompok, required hk, required levelUser}) =>
      MaterialPageRoute(
          builder: (context) =>
              EditHkPage(kelompok: kelompok, hk: hk, levelUser: levelUser));
  final String kelompok;
  final HkModel hk;
  final int levelUser;
  const EditHkPage({
    super.key,
    required this.kelompok,
    required this.hk,
    required this.levelUser,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EditHkPageState();
}

class _EditHkPageState extends ConsumerState<EditHkPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController deskripsiController;
  late TextEditingController semesterController;
  late TextEditingController tanggalController;
  late TextEditingController muridIdController;
  late TextEditingController nilaiController;
  late TextEditingController jatiDiriController;
  late TextEditingController literasiController;
  late TextEditingController rekomendasiController;
  late TextEditingController tanggapanController;
  final ImagePicker picker = ImagePicker();
  DateTime? _selectedDate;
  File? _image;
  String? _errorMessage;
  static const int maxFileSize = 2 * 1024 * 1024;
  String? selectedSemester;
  bool _isNewImage = false;

  @override
  void initState() {
    super.initState();
    deskripsiController =
        TextEditingController(text: widget.hk.deskripsi); //kegiatan
    semesterController = TextEditingController(text: widget.hk.semester); //T.P
    tanggalController = TextEditingController(text: widget.hk.tanggal);
    muridIdController = TextEditingController(text: widget.hk.muridId);
    nilaiController = TextEditingController(text: widget.hk.nilai);
    jatiDiriController = TextEditingController(text: widget.hk.jatiDiri);
    literasiController = TextEditingController(text: widget.hk.literasi);
    rekomendasiController = TextEditingController(text: widget.hk.rekomendasi);
    tanggapanController = TextEditingController(text: widget.hk.tanggapan);
    _selectedDate = DateFormat('dd MMMM yyyy').parse(widget.hk.tanggal);
    selectedSemester = widget.hk.semester;
  }

  @override
  void dispose() {
    super.dispose();
    deskripsiController.dispose();
    tanggalController.dispose();
    semesterController.dispose();
    nilaiController.dispose();
    jatiDiriController.dispose();
    literasiController.dispose();
    rekomendasiController.dispose();
    tanggapanController.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        tanggalController.text =
            DateFormat('dd MMMM yyyy').format(_selectedDate!);
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final fileSize = await file.length();

      setState(() {
        _image = file;
        _isNewImage = true;
        _errorMessage = null;
      });
    }
  }

  void editHasilKarya() {
    if (_formKey.currentState!.validate()) {
      ref.read(hkControllerProvider.notifier).updateHk(
            hkId: widget.hk.id,
            semester: semesterController.text,
            deskripsi: deskripsiController.text,
            nilai: nilaiController.text,
            jatiDiri: jatiDiriController.text,
            literasi: literasiController.text,
            tanggal: tanggalController.text,
            muridId: muridIdController.text,
            imageId: widget.hk.imageId,
            image: _image,
            context: context,
            rekomendasi: rekomendasiController.text,
            tanggapan: tanggapanController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final muridAsyncValue =
        ref.watch(getMuridByFiltersProvider(widget.kelompok));
    final isLoading = ref.watch(hkControllerProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Edit Hasil Karya',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Container(
                margin: const EdgeInsets.all(10),
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _isNewImage
                      ? Image.file(_image!, fit: BoxFit.cover)
                      : ref.watch(getHkImageProvider(widget.hk.imageId)).when(
                            data: (imageData) {
                              if (imageData != null) {
                                return Image.memory(
                                  imageData,
                                  fit: BoxFit.cover,
                                );
                              } else {
                                return const Icon(Icons.image_not_supported);
                              }
                            },
                            loading: () => const Loader(),
                            error: (_, __) => const Icon(Icons.error),
                          ),
                ),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              if (widget.levelUser != 3)
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Pilih Gambar'),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: tanggalController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Tanggal',
                  suffixIcon: widget.levelUser == 3
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () => _selectDate(context),
                        ),
                ),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pilih tanggal';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: deskripsiController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Kegiatan',
                ),
                maxLength: 500,
                minLines: 2,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan Kegiatan';
                  }
                  return null;
                },
                readOnly: widget.levelUser == 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: semesterController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Tujuan Pembelajaran',
                ),
                maxLength: 500,
                minLines: 2,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan Tujuan Pembelajaran';
                  }
                  return null;
                },
                readOnly: widget.levelUser == 3,
              ),
              const SizedBox(height: 16),
              muridAsyncValue.when(
                data: (muridList) {
                  // Check if the current muridId exists in the list
                  final currentMuridExists = muridList
                      .any((murid) => murid.id == muridIdController.text);
                  if (!currentMuridExists) {
                    // Schedule the SnackBar to show after the current build phase
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Data murid tidak ada'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    });
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: DropdownButtonFormField<String>(
                      value: currentMuridExists ? muridIdController.text : null,
                      decoration: const InputDecoration(
                        labelText: "Murid",
                        border: OutlineInputBorder(),
                      ),
                      items: muridList.map((murid) {
                        return DropdownMenuItem<String>(
                          value: murid.id,
                          enabled: widget.levelUser != 3,
                          child: CustomText(text: murid.nama),
                        );
                      }).toList(),
                      onChanged: widget.levelUser != 3
                          ? (String? newValue) {
                              setState(() {
                                muridIdController.text = newValue ?? '';
                              });
                            }
                          : null,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pilih murid';
                        }
                        return null;
                      },
                    ),
                  );
                },
                loading: () => const Loader(),
                error: (error, stack) => CustomText(text: 'Error: $error'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nilaiController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Nilai Agama dan Budi Pekerti',
                ),
                maxLength: 500,
                minLines: 2,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan Nilai Agama dan Budi Pekerti';
                  }
                  return null;
                },
                readOnly: widget.levelUser == 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: jatiDiriController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Jati Diri',
                ),
                maxLength: 500,
                minLines: 2,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan Jati Diri';
                  }
                  return null;
                },
                readOnly: widget.levelUser == 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: literasiController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Literasi dan STEAM',
                ),
                maxLength: 500,
                minLines: 2,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan Literasi dan STEAM';
                  }
                  return null;
                },
                readOnly: widget.levelUser == 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: rekomendasiController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Analisis Umpan Balik',
                ),
                maxLength: 500,
                minLines: 2,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan Umpan Balik';
                  }
                  return null;
                },
                readOnly: widget.levelUser == 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: tanggapanController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Tanggapan Orang Tua',
                ),
                maxLength: 500,
                minLines: 2,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                readOnly: widget.levelUser != 3,
              ),
              const SizedBox(height: 16),
              isLoading
                  ? const Loader()
                  : ElevatedButton(
                      onPressed: editHasilKarya,
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(const Color(0xff104993)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                        ),
                        fixedSize: MaterialStateProperty.all(
                            const Size.fromHeight(45)),
                      ),
                      child: Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: const CustomText(
                          text: 'Simpan Perubahan',
                          color: Colors.white,
                        ),
                      ),
                    ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
