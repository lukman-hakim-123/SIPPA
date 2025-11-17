import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/murid_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/template/user_list_screen.dart';

class MuridScreen extends ConsumerWidget {
  const MuridScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ignore: unused_local_variable
    final userState = ref.watch(userProvider);

    return UserListScreen(
      title: 'Murid',
      dataState: ref.watch(muridProvider),
      onReload: () => ref.invalidate(muridProvider),
      formRoute: '/formMurid',
      detailRoute: '/detailMurid',
      subtitleBuilder: (u) {
        return 'Kelas: ${u.kelompok}';
      },
      imageIdGetter: (u) =>
          ref.read(muridProvider.notifier).getPublicImageUrl(u.imageId),
    );
  }
}
