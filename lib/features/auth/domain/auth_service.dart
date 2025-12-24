import 'package:frontend_transactional_engine/features/auth/domain/user_profile.dart';

/// Interface pour les services d'authentification
abstract class AuthService {
  /// Vérifie si un utilisateur existe avec ce numéro de téléphone
  Future<bool> checkUserExists({required String phoneNumber});

  /// Envoie un code OTP au numéro de téléphone spécifié
  Future<void> sendOtp({required String phoneNumber});

  /// Vérifie le code OTP
  Future<void> verifyOtp({
    required String phoneNumber,
    required String otp,
  });

  /// Complète le profil utilisateur
  Future<void> completeProfile({
    required String phoneNumber,
    required UserProfile profile,
  });

  /// Définit le code PIN
  Future<void> setPin({
    required String phoneNumber,
    required String pin,
  });

  /// Vérifie le code PIN
  Future<void> verifyPin({
    required String phoneNumber,
    required String pin,
  });

  /// Récupère le profil utilisateur
  UserProfile? get profile;

  /// Récupère le numéro de téléphone stocké
  String? get storedPhoneNumber;

  /// Récupère le token d'authentification
  String? get authToken;
}
