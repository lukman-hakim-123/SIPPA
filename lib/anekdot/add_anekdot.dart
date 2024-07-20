import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sippa/widget_view/appbar.dart';
import 'package:sippa/widget_view/drawer.dart';
import 'package:sippa/widget_view/field.dart';

class AddAnekdotPage extends ConsumerStatefulWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const AddAnekdotPage());
  const AddAnekdotPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddAnekdotPageState();
}

class _AddAnekdotPageState extends ConsumerState<AddAnekdotPage> {
  int _selectedIndex = 2;

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final analisisCapaianController = TextEditingController();
  final tanggalController = TextEditingController();
  final bulanController = TextEditingController();
  final muridIdController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    analisisCapaianController.dispose();
    tanggalController.dispose();
  }

  bool _obscureText = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Tambah Murid',
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
                height: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: CustomTextField(
                  labelText: "Bulan",
                  controller: bulanController,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: CustomTextField(
                  labelText: "muridId",
                  controller: muridIdController,
                  forceUppercase: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: TextField(
                  keyboardType: TextInputType.text,
                  controller: analisisCapaianController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'analisisCapaian'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: TextField(
                  obscureText: _obscureText,
                  controller: tanggalController,
                  decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(_obscureText
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText; // Toggle _obscureText
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                      labelText: 'tanggal'),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // onSignup();
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
                  child: const Text("Tambah Murid",
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
      drawer: CustomDrawer(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemSelected,
      ),
    );
  }
}
