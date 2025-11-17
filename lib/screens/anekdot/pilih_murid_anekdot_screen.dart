import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../utils/arg/anekdot_arg.dart';
import '../../widgets/select_murid_page.dart';

class PilihMuridAnekdotScreen extends ConsumerStatefulWidget {
  const PilihMuridAnekdotScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PilihMuridAnekdotScreenState();
}

class _PilihMuridAnekdotScreenState
    extends ConsumerState<PilihMuridAnekdotScreen> {
  @override
  Widget build(BuildContext context) {
    return SelectMuridPage(
      title: "Pilih Murid",
      backRoute: "/anekdot",
      onSelect: (murid) {
        context.go('/formAnekdot', extra: AnekdotArgs(murid: murid));
      },
    );
  }
}
