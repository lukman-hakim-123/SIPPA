import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../utils/arg/cp_arg.dart';
import '../../widgets/template/select_murid_page.dart';

class PilihMuridCpScreen extends ConsumerStatefulWidget {
  const PilihMuridCpScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PilihMuridCpScreenState();
}

class _PilihMuridCpScreenState extends ConsumerState<PilihMuridCpScreen> {
  @override
  Widget build(BuildContext context) {
    return SelectMuridPage(
      title: "Pilih Murid",
      backRoute: "/cp",
      onSelect: (murid) {
        context.go('/formCp', extra: CpArgs(murid: murid));
      },
    );
  }
}
