import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/common/loading.dart';
import '../../providers/murid_provider.dart';
import '../../utils/arg/rubrik_arg.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/my_double_tap_exit.dart';

class PilihMuridRubrikScreen extends ConsumerStatefulWidget {
  const PilihMuridRubrikScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PilihMuridRubrikScreenState();
}

class _PilihMuridRubrikScreenState
    extends ConsumerState<PilihMuridRubrikScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final muridState = ref.watch(muridProvider);
    return MyDoubleTapExit(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const CustomText(
            text: 'Pilih murid',
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
          backgroundColor: AppColors.primary,
          centerTitle: true,
          elevation: 0.0,
          scrolledUnderElevation: 0.0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              context.go('/rubrik');
            },
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(muridProvider);
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                SizedBox(
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
                ),
                const SizedBox(height: 10.0),
                Expanded(
                  child: muridState.when(
                    data: (muridList) {
                      if (muridList.isEmpty) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: const Center(
                            child: CustomText(
                              text: 'Belum ada data murid',
                              fontSize: 16,
                            ),
                          ),
                        );
                      }
                      final filtered = muridList.where((murid) {
                        return murid.nama.toLowerCase().contains(searchQuery);
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
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final murid = filtered[index];
                          return Card(
                            color: Colors.white,
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.grey[300],
                                child: ClipOval(
                                  child: Image.network(
                                    url(murid.imageId),
                                    fit: BoxFit.cover,
                                    width: 100,
                                    height: 100,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child;
                                      }
                                      return Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            value:
                                                loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.person,
                                              color: Colors.grey,
                                              size: 40,
                                            ),
                                  ),
                                ),
                              ),
                              title: CustomText(
                                text: murid.nama,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(text: '${murid.nama} tahun'),
                                  CustomText(
                                    text: murid.kelompok,
                                    fontSize: 12,
                                  ),
                                ],
                              ),
                              onTap: () {
                                context.go(
                                  '/formRubrik',
                                  extra: RubrikArgs(murid: murid),
                                );
                              },
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
        ),
      ),
    );
  }
}
