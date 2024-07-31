import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sippa/auth/controllers/auth_controller.dart';
import 'package:sippa/common/loading.dart';
import 'package:sippa/constant/appwrite.dart';
import 'package:sippa/models/to.dart';
import 'package:sippa/tanggapan_ortu/add_tanggapan_page.dart';
import 'package:sippa/tanggapan_ortu/controller/tanggapan_controller.dart';
import 'package:sippa/tanggapan_ortu/edit_tanggapan_page.dart';
import 'package:sippa/widget_view/appbar.dart';
import 'package:sippa/widget_view/drawer.dart';
import 'package:sippa/widget_view/teks.dart';

class TanggapanPage extends ConsumerStatefulWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const TanggapanPage());

  const TanggapanPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TanggapanPageState();
}

class _TanggapanPageState extends ConsumerState<TanggapanPage> {
  int _selectedIndex = 5;
  List<TanggapanModel> _tanggapanList = [];

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userDetailsAsync = ref.watch(currentUserDetailsProvider);
    return Scaffold(
      appBar: const CustomAppBar(title: 'Tanggapan'),
      body: Padding(
        padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
        child: userDetailsAsync.when(
          data: (userDetails) {
            if (userDetails == null) {
              return const Loader();
            }
            final userId = userDetails.id;
            final levelUser = userDetails.levelUser;
            final tanggapanAsyncValue =
                ref.watch(getTanggapanByUserIdProvider(userId));
            ref.listen<AsyncValue<RealtimeMessage>>(getLatestTanggapanProvider,
                (_, next) {
              next.whenData((data) {
                if (data.events.contains(
                  'databases.*.collections.${AppwriteConstants.toCollection}.documents.*.create',
                )) {
                  final newTanggapan = TanggapanModel.fromMap(data.payload);
                  if ((levelUser == 1) ||
                      (levelUser == 2 && newTanggapan.uid == userId) ||
                      (levelUser == 3 && newTanggapan.muridId == userId)) {
                    if (!_tanggapanList
                        .any((tanggapan) => tanggapan.id == newTanggapan.id)) {
                      setState(() {
                        _tanggapanList.add(newTanggapan);
                      });
                    }
                  }
                } else if (data.events.contains(
                  'databases.*.collections.${AppwriteConstants.toCollection}.documents.*.update',
                )) {
                  final startingPoint =
                      data.events[0].lastIndexOf('documents.');
                  final endPoint = data.events[0].lastIndexOf('.update');
                  final tanggapanId =
                      data.events[0].substring(startingPoint + 10, endPoint);
                  var tanggapan = _tanggapanList
                      .firstWhere((element) => element.id == tanggapanId);
                  final tanggapanIndex = _tanggapanList.indexOf(tanggapan);
                  setState(() {
                    _tanggapanList.removeAt(tanggapanIndex);
                    final updatedTanggapan =
                        TanggapanModel.fromMap(data.payload);
                    if ((levelUser == 1) ||
                        (levelUser == 2 && updatedTanggapan.uid == userId) ||
                        (levelUser == 3 &&
                            updatedTanggapan.muridId == userId)) {
                      _tanggapanList.insert(tanggapanIndex, updatedTanggapan);
                    }
                  });
                } else if (data.events.contains(
                  'databases.*.collections.${AppwriteConstants.toCollection}.documents.*.delete',
                )) {
                  final startingPoint =
                      data.events[0].lastIndexOf('documents.');
                  final endPoint = data.events[0].lastIndexOf('.delete');
                  final tanggapanId =
                      data.events[0].substring(startingPoint + 10, endPoint);

                  setState(() {
                    _tanggapanList.removeWhere(
                        (tanggapan) => tanggapan.id == tanggapanId);
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
                        text: "Tanggapan Orang Tua",
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ),
                  if (levelUser == 3)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, AddTanggapanPage.route());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 3),
                      ),
                      child: const CustomText(
                          text: "Tambah Tanggapan", color: Colors.white),
                    ),
                  const SizedBox(height: 16),
                  tanggapanAsyncValue.when(
                    data: (tanggapanList) {
                      _tanggapanList = tanggapanList;
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
                                  text: 'Tanggal',
                                  fontWeight: FontWeight.w700,
                                )),
                                DataColumn(
                                    label: CustomText(
                                  text: 'Tanggapan',
                                  fontWeight: FontWeight.w700,
                                )),
                                DataColumn(
                                    label: CustomText(
                                  text: 'Guru',
                                  fontWeight: FontWeight.w700,
                                )),
                                DataColumn(
                                    label: CustomText(
                                  text: 'balasan',
                                  fontWeight: FontWeight.w700,
                                )),
                                DataColumn(
                                    label: CustomText(
                                  text: 'Action',
                                  fontWeight: FontWeight.w700,
                                )),
                              ],
                              rows: _tanggapanList
                                  .where((tanggapan) => !(levelUser == 2 &&
                                      tanggapan.kelompok !=
                                          userDetails.kelompok))
                                  .map((tanggapan) {
                                final muridData = ref.watch(
                                    getUserDataProvider(tanggapan.muridId));
                                final guruData = tanggapan.uid != ''
                                    ? ref.watch(
                                        getUserDataProvider(tanggapan.uid))
                                    : const AsyncValue.data(null);
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 150,
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
                                        ),
                                        child: Text(
                                          tanggapan.kelompok,
                                          overflow: TextOverflow.visible,
                                          softWrap: true,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 150,
                                        ),
                                        child: Text(
                                          tanggapan.tanggal,
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
                                          tanggapan.tanggapan,
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
                                        child: guruData.when(
                                          data: (data) => Text(
                                            data?.data['nama'] ?? '',
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
                                        child: Text(
                                          tanggapan.balasan,
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
                                                  EditTanggapanPage.route(
                                                      tanggapan: tanggapan));
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () {
                                              _showDeleteDialog(
                                                  context, ref, tanggapan);
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

void _showDeleteDialog(
    BuildContext context, WidgetRef ref, TanggapanModel tanggapan) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Hapus Data'),
        content: Text(
          'Apakah Anda yakin ingin menghapus tanggapan pada tanggal ${tanggapan.tanggal}?',
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
                  .read(tanggapanControllerProvider.notifier)
                  .deleteTanggapan(tanggapan, context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tanggapan berhasil dihapus'),
                ),
              );
            },
          ),
        ],
      );
    },
  );
}
