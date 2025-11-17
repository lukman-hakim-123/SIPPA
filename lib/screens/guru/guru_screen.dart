import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/guru_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/template/user_list_screen.dart';

class GuruScreen extends ConsumerWidget {
  const GuruScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ignore: unused_local_variable
    final userState = ref.watch(userProvider);

    return UserListScreen(
      title: 'Guru',
      dataState: ref.watch(guruProvider),
      onReload: () => ref.invalidate(guruProvider),
      formRoute: '/formGuru',
      detailRoute: '/detailGuru',
      subtitleBuilder: (u) {
        return 'Kelas: ${u.kelompok} \nSekolah: ${u.sekolah}';
      },
      imageIdGetter: (u) =>
          ref.read(guruProvider.notifier).getPublicImageUrl(u.imageId),
    );
  }
}
