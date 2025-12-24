import 'package:flutter/material.dart';
import 'package:frontend_transactional_engine/features/wallet/data/wallet_service.dart';
import 'package:frontend_transactional_engine/features/wallet/domain/compte.dart';
import 'package:frontend_transactional_engine/features/wallet/domain/transfert.dart';
import 'dart:developer' as developer;

class WalletController extends ChangeNotifier {
  final WalletService _walletService;

  WalletController({required WalletService walletService})
      : _walletService = walletService;

  Compte? _compte;
  bool _isLoading = false;
  String? _errorMessage;

  Compte? get compte => _compte;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get solde => _compte?.solde ?? 0.0;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Charge le compte de l'utilisateur
  Future<bool> loadCompte(String phoneNumber) async {
    _setLoading(true);
    _setError(null);

    try {
      developer.log('💳 Chargement du compte pour: $phoneNumber');
      final compte = await _walletService.getCompteByPhone(phoneNumber);

      if (compte != null) {
        _compte = compte;
        developer.log('✅ Compte chargé: Solde = ${compte.solde} CFA');
        notifyListeners();
        return true;
      } else {
        _setError('Impossible de récupérer le compte');
        return false;
      }
    } catch (e) {
      developer.log('❌ Erreur lors du chargement du compte: $e');
      _setError('Erreur: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Effectue un transfert d'argent
  Future<TransfertResponse?> effectuerTransfert({
    required double montant,
    required String phoneRecepteur,
  }) async {
    if (_compte == null) {
      _setError('Compte non chargé');
      return TransfertResponse(
        message: 'Compte non chargé',
        success: false,
        statusCode: 400,
      );
    }

    // Vérifier le solde
    if (_compte!.solde < montant) {
      _setError('Solde insuffisant');
      return TransfertResponse(
        message: 'Solde insuffisant. Solde actuel: ${_compte!.solde} CFA',
        success: false,
        statusCode: 400,
      );
    }

    _setLoading(true);
    _setError(null);

    try {
      developer.log('💸 Transfert de $montant CFA vers $phoneRecepteur');

      // Récupérer le compte du récepteur
      final compteRecepteur = await _walletService.getCompteByPhone(phoneRecepteur);

      if (compteRecepteur == null) {
        _setError('Destinataire introuvable');
        return TransfertResponse(
          message: 'Aucun compte trouvé pour ce numéro',
          success: false,
          statusCode: 404,
        );
      }

      // Créer la requête de transfert
      final request = TransfertRequest(
        montant: montant,
        compteEmetteur: _compte!.numCompte,
        compteRecepteur: compteRecepteur.numCompte,
      );

      // Effectuer le transfert
      final response = await _walletService.effectuerTransfert(request);

      if (response != null && response.success) {
        // Mettre à jour le solde local
        _compte = Compte(
          numCompte: _compte!.numCompte,
          solde: _compte!.solde - montant,
          typeCompte: _compte!.typeCompte,
          status: _compte!.status,
          dateCreation: _compte!.dateCreation,
        );
        developer.log('✅ Transfert réussi. Nouveau solde: ${_compte!.solde} CFA');
        notifyListeners();
      } else {
        _setError(response?.message ?? 'Erreur lors du transfert');
      }

      return response;
    } catch (e) {
      developer.log('❌ Erreur lors du transfert: $e');
      _setError('Erreur: ${e.toString()}');
      return TransfertResponse(
        message: 'Erreur: ${e.toString()}',
        success: false,
        statusCode: 500,
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Rafraîchit le solde du compte
  Future<void> refreshSolde(String phoneNumber) async {
    await loadCompte(phoneNumber);
  }

  /// Réinitialise l'état
  void reset() {
    _compte = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
