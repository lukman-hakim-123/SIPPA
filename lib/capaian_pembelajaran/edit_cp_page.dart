import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sippa/add_user/controller/user_controller.dart';
import 'package:sippa/capaian_pembelajaran/controller/cp_controller.dart';
import 'package:sippa/common/loading.dart';
import 'package:sippa/models/cp.dart';
import 'package:sippa/widget_view/appbar.dart';
import 'package:sippa/widget_view/teks.dart';

class EditCpPage extends ConsumerStatefulWidget {
  static route(
          {required CpModel cp,
          required String kelompok,
          required String sekolah,
          required int levelUser}) =>
      MaterialPageRoute(
        builder: (context) => EditCpPage(
          cp: cp,
          kelompok: kelompok,
          sekolah: sekolah,
          levelUser: levelUser,
        ),
      );
  final CpModel cp;
  final String kelompok;
  final String sekolah;
  final int levelUser;

  const EditCpPage(
      {super.key,
      required this.cp,
      required this.kelompok,
      required this.sekolah,
      required this.levelUser});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EditCpPageState();
}

class _EditCpPageState extends ConsumerState<EditCpPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController tujuanController;
  late TextEditingController konteksController;
  late TextEditingController agamaController;
  late TextEditingController jatidiriController;
  late TextEditingController literasiController;
  late TextEditingController tanggalController;
  late TextEditingController muridIdController;
  late TextEditingController rekomendasiController;
  late TextEditingController tanggapanController;
  DateTime? _selectedDate;
  bool? isDone;
  late final Map<String, String> _filterParams;

  @override
  void initState() {
    super.initState();
    tujuanController = TextEditingController(text: widget.cp.tujuan);
    konteksController = TextEditingController(text: widget.cp.konteks);
    agamaController = TextEditingController(text: widget.cp.agama);
    jatidiriController = TextEditingController(text: widget.cp.jatidiri);
    literasiController = TextEditingController(text: widget.cp.literasi);
    tanggalController = TextEditingController(text: widget.cp.tanggal);
    muridIdController = TextEditingController(text: widget.cp.muridId);
    rekomendasiController = TextEditingController(text: widget.cp.rekomendasi);
    tanggapanController = TextEditingController(text: widget.cp.tanggapan);
    isDone = widget.cp.isDone;
    _selectedDate = DateFormat('dd MMMM yyyy').parse(widget.cp.tanggal);
    _filterParams = {
      'kelompok': widget.kelompok,
      'sekolah': widget.sekolah,
    };
  }

  @override
  void dispose() {
    super.dispose();
    tujuanController.dispose();
    tanggalController.dispose();
    konteksController.dispose();
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

  void editCp() {
    if (_formKey.currentState!.validate()) {
      ref.read(cpControllerProvider.notifier).updateCp(
            cpId: widget.cp.id,
            tujuan: tujuanController.text,
            tanggal: tanggalController.text,
            konteks: konteksController.text,
            agama: agamaController.text,
            jatidiri: jatidiriController.text,
            literasi: literasiController.text,
            isDone: isDone!,
            muridId: muridIdController.text,
            context: context,
            rekomendasi: rekomendasiController.text,
            tanggapan: tanggapanController.text,
            sekolah: widget.sekolah,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final muridAsyncValue = ref.watch(getMuridByFiltersProvider(_filterParams));
    final isLoading = ref.watch(cpControllerProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Edit Ceklis',
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
                readOnly: widget.levelUser == 3,
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
                error: (error, stack) => CustomText(text: 'Error: $error'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (widget.levelUser != 3) {
                          isDone = false;
                        }
                      });
                    },
                    child: Row(
                      children: [
                        Radio(
                          value: false,
                          groupValue: isDone,
                          onChanged: (value) {
                            setState(() {
                              if (widget.levelUser != 3) {
                                isDone = value!;
                              }
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
                        if (widget.levelUser != 3) {
                          isDone = true;
                        }
                      });
                    },
                    child: Row(
                      children: [
                        Radio(
                          value: true,
                          groupValue: isDone,
                          onChanged: (value) {
                            setState(() {
                              if (widget.levelUser != 3) {
                                isDone = value!;
                              }
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
                        editCp();
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
