import 'dart:convert';

enum VerificationMethodType {
  ed25519VerificationKey2020,
  jsonWebKey2020,
  ecdsaSecp256k1VerificationKey2019,
}

class VerificationMethod {
  final String id;
  final String type;
  final String controller;
  final Map<String, dynamic>? publicKeyJwk;
  final String? publicKeyMultibase;

  const VerificationMethod({
    required this.id,
    required this.type,
    required this.controller,
    this.publicKeyJwk,
    this.publicKeyMultibase,
  });

  factory VerificationMethod.fromJson(Map<String, dynamic> json) {
    return VerificationMethod(
      id: json['id'] as String,
      type: json['type'] as String,
      controller: json['controller'] as String,
      publicKeyJwk: json['publicKeyJwk'] as Map<String, dynamic>?,
      publicKeyMultibase: json['publicKeyMultibase'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'controller': controller,
    if (publicKeyJwk != null) 'publicKeyJwk': publicKeyJwk,
    if (publicKeyMultibase != null) 'publicKeyMultibase': publicKeyMultibase,
  };
}

class ServiceEndpoint {
  final String id;
  final String type;
  final String serviceEndpoint;

  const ServiceEndpoint({
    required this.id,
    required this.type,
    required this.serviceEndpoint,
  });

  factory ServiceEndpoint.fromJson(Map<String, dynamic> json) {
    return ServiceEndpoint(
      id: json['id'] as String,
      type: json['type'] as String,
      serviceEndpoint: json['serviceEndpoint'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'serviceEndpoint': serviceEndpoint,
  };
}

class DIDDocument {
  final List<String> context;
  final String id;
  final List<String>? alsoKnownAs;
  final String? controller;
  final List<VerificationMethod> verificationMethod;
  final List<String>? authentication;
  final List<String>? assertionMethod;
  final List<String>? keyAgreement;
  final List<String>? capabilityInvocation;
  final List<String>? capabilityDelegation;
  final List<ServiceEndpoint>? service;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const DIDDocument({
    required this.context,
    required this.id,
    this.alsoKnownAs,
    this.controller,
    required this.verificationMethod,
    this.authentication,
    this.assertionMethod,
    this.keyAgreement,
    this.capabilityInvocation,
    this.capabilityDelegation,
    this.service,
    required this.createdAt,
    this.updatedAt,
  });

  String get method {
    final parts = id.split(':');
    return parts.length > 1 ? parts[1] : 'unknown';
  }

  String get shortId {
    if (id.length <= 30) return id;
    return '${id.substring(0, 15)}...${id.substring(id.length - 10)}';
  }

  VerificationMethod? get primaryVerificationMethod {
    return verificationMethod.isNotEmpty ? verificationMethod.first : null;
  }

  factory DIDDocument.fromJson(Map<String, dynamic> json) {
    return DIDDocument(
      context: List<String>.from(json['@context'] ?? []),
      id: json['id'] as String,
      alsoKnownAs: json['alsoKnownAs'] != null
          ? List<String>.from(json['alsoKnownAs'])
          : null,
      controller: json['controller'] as String?,
      verificationMethod: (json['verificationMethod'] as List<dynamic>?)
          ?.map((e) => VerificationMethod.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      authentication: json['authentication'] != null
          ? List<String>.from(json['authentication'])
          : null,
      assertionMethod: json['assertionMethod'] != null
          ? List<String>.from(json['assertionMethod'])
          : null,
      keyAgreement: json['keyAgreement'] != null
          ? List<String>.from(json['keyAgreement'])
          : null,
      capabilityInvocation: json['capabilityInvocation'] != null
          ? List<String>.from(json['capabilityInvocation'])
          : null,
      capabilityDelegation: json['capabilityDelegation'] != null
          ? List<String>.from(json['capabilityDelegation'])
          : null,
      service: (json['service'] as List<dynamic>?)
          ?.map((e) => ServiceEndpoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    '@context': context,
    'id': id,
    if (alsoKnownAs != null) 'alsoKnownAs': alsoKnownAs,
    if (controller != null) 'controller': controller,
    'verificationMethod': verificationMethod.map((v) => v.toJson()).toList(),
    if (authentication != null) 'authentication': authentication,
    if (assertionMethod != null) 'assertionMethod': assertionMethod,
    if (keyAgreement != null) 'keyAgreement': keyAgreement,
    if (capabilityInvocation != null) 'capabilityInvocation': capabilityInvocation,
    if (capabilityDelegation != null) 'capabilityDelegation': capabilityDelegation,
    if (service != null) 'service': service!.map((s) => s.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
  };

  String toJsonString() => jsonEncode(toJson());

  DIDDocument copyWith({
    List<String>? context,
    String? id,
    List<String>? alsoKnownAs,
    String? controller,
    List<VerificationMethod>? verificationMethod,
    List<String>? authentication,
    List<String>? assertionMethod,
    List<String>? keyAgreement,
    List<String>? capabilityInvocation,
    List<String>? capabilityDelegation,
    List<ServiceEndpoint>? service,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DIDDocument(
      context: context ?? this.context,
      id: id ?? this.id,
      alsoKnownAs: alsoKnownAs ?? this.alsoKnownAs,
      controller: controller ?? this.controller,
      verificationMethod: verificationMethod ?? this.verificationMethod,
      authentication: authentication ?? this.authentication,
      assertionMethod: assertionMethod ?? this.assertionMethod,
      keyAgreement: keyAgreement ?? this.keyAgreement,
      capabilityInvocation: capabilityInvocation ?? this.capabilityInvocation,
      capabilityDelegation: capabilityDelegation ?? this.capabilityDelegation,
      service: service ?? this.service,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class UserIdentity {
  final DIDDocument didDocument;
  final String? displayName;
  final String? profileImageUrl;
  final bool isBackedUp;
  final DateTime createdAt;

  const UserIdentity({
    required this.didDocument,
    this.displayName,
    this.profileImageUrl,
    this.isBackedUp = false,
    required this.createdAt,
  });

  String get did => didDocument.id;

  factory UserIdentity.fromJson(Map<String, dynamic> json) {
    return UserIdentity(
      didDocument: DIDDocument.fromJson(json['didDocument'] as Map<String, dynamic>),
      displayName: json['displayName'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      isBackedUp: json['isBackedUp'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'didDocument': didDocument.toJson(),
    'displayName': displayName,
    'profileImageUrl': profileImageUrl,
    'isBackedUp': isBackedUp,
    'createdAt': createdAt.toIso8601String(),
  };
}
