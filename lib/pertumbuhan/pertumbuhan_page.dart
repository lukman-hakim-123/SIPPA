import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'package:sippa/auth/controllers/auth_controller.dart';
import 'package:sippa/common/loading.dart';
import 'package:sippa/common/reload.dart';
import 'package:sippa/constant/appwrite.dart';
import 'package:sippa/models/pertumbuhan.dart';
import 'package:sippa/pertumbuhan/add_pertumbuhan_page.dart';
import 'package:sippa/pertumbuhan/controller/pertumbuhanController.dart';
import 'package:sippa/pertumbuhan/edit_pertumbuhan_page.dart';

import 'package:sippa/widget_view/appbar.dart';
import 'package:sippa/widget_view/calendar.dart';
import 'package:sippa/widget_view/drawer.dart';
import 'package:sippa/widget_view/teks.dart';

class PertumbuhanPage extends ConsumerStatefulWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const PertumbuhanPage());

  const PertumbuhanPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PertumbuhanPageState();
}

class _PertumbuhanPageState extends ConsumerState<PertumbuhanPage> {
  int _selectedIndex = 8;
  List<PertumbuhanModel> _pertumbuhanList = [];
  List<PertumbuhanModel> _filteredList = [];
  DateTime _selectedDate = DateTime.now();

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _filterList();
    });
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
  }

  void _filterList() {
    _filteredList = _pertumbuhanList.where((pertumbuhan) {
      final pertumbuhanDate =
          DateFormat("d MMMM yyyy").parse(pertumbuhan.tanggal);
      return pertumbuhanDate.year == _selectedDate.year &&
          pertumbuhanDate.month == _selectedDate.month &&
          pertumbuhanDate.day == _selectedDate.day;
    }).toList();
  }

  Future<void> _refreshData() async {
    // Refresh provider data manually
    await ref.refresh(pertumbuhanControllerProvider);
    // Re-fetch the data from provider
    final userDetails = await ref.read(currentUserDetailsProvider.future);
    if (userDetails != null) {
      final userId = userDetails.id;
      final sekolah = userDetails.sekolah;
      final paramKey = jsonEncode({'id': userId, 'sekolah': sekolah});
      final newPertumbuhanList =
          await ref.read(getPertumbuhanByUserIdProvider(paramKey).future);
      setState(() {
        _pertumbuhanList = newPertumbuhanList;
        _filterList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userDetailsAsync = ref.watch(currentUserDetailsProvider);
    return Scaffold(
      appBar: const CustomAppBar(title: 'Catatan Pertumbuhan'),
      body: Padding(
        padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
        child: userDetailsAsync.when(
          data: (userDetails) {
            if (userDetails == null) {
              return const Loader();
            }
            final userId = userDetails.id;
            final kelompok = userDetails.kelompok;
            final levelUser = userDetails.levelUser;
            final sekolah = userDetails.sekolah;
            final paramKey = jsonEncode({'id': userId, 'sekolah': sekolah});
            final pertumbuhanAsyncValue =
                ref.watch(getPertumbuhanByUserIdProvider(paramKey));
            ref.listen<AsyncValue<RealtimeMessage>>(
                getLatestPertumbuhanProvider, (_, next) {
              next.whenData((data) {
                final payloadSekolah = data.payload['sekolah'];
                if (payloadSekolah != sekolah) return;

                if (data.events.contains(
                  'databases.*.collections.${AppwriteConstants.pertumbuhanCollection}.documents.*.create',
                )) {
                  final newPertumbuhan = PertumbuhanModel.fromMap(data.payload);
                  if ((levelUser == 1) ||
                      (levelUser == 2 && newPertumbuhan.uid == userId) ||
                      (levelUser == 3 && newPertumbuhan.muridId == userId)) {
                    if (!_pertumbuhanList.any(
                        (pertumbuhan) => pertumbuhan.id == newPertumbuhan.id)) {
                      setState(() {
                        _pertumbuhanList.add(newPertumbuhan);
                        _filterList();
                      });
                    }
                  }
                } else if (data.events.contains(
                  'databases.*.collections.${AppwriteConstants.pertumbuhanCollection}.documents.*.update',
                )) {
                  final startingPoint =
                      data.events[0].lastIndexOf('documents.');
                  final endPoint = data.events[0].lastIndexOf('.update');
                  final pertumbuhanId =
                      data.events[0].substring(startingPoint + 10, endPoint);
                  var pertumbuhan = _pertumbuhanList
                      .firstWhere((element) => element.id == pertumbuhanId);
                  final pertumbuhanIndex =
                      _pertumbuhanList.indexOf(pertumbuhan);
                  setState(() {
                    _pertumbuhanList.removeAt(pertumbuhanIndex);
                    final updatedPertumbuhan =
                        PertumbuhanModel.fromMap(data.payload);
                    if ((levelUser == 1) ||
                        (levelUser == 2 && updatedPertumbuhan.uid == userId) ||
                        (levelUser == 3 &&
                            updatedPertumbuhan.muridId == userId)) {
                      _pertumbuhanList.insert(
                          pertumbuhanIndex, updatedPertumbuhan);
                    }
                    _filterList();
                  });
                } else if (data.events.contains(
                  'databases.*.collections.${AppwriteConstants.pertumbuhanCollection}.documents.*.delete',
                )) {
                  final startingPoint =
                      data.events[0].lastIndexOf('documents.');
                  final endPoint = data.events[0].lastIndexOf('.delete');
                  final pertumbuhanId =
                      data.events[0].substring(startingPoint + 10, endPoint);

                  setState(() {
                    _pertumbuhanList.removeWhere(
                        (pertumbuhan) => pertumbuhan.id == pertumbuhanId);
                    _filterList();
                  });
                }
              });
            });

            return RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: CustomText(
                          text: "Catatan Pertumbuhan",
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ),
                    if (levelUser != 3)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              AddPertumbuhanPage.route(
                                  kelompok: kelompok, sekolah: sekolah));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 3),
                        ),
                        child: const CustomText(
                            text: "Tambah Data", color: Colors.white),
                      ),
                    MonthlyCalendar(onDateSelected: _onDateSelected),
                    const SizedBox(height: 16),
                    pertumbuhanAsyncValue.when(
                      data: (pertumbuhanList) {
                        _pertumbuhanList = pertumbuhanList;
                        _filterList();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                dataRowMinHeight: 50,
                                dataRowMaxHeight: double.infinity,
                                border: TableBorder.all(),
                                headingRowColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                        (Set<MaterialState> states) {
                                  return Colors.grey;
                                }),
                                columns: const [
                                  DataColumn(
                                      label: CustomText(
                                    text: 'Tanggal',
                                    fontWeight: FontWeight.w700,
                                  )),
                                  DataColumn(
                                      label: CustomText(
                                    text: 'Nama Murid',
                                    fontWeight: FontWeight.w700,
                                  )),
                                  DataColumn(
                                      label: CustomText(
                                    text: 'Kelompok',
                                    fontWeight: FontWeight.w700,
                                  )),
                                  DataColumn(
                                      label: CustomText(
                                    textAlign: TextAlign.center,
                                    text: 'Tinggi Badan\n(cm)',
                                    fontWeight: FontWeight.w700,
                                  )),
                                  DataColumn(
                                      label: CustomText(
                                    textAlign: TextAlign.center,
                                    text: 'Berat Badan\n(kg)',
                                    fontWeight: FontWeight.w700,
                                  )),

                                  DataColumn(
                                      label: CustomText(
                                    textAlign: TextAlign.center,
                                    text: 'Lingkar Kepala\n(cm)',
                                    fontWeight: FontWeight.w700,
                                  )),
                                  DataColumn(
                                      label: CustomText(
                                    text: 'Kondisi Fisik',
                                    fontWeight: FontWeight.w700,
                                  )),
                                  DataColumn(
                                      label: CustomText(
                                    text: 'Umpan Balik',
                                    fontWeight: FontWeight.w700,
                                  )),
                                  DataColumn(
                                      label: CustomText(
                                    text: 'Tanggapan Orang Tua',
                                    fontWeight: FontWeight.w700,
                                  )),
                                  // if (levelUser != 3)
                                  DataColumn(
                                      label: CustomText(
                                    text: 'Action',
                                    fontWeight: FontWeight.w700,
                                  )),
                                ],
                                rows: _filteredList
                                    .where((pertumbuhan) => !(levelUser == 2 &&
                                        pertumbuhan.kelompok != kelompok))
                                    .map((pertumbuhan) {
                                  final muridData = ref.watch(
                                      getUserDataProvider(pertumbuhan.muridId));
                                  // final guruData = ref.watch(
                                  //     getUserDataProvider(pertumbuhan.uid));
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth:
                                                100, // Ubah sesuai kebutuhan
                                          ),
                                          child: Text(
                                            pertumbuhan.tanggal,
                                            overflow: TextOverflow.visible,
                                            softWrap: true,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth:
                                                100, // Ubah sesuai kebutuhan
                                          ),
                                          child: muridData.when(
                                            data: (data) => Text(
                                              data.data['nama'],
                                              overflow: TextOverflow.visible,
                                              softWrap: true,
                                            ),
                                            loading: () => const Loader(),
                                            error: (error, stack) =>
                                                const Text('Error'),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth:
                                                100, // Ubah sesuai kebutuhan
                                          ),
                                          child: Text(
                                            pertumbuhan.kelompok,
                                            overflow: TextOverflow.visible,
                                            softWrap: true,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth:
                                                200, // Ubah sesuai kebutuhan
                                          ),
                                          child: Text(
                                            pertumbuhan.tinggi.toString(),
                                            overflow: TextOverflow.visible,
                                            softWrap: true,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth:
                                                200, // Ubah sesuai kebutuhan
                                          ),
                                          child: Text(
                                            pertumbuhan.berat.toString(),
                                            overflow: TextOverflow.visible,
                                            softWrap: true,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth:
                                                200, // Ubah sesuai kebutuhan
                                          ),
                                          child: Text(
                                            pertumbuhan.kepala.toString(),
                                            overflow: TextOverflow.visible,
                                            softWrap: true,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth:
                                                200, // Ubah sesuai kebutuhan
                                          ), // Sesuaikan lebar sesuai kebutuhan
                                          child: Text(
                                            pertumbuhan.fisik,
                                            overflow: TextOverflow.visible,
                                            softWrap: true,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth:
                                                200, // Ubah sesuai kebutuhan
                                          ), // Sesuaikan lebar sesuai kebutuhan
                                          child: Text(
                                            pertumbuhan.rekomendasi,
                                            overflow: TextOverflow.visible,
                                            softWrap: true,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth:
                                                200, // Ubah sesuai kebutuhan
                                          ), // Sesuaikan lebar sesuai kebutuhan
                                          child: Text(
                                            pertumbuhan.tanggapan,
                                            overflow: TextOverflow.visible,
                                            softWrap: true,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit),
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    EditPertumbuhanPage.route(
                                                        pertumbuhan:
                                                            pertumbuhan,
                                                        kelompok: kelompok,
                                                        sekolah: sekolah,
                                                        levelUser: levelUser));
                                              },
                                            ),
                                            if (levelUser != 3)
                                              IconButton(
                                                icon: const Icon(Icons.delete),
                                                onPressed: () {
                                                  _showDeleteDialog(
                                                      context,
                                                      ref,
                                                      pertumbuhan,
                                                      muridData);
                                                },
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stack) {
                        if (error.toString().contains('Failed host lookup')) {
                          return ReloadError(
                            onReload: () {
                              ref.refresh(pertumbuhanControllerProvider);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const PertumbuhanPage()),
                              );
                            },
                          );
                        }
                        return Text(error.toString());
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) {
            if (error.toString().contains('Failed host lookup')) {
              return ReloadError(
                onReload: () {
                  ref.refresh(pertumbuhanControllerProvider);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PertumbuhanPage()),
                  );
                },
              );
            }
            return Text(error.toString());
          },
        ),
      ),
      drawer: CustomDrawer(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemSelected,
      ),
    );
  }
}

void _showDeleteDialog(BuildContext context, WidgetRef ref,
    PertumbuhanModel pertumbuhan, AsyncValue<Document?> muridData) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Hapus Data'),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              muridData.when(
                data: (data) {
                  final nama = data?.data['nama'] ?? 'Murid tidak ditemukan';
                  return Text(
                    'Apakah Anda yakin ingin menghapus catatan Pertumbuhan $nama pada tanggal ${pertumbuhan.tanggal}',
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => Text(
                  'Apakah Anda yakin ingin menghapus catatan Pertumbuhan pada tanggal ${pertumbuhan.tanggal}?',
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Batal'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Hapus'),
            onPressed: () {
              Navigator.of(context).pop();
              ref
                  .read(pertumbuhanControllerProvider.notifier)
                  .deletePertumbuhan(pertumbuhan, context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Catatan Pertumbuhan berhasil dihapus'),
                ),
              );
            },
          ),
        ],
      );
    },
  );
}
