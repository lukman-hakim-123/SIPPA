// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sippa/anekdot/add_anekdot.dart';
import 'package:sippa/anekdot/controller/anekdot_controller.dart';
import 'package:sippa/auth/controllers/auth_controller.dart';
import 'package:sippa/common/loading.dart';
import 'package:sippa/constant/appwrite.dart';
import 'package:sippa/models/anekdot.dart';
import 'package:sippa/widget_view/appbar.dart';
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

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userDetailsAsync = ref.watch(currentUserDetailsProvider);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Anekdot'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: userDetailsAsync.when(
          data: (userDetails) {
            final userId = userDetails?.id;
            final kelompok = userDetails?.kelompok;
            final levelUser = userDetails?.levelUser;

            late final AsyncValue<List<AnekdotModel>> anekdotAsyncValue;

            anekdotAsyncValue = ref.watch(getAnekdotByUserIdProvider(userId!));

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
                      });
                    }
                  }
                }
              });
            });

            return ListView(
              children: [
                const SizedBox(height: 16),
                const CustomText(
                  text: "Catatan Anekdot 2024/2025",
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  textAlign: TextAlign.end,
                ),
                const SizedBox(height: 16),
                if (levelUser != 3)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
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
                  ),
                const SizedBox(height: 16),
                anekdotAsyncValue.when(
                  data: (anekdotList) {
                    _anekdotList = anekdotList;
                    return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _anekdotList.length,
                      itemBuilder: (context, index) {
                        final anekdot = _anekdotList[index];
                        final murid = anekdot.muridId;
                        final guru = anekdot.uid;
                        final dataMurid = ref.watch(getUserDataProvider(murid));
                        final dataGuru = ref.watch(getUserDataProvider(guru));

                        return dataMurid.when(
                          data: (muridData) {
                            return dataGuru.when(
                              data: (guruData) {
                                return AnekdotCard(
                                  anekdot: anekdot,
                                  murid: muridData,
                                  guru: guruData,
                                );
                              },
                              loading: () => const Loader(),
                              error: (error, stack) => const Loader(),
                            );
                          },
                          loading: () => const Loader(),
                          error: (error, stack) => Text('Error: $error'),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => const Loader(),
                ),
              ],
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

class AnekdotCard extends StatelessWidget {
  final AnekdotModel anekdot;
  final Document murid;
  final Document guru;

  const AnekdotCard({
    super.key,
    required this.anekdot,
    required this.murid,
    required this.guru,
  });

  @override
  Widget build(BuildContext context) {
    final muridNama = murid.data['nama'];
    final guruNama = guru.data['nama'];
    final kelompok = murid.data['kelompok'];
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Table(
          border: TableBorder.all(color: Colors.black, width: 1),
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey[500]),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomText(text: 'Nama: $muridNama'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomText(text: 'Tanggal: ${anekdot.tanggal}'),
                ),
              ],
            ),
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomText(text: 'Kelompok: $kelompok'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomText(text: 'Guru Kelas: $guruNama'),
                ),
              ],
            ),
            TableRow(
              decoration: BoxDecoration(color: Colors.grey[300]),
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CustomText(text: 'Pengamatan'),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CustomText(text: 'Analisis Capaian'),
                ),
              ],
            ),
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomText(text: anekdot.pengamatan),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomText(text: anekdot.analisisCapaian),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
