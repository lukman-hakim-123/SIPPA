import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/murid_provider.dart';
import 'app_colors.dart';
import 'common/loading.dart';
import 'custom_text.dart';
import 'custom_text_field.dart';

class SelectMuridPage extends ConsumerStatefulWidget {
  final String title;
  final Function(dynamic murid) onSelect;
  final String? backRoute;

  const SelectMuridPage({
    super.key,
    required this.title,
    required this.onSelect,
    this.backRoute,
  });

  @override
  ConsumerState<SelectMuridPage> createState() => _SelectMuridPageState();
}

class _SelectMuridPageState extends ConsumerState<SelectMuridPage> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final muridState = ref.watch(muridProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: CustomText(
          text: widget.title,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20.0,
        ),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        elevation: 0.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (widget.backRoute != null) {
              context.go(widget.backRoute!);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(muridProvider),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
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
              const SizedBox(height: 10),
              Expanded(
                child: muridState.when(
                  loading: () => Loader(),
                  error: (err, st) => Center(child: Text('Error: $err')),
                  data: (muridList) {
                    final filtered = muridList
                        .where(
                          (m) => m.nama.toLowerCase().contains(searchQuery),
                        )
                        .toList();

                    if (filtered.isEmpty) {
                      return const Center(
                        child: CustomText(text: "Tidak ada data"),
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
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.grey[300],
                              child: ClipOval(
                                child: Image.network(
                                  url(murid.imageId),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => const Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            title: CustomText(
                              text: murid.nama,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            subtitle: CustomText(
                              text: "Kelas: ${murid.kelompok}",
                            ),
                            onTap: () {
                              widget.onSelect(murid);
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
