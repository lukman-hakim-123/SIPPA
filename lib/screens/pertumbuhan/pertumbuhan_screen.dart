import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/murid_provider.dart';
import '../../providers/pertumbuhan_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/card/custom_card.dart';
import '../../widgets/common/loading.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/form/custom_text_field.dart';
import '../../widgets/my_double_tap_exit.dart';

class PertumbuhanScreen extends ConsumerStatefulWidget {
  const PertumbuhanScreen({super.key});

  @override
  ConsumerState<PertumbuhanScreen> createState() => _PertumbuhanScreenState();
}

class _PertumbuhanScreenState extends ConsumerState<PertumbuhanScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pertumbuhanState = ref.watch(pertumbuhanProvider);
    final userState = ref.watch(userProvider);
    final muridList = ref.watch(muridProvider).value ?? [];
    final muridMap = {for (var m in muridList) m.id: m};

    return MyDoubleTapExit(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: 'Pertumbuhan Anak',
          showBack: true,
          onBack: () => context.go('/home'),
        ),
        body: userState.when(
          data: (profile) {
            final int userLevel = profile!.levelUser;
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(pertumbuhanProvider);
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),

                child: Column(
                  children: [
                    _searchField(),
                    const SizedBox(height: 10.0),
                    if (userLevel != 3) _addButton(),
                    const SizedBox(height: 10.0),
                    Expanded(
                      child: pertumbuhanState.when(
                        data: (pertumbuhanList) {
                          if (pertumbuhanList.isEmpty) {
                            return SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: const Center(
                                child: CustomText(
                                  text: 'Belum ada data',
                                  fontSize: 16,
                                ),
                              ),
                            );
                          }

                          final filtered = pertumbuhanList.where((pertumbuhan) {
                            final muridName =
                                muridMap[pertumbuhan.muridId]?.nama
                                    .toLowerCase() ??
                                '';
                            return muridName.contains(searchQuery);
                          }).toList();

                          if (filtered.isEmpty) {
                            return const Center(
                              child: CustomText(
                                text: 'Data tidak ditemukan',
                                fontSize: 16,
                              ),
                            );
                          }

                          final url = ref
                              .read(muridProvider.notifier)
                              .getPublicImageUrl;

                          return ListView.builder(
                            padding: const EdgeInsets.only(bottom: 20),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final pertumbuhan = filtered[index];
                              return CustomCard(
                                kelas: pertumbuhan.kelompok,
                                tanggal: pertumbuhan.tanggal,
                                nama: muridMap[pertumbuhan.muridId]?.nama,
                                imageUrl:
                                    (muridMap[pertumbuhan.muridId]
                                            ?.imageId
                                            .isNotEmpty ??
                                        false)
                                    ? url(
                                        muridMap[pertumbuhan.muridId]!.imageId,
                                      )
                                    : null,
                                onTap: () => context.go(
                                  '/detailPertumbuhan',
                                  extra: pertumbuhan.id,
                                ),
                              );
                            },
                          );
                        },
                        loading: () => Loader(),
                        error: (error, stack) =>
                            Center(child: Text('Terjadi kesalahan: $error')),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => LoadingPage(),

          error: (error, _) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }

  Widget _addButton() {
    return CustomButton(
      onPressed: () {
        context.go('/pilihAnakPertumbuhan');
      },
      height: 45.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          CustomText(
            text: 'Tambah Pertumbuhan Anak',
            color: Colors.white,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
          Icon(Icons.add, color: Colors.white, size: 25.0),
        ],
      ),
    );
  }

  Widget _searchField() {
    return SizedBox(
      height: 50.0,
      child: CustomTextFormField(
        controller: searchController,
        hintText: 'Search...',
        suffixIcon: const Icon(Icons.search),
        onChanged: (value) {
          setState(() {
            searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }
}
