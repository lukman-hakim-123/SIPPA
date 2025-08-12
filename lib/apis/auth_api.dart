import 'package:appwrite/appwrite.dart';

import 'package:appwrite/models.dart' as model;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sippa/core/failure.dart';
import 'package:sippa/core/providers.dart';

import '../core/type_defs.dart';

final authAPIProvider = Provider((ref) {
  return AuthAPI(account: ref.watch(appwriteAccountProvider));
});

abstract class IAuthApi {
  FutureEither<model.User> signup({
    required String email,
    required String password,
  });
  FutureEither<model.User> updateEmailPassword({
    required String email,
    required String password,
  });
  FutureEither<model.User> updatePassword({
    required String password,
  });

  FutureEither<model.Session> login({
    required String email,
    required String password,
  });

  Future<model.User?> currentUserAccount();
  FutureEitherVoid logout();
}

class AuthAPI implements IAuthApi {
  final Account _account;
  AuthAPI({required Account account}) : _account = account;

  @override
  Future<model.User?> currentUserAccount() async {
    try {
      return await _account.get();
    } on AppwriteException {
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  FutureEither<model.User> signup(
      {required String email, required String password}) async {
    try {
      final account = await _account.create(
          userId: ID.unique(), email: email, password: password);
      return right(account);
    } on AppwriteException catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    } catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    }
  }

  @override
  FutureEither<model.User> updateEmailPassword(
      {required String email, required String password}) async {
    try {
      final account =
          await _account.updateEmail(email: email, password: password);
      return right(account);
    } on AppwriteException catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    } catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    }
  }

  @override
  FutureEither<model.User> updatePassword({required String password}) async {
    try {
      final account = await _account.updatePassword(password: password);
      return right(account);
    } on AppwriteException catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    } catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    }
  }

  @override
  FutureEither<model.Session> login(
      {required String email, required String password}) async {
    try {
      final session = await _account.createEmailPasswordSession(
          email: email, password: password);
      return right(session);
    } on AppwriteException catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    } catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    }
  }

  @override
  FutureEitherVoid logout() async {
    try {
      await _account.deleteSession(sessionId: 'current');
      return right(null);
    } on AppwriteException catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    } catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    }
  }
}
