import 'package:flutter/foundation.dart';

import 'package:frontend_transactional_engine/features/auth/data/mock_auth_service.dart';
import 'package:frontend_transactional_engine/features/auth/data/real_auth_service.dart';
import 'package:frontend_transactional_engine/features/auth/domain/user_profile.dart';

import '../data/auth_flow_exception.dart';

class AuthFlowController extends ChangeNotifier {
  AuthFlowController({
    MockAuthService? mockAuthService,
    RealAuthService? realAuthService,
  }) : _authService = realAuthService ?? mockAuthService! {
    if (realAuthService == null && mockAuthService == null) {
      throw ArgumentError('Un service d\'authentification doit être fourni');
    }
  }

  final dynamic _authService;

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

  Future<bool> requestOtp(String phoneNumber) async {
    print('🔵 [AuthFlowController] requestOtp appelé avec: $phoneNumber');
    _setLoading(true);
    _setError(null);
    try {
      print('🔵 [AuthFlowController] Appel de _authService.sendOtp...');
      await _authService.sendOtp(phoneNumber: phoneNumber);
      _phoneNumber = phoneNumber;
      print('✅ [AuthFlowController] requestOtp réussi');
      return true;
    } on AuthFlowException catch (e) {
      print('❌ [AuthFlowController] Erreur: ${e.message}');
      _setError(e.message);
      return false;
    } catch (e, stackTrace) {
      print('❌ [AuthFlowController] Exception inattendue: $e');
      print('❌ [AuthFlowController] StackTrace: $stackTrace');
      _setError('Erreur inattendue: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> requestLoginOtp(String phoneNumber) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authService.sendLoginOtp(phoneNumber: phoneNumber);
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
      await _authService.completeProfile(profile);
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
      await _authService.persistPin(pin);
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
      await _authService.loginWithPin(pin);
      return true;
    } on AuthFlowException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login({
    required String phoneNumber,
    required String otp,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authService.login(phoneNumber: phoneNumber, otp: otp, password: password);
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

