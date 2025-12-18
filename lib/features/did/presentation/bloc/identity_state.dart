import 'package:equatable/equatable.dart';
import '../../domain/did_model.dart';

abstract class IdentityState extends Equatable {
  const IdentityState();

  @override
  List<Object?> get props => [];
}

class IdentityInitial extends IdentityState {
  const IdentityInitial();
}

class IdentityLoading extends IdentityState {
  const IdentityLoading();
}

class IdentityLoaded extends IdentityState {
  final UserIdentity? identity;

  const IdentityLoaded(this.identity);

  @override
  List<Object?> get props => [identity];

  bool get hasIdentity => identity != null;

  String get did => identity?.did ?? '';

  String get displayName => identity?.displayName ?? 'My Identity';
}

class IdentityCreated extends IdentityState {
  final UserIdentity identity;

  const IdentityCreated(this.identity);

  @override
  List<Object?> get props => [identity];
}

class IdentityError extends IdentityState {
  final String message;

  const IdentityError(this.message);

  @override
  List<Object?> get props => [message];
}
