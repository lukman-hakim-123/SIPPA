import 'dart:convert';
import 'dart:typed_data';

import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sippa/apis/hasil_karya_api.dart';
import 'package:sippa/apis/users_api.dart';
import 'package:sippa/core/utils.dart';
import 'package:sippa/auth/controllers/auth_controller.dart';
import 'package:sippa/models/hk.dart';
import 'dart:io' as io;

final hkControllerProvider = StateNotifierProvider<HkController, bool>((ref) {
  return HkController(
    ref: ref,
    hkAPI: ref.watch(hkAPIProvider),
  );
});

final getHkByUserIdProvider =
    FutureProvider.family<List<HkModel>, String>((ref, paramKey) async {
  final hkController = ref.watch(hkControllerProvider.notifier);
  final levelUser = ref.watch(currentUserDetailsProvider).value!.levelUser;
  final params = jsonDecode(paramKey) as Map<String, dynamic>;
  final sekolah = params['sekolah'] as String;
  final id = params['id'] as String;

  if (levelUser == 1) {
    return hkController.getAllHk(sekolah);
  } else if (levelUser == 2) {
    return hkController.getAllHk(sekolah);
  } else {
    return hkController.getUserHk(id, sekolah);
  }
});
final getUserDataProvider =
    FutureProvider.family<Document, String>((ref, String uid) async {
  final userAPI = ref.watch(userAPIProvider);
  return await userAPI.getUserData(uid);
});

final getLatestHkProvider = StreamProvider((ref) {
  ref.keepAlive();
  final hkAPI = ref.watch(hkAPIProvider);
  return hkAPI.getLatestHk();
});

final getHkImageProvider =
    FutureProvider.family<Uint8List?, String>((ref, String imageId) async {
  final hkAPI = ref.watch(hkAPIProvider);
  return await hkAPI.getImage(imageId);
});

class HkController extends StateNotifier<bool> {
  final HkAPI _hkAPI;
  final Ref _ref;
  HkController({
    required Ref ref,
    required HkAPI hkAPI,
  })  : _ref = ref,
        _hkAPI = hkAPI,
        super(false);

  Future<List<HkModel>> getUserHk(String uid, String sekolah) async {
    final hkList = await _hkAPI.getUserHk(uid, sekolah);
    return hkList.map((hk) => HkModel.fromMap(hk.data)).toList();
  }

  Future<List<HkModel>> getKelompokHk(String kelompok, String sekolah) async {
    final hkList = await _hkAPI.getKelompokHk(kelompok, sekolah);
    return hkList.map((hk) => HkModel.fromMap(hk.data)).toList();
  }

  Future<List<HkModel>> getAllHk(String sekolah) async {
    final hkList = await _hkAPI.getAllHk(sekolah);
    return hkList.map((hk) => HkModel.fromMap(hk.data)).toList();
  }

  Future<Uint8List?> getHkImage(String imageId) async {
    return await _hkAPI.getImage(imageId);
  }

  void addHk({
    required String semester,
    required String deskripsi,
    required String nilai,
    required String jatiDiri,
    required String literasi,
    required io.File? image,
    required String tanggal,
    required String muridId,
    required String rekomendasi,
    required String sekolah,
    required BuildContext context,
  }) async {
    state = true;
    final user = _ref.read(currentUserDetailsProvider).value!;
    final kelompok = _ref.read(searchUserProvider(muridId)).value?.kelompok;
    if (kelompok == null) {
      showSnackBar(context, 'Tekan lagi');
      state = false;
      return;
    }
    String? imageId;
    if (image != null) {
      imageId = await _hkAPI.uploadFile(image, 'hk_${DateTime.now()}.jpg');
    }

    HkModel hk = HkModel(
      semester: semester,
      deskripsi: deskripsi,
      nilai: nilai,
      jatiDiri: jatiDiri,
      literasi: literasi,
      imageId: imageId ?? '',
      tanggal: tanggal,
      muridId: muridId,
      kelompok: kelompok,
      uid: user.id,
      id: '',
      rekomendasi: rekomendasi,
      tanggapan: '',
      sekolah: sekolah,
    );

    final res = await _hkAPI.addHk(hk);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Capaian Pembelajaran Added');
      Navigator.pop(context);
    });
  }

  Future<void> updateHk({
    required String hkId,
    required String semester,
    required String deskripsi,
    required String nilai,
    required String jatiDiri,
    required String literasi,
    required io.File? image,
    required String tanggal,
    required String imageId,
    required String muridId,
    required String rekomendasi,
    required String tanggapan,
    required String sekolah,
    required BuildContext context,
  }) async {
    state = true;
    final user = _ref.read(currentUserDetailsProvider).value!;
    final kelompok = _ref.read(searchUserProvider(muridId)).value?.kelompok;
    if (kelompok == null) {
      showSnackBar(context, 'Tekan lagi');
      state = false;
      return;
    }
    if (image != null) {
      // Upload new image if provided
      await _hkAPI.deleteImage(imageId);
      imageId = await _hkAPI.uploadFile(image, 'hk_${DateTime.now()}.jpg');
    }

    HkModel hk = HkModel(
      id: hkId,
      semester: semester,
      deskripsi: deskripsi,
      nilai: nilai,
      jatiDiri: jatiDiri,
      literasi: literasi,
      imageId: imageId,
      tanggal: tanggal,
      muridId: muridId,
      kelompok: kelompok,
      rekomendasi: rekomendasi,
      tanggapan: tanggapan,
      sekolah: sekolah,
      uid: user.id,
    );

    final res = await _hkAPI.updateHk(hk);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Hasil Karya Updated');
      Navigator.pop(context);
    });
  }

  void deleteHk(
    HkModel hk,
    BuildContext context,
  ) async {
    try {
      await _hkAPI.deleteImage(hk.imageId);
      await _hkAPI.deleteHk(hk);
    } catch (e) {
      // print(e.toString());
    }
  }
}
