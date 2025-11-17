import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/anekdot_provider.dart';
import '../../providers/murid_provider.dart';
import '../../providers/user_provider.dart';

import '../../widgets/app_colors.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/my_double_tap_exit.dart';
import 'widget/anekdot_card.dart';

class AnekdotScreen extends ConsumerStatefulWidget {
  const AnekdotScreen({super.key});

  @override
  ConsumerState<AnekdotScreen> createState() => _AnekdotScreenState();
}

class _AnekdotScreenState extends ConsumerState<AnekdotScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final anekdotState = ref.watch(anekdotProvider);
    final userState = ref.watch(userProvider);
    final muridList = ref.watch(muridProvider).value ?? [];
    final muridMap = {for (var m in muridList) m.id: m.nama};

    return MyDoubleTapExit(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: 'Anekdot',
          showBack: true,
          onBack: () => context.go('/home'),
        ),

        body: userState.when(
          loading: () => Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),

          error: (error, _) => Center(child: Text('Error: $error')),

          data: (profile) {
            final int userLevel = profile!.levelUser;

            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(anekdotProvider),
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
                        onChanged: (value) =>
                            setState(() => searchQuery = value.toLowerCase()),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // BUTTON ADD
                    if (userLevel != 3)
                      CustomButton(
                        height: 45,
                        onPressed: () => context.go('/pilihAnakAnekdot'),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(
                              text: 'Tambah data Anekdot',
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            Icon(Icons.add, color: Colors.white, size: 24),
                          ],
                        ),
                      ),

                    const SizedBox(height: 14),

                    // LIST DATA
                    Expanded(
                      child: anekdotState.when(
                        loading: () => Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),

                        error: (error, _) =>
                            Center(child: Text("Terjadi kesalahan: $error")),

                        data: (anekdotList) {
                          if (anekdotList.isEmpty) {
                            return _emptyMessage("Belum ada data Anekdot");
                          }

                          // FILTER
                          final filtered = anekdotList.where((a) {
                            final name =
                                muridMap[a.muridId]?.toLowerCase() ?? '';
                            return name.contains(searchQuery);
                          }).toList();

                          if (filtered.isEmpty) {
                            return _emptyMessage("Data tidak ditemukan");
                          }

                          final url = ref
                              .read(anekdotProvider.notifier)
                              .getPublicImageUrl;

                          return ListView.builder(
                            padding: const EdgeInsets.only(bottom: 20),
                            itemCount: filtered.length,
                            itemBuilder: (_, i) {
                              final a = filtered[i];
                              return AnekdotCard(
                                imageUrl: url(a.imageId),
                                name: muridMap[a.muridId] ?? 'Tidak ditemukan',
                                kelas: a.kelompok,
                                onTap: () =>
                                    context.go('/detailAnekdot', extra: a.id),
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

  Widget _emptyMessage(String msg) {
    return Center(child: CustomText(text: msg, fontSize: 16));
  }
}
