import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/common/error.dart';
import '../../widgets/common/loading.dart';
import '../../widgets/template/user_detail_screen.dart';

class DetailAdminScreen extends ConsumerWidget {
  final String adminId;

  const DetailAdminScreen({super.key, required this.adminId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminListAsync = ref.watch(adminProvider);

    return adminListAsync.when(
      data: (admins) {
        final admin = admins.firstWhere(
          (a) => a.id == adminId,
          orElse: () => User(
            id: adminId,
            nama: '',
            email: '',
            levelUser: 1,
            sekolah: '',
            kelompok: '',
            imageId: '',
          ),
        );

        return UserDetailScreen(
          title: 'Detail Admin',
          user: admin,
          getImageUrl: (id) =>
              ref.read(adminProvider.notifier).getPublicImageUrl(id),
          onDelete: (ref, user) =>
              ref.read(adminProvider.notifier).deleteAdmin(user),
          formRoute: '/formAdmin',
          listRoute: '/admin',
          detailItems: [MapEntry('Nama Sekolah', admin.sekolah)],
        );
      },
      loading: () => const Loader(),
      error: (e, _) => ErrorPage(error: e.toString()),
    );
  }
}
