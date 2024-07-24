import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sippa/apis/tanggapan_api.dart';
import 'package:sippa/apis/users_api.dart';
import 'package:sippa/core/utils.dart';
import 'package:sippa/auth/controllers/auth_controller.dart';
import 'package:sippa/models/to.dart';

final tanggapanControllerProvider =
    StateNotifierProvider<TanggapanController, bool>((ref) {
  return TanggapanController(
    ref: ref,
    tanggapanAPI: ref.watch(tanggapanAPIProvider),
  );
});

final getTanggapanByUserIdProvider =
    FutureProvider.family((ref, String id) async {
  final tanggapanController = ref.watch(tanggapanControllerProvider.notifier);
  final levelUser = ref.watch(currentUserDetailsProvider).value!.levelUser;
  if (levelUser == 1) {
    return tanggapanController.getAllTanggapan();
  } else if (levelUser == 2) {
    return tanggapanController.getAllTanggapan();
  } else {
    return tanggapanController.getUserTanggapan(id);
  }
});
final getUserDataProvider =
    FutureProvider.family<Document, String>((ref, String uid) async {
  final userAPI = ref.watch(userAPIProvider);
  return await userAPI.getUserData(uid);
});

final getLatestTanggapanProvider = StreamProvider((ref) {
  final tanggapanAPI = ref.watch(tanggapanAPIProvider);
  return tanggapanAPI.getLatestTanggapan();
});

class TanggapanController extends StateNotifier<bool> {
  final TanggapanAPI _tanggapanAPI;
  final Ref _ref;
  TanggapanController({
    required Ref ref,
    required TanggapanAPI tanggapanAPI,
  })  : _ref = ref,
        _tanggapanAPI = tanggapanAPI,
        super(false);

  Future<List<TanggapanModel>> getUserTanggapan(String uid) async {
    final tanggapanList = await _tanggapanAPI.getUserTanggapan(uid);
    return tanggapanList
        .map((tanggapan) => TanggapanModel.fromMap(tanggapan.data))
        .toList();
  }

  Future<List<TanggapanModel>> getAllTanggapan() async {
    final tanggapanList = await _tanggapanAPI.getAllTanggapan();
    return tanggapanList
        .map((tanggapan) => TanggapanModel.fromMap(tanggapan.data))
        .toList();
  }

  void addTanggapan({
    required String tanggapan,
    required String balasan,
    required String tanggal,
    required BuildContext context,
  }) async {
    state = true;
    final user = _ref.read(currentUserDetailsProvider).value!;
    TanggapanModel tanggapanModel = TanggapanModel(
      tanggapan: tanggapan,
      balasan: balasan,
      tanggal: tanggal,
      muridId: user.id,
      kelompok: user.kelompok,
      uid: '',
      id: '',
    );
    final res = await _tanggapanAPI.addTanggapan(tanggapanModel);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Tanggapan Added');
      Navigator.pop(context);
    });
  }

  void updateTanggapan({
    required String tanggapanId,
    required String tanggapan,
    required String balasan,
    required String kelompok,
    required String tanggal,
    required String muridId,
    required BuildContext context,
  }) async {
    state = true;
    final user = _ref.read(currentUserDetailsProvider).value!;
    TanggapanModel tanggapanModel = TanggapanModel(
      id: tanggapanId,
      tanggapan: tanggapan,
      balasan: balasan,
      kelompok: kelompok,
      tanggal: tanggal,
      muridId: muridId,
      uid: (user.levelUser != 3) ? user.id : '',
    );
    final res = await _tanggapanAPI.updateTanggapan(tanggapanModel);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Tanggapan Updated');
      Navigator.pop(context);
    });
  }

  void deleteTanggapan(
    TanggapanModel tanggapan,
    BuildContext context,
  ) async {
    try {
      await _tanggapanAPI.deleteTanggapan(tanggapan);
    } catch (e) {
      // print(e.toString());
    }
  }
}
