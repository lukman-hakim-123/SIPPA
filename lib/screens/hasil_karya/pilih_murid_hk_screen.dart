import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../utils/arg/hk_arg.dart';
import '../../widgets/template/select_murid_page.dart';

class PilihMuridHkScreen extends ConsumerStatefulWidget {
  const PilihMuridHkScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PilihMuridHkScreenState();
}

class _PilihMuridHkScreenState extends ConsumerState<PilihMuridHkScreen> {
  @override
  Widget build(BuildContext context) {
    return SelectMuridPage(
      title: "Pilih Murid",
      backRoute: "/hk",
      onSelect: (murid) {
        context.go('/formHk', extra: HkArgs(murid: murid));
      },
    );
  }
}
