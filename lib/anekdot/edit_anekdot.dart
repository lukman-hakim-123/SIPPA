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
  final analisisCapaianController = TextEditingController();
  final tanggalController = TextEditingController();
  final pengamatanController = TextEditingController();
  final muridIdController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    analisisCapaianController.text = widget.anekdot.analisisCapaian;
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
    ref.read(anekdotControllerProvider.notifier).updateAnekdot(
        anekdotId: widget.anekdot.id,
        analisisCapaian: analisisCapaianController.text,
        tanggal: tanggalController.text,
        pengamatan: pengamatanController.text,
        muridId: muridIdController.text,
        context: context);
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
                    // Schedule the SnackBar to show after the current build phase
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
                    ),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => Text('Error: $error'),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: Column(
                  children: [
                    TextField(
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
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  minLines: 5,
                  controller: pengamatanController,
                  maxLength: 1000,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: 'Pengamatan'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  minLines: 5,
                  controller: analisisCapaianController,
                  maxLength: 1000,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Analisis Capaian'),
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
                      style:
                          TextStyle(fontFamily: 'inter', color: Colors.white)),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
      )),
    );
  }
}
