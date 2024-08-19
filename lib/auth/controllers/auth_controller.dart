// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io' as io;

import 'package:appwrite/appwrite.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/models.dart' as model;
import 'package:sippa/add_user/list_guru.dart';
import 'package:sippa/add_user/list_murid.dart';
import 'package:sippa/anekdot/anekdot_page.dart';
import 'package:sippa/apis/auth_api.dart';
import 'package:sippa/apis/users_api.dart';
import 'package:sippa/auth/login_page.dart';
import 'package:sippa/models/user.dart';
import 'package:sippa/widget_view/edit_profil_page.dart';

import '../../core/utils.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, bool>((ref) {
  return AuthController(
    authAPI: ref.watch(authAPIProvider),
    userAPI: ref.watch(userAPIProvider),
  );
});

final currentUserDetailsProvider = FutureProvider((ref) {
  final currentUserId = ref.watch(currentUserAccountProvider).value!.$id;
  final userDetails = ref.watch(userDetailsProvider(currentUserId));
  return userDetails.value;
});
final searchUserProvider = FutureProvider.family((ref, String userId) {
  final userData = ref.watch(userDetailsProvider(userId));
  return userData.value;
});
final userDetailsProvider = FutureProvider.family((ref, String uid) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.getUserData(uid);
});

final currentUserAccountProvider = FutureProvider((ref) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.currentUser();
});

class AuthController extends StateNotifier<bool> {
  final AuthAPI _authAPI;
  final UserAPI _userAPI;

  AuthController({
    required AuthAPI authAPI,
    required UserAPI userAPI,
  })  : _authAPI = authAPI,
        _userAPI = userAPI,
        super(false);

  Future<model.User?> currentUser() => _authAPI.currentUserAccount();

  void signup({
    required String email,
    required String password,
    required String nama,
    required String kelompok,
    required io.File? image,
    required BuildContext context,
  }) async {
    state = true;
    final response = await _authAPI.signup(email: email, password: password);
    state = false;
    response.fold((l) => showSnackBar(context, l.message), (r) async {
      String? imageId;
      if (image != null) {
        imageId = await _userAPI.uploadFile(image, 'pp_${DateTime.now()}.jpg');
      }

      User userModel = User(
          imageId: imageId ?? '',
          email: email,
          id: r.$id,
          nama: nama,
          kelompok: kelompok,
          levelUser: 3);
      final res2 = await _userAPI.saveUserData(userModel);
      res2.fold((l) => showSnackBar(context, l.message), (r) {
        showSnackBar(context, "Account Murid Created Successfully");
        Navigator.pushReplacement(
            context, MuridListPage.route(kelompok: kelompok));
      });
    });
  }

  void signupguru({
    required String email,
    required String password,
    required String nama,
    required String kelompok,
    required io.File? image,
    required BuildContext context,
  }) async {
    state = true;

    final response = await _authAPI.signup(email: email, password: password);
    state = false;
    response.fold((l) => showSnackBar(context, l.message), (r) async {
      String? imageId;
      if (image != null) {
        imageId = await _userAPI.uploadFile(image, 'pp_${DateTime.now()}.jpg');
      }

      User userModel = User(
          imageId: imageId ?? '',
          email: email,
          id: r.$id,
          nama: nama,
          kelompok: kelompok,
          levelUser: 2);
      final res2 = await _userAPI.saveUserData(userModel);
      res2.fold((l) => showSnackBar(context, l.message), (r) {
        showSnackBar(context, "Account Guru Created Successfully");
        Navigator.pop(context);
      });
    });
  }

  void login({
    required String email,
    required String password,
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    state = true;

    final response = await _authAPI.login(email: email, password: password);
    state = false;
    response.fold((l) => showSnackBar(context, 'Email atau Password Salah'),
        (r) {
      showSnackBar(context, "Login is Successfully");
      ref.refresh(currentUserAccountProvider);
      Navigator.pushReplacement(context, AnekdotPage.route());
    });
  }

  void updateUser({
    required String nama,
    required String email,
    required String password,
    required io.File? image,
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    state = true;

    await _authAPI.updateEmailPassword(email: email, password: password);
    final user = ref.read(currentUserDetailsProvider).value!;
    String? imageId;
    if (image != null) {
      await _userAPI.deleteImage(user.imageId);
      imageId = await _userAPI.uploadFile(image, 'pp_${DateTime.now()}.jpg');
    }

    User userModel = User(
        id: user.id,
        email: email,
        imageId: imageId ?? user.imageId,
        nama: nama,
        kelompok: user.kelompok,
        levelUser: user.levelUser);
    final res = await _userAPI.updateUser(userModel);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Profile Updated');
      User newUser = ref.refresh(currentUserDetailsProvider).value!;
      Navigator.pushReplacement(
          context, EditProfilePage.route(userDetails: newUser));
    });
  }

  Future<User> getUserData(String uid) async {
    final document = await _userAPI.getUserData(uid);
    final updatedUser = User.fromMap(document.data);
    return updatedUser;
  }

  void logout(BuildContext context) async {
    final res = await _authAPI.logout();
    res.fold(
        (l) => null,
        (r) => {
              Navigator.pushAndRemoveUntil(
                  context, LoginPage.route(), (route) => false),
            });
  }
}
