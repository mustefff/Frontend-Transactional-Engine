import 'package:frontend_transactional_engine/features/auth/domain/user_profile.dart';
import 'package:frontend_transactional_engine/features/auth/data/auth_flow_exception.dart';
import 'package:frontend_transactional_engine/services/api_service.dart';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class RealAuthService {
  String? _lastPhoneNumber;

  Future<void> sendOtp({required String phoneNumber}) async {
    print('📱 [RealAuthService] sendOtp (inscription): $phoneNumber');
    debugPrint('📱 [RealAuthService] sendOtp (inscription): $phoneNumber');
    
    // Formater le numéro avec +221
    final formattedPhone = ApiService.formatPhoneNumber(phoneNumber);
    print('📱 [RealAuthService] Formaté: $formattedPhone');
    debugPrint('📱 [RealAuthService] Formaté: $formattedPhone');
    
    // Appeler l'API d'inscription étape 1
    print('📱 [RealAuthService] Appel de ApiService.inscriptionEtape1...');
    final result = await ApiService.inscriptionEtape1(formattedPhone);
    print('📱 [RealAuthService] Résultat reçu: ${result['success']}');
    
    if (result['success'] == true) {
      _lastPhoneNumber = formattedPhone;
      debugPrint('✅ [RealAuthService] OTP envoyé avec succès (inscription)');
    } else {
      debugPrint('❌ [RealAuthService] Erreur: ${result['error']}');
      throw AuthFlowException(result['error'] ?? 'Erreur lors de l\'envoi du code OTP');
    }
  }

  Future<void> sendLoginOtp({required String phoneNumber}) async {
    debugPrint('📱 [RealAuthService] sendLoginOtp (connexion): $phoneNumber');
    
    // Formater le numéro avec +221
    final formattedPhone = ApiService.formatPhoneNumber(phoneNumber);
    debugPrint('📱 [RealAuthService] Formaté: $formattedPhone');
    
    // Appeler l'API de connexion OTP (pas l'inscription !)
    final result = await ApiService.connexionOtp(formattedPhone);
    
    if (result['success'] == true) {
      _lastPhoneNumber = formattedPhone;
      debugPrint('✅ [RealAuthService] OTP envoyé avec succès (connexion)');
    } else {
      debugPrint('❌ [RealAuthService] Erreur: ${result['error']}');
      throw AuthFlowException(result['error'] ?? 'Erreur lors de l\'envoi du code OTP');
    }
  }

  Future<void> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    debugPrint('📱 [RealAuthService] verifyOtp appelé pour: $phoneNumber');
    
    // Formater le numéro avec +221
    final formattedPhone = ApiService.formatPhoneNumber(phoneNumber);
    
    // Appeler l'API de validation OTP (pour l'inscription uniquement)
    final result = await ApiService.inscriptionEtape1Validation(formattedPhone, otp);
    
    if (result['success'] == true) {
      debugPrint('✅ [RealAuthService] OTP validé avec succès');
    } else {
      debugPrint('❌ [RealAuthService] Erreur: ${result['error']}');
      throw AuthFlowException(result['error'] ?? 'Code OTP incorrect');
    }
  }

  Future<void> verifyLoginOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    debugPrint('📱 [RealAuthService] verifyLoginOtp appelé pour: $phoneNumber');
    
    // Pour la connexion, on ne vérifie pas l'OTP séparément
    // On stocke juste l'OTP pour l'utiliser avec le password plus tard
    // Cette méthode est appelée mais ne fait rien car la vérification se fait
    // lors de l'appel à connexion() avec OTP + password
    debugPrint('✅ [RealAuthService] OTP de connexion stocké (sera vérifié avec le password)');
  }

  Future<void> completeProfile(UserProfile profile) async {
    developer.log('📱 [RealAuthService] completeProfile appelé', name: 'Auth');
    debugPrint('📱 [RealAuthService] completeProfile appelé');
    
    if (_lastPhoneNumber == null) {
      throw AuthFlowException('Aucun numéro de téléphone enregistré');
    }
    
    // Appeler l'API étape 2
    // Convertir la date DateTime en format String YYYY-MM-DD
    final dateStr = '${profile.birthDate.year}-${profile.birthDate.month.toString().padLeft(2, '0')}-${profile.birthDate.day.toString().padLeft(2, '0')}';
    
    final result = await ApiService.inscriptionEtape2(
      telephone: _lastPhoneNumber!,
      nom: profile.lastName,
      prenom: profile.firstName,
      nin: profile.nin,
      dateNaissance: dateStr,
    );
    
    if (result['success'] == true) {
      developer.log('✅ [RealAuthService] Profil complété avec succès', name: 'Auth');
      debugPrint('✅ [RealAuthService] Profil complété avec succès');
    } else {
      developer.log('❌ [RealAuthService] Erreur: ${result['error']}', name: 'Auth');
      debugPrint('❌ [RealAuthService] Erreur: ${result['error']}');
      throw AuthFlowException(result['error'] ?? 'Erreur lors de l\'enregistrement du profil');
    }
  }

  Future<void> persistPin(String pin) async {
    developer.log('📱 [RealAuthService] persistPin appelé', name: 'Auth');
    debugPrint('📱 [RealAuthService] persistPin appelé');
    
    if (_lastPhoneNumber == null) {
      throw AuthFlowException('Aucun numéro de téléphone enregistré');
    }
    
    if (!RegExp(r'^[0-9]{6}$').hasMatch(pin)) {
      throw AuthFlowException('Le code doit contenir exactement 6 chiffres.');
    }
    
    // Appeler l'API étape 3
    final result = await ApiService.inscriptionEtape3(
      telephone: _lastPhoneNumber!,
      password: pin,
      confirmPassword: pin,
    );
    
    if (result['success'] == true) {
      developer.log('✅ [RealAuthService] PIN enregistré avec succès', name: 'Auth');
      debugPrint('✅ [RealAuthService] PIN enregistré avec succès');
    } else {
      developer.log('❌ [RealAuthService] Erreur: ${result['error']}', name: 'Auth');
      debugPrint('❌ [RealAuthService] Erreur: ${result['error']}');
      throw AuthFlowException(result['error'] ?? 'Erreur lors de l\'enregistrement du code');
    }
  }

  Future<void> loginWithPin(String pin) async {
    debugPrint('📱 [RealAuthService] loginWithPin appelé');
    
    if (_lastPhoneNumber == null) {
      throw AuthFlowException('Aucun numéro de téléphone enregistré. Veuillez d\'abord envoyer l\'OTP.');
    }
    
    // Note: Cette méthode devrait utiliser connexionOtp et connexion
    // Pour l'instant, on garde la logique simple
    throw AuthFlowException('Méthode loginWithPin non implémentée. Utilisez le flux de connexion complet.');
  }

  Future<void> login({
    required String phoneNumber,
    required String otp,
    required String password,
  }) async {
    debugPrint('📱 [RealAuthService] login appelé');
    
    // Formater le numéro avec +221
    final formattedPhone = ApiService.formatPhoneNumber(phoneNumber);
    
    // Appeler l'API de connexion avec OTP + password
    final result = await ApiService.connexion(
      telephone: formattedPhone,
      codeOtp: otp,
      password: password,
    );
    
    if (result['success'] == true) {
      debugPrint('✅ [RealAuthService] Connexion réussie');
    } else {
      debugPrint('❌ [RealAuthService] Erreur: ${result['error']}');
      throw AuthFlowException(result['error'] ?? 'Erreur lors de la connexion');
    }
  }

  void reset() {
    _lastPhoneNumber = null;
  }

  UserProfile? get profile => null;
  String? get storedPhoneNumber => _lastPhoneNumber;
}

