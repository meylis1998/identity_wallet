import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/credential_repository.dart';
import 'credential_event.dart';
import 'credential_state.dart';

class CredentialBloc extends Bloc<CredentialEvent, CredentialState> {
  final CredentialRepository _repository;

  CredentialBloc(this._repository) : super(const CredentialInitial()) {
    on<LoadCredentials>(_onLoadCredentials);
    on<AddCredential>(_onAddCredential);
    on<RemoveCredential>(_onRemoveCredential);
    on<UpdateCredential>(_onUpdateCredential);
    on<GenerateSampleCredentials>(_onGenerateSampleCredentials);
    on<ClearAllCredentials>(_onClearAllCredentials);
  }

  Future<void> _onLoadCredentials(
    LoadCredentials event,
    Emitter<CredentialState> emit,
  ) async {
    emit(const CredentialLoading());
    try {
      final credentials = await _repository.getCredentials();
      emit(CredentialLoaded(credentials));
    } catch (e) {
      emit(CredentialError(e.toString()));
    }
  }

  Future<void> _onAddCredential(
    AddCredential event,
    Emitter<CredentialState> emit,
  ) async {
    debugPrint('[CredentialBloc] AddCredential event received');
    debugPrint('[CredentialBloc] Credential ID: ${event.credential.id}');
    debugPrint('[CredentialBloc] Credential Type: ${event.credential.displayName}');
    debugPrint('[CredentialBloc] Issuer: ${event.credential.issuerName}');
    debugPrint('[CredentialBloc] Claims count: ${event.credential.claims.length}');
    try {
      await _repository.addCredential(event.credential);
      debugPrint('[CredentialBloc] Credential added to repository');
      final credentials = await _repository.getCredentials();
      debugPrint('[CredentialBloc] Total credentials after add: ${credentials.length}');
      emit(CredentialLoaded(credentials));
      debugPrint('[CredentialBloc] CredentialLoaded state emitted');
    } catch (e) {
      debugPrint('[CredentialBloc] Error adding credential: $e');
      emit(CredentialError(e.toString()));
    }
  }

  Future<void> _onRemoveCredential(
    RemoveCredential event,
    Emitter<CredentialState> emit,
  ) async {
    try {
      await _repository.removeCredential(event.id);
      final credentials = await _repository.getCredentials();
      emit(CredentialLoaded(credentials));
    } catch (e) {
      emit(CredentialError(e.toString()));
    }
  }

  Future<void> _onUpdateCredential(
    UpdateCredential event,
    Emitter<CredentialState> emit,
  ) async {
    try {
      await _repository.updateCredential(event.credential);
      final credentials = await _repository.getCredentials();
      emit(CredentialLoaded(credentials));
    } catch (e) {
      emit(CredentialError(e.toString()));
    }
  }

  Future<void> _onGenerateSampleCredentials(
    GenerateSampleCredentials event,
    Emitter<CredentialState> emit,
  ) async {
    emit(const CredentialLoading());
    try {
      await _repository.generateSampleCredentials(event.holderDid);
      final credentials = await _repository.getCredentials();
      emit(CredentialLoaded(credentials));
    } catch (e) {
      emit(CredentialError(e.toString()));
    }
  }

  Future<void> _onClearAllCredentials(
    ClearAllCredentials event,
    Emitter<CredentialState> emit,
  ) async {
    try {
      await _repository.clearAllCredentials();
      emit(const CredentialLoaded([]));
    } catch (e) {
      emit(CredentialError(e.toString()));
    }
  }
}
