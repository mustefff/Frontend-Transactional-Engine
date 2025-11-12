import 'dart:async';

import 'package:frontend_transactional_engine/features/auth/domain/user_profile.dart';

class AuthFlowException implements Exception {
  AuthFlowException(this.message);

  final String message;

  @override
  String toString() => message;
}

class MockAuthService {
  String? _lastPhoneNumber;
  String? _expectedOtp;
  UserProfile? _profile;
  String? _pin;

  Future<void> sendOtp({required String phoneNumber}) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));

    final cleaned = phoneNumber.replaceAll(' ', '');
    final isValid = RegExp(r'^[0-9]{8,}$').hasMatch(cleaned);
    if (!isValid) {
      throw AuthFlowException('Numéro de téléphone invalide.');
    }

    _lastPhoneNumber = phoneNumber;
    _expectedOtp = '1234';
  }

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

  Future<void> completeProfile(UserProfile profile) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));

    if (profile.nin.length < 6) {
      throw AuthFlowException('Le NIN doit contenir au moins 6 caractères.');
    }
    _profile = profile;
  }

  Future<void> persistPin(String pin) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!RegExp(r'^[0-9]{6}$').hasMatch(pin)) {
      throw AuthFlowException('Le code doit contenir exactement 6 chiffres.');
    }
    _pin = pin;
  }

  Future<void> loginWithPin(String pin) async {
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

  UserProfile? get profile => _profile;
  String? get storedPhoneNumber => _lastPhoneNumber;
}

