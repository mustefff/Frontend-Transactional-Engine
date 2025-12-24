class Compte {
  final String numCompte;
  final double solde;
  final String typeCompte;
  final String status;
  final String? dateCreation;

  Compte({
    required this.numCompte,
    required this.solde,
    required this.typeCompte,
    required this.status,
    this.dateCreation,
  });

  factory Compte.fromJson(Map<String, dynamic> json) {
    return Compte(
      numCompte: json['numCompte'] as String,
      solde: (json['solde'] as num).toDouble(),
      typeCompte: json['typeCompte'] as String,
      status: json['status'] as String,
      dateCreation: json['dateCreation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numCompte': numCompte,
      'solde': solde,
      'typeCompte': typeCompte,
      'status': status,
      'dateCreation': dateCreation,
    };
  }
}
