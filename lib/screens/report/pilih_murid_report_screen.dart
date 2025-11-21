import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/user_provider.dart';
import '../../widgets/template/select_murid_page.dart';

class PilihMuridReportScreen extends ConsumerStatefulWidget {
  const PilihMuridReportScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PilihMuridReportScreenState();
}

class _PilihMuridReportScreenState
    extends ConsumerState<PilihMuridReportScreen> {
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final profile = ref.watch(userProvider);
    return SelectMuridPage(
      title: "Pilih Murid",
      backRoute: "/home",
      onSelect: (murid) {
        context.go('/report', extra: murid);
      },
    );
  }
}
