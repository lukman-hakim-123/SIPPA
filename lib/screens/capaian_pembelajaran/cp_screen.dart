import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/cp_provider.dart';
import '../../providers/murid_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/common/loading.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/my_double_tap_exit.dart';
import 'widget/Cp_card.dart';

class CpScreen extends ConsumerStatefulWidget {
  const CpScreen({super.key});

  @override
  ConsumerState<CpScreen> createState() => _CpScreenState();
}

class _CpScreenState extends ConsumerState<CpScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cpState = ref.watch(cpProvider);
    final userState = ref.watch(userProvider);
    final muridList = ref.watch(muridProvider).value ?? [];
    final muridMap = {for (var m in muridList) m.id: m};

    return MyDoubleTapExit(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: 'Capaian Pembelajaran',
          showBack: true,
          onBack: () => context.go('/home'),
        ),
        body: userState.when(
          data: (profile) {
            final int userLevel = profile!.levelUser;
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(cpProvider);
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
                      child: cpState.when(
                        data: (cpList) {
                          if (cpList.isEmpty) {
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

                          final filtered = cpList.where((cp) {
                            final muridName =
                                muridMap[cp.muridId]?.nama.toLowerCase() ?? '';
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
                              final cp = filtered[index];
                              return CpCard(
                                cp: cp,
                                murid: muridMap[cp.muridId],
                                imageUrlBuilder: url,
                                onTap: () =>
                                    context.go('/detailCp', extra: cp.id),
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
        context.go('/pilihAnakCp');
      },
      height: 45.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          CustomText(
            text: 'Tambah Capaian Pembelajaran',
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
