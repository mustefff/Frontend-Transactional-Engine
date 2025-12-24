import 'package:flutter/foundation.dart';

import 'package:frontend_transactional_engine/features/auth/domain/auth_service.dart';
import 'package:frontend_transactional_engine/features/auth/domain/user_profile.dart';
import 'package:frontend_transactional_engine/features/auth/data/mock_auth_service.dart';

class AuthFlowController extends ChangeNotifier {
  AuthFlowController({required AuthService authService})
      : _authService = authService;

  final AuthService _authService;

  bool _isLoading = false;
  String? _errorMessage;
  String? _phoneNumber;
  UserProfile? _profile;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get phoneNumber => _phoneNumber;
  UserProfile? get profile => _profile;
  String? get storedPhoneNumber => _authService.storedPhoneNumber;

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() => _setError(null);

  Future<bool> checkUserExists(String phoneNumber) async {
    _setLoading(true);
    _setError(null);
    try {
      final exists = await _authService.checkUserExists(phoneNumber: phoneNumber);
      if (exists) {
        _phoneNumber = phoneNumber;
        // Récupérer le profil depuis le service
        _profile = _authService.profile;
        notifyListeners();
      }
      return exists;
    } on AuthFlowException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Erreur lors de la vérification: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> requestOtp(String phoneNumber) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authService.sendOtp(phoneNumber: phoneNumber);
      _phoneNumber = phoneNumber;
      return true;
    } on AuthFlowException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> verifyOtp(String otp) async {
    if (_phoneNumber == null) {
      _setError('Aucun numéro de téléphone enregistré.');
      return false;
    }
    _setLoading(true);
    _setError(null);
    try {
      await _authService.verifyOtp(
        phoneNumber: _phoneNumber!,
        otp: otp,
      );
      return true;
    } on AuthFlowException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> completeProfile(UserProfile profile) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authService.completeProfile(
        phoneNumber: _phoneNumber!,
        profile: profile,
      );
      _profile = profile;
      return true;
    } on AuthFlowException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> persistPin(String pin) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authService.setPin(
        phoneNumber: _phoneNumber!,
        pin: pin,
      );
      return true;
    } on AuthFlowException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> loginWithPin(String pin) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authService.verifyPin(
        phoneNumber: _phoneNumber!,
        pin: pin,
      );
      return true;
    } on AuthFlowException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void resetFlow() {
    _phoneNumber = null;
    _profile = null;
    _errorMessage = null;
    _setLoading(false);
  }
}

