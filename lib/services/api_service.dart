import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:9089';
  
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

  // Étape 1 : Envoyer le numéro de téléphone pour l'inscription
  static Future<Map<String, dynamic>> inscriptionEtape1(String telephone) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/inscription/etape1'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'telephone': telephone}),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        await savePhoneNumber(telephone);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['message'] ?? 'Erreur lors de l\'envoi du code OTP'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erreur de connexion: ${e.toString()}'};
    }
  }

  // Validation du code OTP (étape 1 validation)
  static Future<Map<String, dynamic>> inscriptionEtape1Validation(
    String telephone,
    String codeOtp,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/inscription/etape1/validation'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'telephone': telephone,
          'codeOtp': codeOtp,
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['message'] ?? 'Code OTP invalide ou expiré'};
      }
    } catch (e) {
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
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/inscription/etape2'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'telephone': telephone,
          'nom': nom,
          'prenom': prenom,
          'nin': nin,
          'dateNaissance': dateNaissance,
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['message'] ?? 'Erreur lors de l\'enregistrement des informations'};
      }
    } catch (e) {
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
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/inscription/etape3'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'telephone': telephone,
          'password': password,
          'confirmPassword': confirmPassword,
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Sauvegarder le token JWT si présent
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        await deletePhoneNumber(); // Nettoyer le numéro temporaire
        return {'success': true, 'data': data, 'token': data['token']};
      } else {
        return {'success': false, 'error': data['message'] ?? 'Erreur lors de la finalisation de l\'inscription'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erreur de connexion: ${e.toString()}'};
    }
  }

  // Envoyer le code OTP pour la connexion
  static Future<Map<String, dynamic>> connexionOtp(String telephone) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/connexion/otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'telephone': telephone}),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        await savePhoneNumber(telephone);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['message'] ?? 'Erreur lors de l\'envoi du code OTP'};
      }
    } catch (e) {
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
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/connexion'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'telephone': telephone,
          'codeOtp': codeOtp,
          'password': password,
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Sauvegarder le token JWT
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        await deletePhoneNumber(); // Nettoyer le numéro temporaire
        return {'success': true, 'data': data, 'token': data['token']};
      } else {
        return {'success': false, 'error': data['message'] ?? 'Erreur lors de la connexion'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erreur de connexion: ${e.toString()}'};
    }
  }
}

