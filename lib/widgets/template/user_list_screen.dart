import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/user.dart';
import '../app_colors.dart';
import '../common/error.dart';
import '../common/loading.dart';
import '../custom_app_bar.dart';
import '../custom_button.dart';
import '../custom_text.dart';
import '../custom_text_field.dart';
import '../my_double_tap_exit.dart';

class UserListScreen extends ConsumerStatefulWidget {
  final String title;
  final AsyncValue<List<User>> dataState;
  final void Function() onReload;
  final String formRoute;
  final String detailRoute;
  final String Function(dynamic) subtitleBuilder;
  final String Function(dynamic) imageIdGetter;

  const UserListScreen({
    super.key,
    required this.title,
    required this.dataState,
    required this.onReload,
    required this.formRoute,
    required this.detailRoute,
    required this.subtitleBuilder,
    required this.imageIdGetter,
  });

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> {
  final searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final dataState = widget.dataState;

    return MyDoubleTapExit(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: widget.title,
          showBack: true,
          onBack: () => context.go('/home'),
        ),
        body: RefreshIndicator(
          onRefresh: () async => widget.onReload(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildSearchBox(),
                const SizedBox(height: 10),
                _buildAddButton(),
                const SizedBox(height: 10),
                Expanded(
                  child: dataState.when(
                    data: _buildList,
                    loading: () => const Loader(),
                    error: (e, _) => ErrorText(error: e.toString()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBox() {
    return CustomTextFormField(
      controller: searchController,
      hintText: 'Search...',
      suffixIcon: const Icon(Icons.search),
      onChanged: (v) => setState(() => searchQuery = v.toLowerCase()),
    );
  }

  Widget _buildAddButton() {
    return CustomButton(
      height: 45,
      onPressed: () => context.go(widget.formRoute),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            text: 'Tambah Data',
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          const Icon(Icons.add, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildList(List<User> list) {
    if (list.isEmpty) {
      return const Center(child: CustomText(text: 'Belum ada data'));
    }

    final filtered = list.where((item) {
      return item.nama.toLowerCase().contains(searchQuery);
    }).toList();

    if (filtered.isEmpty) {
      return const Center(child: CustomText(text: 'Data tidak ditemukan'));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: filtered.length,
      itemBuilder: (_, i) {
        final item = filtered[i];

        return Card(
          color: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[300],
              child: ClipOval(
                child: Image.network(
                  widget.imageIdGetter(item),
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      const Icon(Icons.person, size: 30, color: Colors.grey),
                ),
              ),
            ),
            title: CustomText(text: item.nama, fontWeight: FontWeight.bold),
            subtitle: CustomText(text: widget.subtitleBuilder(item)),
            onTap: () => context.go(widget.detailRoute, extra: item.id),
          ),
        );
      },
    );
  }
}
