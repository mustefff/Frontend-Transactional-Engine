import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:frontend_transactional_engine/features/wallet/domain/compte.dart';
import 'package:frontend_transactional_engine/features/wallet/domain/transfert.dart';
import 'package:frontend_transactional_engine/features/wallet/domain/contact.dart';
import 'package:frontend_transactional_engine/features/wallet/domain/transaction.dart';

class WalletService {
  final String baseUrl;

  WalletService({required this.baseUrl});

  /// Récupère le compte d'un utilisateur par son numéro de téléphone
  Future<Compte?> getCompteByPhone(String phoneNumber) async {
    try {
      final url = '$baseUrl/api/compte/by-phone/$phoneNumber';
      developer.log('📤 GET $url');

      final response = await http.get(Uri.parse(url));
      developer.log('📥 Réponse: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          developer.log('✅ Compte récupéré: ${data['data']}');
          return Compte.fromJson(data['data']);
        }
      }

      developer.log('❌ Erreur: ${response.body}');
      return null;
    } catch (e) {
      developer.log('❌ Exception lors de la récupération du compte: $e');
      return null;
    }
  }

  /// Effectue un transfert d'argent
  Future<TransfertResponse?> effectuerTransfert(TransfertRequest request) async {
    try {
      final url = '$baseUrl/api/transferts';
      developer.log('📤 POST $url');
      developer.log('📦 Body: ${json.encode(request.toJson())}');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      );

      developer.log('📥 Réponse: ${response.statusCode}');
      developer.log('📄 Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        return TransfertResponse.fromJson(data);
      }

      // Gestion des erreurs
      if (response.body.isNotEmpty) {
        try {
          final errorData = json.decode(response.body);
          return TransfertResponse(
            message: errorData['message'] ?? 'Erreur lors du transfert',
            success: false,
            statusCode: response.statusCode,
          );
        } catch (e) {
          return TransfertResponse(
            message: 'Erreur lors du transfert',
            success: false,
            statusCode: response.statusCode,
          );
        }
      }

      return TransfertResponse(
        message: 'Erreur lors du transfert',
        success: false,
        statusCode: response.statusCode,
      );
    } catch (e) {
      developer.log('❌ Exception lors du transfert: $e');
      return TransfertResponse(
        message: 'Erreur de connexion: ${e.toString()}',
        success: false,
        statusCode: 500,
      );
    }
  }

  /// Récupère le compte d'un utilisateur par son numéro de compte (UUID)
  Future<Compte?> getCompteByNumCompte(String numCompte) async {
    // Cette méthode pourrait être implémentée si le backend a un endpoint pour ça
    // Pour l'instant, on utilise getCompteByPhone
    developer.log('⚠️ getCompteByNumCompte non implémenté, utilisez getCompteByPhone');
    return null;
  }

  /// Récupère tous les utilisateurs (contacts)
  Future<List<Contact>> getAllContacts() async {
    try {
      final url = '$baseUrl/api/users/all';
      developer.log('📤 GET $url');

      final response = await http.get(Uri.parse(url));
      developer.log('📥 Réponse: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> usersJson = data['data'];
          final contacts = usersJson
              .map((json) => Contact.fromJson(json))
              .toList();
          developer.log('✅ ${contacts.length} contacts récupérés');
          return contacts;
        }
      }

      developer.log('❌ Erreur: ${response.body}');
      return [];
    } catch (e) {
      developer.log('❌ Exception lors de la récupération des contacts: $e');
      return [];
    }
  }

  /// Récupère l'historique des transactions d'un utilisateur
  Future<List<Transaction>> getTransactionHistory(String phoneNumber) async {
    try {
      final url = '$baseUrl/api/transferts/user/$phoneNumber';
      developer.log('📤 GET $url');

      final response = await http.get(Uri.parse(url));
      developer.log('📥 Réponse: ${response.statusCode}');
      developer.log('📄 Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        developer.log('🔍 Data decoded: $data');
        
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> transactionsJson = data['data'];
          developer.log('📊 Transactions JSON: $transactionsJson');
          
          final transactions = transactionsJson
              .map((json) {
                developer.log('🔄 Parsing transaction: $json');
                return Transaction.fromJson(json);
              })
              .toList();
          developer.log('✅ ${transactions.length} transactions récupérées');
          return transactions;
        } else {
          developer.log('⚠️ Success=false ou data=null');
        }
      }

      developer.log('❌ Erreur: ${response.body}');
      return [];
    } catch (e, stackTrace) {
      developer.log('❌ Exception lors de la récupération de l\'historique: $e');
      developer.log('Stack trace: $stackTrace');
      return [];
    }
  }
}
