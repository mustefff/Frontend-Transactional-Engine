class UserProfile {
  const UserProfile({
    required this.lastName,
    required this.firstName,
    required this.nin,
    required this.birthDate,
  });

  final String lastName;
  final String firstName;
  final String nin;
  final DateTime birthDate;

  UserProfile copyWith({
    String? lastName,
    String? firstName,
    String? nin,
    DateTime? birthDate,
  }) {
    return UserProfile(
      lastName: lastName ?? this.lastName,
      firstName: firstName ?? this.firstName,
      nin: nin ?? this.nin,
      birthDate: birthDate ?? this.birthDate,
    );
  }
}

