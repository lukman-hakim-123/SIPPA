import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sippa/add_user/controller/user_controller.dart';
import 'package:sippa/foto_berseri/controller/foto_berseri_controller.dart';
import 'package:sippa/widget_view/appbar.dart';
import 'package:sippa/widget_view/teks.dart';

class AddFbPage extends ConsumerStatefulWidget {
  static Route route({required String kelompok}) =>
      MaterialPageRoute(builder: (context) => AddFbPage(kelompok: kelompok));

  final String kelompok;

  const AddFbPage({super.key, required this.kelompok});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddFbPageState();
}

class _AddFbPageState extends ConsumerState<AddFbPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController keteranganController = TextEditingController();
  final TextEditingController umpanBalikController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();
  final TextEditingController muridIdController = TextEditingController();
  final TextEditingController nilaiController = TextEditingController();
  final TextEditingController jatiDiriController = TextEditingController();
  final TextEditingController literasiController = TextEditingController();
  final ImagePicker picker = ImagePicker();

  DateTime? _selectedDate;
  File? _image1;
  File? _image2;
  File? _image3;
  String? _errorMessage;
  static const int maxFileSize = 2 * 1024 * 1024;
  String? selectedNilai;

  @override
  void dispose() {
    keteranganController.dispose();
    tanggalController.dispose();
    umpanBalikController.dispose();
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

  Future<void> _pickImage(int imageIndex) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final fileSize = await file.length();

      if (fileSize > maxFileSize) {
        setState(() {
          _errorMessage =
              'Ukuran file melebihi 2 MB. Silakan pilih file yang lebih kecil.';
          if (imageIndex == 1) _image1 = null;
          if (imageIndex == 2) _image2 = null;
          if (imageIndex == 3) _image3 = null;
        });
      } else {
        setState(() {
          if (imageIndex == 1) _image1 = file;
          if (imageIndex == 2) _image2 = file;
          if (imageIndex == 3) _image3 = file;
          _errorMessage = null;
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Tidak ada file yang dipilih.';
      });
    }
  }

  void addFotoBerseri() {
    if (_formKey.currentState!.validate()) {
      if (_image1 == null && _image2 == null && _image3 == null) {
        setState(() {
          _errorMessage = 'Setidaknya pilih satu gambar.';
        });
        return;
      }
      ref.read(fbControllerProvider.notifier).addFb(
          umpanBalik: umpanBalikController.text,
          keterangan: keteranganController.text,
          nilai: nilaiController.text,
          jatiDiri: jatiDiriController.text,
          literasi: literasiController.text,
          tanggal: tanggalController.text,
          muridId: muridIdController.text,
          image1: _image1,
          image2: _image2,
          image3: _image3,
          context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final muridAsyncValue =
        ref.watch(getMuridByFiltersProvider(widget.kelompok));

    return Scaffold(
      appBar: const CustomAppBar(title: 'Tambah Foto Berseri'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_image1 != null)
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
                    child: Image.file(_image1!, fit: BoxFit.cover),
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
                  child: const Center(child: Text('Belum ada gambar dipilih')),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _pickImage(1),
                child: const Text('Pilih Gambar 1'),
              ),
              if (_image2 != null)
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
                    child: Image.file(_image2!, fit: BoxFit.cover),
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
                  child: const Center(child: Text('Belum ada gambar dipilih')),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _pickImage(2),
                child: const Text('Pilih Gambar 2'),
              ),
              if (_image3 != null)
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
                    child: Image.file(_image3!, fit: BoxFit.cover),
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
                  child: const Center(child: Text('Belum ada gambar dipilih')),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _pickImage(3),
                child: const Text('Pilih Gambar 3'),
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(_errorMessage!,
                      style: const TextStyle(color: Colors.red)),
                ),
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
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Pilih murid' : null,
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
                validator: (value) =>
                    value == null || value.isEmpty ? 'Pilih tanggal' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: keteranganController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Deskripsi Foto',
                ),
                maxLength: 500,
                minLines: 2,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                validator: (value) => value == null || value.isEmpty
                    ? 'Masukkan Deskripsi Foto'
                    : null,
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
                validator: (value) => value == null || value.isEmpty
                    ? 'Masukkan Analisis Nilai Agama dan Budi Pekerti'
                    : null,
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
                validator: (value) => value == null || value.isEmpty
                    ? 'Masukkan Analisis Jati Diri'
                    : null,
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
                validator: (value) => value == null || value.isEmpty
                    ? 'Masukkan Analisis Literasi'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: umpanBalikController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Umpan Balik',
                ),
                maxLength: 500,
                minLines: 2,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                validator: (value) => value == null || value.isEmpty
                    ? 'Masukkan Umpan Balik'
                    : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: addFotoBerseri,
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
                  child: const Text("Tambah Foto Berseri",
                      style:
                          TextStyle(fontFamily: 'inter', color: Colors.white)),
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
