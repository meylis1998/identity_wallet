import 'package:equatable/equatable.dart';
import '../../domain/credential_model.dart';

abstract class CredentialEvent extends Equatable {
  const CredentialEvent();

  @override
  List<Object?> get props => [];
}

class LoadCredentials extends CredentialEvent {
  const LoadCredentials();
}

class AddCredential extends CredentialEvent {
  final VerifiableCredential credential;

  const AddCredential(this.credential);

  @override
  List<Object?> get props => [credential];
}

class RemoveCredential extends CredentialEvent {
  final String id;

  const RemoveCredential(this.id);

  @override
  List<Object?> get props => [id];
}

class UpdateCredential extends CredentialEvent {
  final VerifiableCredential credential;

  const UpdateCredential(this.credential);

  @override
  List<Object?> get props => [credential];
}

class GenerateSampleCredentials extends CredentialEvent {
  final String holderDid;

  const GenerateSampleCredentials(this.holderDid);

  @override
  List<Object?> get props => [holderDid];
}

class ClearAllCredentials extends CredentialEvent {
  const ClearAllCredentials();
}
