class AuthFlowException implements Exception {
  AuthFlowException(this.message);

  final String message;

  @override
  String toString() => message;
}

