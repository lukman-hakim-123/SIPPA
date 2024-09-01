import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sippa/add_user/controller/user_controller.dart';
import 'package:sippa/anekdot/controller/anekdot_controller.dart';
import 'package:sippa/common/loading.dart';
import 'package:sippa/widget_view/appbar.dart';

class AddAnekdotPage extends ConsumerStatefulWidget {
  static route({required kelompok}) => MaterialPageRoute(
      builder: (context) => AddAnekdotPage(kelompok: kelompok));

  final String kelompok;
  const AddAnekdotPage({super.key, required this.kelompok});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddAnekdotPageState();
}

class _AddAnekdotPageState extends ConsumerState<AddAnekdotPage> {
  final _formKey = GlobalKey<FormState>();
  final nilaiController = TextEditingController();
  final jatiDiriController = TextEditingController();
  final literasiController = TextEditingController();
  final umpanBalikController = TextEditingController();
  final tanggalController = TextEditingController();
  final pengamatanController = TextEditingController();
  final tujuanController = TextEditingController();
  final muridIdController = TextEditingController();
  DateTime? _selectedDate;
  File? _image;
  String? _errorMessage;
  static const int maxFileSize = 2 * 1024 * 1024;
  final ImagePicker picker = ImagePicker();

  @override
  void dispose() {
    super.dispose();
    nilaiController.dispose();
    jatiDiriController.dispose();
    literasiController.dispose();
    umpanBalikController.dispose();
    tanggalController.dispose();
    muridIdController.dispose();
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
        _errorMessage = null;
      });
    } else {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  void removeImage() {
    setState(() {
      _image = null;
      _errorMessage = null;
    });
  }

  void addAnekdot() {
    if (_formKey.currentState!.validate()) {
      ref.read(anekdotControllerProvider.notifier).addAnekdot(
          nilai: nilaiController.text,
          jatiDiri: jatiDiriController.text,
          literasi: literasiController.text,
          umpanBalik: umpanBalikController.text,
          tanggal: tanggalController.text,
          pengamatan: pengamatanController.text,
          tujuan: tujuanController.text,
          muridId: muridIdController.text,
          image: _image,
          tanggapan: '',
          context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final muridAsyncValue =
        ref.watch(getMuridByFiltersProvider(widget.kelompok));
    final isLoading = ref.watch(anekdotControllerProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Tambah Anekdotal',
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(
          right: 31,
          left: 31,
        ),
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
              if (_image != null)
                ElevatedButton(
                  onPressed: removeImage,
                  child: const Text('Hapus Gambar'),
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
              Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: TextFormField(
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
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: TextFormField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  minLines: 3,
                  controller: pengamatanController,
                  maxLength: 500,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Kegiatan',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan Kegiatan';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: TextFormField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  minLines: 3,
                  controller: tujuanController,
                  maxLength: 500,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Tujuan Pembelajaran',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan Tujuan Pembelajaran';
                    }
                    return null;
                  },
                ),
              ),
              muridAsyncValue.when(
                data: (muridList) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 22),
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Murid",
                        border: OutlineInputBorder(),
                      ),
                      items: muridList.map((murid) {
                        return DropdownMenuItem<String>(
                          value: murid.id,
                          child: Text(murid.nama),
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
                loading: () => const Loader(),
                error: (error, stack) => Text('Error: $error'),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: TextFormField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  minLines: 2,
                  controller: nilaiController,
                  maxLength: 500,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Nilai agama dan budi pekerti',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan Nilai agama dan budi pekerti';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: TextFormField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  minLines: 2,
                  controller: jatiDiriController,
                  maxLength: 500,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Jati diri',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan Jati diri';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: TextFormField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  minLines: 2,
                  controller: literasiController,
                  maxLength: 500,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Literasi dan STEAM',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan Literasi dan STEAM';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: TextFormField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  minLines: 2,
                  controller: umpanBalikController,
                  maxLength: 500,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Umpan Balik',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan Umpan Balik';
                    }
                    return null;
                  },
                ),
              ),
              isLoading
                  ? const Loader()
                  : ElevatedButton(
                      onPressed: () {
                        addAnekdot();
                      },
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
                        child: const Text(
                          "Tambah Anekdotal",
                          style: TextStyle(
                            fontFamily: 'inter',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
              const SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
