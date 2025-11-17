import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user.dart';
import '../../providers/guru_provider.dart';
import '../../widgets/common/error.dart';
import '../../widgets/common/loading.dart';
import '../../widgets/template/user_detail_screen.dart';

class DetailGuruScreen extends ConsumerWidget {
  final String guruId;

  const DetailGuruScreen({super.key, required this.guruId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guruListAsync = ref.watch(guruProvider);

    return guruListAsync.when(
      data: (gurus) {
        final guru = gurus.firstWhere(
          (a) => a.id == guruId,
          orElse: () => User(
            id: guruId,
            nama: '',
            email: '',
            levelUser: 2,
            sekolah: '',
            kelompok: '',
            imageId: '',
          ),
        );

        return UserDetailScreen(
          title: 'Detail guru',
          user: guru,
          getImageUrl: (id) =>
              ref.read(guruProvider.notifier).getPublicImageUrl(id),
          onDelete: (ref, user) =>
              ref.read(guruProvider.notifier).deleteGuru(user),
          formRoute: '/formGuru',
          listRoute: '/guru',
          detailItems: [
            MapEntry('Kelompok', guru.kelompok),
            MapEntry('Nama Sekolah', guru.sekolah),
          ],
        );
      },
      loading: () => const Loader(),
      error: (e, _) => ErrorPage(error: e.toString()),
    );
  }
}
