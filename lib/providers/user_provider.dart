import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/result.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user.dart';
import '../utils/provider.dart';
import 'auth_provider.dart';

part 'user_provider.g.dart';

@riverpod
class UserNotifier extends _$UserNotifier {
  late final UserService _userService = UserService(
    db: ref.read(appwriteTableDBProvider),
    storage: ref.read(appwriteStorageProvider),
  );

  late final AuthService _authService = AuthService(
    account: ref.read(appwriteAccountProvider),
  );

  @override
  Future<User?> build() async {
    final authUser = ref.read(authProvider).value;
    if (authUser != null) {
      final result = await _userService.getUser(authUser.$id);

      if (result.isSuccess) {
        return result.resultValue;
      } else {
        throw Exception(result.errorMessage);
      }
    }
    return null;
  }

  Future<void> createUser(User user) async {
    state = const AsyncValue.loading();
    final result = await _userService.createUser(user);
    if (result.isSuccess) {
      state = AsyncValue.data(result.resultValue);
    } else {
      state = AsyncValue.error(result.errorMessage!, StackTrace.current);
    }
  }

  Future<void> fetchUser(String userId) async {
    state = const AsyncValue.loading();
    final result = await _userService.getUser(userId);

    if (!ref.mounted) return;
    if (result.isSuccess) {
      state = AsyncValue.data(result.resultValue);
    } else {
      state = AsyncValue.error(result.errorMessage!, StackTrace.current);
    }
  }

  Future<void> updateUser(User updatedUser) async {
    state = const AsyncValue.loading();
    final result = await _userService.updateUser(updatedUser);

    if (!ref.mounted) return;
    if (result.isSuccess) {
      state = AsyncValue.data(result.resultValue);
    } else {
      state = AsyncValue.error(result.errorMessage!, StackTrace.current);
    }
  }

  Future<User> _uploadPhotoIfNeeded(
    User user,
    User updatedUser,
    File? photoFile,
  ) async {
    if (photoFile == null) return updatedUser;

    if (user.imageId.isNotEmpty) {
      try {
        await _userService.deleteImage(user.imageId);
      } catch (_) {}
    }

    final uploadedFileId = await _userService.uploadImage(
      photoFile,
      'user_${user.id}',
    );

    if (uploadedFileId != null) {
      return updatedUser.copyWith(imageId: uploadedFileId);
    }

    return updatedUser;
  }

  Future<Result<User>> updateUserAdvanced(
    User user, {
    required User updatedUser,
    File? photoFile,
    String? oldPassword,
    String? newPassword,
  }) async {
    state = const AsyncValue.loading();
    final authUser = ref.read(authProvider).value;
    if (authUser == null) {
      state = AsyncValue.error("User tidak ditemukan", StackTrace.current);
      return Result.failed("User tidak ditemukan");
    }

    try {
      if (updatedUser.email != user.email) {
        final emailResult = await _authService.updateEmail(
          newEmail: updatedUser.email,
          oldPassword: oldPassword ?? '',
        );

        if (!emailResult.isSuccess) {
          return Result.failed(emailResult.errorMessage!);
        }
      }

      if (newPassword != null && newPassword.isNotEmpty) {
        final passResult = await _authService.updatePassword(
          oldPassword: oldPassword ?? '',
          newPassword: newPassword,
        );

        if (!passResult.isSuccess) {
          return Result.failed(passResult.errorMessage!);
        }
      }

      var finalUser = await _uploadPhotoIfNeeded(user, updatedUser, photoFile);
      final result = await _userService.updateUser(finalUser);
      if (result.isSuccess) {
        state = AsyncValue.data(result.resultValue);
        return Result.success(result.resultValue!);
      } else {
        state = AsyncValue.error(result.errorMessage!, StackTrace.current);
        return Result.failed(result.errorMessage!);
      }
    } on AppwriteException catch (e) {
      if (e.code == 401) {
        state = AsyncValue.data(state.value);
        return Result.failed("Password lama salah");
      }
      state = AsyncValue.data(state.value);
      return Result.failed(e.message ?? "Gagal update user");
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
      return Result.failed(e.toString());
    }
  }

  String getPublicImageUrl(String fileId) {
    return _userService.getPublicImageUrl(fileId);
  }
}
