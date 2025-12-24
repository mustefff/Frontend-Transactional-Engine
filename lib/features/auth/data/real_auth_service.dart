import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend_transactional_engine/features/auth/data/mock_auth_service.dart';
import 'package:frontend_transactional_engine/features/auth/domain/auth_service.dart';
import 'package:frontend_transactional_engine/features/auth/domain/user_profile.dart';

/// Service d'authentification réel qui communique avec le backend Spring Boot
class RealAuthService implements AuthService {
  RealAuthService({required this.baseUrl, required this.keycloakUrl}) {
    _loadProfile();
  }

  final String baseUrl;
  final String keycloakUrl;

  String? _lastPhoneNumber;
  UserProfile? _profile;
  String? _pin;
  String? _authToken;
  int? _userId;

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final firstName = prefs.getString('user_firstName');
      final lastName = prefs.getString('user_lastName');
      final nin = prefs.getString('user_nin');
      final phone = prefs.getString('user_phone');
      
      if (firstName != null && lastName != null) {
        _profile = UserProfile(
          firstName: firstName,
          lastName: lastName,
          nin: nin ?? '',
          birthDate: DateTime.now(),
        );
        _lastPhoneNumber = phone;
        developer.log('💾 Profil chargé depuis le cache: $firstName $lastName');
      }
    } catch (e) {
      developer.log('⚠️ Erreur chargement profil: $e');
    }
  }

  Future<void> _saveProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_profile != null) {
        await prefs.setString('user_firstName', _profile!.firstName);
        await prefs.setString('user_lastName', _profile!.lastName);
        await prefs.setString('user_nin', _profile!.nin);
        if (_lastPhoneNumber != null) {
          await prefs.setString('user_phone', _lastPhoneNumber!);
        }
        developer.log('💾 Profil sauvegardé dans le cache');
      }
    } catch (e) {
      developer.log('⚠️ Erreur sauvegarde profil: $e');
    }
  }

  @override
  Future<bool> checkUserExists({required String phoneNumber}) async {
    developer.log('🔍 Vérification existence utilisateur: $phoneNumber');
    
    final cleaned = phoneNumber.replaceAll(' ', '');
    
    try {
      final checkUrl = '$baseUrl/api/users/getUserByPhone/$cleaned';
      developer.log('📤 GET $checkUrl');
      
      final response = await http.get(Uri.parse(checkUrl));
      developer.log('📥 Réponse: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          developer.log('✅ Utilisateur trouvé');
          _lastPhoneNumber = cleaned;
          
          // Récupérer les informations de l'utilisateur depuis le backend
          final userData = data['data'];
          
          // Vérifier si un profil local existe déjà
          final prefs = await SharedPreferences.getInstance();
          final localFirstName = prefs.getString('user_firstName');
          final localLastName = prefs.getString('user_lastName');
          
          // Si un profil local existe et n'est pas "Utilisateur Mobile", le garder
          if (localFirstName != null && localLastName != null && 
              !(localFirstName == 'Utilisateur' && localLastName == 'Mobile')) {
            developer.log('💾 Profil local trouvé: $localFirstName $localLastName (priorité sur le backend)');
            // Le profil local a déjà été chargé dans _loadProfile()
          } else {
            // Sinon, utiliser les données du backend
            _profile = UserProfile(
              lastName: userData['nom'] ?? '',
              firstName: userData['prenom'] ?? '',
              nin: userData['nin']?.toString() ?? '',
              birthDate: DateTime.now(),
            );
            await _saveProfile();
            developer.log('👤 Profil récupéré depuis le backend: ${_profile?.firstName} ${_profile?.lastName}');
          }
          return true;
        }
      }
      
      developer.log(' Utilisateur non trouvé');
      return false;
      
    } catch (e) {
      developer.log(' Erreur lors de la vérification: $e');
      return false;
    }
  }

  @override
  Future<void> sendOtp({required String phoneNumber}) async {
    developer.log('📱 Envoi OTP pour: $phoneNumber');
    
    final cleaned = phoneNumber.replaceAll(' ', '');
    final isValid = RegExp(r'^\+[0-9]{8,}$').hasMatch(cleaned);
    if (!isValid) {
      throw AuthFlowException('Numéro de téléphone invalide. Format attendu: +221XXXXXXXX');
    }

    try {
      // 1. Vérifier si l'utilisateur existe déjà
      final checkUrl = '$baseUrl/api/users/getUserByPhone/$cleaned';
      developer.log('🔍 Vérification utilisateur: $checkUrl');
      
      final checkResponse = await http.get(Uri.parse(checkUrl));
      final checkData = json.decode(checkResponse.body);
      
      if (checkResponse.statusCode == 200 && checkData['success'] == true) {
        // Utilisateur existe déjà
        developer.log('✅ Utilisateur existant trouvé');
        _lastPhoneNumber = cleaned;
        
        // Pour un utilisateur existant, il faudrait renvoyer un OTP
        // Mais le backend n'a pas d'endpoint pour ça, donc on informe l'utilisateur
        throw AuthFlowException('Utilisateur déjà enregistré. Utilisez la connexion.');
      }
      
      // 2. L'utilisateur n'existe pas, on l'inscrit (cela enverra automatiquement l'OTP)
      await _registerNewUser(cleaned);
      
    } catch (e) {
      developer.log('❌ Erreur sendOtp: $e');
      if (e is AuthFlowException) rethrow;
      throw AuthFlowException('Erreur de connexion: ${e.toString()}');
    }
  }

  /// Inscrit un nouvel utilisateur (le backend enverra automatiquement l'OTP)
  Future<void> _registerNewUser(String phoneNumber) async {
    try {
      developer.log('📝 Inscription nouvel utilisateur: $phoneNumber');
      
      // Générer un nom d'utilisateur unique
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final username = 'user$timestamp';
      
      final registerUrl = '$baseUrl/api/users/register/client';
      developer.log('📤 POST $registerUrl');
      
      final response = await http.post(
        Uri.parse(registerUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'prenom': 'Utilisateur',
          'nom': 'Mobile',
          'nomUtilisateur': username,
          'telephone': phoneNumber,
          'password': 'Password123!',
          'roleName': 'user',
          'nin': '1234567890123',
        }),
      );
      
      developer.log('Réponse inscription: ${response.statusCode}');
      developer.log('Body: ${response.body}');
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _lastPhoneNumber = phoneNumber;
          developer.log('✅ Inscription réussie');
          developer.log('');
          developer.log('═══════════════════════════════════════════════════');
          developer.log('🔐 CODE OTP ENVOYÉ PAR LE BACKEND');
          developer.log('📱 Consultez les logs du backend Spring Boot');
          developer.log('🔍 Recherchez: "📧 Code OTP envoyé au numéro"');
          developer.log('═══════════════════════════════════════════════════');
          developer.log('');
          return;
        }
      }
      
      // En cas d'erreur
      final errorData = json.decode(response.body);
      throw AuthFlowException(errorData['message'] ?? 'Erreur lors de l\'inscription');
      
    } catch (e) {
      developer.log('❌ Erreur inscription: $e');
      if (e is AuthFlowException) rethrow;
      throw AuthFlowException('Erreur lors de l\'inscription: ${e.toString()}');
    }
  }

  @override
  Future<void> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    developer.log('🔐 Vérification OTP pour: $phoneNumber');
    
    if (_lastPhoneNumber == null || _lastPhoneNumber != phoneNumber) {
      throw AuthFlowException(
        'Téléphone non reconnu. Veuillez recommencer l\'inscription.',
      );
    }

    try {
      final validateUrl = '$baseUrl/api/compte/validate-otp';
      developer.log('📤 POST $validateUrl');
      
      final response = await http.post(
        Uri.parse(validateUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'telephone': phoneNumber,
          'otpCode': otp,
        }),
      );
      
      developer.log('📥 Réponse validation: ${response.statusCode}');
      developer.log('📄 Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Récupérer l'utilisateur pour obtenir son ID
          final userResponse = await http.get(
            Uri.parse('$baseUrl/api/users/getUserByPhone/$phoneNumber'),
          );
          
          if (userResponse.statusCode == 200) {
            final userData = json.decode(userResponse.body);
            if (userData['success'] == true && userData['data'] != null) {
              _userId = userData['data']['id'];
              developer.log('✅ OTP validé avec succès - userId: $_userId');
            }
          }
          return;
        }
      }

      final errorData = json.decode(response.body);
      throw AuthFlowException(errorData['message'] ?? 'Code OTP invalide.');
      
    } catch (e) {
      developer.log('❌ Erreur validation OTP: $e');
      if (e is AuthFlowException) rethrow;
      throw AuthFlowException('Erreur lors de la validation: ${e.toString()}');
    }
  }

  @override
  Future<void> completeProfile({
    required String phoneNumber,
    required UserProfile profile,
  }) async {
    developer.log('👤 Complétion du profil pour: $phoneNumber');
    
    if (_lastPhoneNumber == null || _lastPhoneNumber != phoneNumber) {
      throw AuthFlowException(
        'Téléphone non reconnu. Veuillez recommencer l\'inscription.',
      );
    }

    try {
      // Mettre à jour le profil dans le backend via l'endpoint public
      final completeProfileUrl = '$baseUrl/api/users/complete-profile';
      developer.log('📤 POST $completeProfileUrl');
      
      final response = await http.post(
        Uri.parse(completeProfileUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'telephone': phoneNumber,
          'nom': profile.lastName,
          'prenom': profile.firstName,
          'nin': profile.nin,
        }),
      );
      
      developer.log('📥 Réponse mise à jour profil: ${response.statusCode}');
      developer.log('📄 Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Stocker le profil localement
          _profile = profile;
          await _saveProfile();
          developer.log('✅ Profil mis à jour dans le backend et sauvegardé localement');
          developer.log('👤 Données backend: ${data['data']}');
          return;
        }
      }

      // Gestion des erreurs
      if (response.body.isNotEmpty) {
        try {
          final errorData = json.decode(response.body);
          throw AuthFlowException(errorData['message'] ?? 'Erreur lors de la mise à jour du profil');
        } catch (e) {
          if (e is AuthFlowException) rethrow;
          throw AuthFlowException('Erreur lors de la mise à jour du profil (${response.statusCode})');
        }
      } else {
        throw AuthFlowException('Erreur lors de la mise à jour du profil (${response.statusCode})');
      }
      
    } catch (e) {
      developer.log('❌ Erreur mise à jour profil: $e');
      if (e is AuthFlowException) rethrow;
      throw AuthFlowException('Erreur lors de la mise à jour: ${e.toString()}');
    }
  }

  @override
  Future<void> setPin({
    required String phoneNumber,
    required String pin,
  }) async {
    developer.log('🔢 Définition du PIN pour: $phoneNumber');
    
    if (_lastPhoneNumber == null || _lastPhoneNumber != phoneNumber) {
      throw AuthFlowException(
        'Téléphone non reconnu. Veuillez recommencer l\'inscription.',
      );
    }

    // Stocker le PIN localement
    _pin = pin;
    developer.log('✅ PIN enregistré localement');
    
    // Note: Le backend n'a pas d'endpoint pour définir un PIN
    // Dans une version complète, il faudrait ajouter cette fonctionnalité
  }

  @override
  Future<void> verifyPin({
    required String phoneNumber,
    required String pin,
  }) async {
    developer.log('🔐 Vérification du PIN pour: $phoneNumber');
    
    if (_lastPhoneNumber == null || _lastPhoneNumber != phoneNumber) {
      throw AuthFlowException('Téléphone non reconnu.');
    }

    if (_pin == null || _pin != pin) {
      throw AuthFlowException('Code PIN incorrect.');
    }

    developer.log('✅ PIN validé');
    
    // Note: Dans une version complète, il faudrait obtenir un token d'authentification
    // depuis Keycloak après la validation du PIN
  }

  @override
  UserProfile? get profile => _profile;

  @override
  String? get storedPhoneNumber => _lastPhoneNumber;

  @override
  String? get authToken => _authToken;
}
