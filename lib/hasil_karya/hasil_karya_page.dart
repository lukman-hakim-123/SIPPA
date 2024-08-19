import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sippa/auth/controllers/auth_controller.dart';
import 'package:sippa/common/loading.dart';
import 'package:sippa/constant/appwrite.dart';
import 'package:sippa/hasil_karya/add_hasil_karya_page.dart';
import 'package:sippa/hasil_karya/controller/hasil_karya_controller.dart';
import 'package:sippa/hasil_karya/edit_hasil_karya_page.dart';

import 'package:sippa/models/hk.dart';
import 'package:sippa/widget_view/appbar.dart';
import 'package:sippa/widget_view/drawer.dart';
import 'package:sippa/widget_view/teks.dart';

class HkPage extends ConsumerStatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => const HkPage());

  const HkPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HkPageState();
}

class _HkPageState extends ConsumerState<HkPage> {
  int _selectedIndex = 3;
  List<HkModel> _hkList = [];

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userDetailsAsync = ref.watch(currentUserDetailsProvider);
    return Scaffold(
      appBar: const CustomAppBar(title: 'Penilaian Hasil Karya'),
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
            final hkAsyncValue = ref.watch(getHkByUserIdProvider(userId));
            ref.listen<AsyncValue<RealtimeMessage>>(getLatestHkProvider,
                (_, next) {
              next.whenData((data) {
                if (data.events.contains(
                  'databases.*.collections.${AppwriteConstants.hkCollection}.documents.*.create',
                )) {
                  final newHk = HkModel.fromMap(data.payload);
                  if ((levelUser == 1) ||
                      (levelUser == 2 && newHk.uid == userId) ||
                      (levelUser == 3 && newHk.muridId == userId)) {
                    if (!_hkList.any((hk) => hk.id == newHk.id)) {
                      setState(() {
                        _hkList.add(newHk);
                      });
                    }
                  }
                } else if (data.events.contains(
                  'databases.*.collections.${AppwriteConstants.hkCollection}.documents.*.update',
                )) {
                  final startingPoint =
                      data.events[0].lastIndexOf('documents.');
                  final endPoint = data.events[0].lastIndexOf('.update');
                  final hkId =
                      data.events[0].substring(startingPoint + 10, endPoint);
                  var hk = _hkList.firstWhere((element) => element.id == hkId);
                  final hkIndex = _hkList.indexOf(hk);
                  setState(() {
                    _hkList.removeAt(hkIndex);
                    final updatedHk = HkModel.fromMap(data.payload);
                    if ((levelUser == 1) ||
                        (levelUser == 2 && updatedHk.uid == userId) ||
                        (levelUser == 3 && updatedHk.muridId == userId)) {
                      _hkList.insert(hkIndex, updatedHk);
                    }
                  });
                } else if (data.events.contains(
                  'databases.*.collections.${AppwriteConstants.hkCollection}.documents.*.delete',
                )) {
                  final startingPoint =
                      data.events[0].lastIndexOf('documents.');
                  final endPoint = data.events[0].lastIndexOf('.delete');
                  final hkId =
                      data.events[0].substring(startingPoint + 10, endPoint);

                  setState(() {
                    _hkList.removeWhere((hk) => hk.id == hkId);
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
                        text: "Penilaian Hasil Karya",
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
                            context, AddHkPage.route(kelompok: kelompok));
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
                  hkAsyncValue.when(
                    data: (hkList) {
                      _hkList = hkList;
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
                                  text: 'Gambar',
                                  fontWeight: FontWeight.w700,
                                )),
                                DataColumn(
                                    label: CustomText(
                                  text: 'Nama Murid',
                                  fontWeight: FontWeight.w700,
                                )),
                                DataColumn(
                                    label: CustomText(
                                  text: 'Nama Guru',
                                  fontWeight: FontWeight.w700,
                                )),
                                DataColumn(
                                    label: CustomText(
                                  text: 'Kelompok',
                                  fontWeight: FontWeight.w700,
                                )),
                                DataColumn(
                                    label: CustomText(
                                  text: 'Tanggal',
                                  fontWeight: FontWeight.w700,
                                )),
                                DataColumn(
                                    label: CustomText(
                                  text: 'Deskripsi',
                                  fontWeight: FontWeight.w700,
                                )),
                                DataColumn(
                                    label: CustomText(
                                  text: 'Analisis Nilai Agama dan budi pekerti',
                                  fontWeight: FontWeight.w700,
                                )),
                                DataColumn(
                                    label: CustomText(
                                  text: 'Analisis Jati Diri',
                                  fontWeight: FontWeight.w700,
                                )),
                                DataColumn(
                                    label: CustomText(
                                  text: 'Analisis Literasi',
                                  fontWeight: FontWeight.w700,
                                )),
                                DataColumn(
                                    label: CustomText(
                                  text: 'Rekomendasi',
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
                              rows: _hkList
                                  .where((hk) => !(levelUser == 2 &&
                                      hk.kelompok != kelompok))
                                  .map((hk) {
                                final muridData =
                                    ref.watch(getUserDataProvider(hk.muridId));
                                final guruData =
                                    ref.watch(getUserDataProvider(hk.uid));
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 150,
                                          maxHeight: 150,
                                        ),
                                        child: ref
                                            .watch(
                                                getHkImageProvider(hk.imageId))
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
                                              100, // Ubah sesuai kebutuhan
                                        ),
                                        child: Text(
                                          hk.kelompok,
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
                                          hk.tanggal,
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
                                          hk.deskripsi,
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
                                          hk.nilai,
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
                                            hk.jatiDiri,
                                            overflow: TextOverflow.visible,
                                            softWrap: true,
                                          )),
                                    ),
                                    DataCell(
                                      ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth:
                                                200, // Ubah sesuai kebutuhan
                                          ),
                                          child: Text(
                                            hk.literasi,
                                            overflow: TextOverflow.visible,
                                            softWrap: true,
                                          )),
                                    ),
                                    DataCell(
                                      ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth:
                                                200, // Ubah sesuai kebutuhan
                                          ),
                                          child: Text(
                                            hk.rekomendasi,
                                            overflow: TextOverflow.visible,
                                            softWrap: true,
                                          )),
                                    ),
                                    DataCell(
                                      ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth:
                                                200, // Ubah sesuai kebutuhan
                                          ),
                                          child: Text(
                                            hk.tanggapan,
                                            overflow: TextOverflow.visible,
                                            softWrap: true,
                                          )),
                                    ),
                                    DataCell(
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  EditHkPage.route(
                                                      hk: hk,
                                                      kelompok: kelompok,
                                                      levelUser: levelUser));
                                            },
                                          ),
                                          if (levelUser != 3)
                                            IconButton(
                                              icon: const Icon(Icons.delete),
                                              onPressed: () {
                                                _showDeleteDialog(context, ref,
                                                    hk, muridData);
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

void _showDeleteDialog(BuildContext context, WidgetRef ref, HkModel hk,
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
                    'Apakah Anda yakin ingin menghapus hasil karya $nama pada tanggal ${hk.tanggal}',
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const Text(
                  'Apakah Anda yakin ingin menghapus hasil karya ini?',
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
              ref.read(hkControllerProvider.notifier).deleteHk(hk, context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Hasil Karya berhasil dihapus'),
                ),
              );
            },
          ),
        ],
      );
    },
  );
}
