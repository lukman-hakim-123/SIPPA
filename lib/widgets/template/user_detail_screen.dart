import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/user.dart';
import '../app_colors.dart';
import '../common/app_dialog.dart';
import '../common/info_row.dart';
import '../custom_app_bar.dart';
import '../custom_button.dart';
import '../custom_text.dart';
import '../my_double_tap_exit.dart';

class UserDetailScreen extends ConsumerStatefulWidget {
  final String title;
  final User user;
  final String Function(String imageId) getImageUrl;
  final Future<void> Function(WidgetRef ref, User user) onDelete;
  final String formRoute;
  final String listRoute;
  final List<MapEntry<String, String>> detailItems;

  const UserDetailScreen({
    super.key,
    required this.title,
    required this.user,
    required this.getImageUrl,
    required this.onDelete,
    required this.formRoute,
    required this.listRoute,
    required this.detailItems,
  });

  @override
  ConsumerState<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends ConsumerState<UserDetailScreen> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.user.imageId.isNotEmpty
        ? widget.getImageUrl(widget.user.imageId)
        : null;

    return MyDoubleTapExit(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: widget.title,
          showBack: true,
          onBack: () => context.go(widget.listRoute),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  _avatar(imageUrl),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: widget.user.nama,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        const SizedBox(height: 4),
                        CustomText(text: widget.user.email),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _detailCard(),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomButton(
                text: 'Edit Data',
                onPressed: () =>
                    context.push(widget.formRoute, extra: widget.user),
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Hapus Data',
                isLoading: _isDeleting,
                backgroundColor: Colors.red,
                onPressed: () => _confirmAndDelete(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatar(String? url) {
    if (url == null || url.isEmpty) {
      return CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey[300],
        child: const Icon(Icons.person, size: 50, color: Colors.white),
      );
    }
    return CircleAvatar(
      radius: 50,
      backgroundColor: Colors.grey[200],
      child: ClipOval(
        child: Image.network(
          url,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          loadingBuilder: (ctx, child, loading) {
            if (loading == null) return child;
            return const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          },
          errorBuilder: (_, _, _) =>
              const Icon(Icons.person, size: 50, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _detailCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 8),
          for (final item in widget.detailItems) infoRow(item.key, item.value),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _confirmAndDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await AppDialog.confirm(
      context,
      title: "Konfirmasi",
      message: "Apakah Anda yakin ingin menghapus data ini?",
      okText: "Hapus",
      okColor: Colors.red,
    );

    if (!confirmed) return;

    setState(() => _isDeleting = true);

    try {
      await widget.onDelete(ref, widget.user);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: CustomText(text: 'Berhasil dihapus', color: Colors.white),
        ),
      );

      context.go(widget.listRoute);
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(text: 'Gagal hapus: $e', color: Colors.white),
        ),
      );
    } finally {
      if (mounted) setState(() => _isDeleting = false); // ← matikan loading
    }
  }
}
