import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sippa/anekdot/anekdot_page.dart';
import 'package:sippa/apis/anekdot_api.dart';
import 'package:sippa/apis/users_api.dart';
import 'package:sippa/core/utils.dart';
import 'package:sippa/models/anekdot.dart';
import 'package:sippa/auth/controllers/auth_controller.dart';

final anekdotControllerProvider =
    StateNotifierProvider<AnekdotController, bool>((ref) {
  return AnekdotController(
    ref: ref,
    anekdotAPI: ref.watch(anekdotAPIProvider),
  );
});

final getAnekdotByUserIdProvider =
    FutureProvider.family((ref, String id) async {
  final anekdotController = ref.watch(anekdotControllerProvider.notifier);
  final levelUser = ref.watch(currentUserDetailsProvider).value!.levelUser;
  if (levelUser == 1) {
    return anekdotController.getAllAnekdot();
  } else if (levelUser == 2) {
    return anekdotController.getAllAnekdot();
  } else {
    return anekdotController.getUserAnekdot(id);
  }
});
final getUserDataProvider =
    FutureProvider.family<Document, String>((ref, String uid) async {
  final userAPI = ref.watch(userAPIProvider);
  return await userAPI.getUserData(uid);
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

  Future<List<AnekdotModel>> getUserAnekdot(String uid) async {
    final anekdotList = await _anekdotAPI.getUserAnekdot(uid);
    return anekdotList
        .map((anekdot) => AnekdotModel.fromMap(anekdot.data))
        .toList();
  }

  Future<List<AnekdotModel>> getKelompokAnekdot(String kelompok) async {
    final anekdotList = await _anekdotAPI.getKelompokAnekdot(kelompok);
    return anekdotList
        .map((anekdot) => AnekdotModel.fromMap(anekdot.data))
        .toList();
  }

  Future<List<AnekdotModel>> getAllAnekdot() async {
    final anekdotList = await _anekdotAPI.getAllAnekdot();
    return anekdotList
        .map((anekdot) => AnekdotModel.fromMap(anekdot.data))
        .toList();
  }

  void addAnekdot({
    required String pengamatan,
    required String tanggal,
    required String analisisCapaian,
    required String muridId,
    required BuildContext context,
  }) async {
    state = true;
    final user = _ref.read(currentUserDetailsProvider).value!;
    AnekdotModel anekdot = AnekdotModel(
      pengamatan: pengamatan,
      tanggal: tanggal,
      analisisCapaian: analisisCapaian,
      muridId: muridId,
      uid: user.id,
      id: '',
    );
    final res = await _anekdotAPI.addAnekdot(anekdot);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Anekdot Added');
      Navigator.pop(context);
    });
  }

  void updateAnekdot({
    required String anekdotId,
    required String pengamatan,
    required String tanggal,
    required String analisisCapaian,
    required String muridId,
    required BuildContext context,
  }) async {
    state = true;
    final user = _ref.read(currentUserDetailsProvider).value!;
    AnekdotModel anekdot = AnekdotModel(
      id: anekdotId,
      pengamatan: pengamatan,
      tanggal: tanggal,
      analisisCapaian: analisisCapaian,
      muridId: muridId,
      uid: user.id,
    );

    final res = await _anekdotAPI.updateAnekdot(anekdot);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Anekdot Updated');
      Navigator.pop(context);
    });
  }

  void deleteAnekdot(
    AnekdotModel anekdot,
    BuildContext context,
  ) async {
    try {
      await _anekdotAPI.deleteAnekdot(anekdot);
    } catch (e) {
      // print(e.toString());
    }
  }
}
