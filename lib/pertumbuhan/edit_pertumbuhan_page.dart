import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sippa/add_user/controller/user_controller.dart';
import 'package:sippa/common/loading.dart';
import 'package:sippa/models/pertumbuhan.dart';
import 'package:sippa/pertumbuhan/controller/pertumbuhanController.dart';
import 'package:sippa/widget_view/appbar.dart';
import 'package:sippa/widget_view/teks.dart';

class EditPertumbuhanPage extends ConsumerStatefulWidget {
  static route(
          {required String kelompok,
          required String sekolah,
          required PertumbuhanModel pertumbuhan,
          required int levelUser}) =>
      MaterialPageRoute(
          builder: (context) => EditPertumbuhanPage(
                kelompok: kelompok,
                sekolah: sekolah,
                pertumbuhan: pertumbuhan,
                levelUser: levelUser,
              ));

  final String kelompok;
  final String sekolah;
  final PertumbuhanModel pertumbuhan;
  final int levelUser;

  const EditPertumbuhanPage(
      {super.key,
      required this.kelompok,
      required this.sekolah,
      required this.pertumbuhan,
      required this.levelUser});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditPertumbuhanPageState();
}

class _EditPertumbuhanPageState extends ConsumerState<EditPertumbuhanPage> {
  final _formKey = GlobalKey<FormState>();
  final tinggiController = TextEditingController();
  final beratController = TextEditingController();
  final kepalaController = TextEditingController();
  final fisikController = TextEditingController();
  final rekomendasiController = TextEditingController();
  final tanggapanController = TextEditingController();
  final tanggalController = TextEditingController();
  final muridIdController = TextEditingController();
  DateTime? _selectedDate;
  late final Map<String, String> _filterParams;

  @override
  void initState() {
    super.initState();
    tinggiController.text = widget.pertumbuhan.tinggi.toString();
    beratController.text = widget.pertumbuhan.berat.toString();
    kepalaController.text = widget.pertumbuhan.kepala.toString();
    fisikController.text = widget.pertumbuhan.fisik;
    rekomendasiController.text = widget.pertumbuhan.rekomendasi;
    tanggapanController.text = widget.pertumbuhan.tanggapan;
    tanggalController.text = widget.pertumbuhan.tanggal;
    muridIdController.text = widget.pertumbuhan.muridId;

    _selectedDate =
        DateFormat('dd MMMM yyyy').parse(widget.pertumbuhan.tanggal);
    _filterParams = {
      'kelompok': widget.kelompok,
      'sekolah': widget.sekolah,
    };
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

  void updatePertumbuhan() {
    if (_formKey.currentState!.validate()) {
      ref.read(pertumbuhanControllerProvider.notifier).updatePertumbuhan(
            tanggal: tanggalController.text,
            muridId: muridIdController.text,
            tinggi: int.parse(tinggiController.text),
            berat: int.parse(beratController.text),
            kepala: int.parse(kepalaController.text),
            fisik: fisikController.text,
            rekomendasi: rekomendasiController.text,
            tanggapan: tanggapanController.text,
            context: context,
            sekolah: widget.sekolah,
            pertumbuhanId: widget.pertumbuhan.id,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final muridAsyncValue = ref.watch(getMuridByFiltersProvider(_filterParams));
    final isLoading = ref.watch(pertumbuhanControllerProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Edit Pertumbuhan',
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 16),
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
                      value: widget.pertumbuhan.muridId,
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
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: TextFormField(
                  controller: tinggiController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Tinggi Badan (cm)',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tinggi badan tidak boleh kosong';
                    }
                    return null;
                  },
                  readOnly: widget.levelUser == 3,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: TextFormField(
                  controller: beratController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Berat Badan (kg)',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Berat badan tidak boleh kosong';
                    }
                    return null;
                  },
                  readOnly: widget.levelUser == 3,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: TextFormField(
                  controller: kepalaController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Lingkar Kepala (cm)',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lingkar kepala tidak boleh kosong';
                    }
                    return null;
                  },
                  readOnly: widget.levelUser == 3,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: TextFormField(
                  controller: fisikController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Kondisi Fisik',
                  ),
                  maxLines: null,
                  minLines: 2,
                  maxLength: 500,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kondisi fisik tidak boleh kosong';
                    }
                    return null;
                  },
                  readOnly: widget.levelUser == 3,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: TextFormField(
                  controller: rekomendasiController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Umpan Balik',
                  ),
                  minLines: 2,
                  maxLength: 500,
                  maxLines: null,
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
                  controller: tanggapanController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Tanggapan Orang Tua',
                  ),
                  maxLength: 500,
                  minLines: 2,
                  maxLines: null,
                  readOnly: widget.levelUser != 3,
                ),
              ),
              isLoading
                  ? const Loader()
                  : ElevatedButton(
                      onPressed: () {
                        updatePertumbuhan();
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
                height: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
