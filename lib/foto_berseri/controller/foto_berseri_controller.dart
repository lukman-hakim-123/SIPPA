import 'dart:typed_data';

import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sippa/apis/foto_berseri_api.dart';
import 'package:sippa/apis/users_api.dart';
import 'package:sippa/core/utils.dart';
import 'package:sippa/auth/controllers/auth_controller.dart';
import 'package:sippa/models/fb.dart';
import 'dart:io' as io;

final fbControllerProvider = StateNotifierProvider<FbController, bool>((ref) {
  return FbController(
    ref: ref,
    fbAPI: ref.watch(fbAPIProvider),
  );
});

final getFbByUserIdProvider = FutureProvider.family((ref, String id) async {
  final fbController = ref.watch(fbControllerProvider.notifier);
  final levelUser = ref.watch(currentUserDetailsProvider).value!.levelUser;
  if (levelUser == 1) {
    return fbController.getAllFb();
  } else if (levelUser == 2) {
    return fbController.getAllFb();
  } else {
    return fbController.getUserFb(id);
  }
});
final getUserDataProvider =
    FutureProvider.family<Document, String>((ref, String uid) async {
  final userAPI = ref.watch(userAPIProvider);
  return await userAPI.getUserData(uid);
});

final getLatestFbProvider = StreamProvider((ref) {
  final fbAPI = ref.watch(fbAPIProvider);
  return fbAPI.getLatestFb();
});

final getFbImageProvider =
    FutureProvider.family<Uint8List?, String>((ref, String imageId) async {
  final fbAPI = ref.watch(fbAPIProvider);
  return await fbAPI.getImage(imageId);
});

class FbController extends StateNotifier<bool> {
  final FbAPI _fbAPI;
  final Ref _ref;
  FbController({
    required Ref ref,
    required FbAPI fbAPI,
  })  : _ref = ref,
        _fbAPI = fbAPI,
        super(false);

  Future<List<FbModel>> getUserFb(String uid) async {
    final fbList = await _fbAPI.getUserFb(uid);
    return fbList.map((fb) => FbModel.fromMap(fb.data)).toList();
  }

  Future<List<FbModel>> getKelompokFb(String kelompok) async {
    final fbList = await _fbAPI.getKelompokFb(kelompok);
    return fbList.map((fb) => FbModel.fromMap(fb.data)).toList();
  }

  Future<List<FbModel>> getAllFb() async {
    final fbList = await _fbAPI.getAllFb();
    return fbList.map((fb) => FbModel.fromMap(fb.data)).toList();
  }

  Future<Uint8List?> getFbImage(String imageId) async {
    return await _fbAPI.getImage(imageId);
  }

  void addFb({
    required String tanggal,
    required String keterangan,
    required String nilai,
    required String jatiDiri,
    required String literasi,
    required String umpanBalik,
    required io.File? image1,
    required io.File? image2,
    required io.File? image3,
    required String muridId,
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
    String? imageId1;
    String? imageId2;
    String? imageId3;
    if (image1 != null) {
      imageId1 = await _fbAPI.uploadFile(image1, 'fb1_${DateTime.now()}.jpg');
    }
    if (image2 != null) {
      imageId2 = await _fbAPI.uploadFile(image2, 'fb2_${DateTime.now()}.jpg');
    }
    if (image3 != null) {
      imageId3 = await _fbAPI.uploadFile(image3, 'fb3_${DateTime.now()}.jpg');
    }

    FbModel fb = FbModel(
      keterangan: keterangan,
      nilai: nilai,
      jatiDiri: jatiDiri,
      literasi: literasi,
      umpanBalik: umpanBalik,
      imageId1: imageId1 ?? '',
      imageId2: imageId2 ?? '',
      imageId3: imageId3 ?? '',
      tanggal: tanggal,
      muridId: muridId,
      kelompok: kelompok,
      uid: user.id,
      id: '',
    );

    final res = await _fbAPI.addFb(fb);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Capaian Pembelajaran Added');
      Navigator.pop(context);
    });
  }

  void updateFb({
    required String fbId,
    required String umpanBalik,
    required String keterangan,
    required String nilai,
    required String jatiDiri,
    required String literasi,
    required io.File? image1,
    required io.File? image2,
    required io.File? image3,
    required String? imageId1,
    required String? imageId2,
    required String? imageId3,
    required bool deleteId1,
    required bool deleteId2,
    required bool deleteId3,
    required String tanggal,
    required String muridId,
    required BuildContext context,
  }) async {
    state = true;
    final user = _ref.read(currentUserDetailsProvider).value!;
    final kelompok = _ref.read(searchUserProvider(muridId)).value!.kelompok;

    if (deleteId1 && imageId1 != '') {
      await _fbAPI.deleteImage(imageId1!);
      imageId1 = '';
    }
    if (deleteId2 && imageId2 != '') {
      await _fbAPI.deleteImage(imageId2!);
      imageId2 = '';
    }
    if (deleteId3 && imageId3 != '') {
      await _fbAPI.deleteImage(imageId3!);
      imageId3 = '';
    }

    if (image1 != null) {
      if (imageId1 != '') {
        await _fbAPI.deleteImage(imageId1!);
      }
      imageId1 = await _fbAPI.uploadFile(image1, 'fb1_${DateTime.now()}.jpg');
    }
    if (image2 != null) {
      if (imageId2 != '') {
        await _fbAPI.deleteImage(imageId2!);
      }
      imageId2 = await _fbAPI.uploadFile(image2, 'fb2_${DateTime.now()}.jpg');
    }
    if (image3 != null) {
      if (imageId3 != '') {
        await _fbAPI.deleteImage(imageId3!);
      }
      imageId3 = await _fbAPI.uploadFile(image3, 'fb3_${DateTime.now()}.jpg');
    }

    FbModel fb = FbModel(
      id: fbId,
      umpanBalik: umpanBalik,
      keterangan: keterangan,
      nilai: nilai,
      jatiDiri: jatiDiri,
      literasi: literasi,
      imageId1: imageId1 ?? '',
      imageId2: imageId2 ?? '',
      imageId3: imageId3 ?? '',
      tanggal: tanggal,
      muridId: muridId,
      kelompok: kelompok,
      uid: user.id,
    );

    final res = await _fbAPI.updateFb(fb);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Hasil Karya Updated');
      Navigator.pop(context);
    });
  }

  void deleteFb(
    FbModel fb,
    BuildContext context,
  ) async {
    try {
      if (fb.imageId1.isNotEmpty) {
        await _fbAPI.deleteImage(fb.imageId1);
      }
      if (fb.imageId2.isNotEmpty) {
        await _fbAPI.deleteImage(fb.imageId2);
      }
      if (fb.imageId3.isNotEmpty) {
        await _fbAPI.deleteImage(fb.imageId3);
      }
      await _fbAPI.deleteFb(fb);
    } catch (e) {
      // print(e.toString());
    }
  }
}
