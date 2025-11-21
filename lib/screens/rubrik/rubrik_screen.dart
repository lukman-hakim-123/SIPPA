import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/rubrik_provider.dart';
import '../../providers/murid_provider.dart';
import '../../providers/user_provider.dart';

import '../../widgets/app_colors.dart';
import '../../widgets/common/loading.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/form/custom_text_field.dart';
import '../../widgets/card/custom_card.dart';
import '../../widgets/my_double_tap_exit.dart';

class RubrikScreen extends ConsumerStatefulWidget {
  const RubrikScreen({super.key});

  @override
  ConsumerState<RubrikScreen> createState() => _RubrikScreenState();
}

class _RubrikScreenState extends ConsumerState<RubrikScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rubrikState = ref.watch(rubrikProvider);
    final userState = ref.watch(userProvider);

    final muridList = ref.watch(muridProvider).value ?? [];
    final muridMap = {for (var m in muridList) m.id: m};

    return MyDoubleTapExit(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: "Rubrik",
          showBack: true,
          onBack: () => context.go('/home'),
        ),
        body: userState.when(
          data: (profile) {
            final userLevel = profile!.levelUser;

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(rubrikProvider);
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  children: [
                    _searchField(),
                    const SizedBox(height: 10),
                    if (userLevel != 3) _addButton(),
                    const SizedBox(height: 10),
                    Expanded(
                      child: rubrikState.when(
                        data: (rubrikList) {
                          if (rubrikList.isEmpty) {
                            return const Center(
                              child: CustomText(
                                text: 'Belum ada data',
                                fontSize: 16,
                              ),
                            );
                          }

                          final filtered = rubrikList.where((r) {
                            final muridName =
                                muridMap[r.muridId]?.nama.toLowerCase() ?? '';
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
                              final rubrik = filtered[index];

                              return CustomCard(
                                nama: muridMap[rubrik.muridId]?.nama,
                                kelas: rubrik.kelompok,
                                tanggal: rubrik.tanggal,
                                imageUrl:
                                    (muridMap[rubrik.muridId]
                                            ?.imageId
                                            .isNotEmpty ??
                                        false)
                                    ? url(muridMap[rubrik.muridId]!.imageId)
                                    : null,
                                onTap: () => context.go(
                                  '/detailRubrik',
                                  extra: rubrik.id,
                                ),
                              );
                            },
                          );
                        },
                        loading: () => const Loader(),
                        error: (err, _) => Text("Error: $err"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const Loader(),
          error: (err, _) => Center(child: Text("Error: $err")),
        ),
      ),
    );
  }

  Widget _searchField() {
    return SizedBox(
      height: 50,
      child: CustomTextFormField(
        controller: searchController,
        hintText: "Search...",
        suffixIcon: const Icon(Icons.search),
        onChanged: (value) {
          setState(() {
            searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _addButton() {
    return CustomButton(
      onPressed: () => context.go('/pilihAnakRubrik'),
      height: 45,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          CustomText(
            text: "Tambah Rubrik",
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          Icon(Icons.add, color: Colors.white, size: 25),
        ],
      ),
    );
  }
}
