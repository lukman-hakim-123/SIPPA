import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/cp.dart';
import '../services/cp_service.dart';
import '../utils/provider.dart';
import 'user_provider.dart';

part 'cp_provider.g.dart';

@riverpod
class CpNotifier extends _$CpNotifier {
  late final CpService _cpService = CpService(
    db: ref.read(appwriteTableDBProvider),
  );

  @override
  Future<List<CpModel>> build() async {
    final profileAsync = ref.watch(userProvider);

    if (profileAsync.isLoading) {
      state = const AsyncValue.loading();
    }

    if (profileAsync.hasError) {
      throw profileAsync.error!;
    }

    final profile = profileAsync.value;
    if (profile == null) return [];

    final level = profile.levelUser;

    if (level == 1) {
      final result = await _cpService.getAllCpBySekolah(profile.sekolah);
      if (result.isSuccess) {
        return result.resultValue ?? [];
      } else {
        throw Exception(result.errorMessage);
      }
    }

    if (level == 2) {
      final result = await _cpService.getAllCpByKelompok(
        profile.sekolah,
        profile.kelompok,
      );
      if (result.isSuccess) {
        return result.resultValue ?? [];
      } else {
        throw Exception(result.errorMessage);
      }
    }

    if (level == 3) {
      final result = await _cpService.getAllCpByUId(profile.id);
      if (result.isSuccess) {
        return result.resultValue ?? [];
      } else {
        throw Exception(result.errorMessage);
      }
    }

    final result = await _cpService.getAllCp();
    if (result.isSuccess) {
      return result.resultValue ?? [];
    } else {
      throw Exception(result.errorMessage);
    }
  }

  Future<void> createCp(CpModel cp) async {
    state = const AsyncValue.loading();
    try {
      final result = await _cpService.createCp(cp);

      if (result.isSuccess) {
        state = AsyncValue.data([result.resultValue!, ...state.value ?? []]);
      } else {
        throw Exception("Gagal menyimpan Cp: ${result.errorMessage}");
      }
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
    }
  }

  Future<void> fetchCpById(String cpId) async {
    state = const AsyncValue.loading();
    final result = await _cpService.getCpById(cpId);
    if (result.isSuccess) {
      state = AsyncValue.data([result.resultValue!]);
    } else {
      state = AsyncValue.error(result.errorMessage!, StackTrace.current);
    }
  }

  Future<void> updateCp(CpModel updatedCp) async {
    state = const AsyncValue.loading();
    try {
      final result = await _cpService.updateCp(updatedCp);

      if (result.isSuccess) {
        final updatedList = (state.value ?? []).map((cp) {
          return cp.id == updatedCp.id ? updatedCp : cp;
        }).toList();

        state = AsyncValue.data(updatedList);
      } else {
        state = AsyncValue.error(result.errorMessage!, StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
    }
  }

  Future<void> deleteCp(CpModel cp) async {
    final previous = state.value ?? [];
    state = const AsyncValue.loading();

    try {
      final result = await _cpService.deleteCp(cp.id);
      if (!ref.mounted) return;
      if (result.isSuccess) {
        state = AsyncValue.data(previous.where((g) => g.id != cp.id).toList());
      } else {
        state = AsyncValue.error(result.errorMessage!, StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
