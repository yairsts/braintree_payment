class VenmoAccountNonce {
  VenmoAccountNonce({
    required this.nonce,
    required this.isDefault,
    required this.username,
    this.email,
    this.externalId,
    this.firstName,
    this.lastName,
    this.phoneNumber,
  });

  final String nonce;
  final bool isDefault;
  final String username;
  final String? email;
  final String? externalId;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;

  factory VenmoAccountNonce.fromJson(Map<String, dynamic> json) {
    return VenmoAccountNonce(
      nonce: json['nonce'],
      isDefault: json['isDefault'] ?? false,
      username: json['username'],
      email: json['email'],
      externalId: json['externalId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phoneNumber: json['phoneNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nonce': nonce,
      'isDefault': isDefault,
      'username': username,
      'email': email,
      'externalId': externalId,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
    };
  }
}
