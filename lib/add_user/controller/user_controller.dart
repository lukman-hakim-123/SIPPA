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

// Perbaikan: tambahkan parameter sekolah di family
final getMuridByFiltersProvider =
    FutureProvider.family<List<User>, Map<String, String>>((ref, params) async {
  final muridController = ref.watch(muridControllerProvider.notifier);
  final levelUser = ref.watch(currentUserDetailsProvider).value!.levelUser;
  final sekolah = params['sekolah']!;
  final kelompok = params['kelompok']!;

  if (levelUser == 1) {
    await muridController.fetchAllMurid(sekolah);
    return muridController.state;
    // return ref.watch(muridControllerProvider);
  } else {
    await muridController.fetchMurid(kelompok, sekolah);
    return muridController.state;
    // return ref.watch(muridControllerProvider);
  }
});

final getUserImageProvider =
    FutureProvider.family<Uint8List?, String>((ref, String imageId) async {
  final userAPI = ref.watch(userAPIProvider);
  return await userAPI.getImage(imageId);
});

// Perbaikan: ambil sekolah dari currentUserDetailsProvider
final getLatestUsersProvider = StreamProvider((ref) {
  ref.keepAlive();
  final userApi = ref.watch(userAPIProvider);
  final sekolah = ref.watch(currentUserDetailsProvider).value!.sekolah;
  return userApi.getLatestMurid(sekolah);
});

// Perbaikan: ambil sekolah dari currentUserDetailsProvider
final getGuruByFiltersProvider = FutureProvider<List<User>>((ref) async {
  final guruController = ref.watch(muridControllerProvider.notifier);
  final sekolah = ref.watch(currentUserDetailsProvider).value!.sekolah;
  await guruController.fetchGuru(sekolah);
  return ref.watch(muridControllerProvider);
});

class UserController extends StateNotifier<List<User>> {
  final UserAPI _userAPI;

  UserController({
    required UserAPI userAPI,
  })  : _userAPI = userAPI,
        super([]);

  Future<void> fetchMurid(String kelompok, String sekolah) async {
    try {
      final documents = await _userAPI.getKelompokMurid(kelompok, sekolah);
      state = documents.map((doc) => User.fromMap(doc.data)).toList();
    } catch (e) {
      state = [];
    }
  }

  Future<void> fetchAllMurid(String sekolah) async {
    try {
      final documents = await _userAPI.getAllMurid(sekolah);
      state = documents.map((doc) => User.fromMap(doc.data)).toList();
    } catch (e) {
      state = [];
    }
  }

  Future<void> fetchGuru(String sekolah) async {
    try {
      final documents = await _userAPI.getAllGuru(sekolah);
      state = documents.map((doc) => User.fromMap(doc.data)).toList();
    } catch (e) {
      state = [];
    }
  }

  Future<void> deleteGuru(User user) async {
    try {
      if (user.imageId != '') {
        await _userAPI.deleteImage(user.imageId);
      }
      String sekolah = user.sekolah;
      await _userAPI.deleteGuru(user);
      await fetchGuru(sekolah);
    } catch (e) {
      print('Gagal menghapus guru: $e');
    }
  }

  Future<void> deleteMurid(User user) async {
    try {
      if (user.imageId != '') {
        await _userAPI.deleteImage(user.imageId);
      }
      String sekolah = user.sekolah;
      await _userAPI.deleteGuru(user); // perbaikan: bukan deleteGuru
      await fetchAllMurid(sekolah);
    } catch (e) {
      print('Gagal menghapus murid: $e');
    }
  }
}
