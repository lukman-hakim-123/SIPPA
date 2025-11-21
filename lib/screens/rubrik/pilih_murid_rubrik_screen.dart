import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../utils/arg/rubrik_arg.dart';
import '../../widgets/template/select_murid_page.dart';

class PilihMuridRubrikScreen extends ConsumerStatefulWidget {
  const PilihMuridRubrikScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PilihMuridRubrikScreenState();
}

class _PilihMuridRubrikScreenState
    extends ConsumerState<PilihMuridRubrikScreen> {
  @override
  Widget build(BuildContext context) {
    return SelectMuridPage(
      title: "Pilih Murid",
      backRoute: "/rubrik",
      onSelect: (murid) {
        context.go('/formRubrik', extra: RubrikArgs(murid: murid));
      },
    );
  }
}
