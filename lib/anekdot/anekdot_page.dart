import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:sippa/anekdot/add_anekdot.dart';
import 'package:sippa/anekdot/controller/anekdot_controller.dart';
import 'package:sippa/anekdot/edit_anekdot.dart';

import 'package:sippa/auth/controllers/auth_controller.dart';
import 'package:sippa/common/loading.dart';
import 'package:sippa/common/reload.dart';
import 'package:sippa/constant/appwrite.dart';
import 'package:sippa/models/anekdot.dart';

import 'package:sippa/widget_view/appbar.dart';
import 'package:sippa/widget_view/calendar.dart';
import 'package:sippa/widget_view/drawer.dart';
import 'package:sippa/widget_view/teks.dart';

class AnekdotPage extends ConsumerStatefulWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const AnekdotPage());

  const AnekdotPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AnekdotPageState();
}

class _AnekdotPageState extends ConsumerState<AnekdotPage> {
  int _selectedIndex = 0;
  List<AnekdotModel> _anekdotList = [];
  List<AnekdotModel> _filteredList = [];
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
    _filteredList = _anekdotList.where((anekdot) {
      final anekdotDate = DateFormat("d MMMM yyyy").parse(anekdot.tanggal);
      return anekdotDate.year == _selectedDate.year &&
          anekdotDate.month == _selectedDate.month &&
          anekdotDate.day == _selectedDate.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final userDetailsAsync = ref.watch(currentUserDetailsProvider);
    return Scaffold(
      appBar: const CustomAppBar(title: 'Catatan Anekdotal'),
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
            final anekdotAsyncValue =
                ref.watch(getAnekdotByUserIdProvider(userId));
            ref.listen<AsyncValue<RealtimeMessage>>(getLatestAnekdotProvider,
                (_, next) {
              next.whenData((data) {
                if (data.events.contains(
                  'databases.*.collections.${AppwriteConstants.anekdotCollection}.documents.*.create',
                )) {
                  final newAnekdot = AnekdotModel.fromMap(data.payload);
                  if ((levelUser == 1) ||
                      (levelUser == 2 && newAnekdot.uid == userId) ||
                      (levelUser == 3 && newAnekdot.muridId == userId)) {
                    if (!_anekdotList
                        .any((anekdot) => anekdot.id == newAnekdot.id)) {
                      setState(() {
                        _anekdotList.add(newAnekdot);
                        _filterList();
                      });
                    }
                  }
                } else if (data.events.contains(
                  'databases.*.collections.${AppwriteConstants.anekdotCollection}.documents.*.update',
                )) {
                  final startingPoint =
                      data.events[0].lastIndexOf('documents.');
                  final endPoint = data.events[0].lastIndexOf('.update');
                  final anekdotId =
                      data.events[0].substring(startingPoint + 10, endPoint);
                  var anekdot = _anekdotList
                      .firstWhere((element) => element.id == anekdotId);
                  final anekdotIndex = _anekdotList.indexOf(anekdot);
                  setState(() {
                    _anekdotList.removeAt(anekdotIndex);
                    final updatedAnekdot = AnekdotModel.fromMap(data.payload);
                    if ((levelUser == 1) ||
                        (levelUser == 2 && updatedAnekdot.uid == userId) ||
                        (levelUser == 3 && updatedAnekdot.muridId == userId)) {
                      _anekdotList.insert(anekdotIndex, updatedAnekdot);
                    }
                    _filterList();
                  });
                } else if (data.events.contains(
                  'databases.*.collections.${AppwriteConstants.anekdotCollection}.documents.*.delete',
                )) {
                  final startingPoint =
                      data.events[0].lastIndexOf('documents.');
                  final endPoint = data.events[0].lastIndexOf('.delete');
                  final anekdotId =
                      data.events[0].substring(startingPoint + 10, endPoint);

                  setState(() {
                    _anekdotList
                        .removeWhere((anekdot) => anekdot.id == anekdotId);
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
                        text: "Catatan Anekdotal",
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
                            context, AddAnekdotPage.route(kelompok: kelompok));
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
                  anekdotAsyncValue.when(
                    data: (anekdotList) {
                      _anekdotList = anekdotList;
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
                                  text: 'Foto',
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
                                // if (levelUser != 3)
                                DataColumn(
                                    label: CustomText(
                                  text: 'Action',
                                  fontWeight: FontWeight.w700,
                                )),
                              ],
                              rows: _filteredList
                                  .where((anekdot) => !(levelUser == 2 &&
                                      anekdot.kelompok != kelompok))
                                  .map((anekdot) {
                                final muridData = ref.watch(
                                    getUserDataProvider(anekdot.muridId));
                                final guruData =
                                    ref.watch(getUserDataProvider(anekdot.uid));
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth:
                                              100, // Ubah sesuai kebutuhan
                                        ),
                                        child: Text(
                                          anekdot.tanggal,
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
                                        child: Text(
                                          anekdot.kelompok,
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
                                          anekdot.pengamatan,
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
                                          anekdot.tujuan,
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
                                          maxWidth: 150,
                                          maxHeight: 150,
                                        ),
                                        child: ref
                                            .watch(getAnekdotImageProvider(
                                                anekdot.imageId))
                                            .when(
                                              data: (imageData) {
                                                if (imageData != null) {
                                                  return Image.memory(
                                                    imageData,
                                                    fit: BoxFit.cover,
                                                  );
                                                } else {
                                                  return const Icon(Icons
                                                      .image_not_supported);
                                                }
                                              },
                                              loading: () =>
                                                  const CircularProgressIndicator(),
                                              error: (_, __) =>
                                                  const Icon(Icons.error),
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
                                          anekdot.nilai,
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
                                          anekdot.jatiDiri,
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
                                          anekdot.literasi,
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
                                          anekdot.umpanBalik,
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
                                          anekdot.tanggapan,
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
                                                  EditAnekdotPage.route(
                                                      anekdot: anekdot,
                                                      kelompok: kelompok,
                                                      levelUser: levelUser));
                                            },
                                          ),
                                          if (levelUser != 3)
                                            IconButton(
                                              icon: const Icon(Icons.delete),
                                              onPressed: () {
                                                _showDeleteDialog(context, ref,
                                                    anekdot, muridData);
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
                    error: (error, stack) {
                      if (error.toString().contains('Failed host lookup')) {
                        return ReloadError(
                          onReload: () {
                            ref.refresh(anekdotControllerProvider);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const AnekdotPage()),
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
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) {
                      if (error.toString().contains('Failed host lookup')) {
                        return ReloadError(
                          onReload: () {
                            ref.refresh(anekdotControllerProvider);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const AnekdotPage()),
                            );
                          },
                        );
                      }
                      return const Loader();
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
    AnekdotModel anekdot, AsyncValue<Document?> muridData) {
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
                    'Apakah Anda yakin ingin menghapus catatan anekdotal $nama pada tanggal ${anekdot.tanggal}',
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => Text(
                  'Apakah Anda yakin ingin menghapus catatan anekdotal pada tanggal ${anekdot.tanggal}?',
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
                  .read(anekdotControllerProvider.notifier)
                  .deleteAnekdot(anekdot, context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Catatan Anekdotal berhasil dihapus'),
                ),
              );
            },
          ),
        ],
      );
    },
  );
}
