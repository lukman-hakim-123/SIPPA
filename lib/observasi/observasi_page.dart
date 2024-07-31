import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sippa/observasi/add_observasi_page.dart';
import 'package:sippa/observasi/controller/observasi_controller.dart';
import 'package:sippa/observasi/edit_observasi_page.dart';

import 'package:sippa/auth/controllers/auth_controller.dart';
import 'package:sippa/common/loading.dart';
import 'package:sippa/constant/appwrite.dart';
import 'package:sippa/models/observasi.dart';

import 'package:sippa/widget_view/appbar.dart';
import 'package:sippa/widget_view/drawer.dart';
import 'package:sippa/widget_view/teks.dart';

class ObservasiPage extends ConsumerStatefulWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const ObservasiPage());

  const ObservasiPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ObservasiPageState();
}

class _ObservasiPageState extends ConsumerState<ObservasiPage> {
  int _selectedIndex = 1;
  List<ObservasiModel> _observasiList = [];

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userDetailsAsync = ref.watch(currentUserDetailsProvider);
    return Scaffold(
      appBar: const CustomAppBar(title: 'Catatan Observasi'),
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
            final observasiAsyncValue =
                ref.watch(getObservasiByUserIdProvider(userId));
            ref.listen<AsyncValue<RealtimeMessage>>(getLatestObservasiProvider,
                (_, next) {
              next.whenData((data) {
                if (data.events.contains(
                  'databases.*.collections.${AppwriteConstants.obsCollection}.documents.*.create',
                )) {
                  final newObservasi = ObservasiModel.fromMap(data.payload);
                  if ((levelUser == 1) ||
                      (levelUser == 2 && newObservasi.uid == userId) ||
                      (levelUser == 3 && newObservasi.muridId == userId)) {
                    if (!_observasiList
                        .any((observasi) => observasi.id == newObservasi.id)) {
                      setState(() {
                        _observasiList.add(newObservasi);
                      });
                    }
                  }
                } else if (data.events.contains(
                  'databases.*.collections.${AppwriteConstants.obsCollection}.documents.*.update',
                )) {
                  final startingPoint =
                      data.events[0].lastIndexOf('documents.');
                  final endPoint = data.events[0].lastIndexOf('.update');
                  final observasiId =
                      data.events[0].substring(startingPoint + 10, endPoint);
                  var observasi = _observasiList
                      .firstWhere((element) => element.id == observasiId);
                  final observasiIndex = _observasiList.indexOf(observasi);
                  setState(() {
                    _observasiList.removeAt(observasiIndex);
                    final updatedObservasi =
                        ObservasiModel.fromMap(data.payload);
                    if ((levelUser == 1) ||
                        (levelUser == 2 && updatedObservasi.uid == userId) ||
                        (levelUser == 3 &&
                            updatedObservasi.muridId == userId)) {
                      _observasiList.insert(observasiIndex, updatedObservasi);
                    }
                  });
                } else if (data.events.contains(
                  'databases.*.collections.${AppwriteConstants.obsCollection}.documents.*.delete',
                )) {
                  final startingPoint =
                      data.events[0].lastIndexOf('documents.');
                  final endPoint = data.events[0].lastIndexOf('.delete');
                  final observasiId =
                      data.events[0].substring(startingPoint + 10, endPoint);

                  setState(() {
                    _observasiList.removeWhere(
                        (observasi) => observasi.id == observasiId);
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
                        text: "Catatan Observasi",
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ),
                  if (levelUser != 3)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(context,
                            AddObservasiPage.route(kelompok: kelompok));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 3),
                      ),
                      child: const CustomText(
                          text: "Tambah Data", color: Colors.white),
                    ),
                  const SizedBox(height: 16),
                  observasiAsyncValue.when(
                    data: (observasiList) {
                      _observasiList = observasiList;
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
                              columns: [
                                const DataColumn(
                                    label: CustomText(
                                  text: 'Foto',
                                  fontWeight: FontWeight.w700,
                                )),
                                const DataColumn(
                                    label: CustomText(
                                  text: 'Nama Murid',
                                  fontWeight: FontWeight.w700,
                                )),
                                const DataColumn(
                                    label: CustomText(
                                  text: 'Kelompok',
                                  fontWeight: FontWeight.w700,
                                )),
                                const DataColumn(
                                    label: CustomText(
                                  text: 'Tanggal',
                                  fontWeight: FontWeight.w700,
                                )),
                                const DataColumn(
                                    label: CustomText(
                                  text: 'Nama Guru',
                                  fontWeight: FontWeight.w700,
                                )),
                                const DataColumn(
                                    label: CustomText(
                                  text: 'Kegiatan',
                                  fontWeight: FontWeight.w700,
                                )),
                                const DataColumn(
                                    label: CustomText(
                                  text: 'Hasil Observasi',
                                  fontWeight: FontWeight.w700,
                                )),
                                const DataColumn(
                                    label: CustomText(
                                  text: 'Rekomendasi',
                                  fontWeight: FontWeight.w700,
                                )),
                                if (levelUser != 3)
                                  const DataColumn(
                                      label: CustomText(
                                    text: 'Action',
                                    fontWeight: FontWeight.w700,
                                  )),
                              ],
                              rows: _observasiList
                                  .where((observasi) => !(levelUser == 2 &&
                                      observasi.kelompok != kelompok))
                                  .map((observasi) {
                                final muridData = ref.watch(
                                    getUserDataProvider(observasi.muridId));
                                final guruData = ref
                                    .watch(getUserDataProvider(observasi.uid));
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 150,
                                          maxHeight: 150,
                                        ),
                                        child: ref
                                            .watch(getObservasiImageProvider(
                                                observasi.imageId))
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
                                          observasi.kelompok,
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
                                          observasi.tanggal,
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
                                        child: guruData.when(
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
                                        child: Text(
                                          observasi.kegiatan,
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
                                          observasi.hasilObservasi,
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
                                          observasi.rekomendasi,
                                          overflow: TextOverflow.visible,
                                          softWrap: true,
                                        ),
                                      ),
                                    ),
                                    if (levelUser != 3)
                                      DataCell(
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit),
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    EditObservasiPage.route(
                                                        observasi: observasi,
                                                        kelompok: kelompok));
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete),
                                              onPressed: () {
                                                _showDeleteDialog(context, ref,
                                                    observasi, muridData);
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

void _showDeleteDialog(BuildContext context, WidgetRef ref,
    ObservasiModel observasi, AsyncValue<Document?> muridData) {
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
                    'Apakah Anda yakin ingin menghapus observasi $nama pada tanggal ${observasi.tanggal}',
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => Text(
                  'Apakah Anda yakin ingin menghapus observasi pada tanggal ${observasi.tanggal}?',
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
                  .read(observasiControllerProvider.notifier)
                  .deleteObservasi(observasi, context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('observasi berhasil dihapus'),
                ),
              );
            },
          ),
        ],
      );
    },
  );
}
