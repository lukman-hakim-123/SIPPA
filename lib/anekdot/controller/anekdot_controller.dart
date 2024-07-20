import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sippa/anekdot/anekdot_page.dart';
import 'package:sippa/apis/anekdot_api.dart';
import 'package:sippa/core/utils.dart';
import 'package:sippa/models/anekdot.dart';
import 'package:sippa/auth/controllers/auth_controller.dart';

final taskControllerProvider =
    StateNotifierProvider<AnekdotController, bool>((ref) {
  return AnekdotController(
    ref: ref,
    anekdotAPI: ref.watch(anekdotAPIProvider),
  );
});

final getAnekdotByUserIdProvider =
    FutureProvider.family((ref, String id) async {
  final taskController = ref.watch(taskControllerProvider.notifier);
  return taskController.getTasks(id);
});

final getLatestAnekdotProvider = StreamProvider((ref) {
  final anekdotAPI = ref.watch(anekdotAPIProvider);
  return anekdotAPI.getLatestAnekdot();
});

class AnekdotController extends StateNotifier<bool> {
  final AnekdotAPI _anekdotAPI;
  final Ref _ref;
  AnekdotController({
    required Ref ref,
    required AnekdotAPI anekdotAPI,
  })  : _ref = ref,
        _anekdotAPI = anekdotAPI,
        super(false);

  Future<List<AnekdotModel>> getTasks(String uid) async {
    final taskList = await _anekdotAPI.getUserAnekdot(uid);
    return taskList.map((task) => AnekdotModel.fromMap(task.data)).toList();
  }

  void addTask({
    required String bulan,
    required String tanggal,
    required String analisisCapaian,
    required String muridId,
    required BuildContext context,
  }) async {
    state = true;
    final user = _ref.read(currentUserDetailsProvider).value!;
    AnekdotModel anekdot = AnekdotModel(
      bulan: bulan,
      tanggal: tanggal,
      analisisCapaian: analisisCapaian,
      muridId: muridId,
      uid: user.id,
      createdAt: DateTime.now(),
      id: '',
    );
    final res = await _anekdotAPI.addAnekdot(anekdot);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Task Added');
      Navigator.push(
        context,
        AnekdotPage.route(),
      );
    });
  }
}
