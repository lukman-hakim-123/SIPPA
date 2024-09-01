import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sippa/add_user/controller/user_controller.dart';
import 'package:sippa/common/loading.dart';
import 'package:sippa/models/rubrik.dart';
import 'package:sippa/rubrik/controller/rubrik_controller.dart';
import 'package:sippa/widget_view/appbar.dart';
import 'package:sippa/widget_view/teks.dart';

class EditRubrikPage extends ConsumerStatefulWidget {
  static route(
          {required RubrikModel rubrik,
          required String kelompok,
          required int levelUser}) =>
      MaterialPageRoute(
        builder: (context) => EditRubrikPage(
          rubrik: rubrik,
          kelompok: kelompok,
          levelUser: levelUser,
        ),
      );
  final RubrikModel rubrik;
  final String kelompok;
  final int levelUser;

  const EditRubrikPage(
      {super.key,
      required this.rubrik,
      required this.kelompok,
      required this.levelUser});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EditRubrikPageState();
}

class _EditRubrikPageState extends ConsumerState<EditRubrikPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController tujuanController;
  late TextEditingController kegiatanController;
  late TextEditingController agamaController;
  late TextEditingController jatidiriController;
  late TextEditingController literasiController;
  late TextEditingController tanggalController;
  late TextEditingController muridIdController;
  late TextEditingController rekomendasiController;
  late TextEditingController tanggapanController;
  DateTime? _selectedDate;
  String? score;

  @override
  void initState() {
    super.initState();
    tujuanController = TextEditingController(text: widget.rubrik.tujuan);
    kegiatanController = TextEditingController(text: widget.rubrik.kegiatan);
    agamaController = TextEditingController(text: widget.rubrik.agama);
    jatidiriController = TextEditingController(text: widget.rubrik.jatidiri);
    literasiController = TextEditingController(text: widget.rubrik.literasi);
    tanggalController = TextEditingController(text: widget.rubrik.tanggal);
    muridIdController = TextEditingController(text: widget.rubrik.muridId);
    rekomendasiController =
        TextEditingController(text: widget.rubrik.rekomendasi);
    tanggapanController = TextEditingController(text: widget.rubrik.tanggapan);
    score = widget.rubrik.skor;
    _selectedDate = DateFormat('dd MMMM yyyy').parse(widget.rubrik.tanggal);
  }

  @override
  void dispose() {
    super.dispose();
    tujuanController.dispose();
    tanggalController.dispose();
    kegiatanController.dispose();
    agamaController.dispose();
    jatidiriController.dispose();
    literasiController.dispose();
    rekomendasiController.dispose();
    tanggapanController.dispose();
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

  void editRubrik() {
    if (_formKey.currentState!.validate()) {
      ref.read(rubrikControllerProvider.notifier).updateRubrik(
            rubrikId: widget.rubrik.id,
            tujuan: tujuanController.text,
            tanggal: tanggalController.text,
            // kegiatan: kegiatanController.text,
            agama: agamaController.text,
            jatidiri: jatidiriController.text,
            literasi: literasiController.text,
            skor: score!,
            muridId: muridIdController.text,
            context: context,
            rekomendasi: rekomendasiController.text,
            tanggapan: tanggapanController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final muridAsyncValue =
        ref.watch(getMuridByFiltersProvider(widget.kelompok));
    final isLoading = ref.watch(rubrikControllerProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Edit Rubrik',
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
              //   readOnly: widget.levelUser == 3,
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
                  labelText: 'Tujuan',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan Tujuan';
                  }
                  return null;
                },
                readOnly: widget.levelUser == 3,
              ),
              const SizedBox(height: 16),
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
                    padding: const EdgeInsets.only(bottom: 16),
                    child: DropdownButtonFormField<String>(
                      value: muridIdController.text,
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
                value: score,
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
                onChanged: widget.levelUser != 3
                    ? (value) {
                        setState(() {
                          score = value!;
                        });
                      }
                    : null,
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
                readOnly: widget.levelUser == 3,
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
                readOnly: widget.levelUser == 3,
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
                readOnly: widget.levelUser == 3,
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
                readOnly: widget.levelUser == 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                minLines: 3,
                controller: tanggapanController,
                maxLength: 500,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Tanggapan Orang Tua',
                ),
                readOnly: widget.levelUser != 3,
              ),
              const SizedBox(height: 16),
              isLoading
                  ? const Loader()
                  : ElevatedButton(
                      onPressed: () {
                        editRubrik();
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
                          text: "Simpan Perubahan",
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
