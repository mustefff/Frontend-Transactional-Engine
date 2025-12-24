class Contact {
  final String id;
  final String nom;
  final String prenom;
  final String telephone;
  final String nomUtilisateur;
  final String? roleName;

  Contact({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.nomUtilisateur,
    this.roleName,
  });

  String get fullName => '$prenom $nom';
  String get initial => prenom.isNotEmpty ? prenom[0].toUpperCase() : 'U';

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'].toString(),
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      telephone: json['telephone'] ?? '',
      nomUtilisateur: json['nomUtilisateur'] ?? '',
      roleName: json['roleName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'nomUtilisateur': nomUtilisateur,
      'roleName': roleName,
    };
  }
}
