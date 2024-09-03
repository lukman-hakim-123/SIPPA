import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'package:sippa/auth/controllers/auth_controller.dart';
import 'package:sippa/capaian_pembelajaran/add_cp_page.dart';
import 'package:sippa/capaian_pembelajaran/controller/cp_controller.dart';
import 'package:sippa/capaian_pembelajaran/edit_cp_page.dart';
import 'package:sippa/common/loading.dart';
import 'package:sippa/constant/appwrite.dart';

import 'package:sippa/models/cp.dart';
import 'package:sippa/widget_view/appbar.dart';
import 'package:sippa/widget_view/calendar.dart';
import 'package:sippa/widget_view/drawer.dart';
import 'package:sippa/widget_view/teks.dart';

class CpPage extends ConsumerStatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => const CpPage());

  const CpPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CpPageState();
}

class _CpPageState extends ConsumerState<CpPage> {
  int _selectedIndex = 2;
  List<CpModel> _cpList = [];
  List<CpModel> _filteredList = [];
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
    _filteredList = _cpList.where((cp) {
      final cpDate = DateFormat("d MMMM yyyy").parse(cp.tanggal);
      return cpDate.year == _selectedDate.year &&
          cpDate.month == _selectedDate.month &&
          cpDate.day == _selectedDate.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final userDetailsAsync = ref.watch(currentUserDetailsProvider);
    return Scaffold(
      appBar: const CustomAppBar(title: 'Ceklis'),
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
            final cpAsyncValue = ref.watch(getCpByUserIdProvider(userId));
            ref.listen<AsyncValue<RealtimeMessage>>(getLatestCpProvider,
                (_, next) {
              next.whenData((data) {
                if (data.events.contains(
                  'databases.*.collections.${AppwriteConstants.cpCollection}.documents.*.create',
                )) {
                  final newCp = CpModel.fromMap(data.payload);
                  if ((levelUser == 1) ||
                      (levelUser == 2 && newCp.uid == userId) ||
                      (levelUser == 3 && newCp.muridId == userId)) {
                    if (!_cpList.any((cp) => cp.id == newCp.id)) {
                      setState(() {
                        _cpList.add(newCp);
                        _filterList();
                      });
                    }
                  }
                } else if (data.events.contains(
                  'databases.*.collections.${AppwriteConstants.cpCollection}.documents.*.update',
                )) {
                  final startingPoint =
                      data.events[0].lastIndexOf('documents.');
                  final endPoint = data.events[0].lastIndexOf('.update');
                  final cpId =
                      data.events[0].substring(startingPoint + 10, endPoint);
                  var cp = _cpList.firstWhere((element) => element.id == cpId);
                  final cpIndex = _cpList.indexOf(cp);
                  setState(() {
                    _cpList.removeAt(cpIndex);
                    final updatedCp = CpModel.fromMap(data.payload);
                    if ((levelUser == 1) ||
                        (levelUser == 2 && updatedCp.uid == userId) ||
                        (levelUser == 3 && updatedCp.muridId == userId)) {
                      _cpList.insert(cpIndex, updatedCp);
                    }
                    _filterList();
                  });
                } else if (data.events.contains(
                  'databases.*.collections.${AppwriteConstants.cpCollection}.documents.*.delete',
                )) {
                  final startingPoint =
                      data.events[0].lastIndexOf('documents.');
                  final endPoint = data.events[0].lastIndexOf('.delete');
                  final cpId =
                      data.events[0].substring(startingPoint + 10, endPoint);

                  setState(() {
                    _cpList.removeWhere((cp) => cp.id == cpId);
                    _filterList();
                  });
                }
              });
            });

            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: CustomText(
                        text: "Ceklis",
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
                            context, AddCpPage.route(kelompok: kelompok));
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
                  cpAsyncValue.when(
                    data: (cpList) {
                      _cpList = cpList;
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
                                  text: 'Kelompok',
                                  fontWeight: FontWeight.w700,
                                )),
                                DataColumn(
                                    label: CustomText(
                                  text: 'Kegiatan',
                                  fontWeight: FontWeight.w700,
                                )),
                                DataColumn(
                                    label: CustomText(
                                  text: 'Tujuan Pembelajaran',
                                  fontWeight: FontWeight.w700,
                                )),
                                DataColumn(
                                    label: CustomText(
                                  text: 'Nama Murid',
                                  fontWeight: FontWeight.w700,
                                )),
                                DataColumn(
                                    label: CustomText(
                                  text: 'Kemunculan',
                                  fontWeight: FontWeight.w700,
                                )),
                                DataColumn(
                                    label: CustomText(
                                  text: 'Nilai Agama dan Budi Pekerti',
                                  fontWeight: FontWeight.w700,
                                )),
                                DataColumn(
                                    label: CustomText(
                                  text: 'Jati Diri',
                                  fontWeight: FontWeight.w700,
                                )),
                                DataColumn(
                                    label: CustomText(
                                  text: 'Literasi dan STEAM',
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
                                DataColumn(
                                    label: CustomText(
                                  text: 'Action',
                                  fontWeight: FontWeight.w700,
                                )),
                              ],
                              rows: _filteredList
                                  .where((cp) => !(levelUser == 2 &&
                                      cp.kelompok != kelompok))
                                  .map((cp) {
                                final muridData =
                                    ref.watch(getUserDataProvider(cp.muridId));
                                // final guruData =
                                //     ref.watch(getUserDataProvider(cp.uid));
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 100,
                                        ),
                                        child: Text(
                                          cp.tanggal,
                                          overflow: TextOverflow.visible,
                                          softWrap: true,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 100,
                                        ),
                                        child: Text(
                                          cp.kelompok,
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
                                          cp.konteks,
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
                                          cp.tujuan,
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
                                                200, // Ubah sesuai kebutuhan
                                          ),
                                          child: Center(
                                            child: cp.isDone
                                                ? const Icon(
                                                    Icons.check,
                                                    color: Colors.green,
                                                  )
                                                : const Icon(
                                                    Icons.close,
                                                    color: Colors.red,
                                                  ),
                                          )),
                                    ),
                                    DataCell(
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth:
                                              200, // Ubah sesuai kebutuhan
                                        ), // Sesuaikan lebar sesuai kebutuhan
                                        child: Text(
                                          cp.agama,
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
                                          cp.jatidiri,
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
                                          cp.literasi,
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
                                          cp.rekomendasi,
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
                                          cp.tanggapan,
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
                                                  EditCpPage.route(
                                                      cp: cp,
                                                      kelompok: kelompok,
                                                      levelUser: levelUser));
                                            },
                                          ),
                                          if (levelUser != 3)
                                            IconButton(
                                              icon: const Icon(Icons.delete),
                                              onPressed: () {
                                                _showDeleteDialog(context, ref,
                                                    cp, muridData);
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
                        ],
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => const Loader(),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => const Loader(),
        ),
      ),
      drawer: CustomDrawer(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemSelected,
      ),
    );
  }
}

void _showDeleteDialog(BuildContext context, WidgetRef ref, CpModel cp,
    AsyncValue<Document?> muridData) {
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
                    'Apakah Anda yakin ingin menghapus Ceklis $nama pada tanggal ${cp.tanggal}',
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => Text(
                  'Apakah Anda yakin ingin menghapus Ceklis pada tanggal ${cp.tanggal}?',
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
              ref.read(cpControllerProvider.notifier).deleteCp(cp, context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ceklis berhasil dihapus'),
                ),
              );
            },
          ),
        ],
      );
    },
  );
}
