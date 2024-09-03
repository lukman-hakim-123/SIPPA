import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:sippa/auth/controllers/auth_controller.dart';
import 'package:sippa/common/loading.dart';
import 'package:sippa/constant/appwrite.dart';
import 'package:sippa/models/rubrik.dart';
import 'package:sippa/rubrik/add_rubrik_page.dart';
import 'package:sippa/rubrik/controller/rubrik_controller.dart';
import 'package:sippa/rubrik/edit_rubrik_page.dart';

import 'package:sippa/widget_view/appbar.dart';
import 'package:sippa/widget_view/drawer.dart';
import 'package:sippa/widget_view/teks.dart';
import 'package:sippa/widget_view/calendar.dart';
import 'package:intl/date_symbol_data_local.dart';

class RubrikPage extends ConsumerStatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => const RubrikPage());

  const RubrikPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RubrikPageState();
}

class _RubrikPageState extends ConsumerState<RubrikPage> {
  int _selectedIndex = 5;
  List<RubrikModel> _rubrikList = [];
  List<RubrikModel> _filteredRubrikList = [];
  DateTime _selectedDate = DateTime.now();

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _filterRubrikList();
    });
  }

  void _filterRubrikList() {
    _filteredRubrikList = _rubrikList.where((rubrik) {
      final rubrikDate = DateFormat("d MMMM yyyy").parse(rubrik.tanggal);
      return rubrikDate.year == _selectedDate.year &&
          rubrikDate.month == _selectedDate.month &&
          rubrikDate.day == _selectedDate.day;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
  }

  @override
  Widget build(BuildContext context) {
    final userDetailsAsync = ref.watch(currentUserDetailsProvider);
    return Scaffold(
      appBar: const CustomAppBar(title: 'Rubrik'),
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
            final rubrikAsyncValue =
                ref.watch(getRubrikByUserIdProvider(userId));
            ref.listen<AsyncValue<RealtimeMessage>>(getLatestRubrikProvider,
                (_, next) {
              next.whenData((data) {
                if (data.events.contains(
                  'databases.*.collections.${AppwriteConstants.rubrikCollection}.documents.*.create',
                )) {
                  final newRubrik = RubrikModel.fromMap(data.payload);
                  if ((levelUser == 1) ||
                      (levelUser == 2 && newRubrik.uid == userId) ||
                      (levelUser == 3 && newRubrik.muridId == userId)) {
                    if (!_rubrikList
                        .any((rubrik) => rubrik.id == newRubrik.id)) {
                      setState(() {
                        _rubrikList.add(newRubrik);
                        _filterRubrikList();
                      });
                    }
                  }
                } else if (data.events.contains(
                  'databases.*.collections.${AppwriteConstants.rubrikCollection}.documents.*.update',
                )) {
                  final startingPoint =
                      data.events[0].lastIndexOf('documents.');
                  final endPoint = data.events[0].lastIndexOf('.update');
                  final rubrikId =
                      data.events[0].substring(startingPoint + 10, endPoint);
                  var rubrik = _rubrikList
                      .firstWhere((element) => element.id == rubrikId);
                  final rubrikIndex = _rubrikList.indexOf(rubrik);
                  setState(() {
                    _rubrikList.removeAt(rubrikIndex);
                    final updatedRubrik = RubrikModel.fromMap(data.payload);
                    if ((levelUser == 1) ||
                        (levelUser == 2 && updatedRubrik.uid == userId) ||
                        (levelUser == 3 && updatedRubrik.muridId == userId)) {
                      _rubrikList.insert(rubrikIndex, updatedRubrik);
                    }
                    _filterRubrikList();
                  });
                } else if (data.events.contains(
                  'databases.*.collections.${AppwriteConstants.rubrikCollection}.documents.*.delete',
                )) {
                  final startingPoint =
                      data.events[0].lastIndexOf('documents.');
                  final endPoint = data.events[0].lastIndexOf('.delete');
                  final rubrikId =
                      data.events[0].substring(startingPoint + 10, endPoint);

                  setState(() {
                    _rubrikList.removeWhere((rubrik) => rubrik.id == rubrikId);
                    _filterRubrikList();
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
                        text: "Rubrik",
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
                            context, AddRubrikPage.route(kelompok: kelompok));
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
                  rubrikAsyncValue.when(
                    data: (rubrikList) {
                      _rubrikList = rubrikList;
                      _filterRubrikList();
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
                                // DataColumn(
                                //     label: CustomText(
                                //   text: 'Kegiatan',
                                //   fontWeight: FontWeight.w700,
                                // )),
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
                                  textAlign: TextAlign.center,
                                  text:
                                      'Skor 1\n Belum Mencapai Tujuan Pembelajaran',
                                  fontWeight: FontWeight.w700,
                                )),
                                DataColumn(
                                    label: CustomText(
                                  textAlign: TextAlign.center,
                                  text:
                                      'Skor 2\n Mencapai Tujuan Pembelajaran dengan Bantuan',
                                  fontWeight: FontWeight.w700,
                                )),
                                DataColumn(
                                    label: CustomText(
                                  textAlign: TextAlign.center,
                                  text:
                                      'Skor 3\n Mencapai Tujuan Pembelajaran Secara Mandiri',
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
                              rows: _filteredRubrikList
                                  .where((rubrik) => !(levelUser == 2 &&
                                      rubrik.kelompok != kelompok))
                                  .map((rubrik) {
                                final muridData = ref
                                    .watch(getUserDataProvider(rubrik.muridId));
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 100,
                                        ),
                                        child: Text(
                                          rubrik.tanggal,
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
                                          rubrik.kelompok,
                                          overflow: TextOverflow.visible,
                                          softWrap: true,
                                        ),
                                      ),
                                    ),
                                    // DataCell(
                                    //   ConstrainedBox(
                                    //     constraints: const BoxConstraints(
                                    //       maxWidth: 200,
                                    //     ),
                                    //     child: Text(
                                    //       rubrik.kegiatan,
                                    //       overflow: TextOverflow.visible,
                                    //       softWrap: true,
                                    //     ),
                                    //   ),
                                    // ),
                                    DataCell(
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 200,
                                        ),
                                        child: Text(
                                          rubrik.tujuan,
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
                                            maxWidth: 200,
                                          ),
                                          child: Center(
                                              child: (rubrik.skor == '1')
                                                  ? const Icon(
                                                      Icons.check,
                                                      color: Colors.green,
                                                    )
                                                  : Container()
                                              // const Icon(
                                              //     Icons.close,
                                              //     color: Colors.red,
                                              //   ),
                                              )),
                                    ),
                                    DataCell(
                                      ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth: 200,
                                          ),
                                          child: Center(
                                              child: (rubrik.skor == '2')
                                                  ? const Icon(
                                                      Icons.check,
                                                      color: Colors.green,
                                                    )
                                                  : Container()
                                              // const Icon(
                                              //     Icons.close,
                                              //     color: Colors.red,
                                              //   ),
                                              )),
                                    ),
                                    DataCell(
                                      ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth: 200,
                                          ),
                                          child: Center(
                                              child: (rubrik.skor == '3')
                                                  ? const Icon(
                                                      Icons.check,
                                                      color: Colors.green,
                                                    )
                                                  : Container()
                                              // const Icon(
                                              //     Icons.close,
                                              //     color: Colors.red,
                                              //   ),
                                              )),
                                    ),
                                    DataCell(
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 200,
                                        ),
                                        child: Text(
                                          rubrik.agama,
                                          overflow: TextOverflow.visible,
                                          softWrap: true,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 200,
                                        ),
                                        child: Text(
                                          rubrik.jatidiri,
                                          overflow: TextOverflow.visible,
                                          softWrap: true,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 200,
                                        ),
                                        child: Text(
                                          rubrik.literasi,
                                          overflow: TextOverflow.visible,
                                          softWrap: true,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 200,
                                        ),
                                        child: Text(
                                          rubrik.rekomendasi,
                                          overflow: TextOverflow.visible,
                                          softWrap: true,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 200,
                                        ),
                                        child: Text(
                                          rubrik.tanggapan,
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
                                                  EditRubrikPage.route(
                                                      rubrik: rubrik,
                                                      kelompok: kelompok,
                                                      levelUser: levelUser));
                                            },
                                          ),
                                          if (levelUser != 3)
                                            IconButton(
                                              icon: const Icon(Icons.delete),
                                              onPressed: () {
                                                _showDeleteDialog(context, ref,
                                                    rubrik, muridData);
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

void _showDeleteDialog(BuildContext context, WidgetRef ref, RubrikModel rubrik,
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
                    'Apakah Anda yakin ingin menghapus Rubrik $nama pada tanggal ${rubrik.tanggal}',
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => Text(
                  'Apakah Anda yakin ingin menghapus Rubrik pada tanggal ${rubrik.tanggal}?',
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
                  .read(rubrikControllerProvider.notifier)
                  .deleteRubrik(rubrik, context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Rubrik berhasil dihapus'),
                ),
              );
            },
          ),
        ],
      );
    },
  );
}
