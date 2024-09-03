import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sippa/add_user/controller/user_controller.dart';
import 'package:sippa/anekdot/controller/anekdot_controller.dart';
import 'package:sippa/common/loading.dart';
import 'package:sippa/models/anekdot.dart';
import 'package:sippa/widget_view/appbar.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:sippa/widget_view/teks.dart';

class EditAnekdotPage extends ConsumerStatefulWidget {
  static route(
          {required String kelompok,
          required AnekdotModel anekdot,
          required int levelUser}) =>
      MaterialPageRoute(
          builder: (context) => EditAnekdotPage(
                kelompok: kelompok,
                anekdot: anekdot,
                levelUser: levelUser,
              ));

  final String kelompok;
  final AnekdotModel anekdot;
  final int levelUser;

  const EditAnekdotPage(
      {super.key,
      required this.kelompok,
      required this.anekdot,
      required this.levelUser});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditAnekdotPageState();
}

class _EditAnekdotPageState extends ConsumerState<EditAnekdotPage> {
  final _formKey = GlobalKey<FormState>();
  final nilaiController = TextEditingController();
  final jatiDiriController = TextEditingController();
  final literasiController = TextEditingController();
  final umpanBalikController = TextEditingController();
  final tanggalController = TextEditingController();
  final pengamatanController = TextEditingController();
  final tujuanController = TextEditingController();
  final muridIdController = TextEditingController();
  final tanggapanController = TextEditingController();

  DateTime? _selectedDate;
  final ImagePicker picker = ImagePicker();
  File? _image;
  String? _errorMessage;
  static const int maxFileSize = 2 * 1024 * 1024;
  bool _isNewImage = false;
  bool _deleteImage = false;

  @override
  void initState() {
    super.initState();
    nilaiController.text = widget.anekdot.nilai;
    jatiDiriController.text = widget.anekdot.jatiDiri;
    literasiController.text = widget.anekdot.literasi;
    umpanBalikController.text = widget.anekdot.umpanBalik;
    tanggalController.text = widget.anekdot.tanggal;
    pengamatanController.text = widget.anekdot.pengamatan;
    tujuanController.text = widget.anekdot.tujuan;
    muridIdController.text = widget.anekdot.muridId;
    tanggapanController.text = widget.anekdot.tanggapan;
    _selectedDate = DateFormat('dd MMMM yyyy').parse(widget.anekdot.tanggal);
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
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final fileSize = await file.length();

        setState(() {
          _image = file;
          _isNewImage = true;

          _errorMessage = null;
        });
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

  void updateAnekdot() {
    if (_formKey.currentState!.validate()) {
      ref.read(anekdotControllerProvider.notifier).updateAnekdot(
          anekdotId: widget.anekdot.id,
          nilai: nilaiController.text,
          jatiDiri: jatiDiriController.text,
          literasi: literasiController.text,
          umpanBalik: umpanBalikController.text,
          tanggal: tanggalController.text,
          pengamatan: pengamatanController.text,
          tujuan: tujuanController.text,
          image: _image,
          imageId: widget.anekdot.imageId,
          deleteId: _deleteImage,
          muridId: muridIdController.text,
          tanggapan: tanggapanController.text,
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
        title: 'Edit Anekdotal',
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
              Column(
                children: <Widget>[
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
                      child: _deleteImage
                          ? const Icon(Icons.image_not_supported, size: 50)
                          : _isNewImage && _image != null
                              ? Image.file(_image!, fit: BoxFit.cover)
                              : widget.anekdot.imageId.isNotEmpty
                                  ? ref
                                      .watch(getAnekdotImageProvider(
                                          widget.anekdot.imageId))
                                      .when(
                                        data: (imageData) {
                                          return imageData != null
                                              ? Image.memory(imageData,
                                                  fit: BoxFit.cover)
                                              : const Icon(
                                                  Icons.image_not_supported);
                                        },
                                        loading: () => const Loader(),
                                        error: (_, __) =>
                                            const Icon(Icons.error),
                                      )
                                  : const Icon(Icons.add_photo_alternate,
                                      size: 50),
                    ),
                  ),
                  if (widget.levelUser != 3)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _pickImage,
                          child: const Text('Pilih Gambar'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              if (_deleteImage) {
                                _image = null;
                              }
                              _deleteImage = !_deleteImage;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _deleteImage ? Colors.red : Colors.grey,
                          ),
                          child: Text(
                              _deleteImage ? 'Batal Hapus' : 'Hapus Gambar'),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                ],
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(_errorMessage!,
                      style: const TextStyle(color: Colors.red)),
                ),
              const SizedBox(
                height: 16,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: TextFormField(
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
                      return 'Tanggal tidak boleh kosong';
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
                  controller: pengamatanController,
                  maxLength: 500,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: 'Kegiatan'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kegiatan tidak boleh kosong';
                    }
                    return null;
                  },
                  readOnly: widget.levelUser == 3,
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
                      labelText: 'Tujuan Pembelajaran'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tujuan Pembelajaran tidak boleh kosong';
                    }
                    return null;
                  },
                  readOnly: widget.levelUser == 3,
                ),
              ),
              muridAsyncValue.when(
                data: (muridList) {
                  final currentMuridExists = muridList
                      .any((murid) => murid.id == muridIdController.text);
                  if (!currentMuridExists) {
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
                    padding: const EdgeInsets.only(bottom: 22),
                    child: DropdownButtonFormField<String>(
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
                      value: widget.anekdot.muridId,
                      onChanged: widget.levelUser != 3
                          ? (String? newValue) {
                              muridIdController.text = newValue ?? '';
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
                error: (error, stack) => Text('Error: $error'),
              ),
              const SizedBox(
                height: 16,
              ),
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
                      labelText: 'Nilai Agama dan Budi Pekerti'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nilai Agama dan Budi Pekerti tidak boleh kosong';
                    }
                    return null;
                  },
                  readOnly: widget.levelUser == 3,
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
                      border: OutlineInputBorder(), labelText: 'Jati Diri'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Jati Diri tidak boleh kosong';
                    }
                    return null;
                  },
                  readOnly: widget.levelUser == 3,
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
                      labelText: 'Literasi dan STEAM'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Literasi dan STEAM tidak boleh kosong';
                    }
                    return null;
                  },
                  readOnly: widget.levelUser == 3,
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
                      border: OutlineInputBorder(), labelText: 'Umpan Balik'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Umpan Balik tidak boleh kosong';
                    }
                    return null;
                  },
                  readOnly: widget.levelUser == 3,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: TextFormField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  minLines: 2,
                  controller: tanggapanController,
                  maxLength: 500,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Tanggapan Orang Tua'),
                  readOnly: widget.levelUser != 3,
                ),
              ),
              isLoading
                  ? const Loader()
                  : ElevatedButton(
                      onPressed: () {
                        updateAnekdot();
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
                        child: const Text("Simpan Perubahan",
                            style: TextStyle(
                                fontFamily: 'inter', color: Colors.white)),
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
