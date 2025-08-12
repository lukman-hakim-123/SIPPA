import 'dart:convert';

import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sippa/apis/pertumbuhan_api.dart';
import 'package:sippa/apis/users_api.dart';
import 'package:sippa/auth/controllers/auth_controller.dart';
import 'package:sippa/core/utils.dart';
import 'package:sippa/models/pertumbuhan.dart';

final pertumbuhanControllerProvider =
    StateNotifierProvider<PertumbuhanController, bool>((ref) {
  return PertumbuhanController(
    ref: ref,
    pertumbuhanAPI: ref.watch(pertumbuhanAPIProvider),
  );
});

final getPertumbuhanByUserIdProvider =
    FutureProvider.family<List<PertumbuhanModel>, String>(
        (ref, paramKey) async {
  final pertumbuhanController =
      ref.watch(pertumbuhanControllerProvider.notifier);
  final levelUser = ref.watch(currentUserDetailsProvider).value!.levelUser;
  final params = jsonDecode(paramKey) as Map<String, dynamic>;
  final sekolah = params['sekolah'] as String;
  final id = params['id'] as String;

  if (levelUser == 1) {
    return pertumbuhanController.getAllPertumbuhan(sekolah);
  } else if (levelUser == 2) {
    return pertumbuhanController.getAllPertumbuhan(sekolah);
  } else {
    return pertumbuhanController.getUserPertumbuhan(id, sekolah);
  }
});
final getUserDataProvider =
    FutureProvider.family<Document, String>((ref, String uid) async {
  final userAPI = ref.watch(userAPIProvider);
  return await userAPI.getUserData(uid);
});
final getLatestPertumbuhanProvider = StreamProvider((ref) {
  ref.keepAlive();
  final pertumbuhanAPI = ref.watch(pertumbuhanAPIProvider);
  return pertumbuhanAPI.getLatestPertumbuhan();
});

class PertumbuhanController extends StateNotifier<bool> {
  final PertumbuhanAPI _pertumbuhanAPI;
  final Ref _ref;

  PertumbuhanController({
    required Ref ref,
    required PertumbuhanAPI pertumbuhanAPI,
  })  : _ref = ref,
        _pertumbuhanAPI = pertumbuhanAPI,
        super(false);

  Future<List<PertumbuhanModel>> getUserPertumbuhan(
      String uid, String sekolah) async {
    final pertumbuhanList =
        await _pertumbuhanAPI.getUserPertumbuhan(uid, sekolah);
    return pertumbuhanList
        .map((pertumbuhan) => PertumbuhanModel.fromMap(pertumbuhan.data))
        .toList();
  }

  Future<List<PertumbuhanModel>> getKelompokPertumbuhan(
      String kelompok, String sekolah) async {
    final pertumbuhanList =
        await _pertumbuhanAPI.getKelompokPertumbuhan(kelompok, sekolah);
    return pertumbuhanList
        .map((pertumbuhan) => PertumbuhanModel.fromMap(pertumbuhan.data))
        .toList();
  }

  Future<List<PertumbuhanModel>> getAllPertumbuhan(String sekolah) async {
    final pertumbuhanList = await _pertumbuhanAPI.getAllPertumbuhan(sekolah);
    return pertumbuhanList
        .map((pertumbuhan) => PertumbuhanModel.fromMap(pertumbuhan.data))
        .toList();
  }

  void addPertumbuhan({
    required String tanggal,
    required String muridId,
    required int tinggi,
    required int berat,
    required int kepala,
    required String fisik,
    required String rekomendasi,
    required String sekolah,
    required BuildContext context,
  }) async {
    state = true;
    try {
      final user = _ref.read(currentUserDetailsProvider).value;
      if (user == null) {
        showSnackBar(context, 'User details not available');
        state = false;
        return;
      }

      final kelompok = _ref.read(searchUserProvider(muridId)).value?.kelompok;
      if (kelompok == null) {
        showSnackBar(context, 'Tekan lagi');
        state = false;
        return;
      }

      PertumbuhanModel pertumbuhan = PertumbuhanModel(
        tanggal: tanggal,
        uid: user.id,
        id: '',
        muridId: muridId,
        kelompok: kelompok,
        tinggi: tinggi,
        berat: berat,
        kepala: kepala,
        fisik: fisik,
        rekomendasi: rekomendasi,
        sekolah: sekolah,
        tanggapan: '',
      );

      final res = await _pertumbuhanAPI.addPertumbuhan(pertumbuhan);

      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) {
          showSnackBar(context, 'Pertumbuhan Added');
          Navigator.pop(context);
        },
      );
    } catch (e) {
      showSnackBar(context, 'Terjadi kesalahan: $e');
    } finally {
      state = false;
    }
  }

  void updatePertumbuhan({
    required String pertumbuhanId,
    required String tanggal,
    required String muridId,
    required int tinggi,
    required int berat,
    required int kepala,
    required String fisik,
    required String rekomendasi,
    required String tanggapan,
    required String sekolah,
    required BuildContext context,
  }) async {
    state = true;
    try {
      final user = _ref.read(currentUserDetailsProvider).value!;
      final kelompok = _ref.read(searchUserProvider(muridId)).value?.kelompok;
      if (kelompok == null) {
        showSnackBar(context, 'Tekan lagi');
        state = false;
        return;
      }

      PertumbuhanModel pertumbuhan = PertumbuhanModel(
        id: pertumbuhanId,
        tanggal: tanggal,
        uid: user.id,
        muridId: muridId,
        kelompok: kelompok,
        tinggi: tinggi,
        berat: berat,
        kepala: kepala,
        fisik: fisik,
        rekomendasi: rekomendasi,
        tanggapan: tanggapan,
        sekolah: sekolah,
      );

      final res = await _pertumbuhanAPI.updatePertumbuhan(pertumbuhan);

      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) {
          showSnackBar(context, 'Pertumbuhan Updated');
          Navigator.pop(context);
        },
      );
    } catch (e) {
      showSnackBar(context, 'Tekan lagi');
    } finally {
      state = false;
    }
  }

  void deletePertumbuhan(
    PertumbuhanModel pertumbuhan,
    BuildContext context,
  ) async {
    try {
      await _pertumbuhanAPI.deletePertumbuhan(pertumbuhan);
    } catch (e) {
      // Handle or log error
    }
  }
}
