import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sippa/add_user/controller/user_controller.dart';
import 'package:sippa/common/loading.dart';
import 'package:sippa/pertumbuhan/controller/pertumbuhanController.dart';
import 'package:sippa/widget_view/appbar.dart';

class AddPertumbuhanPage extends ConsumerStatefulWidget {
  static route({required kelompok}) => MaterialPageRoute(
      builder: (context) => AddPertumbuhanPage(kelompok: kelompok));

  final String kelompok;
  const AddPertumbuhanPage({super.key, required this.kelompok});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddPertumbuhanPageState();
}

class _AddPertumbuhanPageState extends ConsumerState<AddPertumbuhanPage> {
  final _formKey = GlobalKey<FormState>();
  final tanggalController = TextEditingController();
  final tinggiController = TextEditingController();
  final beratController = TextEditingController();
  final kepalaController = TextEditingController();
  final fisikController = TextEditingController();
  final rekomendasiController = TextEditingController();
  final muridIdController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    super.dispose();
    tanggalController.dispose();
    tinggiController.dispose();
    beratController.dispose();
    kepalaController.dispose();
    fisikController.dispose();
    rekomendasiController.dispose();
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

  void addPertumbuhan() {
    if (_formKey.currentState!.validate()) {
      ref.read(pertumbuhanControllerProvider.notifier).addPertumbuhan(
            tanggal: tanggalController.text,
            muridId: muridIdController.text,
            tinggi: int.parse(tinggiController.text),
            berat: int.parse(beratController.text),
            kepala: int.parse(kepalaController.text),
            fisik: fisikController.text,
            rekomendasi: rekomendasiController.text,
            context: context,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final muridAsyncValue =
        ref.watch(getMuridByFiltersProvider(widget.kelompok));
    final isLoading = ref.watch(pertumbuhanControllerProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Tambah Pertumbuhan',
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 31),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 16),
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
              muridAsyncValue.when(
                data: (muridList) {
                  return DropdownButtonFormField<String>(
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
                  );
                },
                loading: () => const Loader(),
                error: (error, stack) => Text('Error: $error'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: tinggiController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Tinggi Badan (cm)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan Tinggi Badan';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: beratController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Berat Badan (kg)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan Berat Badan';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: kepalaController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Lingkar Kepala (cm)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan Lingkar Kepala';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: fisikController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Kondisi Fisik',
                ),
                maxLength: 500,
                minLines: 3,
                maxLines: null,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan kondisi fisik';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: rekomendasiController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Umpan Balik',
                ),
                maxLength: 500,
                minLines: 3,
                maxLines: null,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan Umpan Balik';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              isLoading
                  ? const Loader()
                  : ElevatedButton(
                      onPressed: addPertumbuhan,
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
                      child: const Text(
                        "Tambah Data Pertumbuhan",
                        style: TextStyle(
                          fontFamily: 'inter',
                          color: Colors.white,
                        ),
                      ),
                    ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
