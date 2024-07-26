import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sippa/auth/controllers/auth_controller.dart';
import 'package:sippa/models/to.dart';
import 'package:sippa/tanggapan_ortu/controller/tanggapan_controller.dart';
import 'package:sippa/widget_view/appbar.dart';

class EditTanggapanPage extends ConsumerStatefulWidget {
  final TanggapanModel tanggapan;

  static route({required TanggapanModel tanggapan}) => MaterialPageRoute(
      builder: (context) => EditTanggapanPage(tanggapan: tanggapan));

  const EditTanggapanPage({super.key, required this.tanggapan});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditTanggapanPageState();
}

class _EditTanggapanPageState extends ConsumerState<EditTanggapanPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController tanggapanController;
  late final TextEditingController tanggalTanggapanController;
  late final TextEditingController balasanController;

  @override
  void initState() {
    super.initState();
    tanggapanController =
        TextEditingController(text: widget.tanggapan.tanggapan);
    tanggalTanggapanController =
        TextEditingController(text: widget.tanggapan.tanggal);
    balasanController = TextEditingController(text: widget.tanggapan.balasan);
  }

  @override
  void dispose() {
    tanggapanController.dispose();
    tanggalTanggapanController.dispose();
    balasanController.dispose();
    super.dispose();
  }

  void editTanggapan() {
    if (_formKey.currentState!.validate()) {
      ref.read(tanggapanControllerProvider.notifier).updateTanggapan(
          tanggapan: tanggapanController.text,
          tanggal: tanggalTanggapanController.text,
          balasan: balasanController.text,
          kelompok: widget.tanggapan.kelompok,
          muridId: widget.tanggapan.muridId,
          tanggapanId: widget.tanggapan.id,
          context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userDetailsAsync = ref.watch(currentUserDetailsProvider);
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Edit Tanggapan',
      ),
      backgroundColor: Colors.white,
      body: userDetailsAsync.when(
        data: (userDetails) {
          final levelUser = userDetails!.levelUser;
          return SingleChildScrollView(
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
                          readOnly: levelUser != 3,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 22),
                        child: TextFormField(
                          controller: tanggalTanggapanController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Tanggal Tanggapan',
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
                      Padding(
                        padding: const EdgeInsets.only(bottom: 22),
                        child: TextFormField(
                          controller: balasanController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Balasan',
                          ),
                          maxLines: null,
                          minLines: 3,
                          maxLength: 500,
                          onChanged: (value) {
                            widget.tanggapan.balasan = value;
                          },
                          readOnly: levelUser == 3,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          editTanggapan();
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              const Color(0xff104993)),
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
                          child: const Text(
                            "Simpan Perubahan",
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => const Center(child: Text('Error')),
      ),
    );
  }
}
