import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/admin_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/template/user_list_screen.dart';

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ignore: unused_local_variable
    final userState = ref.watch(userProvider);
    return UserListScreen(
      title: 'Admin',
      dataState: ref.watch(adminProvider),
      formRoute: '/formAdmin',
      detailRoute: '/detailAdmin',
      onReload: () => ref.invalidate(adminProvider),
      subtitleBuilder: (u) => 'sekolah: ${u.sekolah}',
      imageIdGetter: (u) =>
          ref.read(adminProvider.notifier).getPublicImageUrl(u.imageId),
    );
  }
}
