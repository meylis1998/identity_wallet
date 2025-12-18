import 'package:equatable/equatable.dart';
import '../../domain/credential_model.dart';

abstract class CredentialState extends Equatable {
  const CredentialState();

  @override
  List<Object?> get props => [];
}

class CredentialInitial extends CredentialState {
  const CredentialInitial();
}

class CredentialLoading extends CredentialState {
  const CredentialLoading();
}

class CredentialLoaded extends CredentialState {
  final List<VerifiableCredential> credentials;

  const CredentialLoaded(this.credentials);

  @override
  List<Object?> get props => [credentials];

  bool get isEmpty => credentials.isEmpty;

  int get count => credentials.length;
}

class CredentialError extends CredentialState {
  final String message;

  const CredentialError(this.message);

  @override
  List<Object?> get props => [message];
}
