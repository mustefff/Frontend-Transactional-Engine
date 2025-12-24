import 'dart:async';

import 'package:frontend_transactional_engine/features/auth/domain/auth_service.dart';
import 'package:frontend_transactional_engine/features/auth/domain/user_profile.dart';

class AuthFlowException implements Exception {
  AuthFlowException(this.message);

  final String message;

  @override
  String toString() => message;
}

class MockAuthService implements AuthService {
  String? _lastPhoneNumber;
  String? _expectedOtp;
  UserProfile? _profile;
  String? _pin;

  @override
  String? get storedPhoneNumber => _lastPhoneNumber;

  @override
  UserProfile? get profile => _profile;

  @override
  String? get authToken => null;

  @override
  Future<bool> checkUserExists({required String phoneNumber}) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    // Dans le mock, on simule qu'un utilisateur existe si un PIN a été défini
    return _pin != null;
  }

  @override
  Future<void> sendOtp({required String phoneNumber}) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));

    final cleaned = phoneNumber.replaceAll(' ', '');
    final isValid = RegExp(r'^[0-9]{8,}$').hasMatch(cleaned);
    if (!isValid) {
      throw AuthFlowException('Numéro de téléphone invalide.');
    }

    _lastPhoneNumber = phoneNumber;
    _expectedOtp = '123456'; // OTP à 6 chiffres
  }

  @override
  Future<void> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));

    if (_lastPhoneNumber == null || _lastPhoneNumber != phoneNumber) {
      throw AuthFlowException(
        'Téléphone non reconnu. Veuillez recommencer l’inscription.',
      );
    }

    if (_expectedOtp != otp) {
      throw AuthFlowException('Code OTP incorrect. Essayez à nouveau.');
    }
  }

  @override
  Future<void> completeProfile({
    required String phoneNumber,
    required UserProfile profile,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));

    if (profile.nin.length < 6) {
      throw AuthFlowException('Le NIN doit contenir au moins 6 caractères.');
    }
    _profile = profile;
  }

  @override
  Future<void> setPin({
    required String phoneNumber,
    required String pin,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!RegExp(r'^[0-9]{6}$').hasMatch(pin)) {
      throw AuthFlowException('Le code doit contenir exactement 6 chiffres.');
    }
    _pin = pin;
  }

  @override
  Future<void> verifyPin({
    required String phoneNumber,
    required String pin,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));

    if (_pin == null) {
      throw AuthFlowException('Aucun code enregistré. Veuillez vous inscrire.');
    }

    if (_pin != pin) {
      throw AuthFlowException('Code incorrect. Veuillez réessayer.');
    }
  }

  void reset() {
    _lastPhoneNumber = null;
    _expectedOtp = null;
    _profile = null;
    _pin = null;
  }
}

