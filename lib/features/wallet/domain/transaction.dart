class Transaction {
  final int id;
  final double montant;
  final String date;
  final bool isDebit;
  final String type;
  final String autreNom;
  final String autreTelephone;

  Transaction({
    required this.id,
    required this.montant,
    required this.date,
    required this.isDebit,
    required this.type,
    required this.autreNom,
    required this.autreTelephone,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int,
      montant: (json['montant'] as num).toDouble(),
      date: json['date'] as String,
      isDebit: json['isDebit'] as bool,
      type: json['type'] as String,
      autreNom: (json['autreNom'] ?? 'Inconnu').toString(),
      autreTelephone: (json['autreTelephone'] ?? '').toString(),
    );
  }

  String get formattedAmount {
    final sign = isDebit ? '-' : '+';
    return '$sign${montant.toStringAsFixed(0)} CFA';
  }

  String get title {
    if (isDebit) {
      return 'Envoyé à $autreNom';
    } else {
      return 'Reçu de $autreNom';
    }
  }

  String get subtitle {
    return autreTelephone.isNotEmpty ? autreTelephone : 'Numéro inconnu';
  }
}
