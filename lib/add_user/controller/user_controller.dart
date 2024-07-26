import 'dart:typed_data';
import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sippa/add_user/list_murid.dart';
import 'package:sippa/apis/users_api.dart';
import 'package:sippa/auth/controllers/auth_controller.dart';
import 'package:sippa/core/utils.dart';
import 'package:sippa/models/user.dart';

final muridControllerProvider =
    StateNotifierProvider<UserController, List<User>>((ref) {
  return UserController(userAPI: ref.watch(userAPIProvider));
});

final getMuridByFiltersProvider =
    FutureProvider.family<List<User>, String>((ref, kelompok) async {
  final muridController = ref.watch(muridControllerProvider.notifier);
  final levelUser = ref.watch(currentUserDetailsProvider).value!.levelUser;
  if (levelUser == 1) {
    await muridController.fetchAllMurid();
    return ref.watch(muridControllerProvider);
  } else {
    await muridController.fetchMurid(kelompok);
    return ref.watch(muridControllerProvider);
  }
});

final getUserImageProvider =
    FutureProvider.family<Uint8List?, String>((ref, String imageId) async {
  final userAPI = ref.watch(userAPIProvider);
  return await userAPI.getImage(imageId);
});

final getLatestUsersProvider = StreamProvider((ref) {
  final userApi = ref.watch(userAPIProvider);
  return userApi.getLatestMurid();
});

final getGuruByFiltersProvider = FutureProvider<List<User>>((ref) async {
  final guruController = ref.watch(muridControllerProvider.notifier);
  await guruController.fetchGuru();
  return ref.watch(muridControllerProvider);
});

class UserController extends StateNotifier<List<User>> {
  final UserAPI _userAPI;

  UserController({
    required UserAPI userAPI,
  })  : _userAPI = userAPI,
        super([]);

  Future<void> fetchMurid(String kelompok) async {
    try {
      final documents = await _userAPI.getKelompokMurid(kelompok);
      state = documents.map((doc) => User.fromMap(doc.data)).toList();
    } catch (e) {
      state = [];
      // Handle errors as needed
      // Or handle error state if needed
    }
  }

  Future<void> fetchAllMurid() async {
    try {
      final documents = await _userAPI.getAllMurid();
      state = documents.map((doc) => User.fromMap(doc.data)).toList();
    } catch (e) {
      state = [];
      // Handle errors as needed
      // Or handle error state if needed
    }
  }

  Future<void> fetchGuru() async {
    try {
      final documents = await _userAPI.getAllGuru();
      state = documents.map((doc) => User.fromMap(doc.data)).toList();
    } catch (e) {
      state = [];
      // Handle errors as needed
      // Or handle error state if needed
    }
  }

  Future<void> deleteGuru(User user) async {
    try {
      if (user.imageId != '') {
        await _userAPI.deleteImage(user.imageId);
      }
      await _userAPI.deleteGuru(user);
      await fetchGuru();
    } catch (e) {
      print('Gagal menghapus guru: $e');
    }
  }

  Future<void> deleteMurid(User user) async {
    try {
      if (user.imageId != '') {
        await _userAPI.deleteImage(user.imageId);
      }
      await _userAPI.deleteGuru(user);
      await fetchGuru();
    } catch (e) {
      print('Gagal menghapus guru: $e');
    }
  }

  void updateMurid({
    required String muridId,
    required String nama,
    required String email,
    required int levelUser,
    required String
        kelompok, // Nullable karena hanya level 1 yang bisa mengubahnya
    required io.File? image,
    required String imageId,
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    // Menghapus gambar lama jika ada gambar baru
    if (image != null) {
      if (imageId != '' && imageId.isNotEmpty) {
        await _userAPI.deleteImage(imageId);
      }
      imageId = await _userAPI.uploadFile(image, 'pp_${DateTime.now()}.jpg');
    }

    // Membuat model User baru dengan data yang diperbarui
    User userModel = User(
      id: muridId,
      email: email,
      imageId: imageId,
      nama: nama,
      kelompok: kelompok,
      levelUser: levelUser,
    );

    // Memperbarui data murid di API
    final res = await _userAPI.updateMurid(userModel);
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        showSnackBar(context, 'Berhasil Terupdate');
        Navigator.pop(
          context,
        );
      },
    );
  }
}
