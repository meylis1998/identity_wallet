import 'dart:convert';

enum CredentialStatus {
  valid,
  expired,
  revoked,
  pending,
}

enum CredentialType {
  driversLicense,
  stateId,
  voterRegistration,
  vaccination,
  education,
  custom,
}

class CredentialClaim {
  final String id;
  final String label;
  final String value;
  final bool required;
  final bool sensitive;

  const CredentialClaim({
    required this.id,
    required this.label,
    required this.value,
    this.required = false,
    this.sensitive = false,
  });

  factory CredentialClaim.fromJson(Map<String, dynamic> json) {
    return CredentialClaim(
      id: json['id'] as String,
      label: json['label'] as String,
      value: json['value'] as String,
      required: json['required'] as bool? ?? false,
      sensitive: json['sensitive'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'value': value,
    'required': required,
    'sensitive': sensitive,
  };
}

class VerifiableCredential {
  final String id;
  final List<String> context;
  final List<String> type;
  final String issuer;
  final String issuerName;
  final String issuerLogoUrl;
  final DateTime issuanceDate;
  final DateTime? expirationDate;
  final String holderDid;
  final List<CredentialClaim> claims;
  final CredentialStatus status;
  final CredentialType credentialType;
  final Map<String, dynamic>? proof;
  final String? credentialSubjectId;
  final DateTime addedAt;

  const VerifiableCredential({
    required this.id,
    required this.context,
    required this.type,
    required this.issuer,
    required this.issuerName,
    required this.issuerLogoUrl,
    required this.issuanceDate,
    this.expirationDate,
    required this.holderDid,
    required this.claims,
    required this.status,
    required this.credentialType,
    this.proof,
    this.credentialSubjectId,
    required this.addedAt,
  });

  String get displayName {
    switch (credentialType) {
      case CredentialType.driversLicense:
        return "Driver's License";
      case CredentialType.stateId:
        return 'State ID';
      case CredentialType.voterRegistration:
        return 'Voter Registration';
      case CredentialType.vaccination:
        return 'Vaccination Record';
      case CredentialType.education:
        return 'Education Credential';
      case CredentialType.custom:
        return type.isNotEmpty ? type.last : 'Credential';
    }
  }

  bool get isExpired {
    if (expirationDate == null) return false;
    return DateTime.now().isAfter(expirationDate!);
  }

  CredentialStatus get effectiveStatus {
    if (status == CredentialStatus.revoked) return CredentialStatus.revoked;
    if (isExpired) return CredentialStatus.expired;
    return status;
  }

  List<CredentialClaim> get publicClaims =>
      claims.where((c) => !c.sensitive).toList();

  List<CredentialClaim> get sensitiveClaims =>
      claims.where((c) => c.sensitive).toList();

  List<CredentialClaim> get requiredClaims =>
      claims.where((c) => c.required).toList();

  factory VerifiableCredential.fromJson(Map<String, dynamic> json) {
    return VerifiableCredential(
      id: json['id'] as String,
      context: List<String>.from(json['@context'] ?? json['context'] ?? []),
      type: List<String>.from(json['type'] ?? []),
      issuer: json['issuer'] is String
          ? json['issuer'] as String
          : (json['issuer'] as Map<String, dynamic>)['id'] as String,
      issuerName: json['issuerName'] as String? ?? 'Unknown Issuer',
      issuerLogoUrl: json['issuerLogoUrl'] as String? ?? '',
      issuanceDate: DateTime.parse(json['issuanceDate'] as String),
      expirationDate: json['expirationDate'] != null
          ? DateTime.parse(json['expirationDate'] as String)
          : null,
      holderDid: json['holderDid'] as String? ?? '',
      claims: (json['claims'] as List<dynamic>?)
          ?.map((e) => CredentialClaim.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      status: CredentialStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => CredentialStatus.valid,
      ),
      credentialType: CredentialType.values.firstWhere(
        (t) => t.name == json['credentialType'],
        orElse: () => CredentialType.custom,
      ),
      proof: json['proof'] as Map<String, dynamic>?,
      credentialSubjectId: json['credentialSubject']?['id'] as String?,
      addedAt: json['addedAt'] != null
          ? DateTime.parse(json['addedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    '@context': context,
    'type': type,
    'issuer': issuer,
    'issuerName': issuerName,
    'issuerLogoUrl': issuerLogoUrl,
    'issuanceDate': issuanceDate.toIso8601String(),
    'expirationDate': expirationDate?.toIso8601String(),
    'holderDid': holderDid,
    'claims': claims.map((c) => c.toJson()).toList(),
    'status': status.name,
    'credentialType': credentialType.name,
    'proof': proof,
    'credentialSubject': credentialSubjectId != null
        ? {'id': credentialSubjectId}
        : null,
    'addedAt': addedAt.toIso8601String(),
  };

  String toJsonString() => jsonEncode(toJson());

  VerifiableCredential copyWith({
    String? id,
    List<String>? context,
    List<String>? type,
    String? issuer,
    String? issuerName,
    String? issuerLogoUrl,
    DateTime? issuanceDate,
    DateTime? expirationDate,
    String? holderDid,
    List<CredentialClaim>? claims,
    CredentialStatus? status,
    CredentialType? credentialType,
    Map<String, dynamic>? proof,
    String? credentialSubjectId,
    DateTime? addedAt,
  }) {
    return VerifiableCredential(
      id: id ?? this.id,
      context: context ?? this.context,
      type: type ?? this.type,
      issuer: issuer ?? this.issuer,
      issuerName: issuerName ?? this.issuerName,
      issuerLogoUrl: issuerLogoUrl ?? this.issuerLogoUrl,
      issuanceDate: issuanceDate ?? this.issuanceDate,
      expirationDate: expirationDate ?? this.expirationDate,
      holderDid: holderDid ?? this.holderDid,
      claims: claims ?? this.claims,
      status: status ?? this.status,
      credentialType: credentialType ?? this.credentialType,
      proof: proof ?? this.proof,
      credentialSubjectId: credentialSubjectId ?? this.credentialSubjectId,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
