// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:sippa/add_user/controller/user_controller.dart';
import 'package:sippa/capaian_pembelajaran/controller/cp_controller.dart';
import 'package:sippa/widget_view/appbar.dart';
import 'package:sippa/widget_view/teks.dart';

class AddCpPage extends ConsumerStatefulWidget {
  static route({required kelompok}) =>
      MaterialPageRoute(builder: (context) => AddCpPage(kelompok: kelompok));
  final String kelompok;
  const AddCpPage({
    super.key,
    required this.kelompok,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddCpPageState();
}

class _AddCpPageState extends ConsumerState<AddCpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController tujuanController = TextEditingController();
  final TextEditingController konteksController = TextEditingController();
  final TextEditingController teramatiController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();
  final TextEditingController muridIdController = TextEditingController();
  DateTime? _selectedDate;
  bool isDone = false;
  @override
  void dispose() {
    super.dispose();
    tujuanController.dispose();
    tanggalController.dispose();
    konteksController.dispose();
    teramatiController.dispose();
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
          teramati: teramatiController.text,
          isDone: isDone,
          muridId: muridIdController.text,
          context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final muridAsyncValue =
        ref.watch(getMuridByFiltersProvider(widget.kelompok));

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Tambah CP',
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 31, right: 31),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 30),
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
              TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                minLines: 3,
                controller: tujuanController,
                maxLength: 500,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Tujuan',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan Tujuan';
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
                  labelText: 'Konteks',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan Konteks';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                minLines: 3,
                controller: teramatiController,
                maxLength: 500,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Teramati',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan Teramati';
                  }
                  return null;
                },
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
              ElevatedButton(
                onPressed: () {
                  addCp();
                },
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
                    text: "Tambah Capaian",
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
