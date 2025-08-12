// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:sippa/add_user/controller/user_controller.dart';
import 'package:sippa/capaian_pembelajaran/controller/cp_controller.dart';
import 'package:sippa/common/loading.dart';
import 'package:sippa/widget_view/appbar.dart';
import 'package:sippa/widget_view/teks.dart';

class AddCpPage extends ConsumerStatefulWidget {
  static route({required kelompok, required sekolah}) => MaterialPageRoute(
      builder: (context) => AddCpPage(kelompok: kelompok, sekolah: sekolah));
  final String kelompok;
  final String sekolah;
  const AddCpPage({
    super.key,
    required this.kelompok,
    required this.sekolah,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddCpPageState();
}

class _AddCpPageState extends ConsumerState<AddCpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController tujuanController = TextEditingController();
  final TextEditingController konteksController = TextEditingController();
  final TextEditingController agamaController = TextEditingController();
  final TextEditingController jatidiriController = TextEditingController();
  final TextEditingController literasiController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();
  final TextEditingController muridIdController = TextEditingController();
  final TextEditingController rekomendasiController = TextEditingController();
  DateTime? _selectedDate;
  bool isDone = false;
  @override
  void dispose() {
    super.dispose();
    agamaController.dispose();
    jatidiriController.dispose();
    literasiController.dispose();
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

  void addCp() {
    if (_formKey.currentState!.validate()) {
      ref.read(cpControllerProvider.notifier).addCp(
          tujuan: tujuanController.text,
          tanggal: tanggalController.text,
          konteks: konteksController.text,
          agama: agamaController.text,
          jatidiri: jatidiriController.text,
          literasi: literasiController.text,
          isDone: isDone,
          muridId: muridIdController.text,
          rekomendasi: rekomendasiController.text,
          context: context,
          sekolah: widget.sekolah);
    }
  }

  late final Map<String, String> _filterParams;

  @override
  void initState() {
    super.initState();
    _filterParams = {
      'kelompok': widget.kelompok,
      'sekolah': widget.sekolah,
    };
  }

  @override
  Widget build(BuildContext context) {
    final muridAsyncValue = ref.watch(getMuridByFiltersProvider(_filterParams));
    final isLoading = ref.watch(cpControllerProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Tambah Ceklis',
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 31, right: 31),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 30),
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
              TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                minLines: 3,
                controller: konteksController,
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
              const SizedBox(height: 16),
              TextFormField(
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
                loading: () => const Loader(),
                error: (error, stack) => CustomText(text: 'Error: $error'),
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        isDone = false;
                      });
                    },
                    child: Row(
                      children: [
                        Radio(
                          value: false,
                          groupValue: isDone,
                          onChanged: (value) {
                            setState(() {
                              isDone = value!;
                            });
                          },
                        ),
                        const CustomText(text: 'Belum Muncul'),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        isDone = true;
                      });
                    },
                    child: Row(
                      children: [
                        Radio(
                          value: true,
                          groupValue: isDone,
                          onChanged: (value) {
                            setState(() {
                              isDone = value!;
                            });
                          },
                        ),
                        const CustomText(text: 'Sudah Muncul'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                minLines: 3,
                controller: agamaController,
                maxLength: 500,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Nilai Agama dan Budi Pekerti',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan Nilai Agama dan Budi Pekerti';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                minLines: 3,
                controller: jatidiriController,
                maxLength: 500,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Jati Diri',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan Jati Diri';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                minLines: 3,
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
              const SizedBox(height: 16),
              TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                minLines: 3,
                controller: rekomendasiController,
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
              const SizedBox(height: 16),
              isLoading
                  ? const Loader()
                  : ElevatedButton(
                      onPressed: () {
                        addCp();
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
                        child: const CustomText(
                          text: "Tambah Ceklis",
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
