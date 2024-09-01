// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:sippa/add_user/controller/user_controller.dart';
import 'package:sippa/common/loading.dart';
import 'package:sippa/rubrik/controller/rubrik_controller.dart';
import 'package:sippa/widget_view/appbar.dart';
import 'package:sippa/widget_view/teks.dart';

class AddRubrikPage extends ConsumerStatefulWidget {
  static route({required kelompok}) => MaterialPageRoute(
      builder: (context) => AddRubrikPage(kelompok: kelompok));
  final String kelompok;
  const AddRubrikPage({
    super.key,
    required this.kelompok,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddRubrikPageState();
}

class _AddRubrikPageState extends ConsumerState<AddRubrikPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController tujuanController = TextEditingController();
  final TextEditingController kegiatanController = TextEditingController();
  final TextEditingController agamaController = TextEditingController();
  final TextEditingController jatidiriController = TextEditingController();
  final TextEditingController literasiController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();
  final TextEditingController muridIdController = TextEditingController();
  final TextEditingController rekomendasiController = TextEditingController();
  DateTime? _selectedDate;
  String skor = '1';

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

  void addRubrik() {
    if (_formKey.currentState!.validate()) {
      ref.read(rubrikControllerProvider.notifier).addRubrik(
          tujuan: tujuanController.text,
          tanggal: tanggalController.text,
          // kegiatan: kegiatanController.text,
          agama: agamaController.text,
          jatidiri: jatidiriController.text,
          literasi: literasiController.text,
          skor: skor,
          muridId: muridIdController.text,
          rekomendasi: rekomendasiController.text,
          context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final muridAsyncValue =
        ref.watch(getMuridByFiltersProvider(widget.kelompok));
    final isLoading = ref.watch(rubrikControllerProvider);
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Tambah Rubrik',
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
              // const SizedBox(height: 16),
              // TextFormField(
              //   keyboardType: TextInputType.multiline,
              //   maxLines: null,
              //   minLines: 3,
              //   controller: kegiatanController,
              //   maxLength: 500,
              //   decoration: const InputDecoration(
              //     border: OutlineInputBorder(),
              //     labelText: 'Kegiatan',
              //   ),
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Masukkan Kegiatan';
              //     }
              //     return null;
              //   },
              // ),
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
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                isExpanded: true,
                value: skor,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Skor',
                ),
                items: const [
                  DropdownMenuItem(
                    value: '1',
                    child: CustomText(
                      text: 'Skor 1: Belum Mencapai Tujuan Pembelajaran',
                    ),
                  ),
                  DropdownMenuItem(
                    value: '2',
                    child: CustomText(
                      text:
                          'Skor 2: Mencapai Tujuan Pembelajaran dengan Bantuan',
                    ),
                  ),
                  DropdownMenuItem(
                    value: '3',
                    child: CustomText(
                      text:
                          'Skor 3: Mencapai Tujuan Pembelajaran Secara Mandiri',
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    skor = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pilih Skor';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
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
                      onPressed: addRubrik,
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
                      child: const CustomText(
                        text: "Tambah Rubrik",
                        color: Colors.white,
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
