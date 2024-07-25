import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sippa/add_user/controller/user_controller.dart';
import 'package:sippa/foto_berseri/controller/foto_berseri_controller.dart';
import 'package:sippa/models/fb.dart';
import 'package:sippa/widget_view/appbar.dart';
import 'package:sippa/widget_view/teks.dart';

class EditFbPage extends ConsumerStatefulWidget {
  static Route route({required FbModel fb, required String kelompok}) =>
      MaterialPageRoute(
          builder: (context) => EditFbPage(fb: fb, kelompok: kelompok));

  final FbModel fb;
  final String kelompok;

  const EditFbPage({super.key, required this.fb, required this.kelompok});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EditFbPageState();
}

class _EditFbPageState extends ConsumerState<EditFbPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController keteranganController;
  late TextEditingController umpanBalikController;
  late TextEditingController tanggalController;
  late TextEditingController muridIdController;
  late TextEditingController nilaiController;
  late TextEditingController jatiDiriController;
  late TextEditingController literasiController;
  final ImagePicker picker = ImagePicker();

  DateTime? _selectedDate;
  File? _image1;
  File? _image2;
  File? _image3;
  String? _errorMessage;
  static const int maxFileSize = 2 * 1024 * 1024;
  bool _isNewImage1 = false;
  bool _isNewImage2 = false;
  bool _isNewImage3 = false;
  bool _deleteImage1 = false;
  bool _deleteImage2 = false;
  bool _deleteImage3 = false;

  @override
  void initState() {
    super.initState();
    keteranganController = TextEditingController(text: widget.fb.keterangan);
    umpanBalikController = TextEditingController(text: widget.fb.umpanBalik);
    tanggalController = TextEditingController(text: widget.fb.tanggal);
    muridIdController = TextEditingController(text: widget.fb.muridId);
    nilaiController = TextEditingController(text: widget.fb.nilai);
    jatiDiriController = TextEditingController(text: widget.fb.jatiDiri);
    literasiController = TextEditingController(text: widget.fb.literasi);
    _selectedDate = DateFormat('dd MMMM yyyy').parse(widget.fb.tanggal);
  }

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
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final fileSize = await file.length();

        if (fileSize > maxFileSize) {
          setState(() {
            _errorMessage =
                'Ukuran file melebihi 2 MB. Silakan pilih file yang lebih kecil.';
          });
        } else {
          setState(() {
            switch (imageIndex) {
              case 1:
                _image1 = file;
                _isNewImage1 = true;
                break;
              case 2:
                _image2 = file;
                _isNewImage2 = true;
                break;
              case 3:
                _image3 = file;
                _isNewImage3 = true;
                break;
            }
            _errorMessage = null;
          });
        }
      } else {
        setState(() {
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan saat memilih gambar: $e';
      });
    }
  }

  void updateFotoBerseri() {
    if (_formKey.currentState!.validate()) {
      if (_formKey.currentState!.validate()) {
        if (_image1 == null &&
            _image2 == null &&
            _image3 == null &&
            widget.fb.imageId1 == '' &&
            widget.fb.imageId2 == '' &&
            widget.fb.imageId3 == '') {
          setState(() {
            _errorMessage = 'Pilih setidaknya satu gambar.';
          });
          return;
        }

        setState(() {
          _errorMessage = null;
        });

        ref.read(fbControllerProvider.notifier).updateFb(
            fbId: widget.fb.id,
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
            imageId1: widget.fb.imageId1,
            imageId2: widget.fb.imageId2,
            imageId3: widget.fb.imageId3,
            deleteId1: _deleteImage1,
            deleteId2: _deleteImage2,
            deleteId3: _deleteImage3,
            context: context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final muridAsyncValue =
        ref.watch(getMuridByFiltersProvider(widget.kelompok));

    return Scaffold(
      appBar: const CustomAppBar(title: 'Edit Foto Berseri'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildImageContainer(1),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(_errorMessage!,
                      style: const TextStyle(color: Colors.red)),
                ),
              _buildImageContainer(2),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(_errorMessage!,
                      style: const TextStyle(color: Colors.red)),
                ),
              _buildImageContainer(3),
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
                      value: muridIdController.text,
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
                onPressed: updateFotoBerseri,
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
                  child: const Text("Simpan Perubahan",
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

  Widget _buildImageContainer(int imageIndex) {
    File? image;
    bool isNewImage = false;
    String imageId = '';
    bool deleteImage = false;

    switch (imageIndex) {
      case 1:
        image = _image1;
        isNewImage = _isNewImage1;
        imageId = widget.fb.imageId1;
        deleteImage = _deleteImage1;
        break;
      case 2:
        image = _image2;
        isNewImage = _isNewImage2;
        imageId = widget.fb.imageId2;
        deleteImage = _deleteImage2;
        break;
      case 3:
        image = _image3;
        isNewImage = _isNewImage3;
        imageId = widget.fb.imageId3;
        deleteImage = _deleteImage3;
        break;
    }

    return Column(
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
            child: deleteImage
                ? const Icon(Icons.image_not_supported, size: 50)
                : isNewImage && image != null
                    ? Image.file(image, fit: BoxFit.cover)
                    : imageId.isNotEmpty
                        ? ref.watch(getFbImageProvider(imageId)).when(
                              data: (imageData) {
                                return imageData != null
                                    ? Image.memory(imageData, fit: BoxFit.cover)
                                    : const Icon(Icons.image_not_supported);
                              },
                              loading: () => const CircularProgressIndicator(),
                              error: (_, __) => const Icon(Icons.error),
                            )
                        : const Icon(Icons.add_photo_alternate, size: 50),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _pickImage(imageIndex),
              child: Text('Pilih Gambar $imageIndex'),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  switch (imageIndex) {
                    case 1:
                      _deleteImage1 = !_deleteImage1;
                      _image1 = null;
                      break;
                    case 2:
                      _deleteImage2 = !_deleteImage2;
                      _image2 = null;
                      break;
                    case 3:
                      _deleteImage3 = !_deleteImage3;
                      _image3 = null;
                      break;
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: deleteImage ? Colors.red : Colors.grey,
              ),
              child: Text(deleteImage ? 'Batal Hapus' : 'Hapus Gambar'),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
