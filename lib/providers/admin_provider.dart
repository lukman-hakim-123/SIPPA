import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/user.dart';
import '../services/auth_service.dart';
import '../services/admin_service.dart';
import '../utils/provider.dart';

part 'admin_provider.g.dart';

@riverpod
class AdminNotifier extends _$AdminNotifier {
  late final AuthService _authService = AuthService(
    account: ref.read(appwriteAccountProvider),
  );
  late final AdminService _adminService = AdminService(
    db: ref.read(appwriteTableDBProvider),
    storage: ref.read(appwriteStorageProvider),
  );

  @override
  Future<List<User>> build() async {
    final result = await _adminService.getAllAdmin();
    if (result.isSuccess) {
      return result.resultValue ?? [];
    } else {
      throw Exception(result.errorMessage);
    }
  }

  Future<void> createAdmin(
    String nama,
    String email,
    String password,
    String sekolah,
    File? photoFile,
  ) async {
    state = const AsyncValue.loading();
    try {
      final authResult = await _authService.createAccount(
        email: email,
        password: password,
      );

      if (!authResult.isSuccess) {
        throw Exception("Gagal membuat akun admin: ${authResult.errorMessage}");
      }

      final userId = authResult.resultValue?.$id ?? '';
      if (userId.isEmpty) {
        throw Exception("User ID dari Appwrite kosong");
      }

      final adminProfile = User(
        id: userId,
        nama: nama,
        email: email,
        imageId: '',
        levelUser: 1,
        sekolah: sekolah,
        kelompok: '',
      );

      User finalAdmin = adminProfile;

      if (photoFile != null) {
        finalAdmin = await _uploadPhoto(
          adminProfile,
          adminProfile,
          photoFile: photoFile,
          isCreate: true,
        );
      }

      final result = await _adminService.createAdmin(finalAdmin);

      if (result.isSuccess) {
        state = AsyncValue.data([result.resultValue!, ...state.value ?? []]);
      } else {
        throw Exception("Gagal menyimpan admin: ${result.errorMessage}");
      }
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
    }
  }

  Future<void> fetchAdminById(String adminId) async {
    state = const AsyncValue.loading();
    final result = await _adminService.getAdminById(adminId);
    if (result.isSuccess) {
      state = AsyncValue.data([result.resultValue!]);
    } else {
      state = AsyncValue.error(result.errorMessage!, StackTrace.current);
    }
  }

  Future<void> updateAdmin(
    User updatedAdmin,
    User oldAdmin,
    File? photoFile,
  ) async {
    state = const AsyncValue.loading();
    try {
      final finalAdmin = await _uploadPhoto(
        oldAdmin,
        updatedAdmin,
        photoFile: photoFile,
        isCreate: false,
      );
      final result = await _adminService.updateAdmin(finalAdmin);

      if (result.isSuccess) {
        final updatedList = (state.value ?? []).map((admin) {
          return admin.id == finalAdmin.id ? finalAdmin : admin;
        }).toList();

        state = AsyncValue.data(updatedList);
      } else {
        state = AsyncValue.error(result.errorMessage!, StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
    }
  }

  Future<void> deleteAdmin(User admin) async {
    final previous = state.value ?? [];
    state = const AsyncValue.loading();

    try {
      await _adminService.deleteImage(admin.imageId);
      final result = await _adminService.deleteAdmin(admin.id);
      if (!ref.mounted) return;

      if (result.isSuccess) {
        state = AsyncValue.data(
          previous.where((g) => g.id != admin.id).toList(),
        );
      } else {
        state = AsyncValue.error(result.errorMessage!, StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<User> _uploadPhoto(
    User oldAdmin,
    User updatedAdmin, {
    File? photoFile,
    bool isCreate = false,
  }) async {
    if (isCreate && photoFile == null) {
      throw Exception("Foto wajib diunggah saat create");
    }

    if (!isCreate && photoFile == null) {
      return updatedAdmin.copyWith(imageId: oldAdmin.imageId);
    }

    if (!isCreate && photoFile != null && oldAdmin.imageId.isNotEmpty) {
      try {
        await _adminService.deleteImage(oldAdmin.imageId);
      } catch (_) {}
    }

    final result = await _adminService.uploadImage(
      photoFile!,
      'admin_${updatedAdmin.email}',
    );

    if (result.isSuccess) {
      return updatedAdmin.copyWith(imageId: result.resultValue!);
    } else {
      throw Exception("Upload foto gagal: ${result.errorMessage}");
    }
  }

  String getPublicImageUrl(String fileId) {
    return _adminService.getPublicImageUrl(fileId);
  }
}
