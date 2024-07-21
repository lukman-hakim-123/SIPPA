import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sippa/apis/users_api.dart';
import 'package:sippa/auth/controllers/auth_controller.dart';
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
      await _userAPI.deleteGuru(user);
      await fetchGuru();
    } catch (e) {
      print('Gagal menghapus guru: $e');
    }
  }

  Future<void> deleteMurid(User user) async {
    try {
      await _userAPI.deleteGuru(user);
      await fetchGuru();
    } catch (e) {
      print('Gagal menghapus guru: $e');
    }
  }
}
