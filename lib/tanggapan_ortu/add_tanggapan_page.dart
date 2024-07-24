import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sippa/tanggapan_ortu/controller/tanggapan_controller.dart';
import 'package:sippa/widget_view/appbar.dart';

class AddTanggapanPage extends ConsumerStatefulWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const AddTanggapanPage());

  const AddTanggapanPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddTanggapanPageState();
}

class _AddTanggapanPageState extends ConsumerState<AddTanggapanPage> {
  final _formKey = GlobalKey<FormState>();
  final tanggapanController = TextEditingController();
  final tanggalTanggapanController = TextEditingController();
  DateTime? _selectedTanggapanDate;

  @override
  void dispose() {
    super.dispose();
    tanggapanController.dispose();
    tanggalTanggapanController.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedTanggapanDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedTanggapanDate = picked;
        tanggalTanggapanController.text =
            DateFormat('dd MMMM yyyy').format(_selectedTanggapanDate!);
      });
    }
  }

  void addTanggapan() {
    if (_formKey.currentState!.validate()) {
      ref.read(tanggapanControllerProvider.notifier).addTanggapan(
          tanggapan: tanggapanController.text,
          tanggal: tanggalTanggapanController.text,
          balasan: '',
          context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Tambah Tanggapan',
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
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 22),
                    child: TextFormField(
                      controller: tanggapanController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      minLines: 3,
                      maxLength: 500,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Tanggapan',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan tanggapan';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 22),
                    child: TextFormField(
                      controller: tanggalTanggapanController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'Tanggal Tanggapan',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () => _selectDate(context),
                        ),
                      ),
                      readOnly: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pilih tanggal tanggapan';
                        }
                        return null;
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      addTanggapan();
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
                        "Tambah Tanggapan",
                        style: TextStyle(
                          fontFamily: 'inter',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
