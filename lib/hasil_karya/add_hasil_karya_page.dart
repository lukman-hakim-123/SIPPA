import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sippa/add_user/controller/user_controller.dart';
import 'package:sippa/hasil_karya/controller/hasil_karya_controller.dart';

import 'package:sippa/widget_view/appbar.dart';
import 'package:sippa/widget_view/teks.dart';

class AddHkPage extends ConsumerStatefulWidget {
  static route({required kelompok}) =>
      MaterialPageRoute(builder: (context) => AddHkPage(kelompok: kelompok));
  final String kelompok;
  const AddHkPage({
    super.key,
    required this.kelompok,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddHkPageState();
}

class _AddHkPageState extends ConsumerState<AddHkPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController deskripsiController = TextEditingController();
  final TextEditingController semesterController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();
  final TextEditingController muridIdController = TextEditingController();
  final TextEditingController nilaiController = TextEditingController();
  final TextEditingController jatiDiriController = TextEditingController();
  final TextEditingController literasiController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  DateTime? _selectedDate;
  File? _image;
  String? _errorMessage;
  static const int maxFileSize = 2 * 1024 * 1024;
  String? selectedSemester;

  @override
  void dispose() {
    deskripsiController.dispose();
    tanggalController.dispose();
    semesterController.dispose();
    nilaiController.dispose();
    jatiDiriController.dispose();
    literasiController.dispose();
    super.dispose();
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

      if (fileSize > maxFileSize) {
        setState(() {
          _errorMessage =
              'Ukuran file melebihi 2 MB. Silakan pilih file yang lebih kecil.';
          _image = null;
        });
      } else {
        setState(() {
          _image = file;
          _errorMessage = null;
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Tidak ada file yang dipilih.';
      });
    }
  }

  void addHasilKarya() {
    if (_formKey.currentState!.validate()) {
      ref.read(hkControllerProvider.notifier).addHk(
          semester: selectedSemester!,
          deskripsi: deskripsiController.text,
          nilai: nilaiController.text,
          jatiDiri: jatiDiriController.text,
          literasi: literasiController.text,
          tanggal: tanggalController.text,
          muridId: muridIdController.text,
          image: _image,
          context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final muridAsyncValue =
        ref.watch(getMuridByFiltersProvider(widget.kelompok));

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Tambah Hasil Karya',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_image != null)
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
                    child: Image.file(
                      _image!,
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                )
              else
                Container(
                  margin: const EdgeInsets.all(10),
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text('Belum ada gambar dipilih'),
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
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Pilih Gambar'),
              ),
              const SizedBox(height: 16),
              muridAsyncValue.when(
                data: (muridList) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Murid",
                        border: OutlineInputBorder(),
                      ),
                      items: muridList.map((murid) {
                        return DropdownMenuItem<String>(
                          value: murid.id,
                          child: CustomText(text: murid.nama),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        muridIdController.text = newValue ?? '';
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pilih murid';
                        }
                        return null;
                      },
                    ),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => CustomText(text: 'Error: $error'),
              ),
              TextFormField(
                controller: tanggalController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Tanggal',
                  suffixIcon: IconButton(
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
              DropdownButtonFormField<String>(
                value: selectedSemester,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Semester',
                ),
                items: const [
                  DropdownMenuItem(
                      value: "1 (gasal)", child: Text("1 (gasal)")),
                  DropdownMenuItem(
                      value: "2 (genap)", child: Text("2 (genap)")),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    selectedSemester = newValue ?? '';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pilih Semester';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: deskripsiController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Deskripsi Foto',
                ),
                maxLength: 500,
                minLines: 2,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan Deskripsi Foto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nilaiController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Analisis Nilai Agama dan Budi Pekerti',
                ),
                maxLength: 500,
                minLines: 2,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan Analisis Nilai Agama dan Budi Pekerti';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: jatiDiriController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Analisis Jati Diri',
                ),
                maxLength: 500,
                minLines: 2,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan Analisis Jati Diri';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: literasiController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Analisis Literasi',
                ),
                maxLength: 500,
                minLines: 2,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan Analisis Literasi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: addHasilKarya,
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(const Color(0xff104993)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                  ),
                  fixedSize:
                      MaterialStateProperty.all(const Size.fromHeight(45)),
                ),
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: const CustomText(
                    text: 'Tambah Hasil Karya',
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
