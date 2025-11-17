import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user.dart';
import '../../providers/murid_provider.dart';
import '../../widgets/common/error.dart';
import '../../widgets/common/loading.dart';
import '../../widgets/template/user_detail_screen.dart';

class DetailMuridScreen extends ConsumerWidget {
  final String muridId;

  const DetailMuridScreen({super.key, required this.muridId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final muridListAsync = ref.watch(muridProvider);

    return muridListAsync.when(
      data: (murids) {
        final murid = murids.firstWhere(
          (a) => a.id == muridId,
          orElse: () => User(
            id: muridId,
            nama: '',
            email: '',
            levelUser: 2,
            sekolah: '',
            kelompok: '',
            imageId: '',
          ),
        );

        return UserDetailScreen(
          title: 'Detail murid',
          user: murid,
          getImageUrl: (id) =>
              ref.read(muridProvider.notifier).getPublicImageUrl(id),
          onDelete: (ref, user) =>
              ref.read(muridProvider.notifier).deleteMurid(user),
          formRoute: '/formMurid',
          listRoute: '/murid',
          detailItems: [
            MapEntry('Kelompok', murid.kelompok),
            MapEntry('Nama Sekolah', murid.sekolah),
          ],
        );
      },
      loading: () => const Loader(),
      error: (e, _) => ErrorPage(error: e.toString()),
    );
  }
}
