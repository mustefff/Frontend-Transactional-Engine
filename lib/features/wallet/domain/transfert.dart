class TransfertRequest {
  final double montant;
  final String compteEmetteur;
  final String compteRecepteur;

  TransfertRequest({
    required this.montant,
    required this.compteEmetteur,
    required this.compteRecepteur,
  });

  Map<String, dynamic> toJson() {
    return {
      'montant': montant,
      'compteEmetteur': compteEmetteur,
      'compteRecepteur': compteRecepteur,
    };
  }
}

class TransfertResponse {
  final String message;
  final bool success;
  final int statusCode;

  TransfertResponse({
    required this.message,
    required this.success,
    required this.statusCode,
  });

  factory TransfertResponse.fromJson(Map<String, dynamic> json) {
    return TransfertResponse(
      message: json['message'] as String,
      success: json['success'] as bool,
      statusCode: json['statusCode'] as int,
    );
  }
}
