import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/did_repository.dart';
import 'identity_event.dart';
import 'identity_state.dart';

class IdentityBloc extends Bloc<IdentityEvent, IdentityState> {
  final DIDRepository _repository;

  IdentityBloc(this._repository) : super(const IdentityInitial()) {
    on<LoadIdentity>(_onLoadIdentity);
    on<CreateIdentity>(_onCreateIdentity);
    on<UpdateDisplayName>(_onUpdateDisplayName);
    on<MarkIdentityBackedUp>(_onMarkIdentityBackedUp);
    on<DeleteIdentity>(_onDeleteIdentity);
  }

  Future<void> _onLoadIdentity(
    LoadIdentity event,
    Emitter<IdentityState> emit,
  ) async {
    emit(const IdentityLoading());
    try {
      final identity = await _repository.getUserIdentity();
      emit(IdentityLoaded(identity));
    } catch (e) {
      emit(IdentityError(e.toString()));
    }
  }

  Future<void> _onCreateIdentity(
    CreateIdentity event,
    Emitter<IdentityState> emit,
  ) async {
    emit(const IdentityLoading());
    try {
      final identity = await _repository.createDID(displayName: event.displayName);
      emit(IdentityCreated(identity));
      emit(IdentityLoaded(identity));
    } catch (e) {
      emit(IdentityError(e.toString()));
    }
  }

  Future<void> _onUpdateDisplayName(
    UpdateDisplayName event,
    Emitter<IdentityState> emit,
  ) async {
    try {
      final identity = await _repository.updateDisplayName(event.displayName);
      emit(IdentityLoaded(identity));
    } catch (e) {
      emit(IdentityError(e.toString()));
    }
  }

  Future<void> _onMarkIdentityBackedUp(
    MarkIdentityBackedUp event,
    Emitter<IdentityState> emit,
  ) async {
    try {
      final identity = await _repository.markAsBackedUp();
      emit(IdentityLoaded(identity));
    } catch (e) {
      emit(IdentityError(e.toString()));
    }
  }

  Future<void> _onDeleteIdentity(
    DeleteIdentity event,
    Emitter<IdentityState> emit,
  ) async {
    try {
      await _repository.deleteIdentity();
      emit(const IdentityLoaded(null));
    } catch (e) {
      emit(IdentityError(e.toString()));
    }
  }
}
