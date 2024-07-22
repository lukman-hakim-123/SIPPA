import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sippa/add_user/controller/user_controller.dart';
import 'package:sippa/anekdot/controller/anekdot_controller.dart';
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
  final analisisCapaianController = TextEditingController();
  final tanggalController = TextEditingController();
  final pengamatanController = TextEditingController();
  final muridIdController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    super.dispose();
    analisisCapaianController.dispose();
    tanggalController.dispose();
    pengamatanController.dispose();
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

  void addAnekdot() {
    if (_formKey.currentState!.validate()) {
      ref.read(anekdotControllerProvider.notifier).addAnekdot(
          analisisCapaian: analisisCapaianController.text,
          tanggal: tanggalController.text,
          pengamatan: pengamatanController.text,
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
        title: 'Tambah Anekdot',
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            right: 31,
            left: 31,
            bottom: 40,
          ),
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(
                    height: 40,
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
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => Text('Error: $error'),
                  ),
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 22),
                    child: TextFormField(
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      minLines: 5,
                      controller: pengamatanController,
                      maxLength: 1000,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Pengamatan',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan pengamatan';
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
                      minLines: 5,
                      controller: analisisCapaianController,
                      maxLength: 1000,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Analisis Capaian',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan analisis capaian';
                        }
                        return null;
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      addAnekdot();
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
                      child: const Text(
                        "Tambah Anekdot",
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
        ),
      ),
    );
  }
}
