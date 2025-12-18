import 'package:equatable/equatable.dart';

abstract class IdentityEvent extends Equatable {
  const IdentityEvent();

  @override
  List<Object?> get props => [];
}

class LoadIdentity extends IdentityEvent {
  const LoadIdentity();
}

class CreateIdentity extends IdentityEvent {
  final String? displayName;

  const CreateIdentity({this.displayName});

  @override
  List<Object?> get props => [displayName];
}

class UpdateDisplayName extends IdentityEvent {
  final String displayName;

  const UpdateDisplayName(this.displayName);

  @override
  List<Object?> get props => [displayName];
}

class MarkIdentityBackedUp extends IdentityEvent {
  const MarkIdentityBackedUp();
}

class DeleteIdentity extends IdentityEvent {
  const DeleteIdentity();
}
