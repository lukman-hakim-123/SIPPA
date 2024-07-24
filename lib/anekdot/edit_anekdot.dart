import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sippa/add_user/controller/user_controller.dart';
import 'package:sippa/anekdot/controller/anekdot_controller.dart';
import 'package:sippa/models/anekdot.dart';
import 'package:sippa/widget_view/appbar.dart';

class EditAnekdotPage extends ConsumerStatefulWidget {
  static route({required String kelompok, required AnekdotModel anekdot}) =>
      MaterialPageRoute(
          builder: (context) => EditAnekdotPage(
                kelompok: kelompok,
                anekdot: anekdot,
              ));

  final String kelompok;
  final AnekdotModel anekdot;

  const EditAnekdotPage(
      {super.key, required this.kelompok, required this.anekdot});

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
  final muridIdController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    nilaiController.text = widget.anekdot.nilai;
    jatiDiriController.text = widget.anekdot.jatiDiri;
    literasiController.text = widget.anekdot.literasi;
    umpanBalikController.text = widget.anekdot.umpanBalik;
    tanggalController.text = widget.anekdot.tanggal;
    pengamatanController.text = widget.anekdot.pengamatan;
    muridIdController.text = widget.anekdot.muridId;
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
        title: 'Edit Anekdot',
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
                            child: Text(murid.nama),
                          );
                        }).toList(),
                        value: widget.anekdot.muridId,
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
                    maxLength: 1000,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), labelText: 'Pengamatan'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Pengamatan tidak boleh kosong';
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
                    controller: nilaiController,
                    maxLength: 500,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Nilai agama dan budi pekerti'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nilai agama dan budi pekerti tidak boleh kosong';
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
                        border: OutlineInputBorder(), labelText: 'Jati Diri'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Jati Diri tidak boleh kosong';
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
                        labelText: 'Literasi dan STEAM'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Literasi dan STEAM tidak boleh kosong';
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
                        border: OutlineInputBorder(), labelText: 'Umpan Balik'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Umpan Balik tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    updateAnekdot();
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
                    child: const Text("Edit Anekdot",
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
      )),
    );
  }
}
