import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // URL du backend
  // 
  // CONFIGURATION :
  // - Pour Android Emulator : http://10.0.2.2:9089
  // - Pour iOS Simulator : http://localhost:9089
  // - Pour web (Chrome) : http://localhost:9089
  // - Pour appareil physique : http://VOTRE_IP:9089 (ex: http://192.168.1.100:9089)
  //
  // Changez cette valeur selon votre plateforme :
  static const String baseUrl = 'http://10.0.2.2:9089';
  
  // Alternative : Détection automatique (décommentez si besoin)
  // static String get baseUrl {
  //   if (kIsWeb) {
  //     return 'http://localhost:9089';
  //   }
  //   // Pour Android, utilisez 10.0.2.2
  //   // Pour iOS/autres, utilisez localhost
  //   return 'http://10.0.2.2:9089';  // Android Emulator
  //   // return 'http://localhost:9089';  // iOS Simulator / autres
  // }
  
  // Formater le numéro de téléphone pour toujours inclure +221
  static String formatPhoneNumber(String phone) {
    // Supprimer tous les espaces, tirets et autres caractères non numériques sauf +
    String cleaned = phone.trim().replaceAll(RegExp(r'[\s-()]'), '');
    
    // Si le numéro contient déjà +221, nettoyer et reformater
    if (cleaned.contains('+221')) {
      cleaned = cleaned.replaceAll('+221', '').replaceAll('+', '');
      return '+221$cleaned';
    }
    
    // Si le numéro commence par + mais pas +221, extraire le numéro
    if (cleaned.startsWith('+')) {
      cleaned = cleaned.substring(1);
    }
    
    // Si le numéro commence par 221, ajouter le +
    if (cleaned.startsWith('221')) {
      return '+$cleaned';
    }
    
    // Si le numéro commence par 0, remplacer par +221
    if (cleaned.startsWith('0')) {
      return '+221${cleaned.substring(1)}';
    }
    
    // Sinon, ajouter +221 au début
    return '+221$cleaned';
  }
  
  // Test de connexion au backend
  static Future<bool> testConnection() async {
    try {
      developer.log('🔍 [API] Test de connexion au backend...', name: 'API');
      debugPrint('🔍 [API] Test de connexion au backend: $baseUrl');
      
      final response = await http.get(
        Uri.parse('$baseUrl/actuator/health'),
      ).timeout(Duration(seconds: 5));
      
      developer.log('🔍 [API] Réponse du test: ${response.statusCode}', name: 'API');
      debugPrint('🔍 [API] Réponse du test: ${response.statusCode}');
      
      return response.statusCode == 200;
    } catch (e) {
      developer.log('❌ [API] Erreur de test de connexion: $e', name: 'API');
      debugPrint('❌ [API] Erreur de test de connexion: $e');
      return false;
    }
  }
  
  // Récupérer le token JWT stocké
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }
  
  // Sauvegarder le token JWT
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }
  
  // Supprimer le token JWT
  static Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }
  
  // Sauvegarder le numéro de téléphone temporairement
  static Future<void> savePhoneNumber(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('temp_phone', phone);
  }
  
  // Récupérer le numéro de téléphone temporaire
  static Future<String?> getPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('temp_phone');
  }
  
  // Supprimer le numéro de téléphone temporaire
  static Future<void> deletePhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('temp_phone');
  }

  // Sauvegarder les informations utilisateur
  static Future<void> saveUserInfo({
    required String userId,
    required String telephone,
    required String nom,
    required String prenom,
    String? compteId,
    String? numCompte,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
    await prefs.setString('user_telephone', telephone);
    await prefs.setString('user_nom', nom);
    await prefs.setString('user_prenom', prenom);
    if (compteId != null) {
      await prefs.setString('user_compte_id', compteId);
    }
    if (numCompte != null) {
      await prefs.setString('user_num_compte', numCompte);
    }
  }

  // Récupérer les informations utilisateur
  static Future<Map<String, String?>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userId': prefs.getString('user_id'),
      'telephone': prefs.getString('user_telephone'),
      'nom': prefs.getString('user_nom'),
      'prenom': prefs.getString('user_prenom'),
      'compteId': prefs.getString('user_compte_id'),
      'numCompte': prefs.getString('user_num_compte'),
    };
  }

  // Supprimer les informations utilisateur (pour la déconnexion)
  static Future<void> deleteUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_telephone');
    await prefs.remove('user_nom');
    await prefs.remove('user_prenom');
    await prefs.remove('user_compte_id');
    await prefs.remove('user_num_compte');
  }

  // Étape 1 : Envoyer le numéro de téléphone pour l'inscription
  static Future<Map<String, dynamic>> inscriptionEtape1(String telephone) async {
    try {
      print('═══════════════════════════════════════════════════════════');
      print('🔵 [API] inscriptionEtape1 appelée');
      print('🔵 [API] Téléphone reçu: $telephone');
      
      // Formater le numéro pour toujours inclure +221
      final formattedPhone = formatPhoneNumber(telephone);
      print('🔵 [API] Téléphone formaté: $formattedPhone');
      
      final url = '$baseUrl/api/auth/inscription/etape1';
      final body = jsonEncode({'telephone': formattedPhone});
      
      print('🔵 [API] POST $url');
      print('🔵 [API] Body: $body');
      debugPrint('🔵 [API] POST $url');
      debugPrint('🔵 [API] Body: $body');
      
      print('🔵 [API] Envoi de la requête HTTP...');
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: body,
      ).timeout(Duration(seconds: 10));
      
      print('🔵 [API] Réponse reçue ! Status: ${response.statusCode}');
      print('🔵 [API] Response: ${response.body}');
      debugPrint('🔵 [API] Status: ${response.statusCode}');
      debugPrint('🔵 [API] Response: ${response.body}');
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        await savePhoneNumber(formattedPhone);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['message'] ?? 'Erreur lors de l\'envoi du code OTP'};
      }
    } catch (e) {
      debugPrint('❌ [API] Erreur: $e');
      return {'success': false, 'error': 'Erreur de connexion: ${e.toString()}'};
    }
  }

  // Validation du code OTP (étape 1 validation)
  static Future<Map<String, dynamic>> inscriptionEtape1Validation(
    String telephone,
    String codeOtp,
  ) async {
    try {
      final formattedPhone = formatPhoneNumber(telephone);
      final url = '$baseUrl/api/auth/inscription/etape1/validation';
      final body = jsonEncode({
        'telephone': formattedPhone,
        'codeOtp': codeOtp,
      });
      
      debugPrint('🔵 [API] POST $url');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: body,
      ).timeout(Duration(seconds: 10));
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['message'] ?? 'Code OTP invalide ou expiré'};
      }
    } catch (e) {
      debugPrint('❌ [API] Erreur: $e');
      return {'success': false, 'error': 'Erreur de connexion: ${e.toString()}'};
    }
  }

  // Étape 2 : Enregistrer les informations personnelles
  static Future<Map<String, dynamic>> inscriptionEtape2({
    required String telephone,
    required String nom,
    required String prenom,
    required String nin,
    required String dateNaissance,
  }) async {
    try {
      final formattedPhone = formatPhoneNumber(telephone);
      final url = '$baseUrl/api/auth/inscription/etape2';
      final body = jsonEncode({
        'telephone': formattedPhone,
        'nom': nom,
        'prenom': prenom,
        'nin': nin,
        'dateNaissance': dateNaissance,
      });
      
      debugPrint('🔵 [API] POST $url');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: body,
      ).timeout(Duration(seconds: 10));
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['message'] ?? 'Erreur lors de l\'enregistrement des informations'};
      }
    } catch (e) {
      debugPrint('❌ [API] Erreur: $e');
      return {'success': false, 'error': 'Erreur de connexion: ${e.toString()}'};
    }
  }

  // Étape 3 : Finaliser l'inscription avec le mot de passe
  static Future<Map<String, dynamic>> inscriptionEtape3({
    required String telephone,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final formattedPhone = formatPhoneNumber(telephone);
      final url = '$baseUrl/api/auth/inscription/etape3';
      final body = jsonEncode({
        'telephone': formattedPhone,
        'password': password,
        'confirmPassword': confirmPassword,
      });
      
      debugPrint('🔵 [API] POST $url');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: body,
      ).timeout(Duration(seconds: 10));
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        // Sauvegarder les informations utilisateur
        if (data['userId'] != null && data['nom'] != null && data['prenom'] != null) {
          await saveUserInfo(
            userId: data['userId'].toString(),
            telephone: data['telephone'] ?? formattedPhone,
            nom: data['nom'],
            prenom: data['prenom'],
            compteId: data['compteId']?.toString(),
            numCompte: data['numCompte'],
          );
        }
        await deletePhoneNumber();
        return {'success': true, 'data': data, 'token': data['token']};
      } else {
        return {'success': false, 'error': data['message'] ?? 'Erreur lors de la finalisation de l\'inscription'};
      }
    } catch (e) {
      debugPrint('❌ [API] Erreur: $e');
      return {'success': false, 'error': 'Erreur de connexion: ${e.toString()}'};
    }
  }

  // Envoyer le code OTP pour la connexion
  static Future<Map<String, dynamic>> connexionOtp(String telephone) async {
    try {
      final formattedPhone = formatPhoneNumber(telephone);
      final url = '$baseUrl/api/auth/connexion/otp';
      final body = jsonEncode({'telephone': formattedPhone});
      
      debugPrint('🔵 [API] POST $url');
      debugPrint('🔵 [API] Téléphone: $formattedPhone');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: body,
      ).timeout(Duration(seconds: 10));
      
      debugPrint('🔵 [API] Status: ${response.statusCode}');
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        await savePhoneNumber(formattedPhone);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['message'] ?? 'Erreur lors de l\'envoi du code OTP'};
      }
    } catch (e) {
      debugPrint('❌ [API] Erreur: $e');
      return {'success': false, 'error': 'Erreur de connexion: ${e.toString()}'};
    }
  }

  // Connexion avec OTP et mot de passe
  static Future<Map<String, dynamic>> connexion({
    required String telephone,
    required String codeOtp,
    required String password,
  }) async {
    try {
      final formattedPhone = formatPhoneNumber(telephone);
      final url = '$baseUrl/api/auth/connexion';
      final body = jsonEncode({
        'telephone': formattedPhone,
        'codeOtp': codeOtp,
        'password': password,
      });
      
      debugPrint('🔵 [API] POST $url');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: body,
      ).timeout(Duration(seconds: 10));
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        // Sauvegarder les informations utilisateur
        if (data['userId'] != null && data['nom'] != null && data['prenom'] != null) {
          await saveUserInfo(
            userId: data['userId'].toString(),
            telephone: data['telephone'] ?? formattedPhone,
            nom: data['nom'],
            prenom: data['prenom'],
            compteId: data['compteId']?.toString(),
            numCompte: data['numCompte'],
          );
        }
        await deletePhoneNumber();
        return {'success': true, 'data': data, 'token': data['token']};
      } else {
        return {'success': false, 'error': data['message'] ?? 'Erreur lors de la connexion'};
      }
    } catch (e) {
      debugPrint('❌ [API] Erreur: $e');
      return {'success': false, 'error': 'Erreur de connexion: ${e.toString()}'};
    }
  }

  // Déconnexion
  static Future<Map<String, dynamic>> logout({String? userId}) async {
    try {
      debugPrint('🔵 [API] Déconnexion de l\'utilisateur...');
      
      // Récupérer le token pour l'envoyer dans le header si nécessaire
      final token = await getToken();
      
      // Construire l'URL avec le userId en paramètre si fourni
      String url = '$baseUrl/api/auth/logout';
      if (userId != null && userId.isNotEmpty) {
        url += '?userId=$userId';
      }
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 10));
      
      debugPrint('🔵 [API] Status: ${response.statusCode}');
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Supprimer toutes les données locales
        await deleteToken();
        await deletePhoneNumber();
        await deleteUserInfo();
        
        debugPrint('✅ [API] Déconnexion réussie');
        return {'success': true, 'data': data};
      } else {
        // Même en cas d'erreur, on nettoie les données locales
        await deleteToken();
        await deletePhoneNumber();
        await deleteUserInfo();
        
        return {'success': false, 'error': data['message'] ?? 'Erreur lors de la déconnexion'};
      }
    } catch (e) {
      // Même en cas d'exception, on nettoie les données locales
      await deleteToken();
      await deletePhoneNumber();
      await deleteUserInfo();
      
      debugPrint('❌ [API] Erreur lors de la déconnexion: $e');
      // On retourne success car les données locales sont nettoyées
      return {'success': true, 'error': 'Déconnexion locale effectuée'};
    }
  }
}

