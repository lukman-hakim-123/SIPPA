import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../utils/arg/pertumbuhan_arg.dart';
import '../../widgets/template/select_murid_page.dart';

class PilihMuridPertumbuhanScreen extends ConsumerStatefulWidget {
  const PilihMuridPertumbuhanScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PilihMuridPertumbuhanScreenState();
}

class _PilihMuridPertumbuhanScreenState
    extends ConsumerState<PilihMuridPertumbuhanScreen> {
  @override
  Widget build(BuildContext context) {
    return SelectMuridPage(
      title: "Pilih Murid",
      backRoute: "/pertumbuhan",
      onSelect: (murid) {
        context.go('/formPertumbuhan', extra: PertumbuhanArgs(murid: murid));
      },
    );
  }
}
