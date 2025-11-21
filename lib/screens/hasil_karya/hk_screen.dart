import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/hk_provider.dart';
import '../../providers/murid_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/card/custom_image_card.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/form/custom_text_field.dart';
import '../../widgets/my_double_tap_exit.dart';

class HkScreen extends ConsumerStatefulWidget {
  const HkScreen({super.key});

  @override
  ConsumerState<HkScreen> createState() => _HkScreenState();
}

class _HkScreenState extends ConsumerState<HkScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final hkState = ref.watch(hkProvider);
    final userState = ref.watch(userProvider);
    final muridList = ref.watch(muridProvider).value ?? [];
    final muridMap = {for (var m in muridList) m.id: m.nama};

    return MyDoubleTapExit(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: 'Hasil Karya',
          showBack: true,
          onBack: () => context.go('/home'),
        ),

        body: userState.when(
          loading: () => Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),

          error: (e, _) => Center(child: Text('Error: $e')),

          data: (profile) {
            final int userLevel = profile!.levelUser;
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(hkProvider),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  children: [
                    // SEARCH
                    SizedBox(
                      height: 50,
                      child: CustomTextFormField(
                        controller: searchController,
                        hintText: 'Search...',
                        suffixIcon: const Icon(Icons.search),
                        onChanged: (v) =>
                            setState(() => searchQuery = v.toLowerCase()),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ADD BUTTON
                    if (userLevel != 3)
                      CustomButton(
                        height: 45,
                        onPressed: () => context.go('/pilihAnakHk'),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            CustomText(
                              text: 'Tambah Hasil Karya',
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            Icon(Icons.add, color: Colors.white),
                          ],
                        ),
                      ),

                    const SizedBox(height: 14),

                    Expanded(
                      child: hkState.when(
                        loading: () => Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                        error: (e, _) =>
                            Center(child: Text("Terjadi kesalahan: $e")),

                        data: (list) {
                          if (list.isEmpty) {
                            return _emptyMessage("Belum ada data Hasil Karya");
                          }

                          // FILTER
                          final filtered = list.where((a) {
                            final name =
                                muridMap[a.muridId]?.toLowerCase() ?? '';
                            return name.contains(searchQuery);
                          }).toList();

                          if (filtered.isEmpty) {
                            return _emptyMessage("Data tidak ditemukan");
                          }

                          final url = ref
                              .read(hkProvider.notifier)
                              .getPublicImageUrl;

                          return ListView.builder(
                            padding: const EdgeInsets.only(bottom: 20),
                            itemCount: filtered.length,
                            itemBuilder: (_, i) {
                              final hk = filtered[i];
                              return CustomImageCard(
                                imageUrl: url(hk.imageId),
                                name: muridMap[hk.muridId] ?? 'Tidak ditemukan',
                                kelas: hk.kelompok,
                                onTap: () =>
                                    context.go('/detailHk', extra: hk.id),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _emptyMessage(String msg) =>
      Center(child: CustomText(text: msg, fontSize: 16));
}
