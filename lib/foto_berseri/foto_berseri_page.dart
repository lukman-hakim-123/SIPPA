import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sippa/auth/controllers/auth_controller.dart';
import 'package:sippa/common/loading.dart';
import 'package:sippa/constant/appwrite.dart';
import 'package:sippa/foto_berseri/add_foto_berseri_page.dart';
import 'package:sippa/foto_berseri/controller/foto_berseri_controller.dart';
import 'package:sippa/foto_berseri/edit_foto_berseri_page.dart';
import 'package:sippa/models/fb.dart';

import 'package:sippa/widget_view/appbar.dart';
import 'package:sippa/widget_view/drawer.dart';
import 'package:sippa/widget_view/teks.dart';

class FbPage extends ConsumerStatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => const FbPage());

  const FbPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FbPageState();
}

class _FbPageState extends ConsumerState<FbPage> {
  List<FbModel> _fbList = [];
  int _selectedIndex = 4;

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userDetailsAsync = ref.watch(currentUserDetailsProvider);
    return Scaffold(
      appBar: const CustomAppBar(title: 'Foto Berseri'),
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
            final fbAsyncValue = ref.watch(getFbByUserIdProvider(userId));
            ref.listen<AsyncValue<RealtimeMessage>>(getLatestFbProvider,
                (_, next) {
              next.whenData((data) {
                if (data.events.contains(
                  'databases.*.collections.${AppwriteConstants.fbCollection}.documents.*.create',
                )) {
                  final newFb = FbModel.fromMap(data.payload);
                  if ((levelUser == 1) ||
                      (levelUser == 2 && newFb.uid == userId) ||
                      (levelUser == 3 && newFb.muridId == userId)) {
                    if (!_fbList.any((fb) => fb.id == newFb.id)) {
                      setState(() {
                        _fbList.add(newFb);
                      });
                    }
                  }
                } else if (data.events.contains(
                  'databases.*.collections.${AppwriteConstants.fbCollection}.documents.*.update',
                )) {
                  final startingPoint =
                      data.events[0].lastIndexOf('documents.');
                  final endPoint = data.events[0].lastIndexOf('.update');
                  final fbId =
                      data.events[0].substring(startingPoint + 10, endPoint);
                  var fb = _fbList.firstWhere((element) => element.id == fbId);
                  final fbIndex = _fbList.indexOf(fb);
                  setState(() {
                    _fbList.removeAt(fbIndex);
                    final updatedFb = FbModel.fromMap(data.payload);
                    if ((levelUser == 1) ||
                        (levelUser == 2 && updatedFb.uid == userId) ||
                        (levelUser == 3 && updatedFb.muridId == userId)) {
                      _fbList.insert(fbIndex, updatedFb);
                    }
                  });
                } else if (data.events.contains(
                  'databases.*.collections.${AppwriteConstants.fbCollection}.documents.*.delete',
                )) {
                  final startingPoint =
                      data.events[0].lastIndexOf('documents.');
                  final endPoint = data.events[0].lastIndexOf('.delete');
                  final fbId =
                      data.events[0].substring(startingPoint + 10, endPoint);

                  setState(() {
                    _fbList.removeWhere((fb) => fb.id == fbId);
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
                        text: "Foto Berseri",
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
                            context, AddFbPage.route(kelompok: kelompok));
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
                  fbAsyncValue.when(
                    data: (fbList) {
                      _fbList = fbList;
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
                                  text: 'Foto 1',
                                  fontWeight: FontWeight.w700,
                                )),
                                DataColumn(
                                    label: CustomText(
                                  text: 'Foto 2',
                                  fontWeight: FontWeight.w700,
                                )),
                                DataColumn(
                                    label: CustomText(
                                  text: 'Foto 3',
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
                                  text: 'Keterangan',
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
                                  text: 'Analisis Literasi dan STEAM',
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
                              rows: _fbList
                                  .where((fb) => !(levelUser == 2 &&
                                      fb.kelompok != kelompok))
                                  .map((fb) {
                                final muridData =
                                    ref.watch(getUserDataProvider(fb.muridId));
                                final guruData =
                                    ref.watch(getUserDataProvider(fb.uid));
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
                                                getFbImageProvider(fb.imageId1))
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
                                          maxWidth: 150,
                                          maxHeight: 150,
                                        ),
                                        child: ref
                                            .watch(
                                                getFbImageProvider(fb.imageId2))
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
                                          maxWidth: 150,
                                          maxHeight: 150,
                                        ),
                                        child: ref
                                            .watch(
                                                getFbImageProvider(fb.imageId3))
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
                                          fb.kelompok,
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
                                          fb.tanggal,
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
                                          fb.keterangan,
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
                                          fb.nilai,
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
                                            fb.jatiDiri,
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
                                            fb.literasi,
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
                                            fb.umpanBalik,
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
                                            fb.tanggapan,
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
                                                  EditFbPage.route(
                                                      fb: fb,
                                                      kelompok: kelompok,
                                                      levelUser: levelUser));
                                            },
                                          ),
                                          if (levelUser != 3)
                                            IconButton(
                                              icon: const Icon(Icons.delete),
                                              onPressed: () {
                                                _showDeleteDialog(context, ref,
                                                    fb, muridData);
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

void _showDeleteDialog(BuildContext context, WidgetRef ref, FbModel fb,
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
                    'Apakah Anda yakin ingin menghapus foto berseri $nama pada tanggal ${fb.tanggal}',
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const Text(
                  'Apakah Anda yakin ingin menghapus foto berseri ini?',
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
              ref.read(fbControllerProvider.notifier).deleteFb(fb, context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Foto berseri berhasil dihapus'),
                ),
              );
            },
          ),
        ],
      );
    },
  );
}
