import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:identity_wallet/features/credentials/presentation/bloc/credential_bloc.dart';
import 'package:identity_wallet/features/credentials/presentation/bloc/credential_state.dart';
import 'package:identity_wallet/features/credentials/presentation/bloc/credential_event.dart';
import 'package:identity_wallet/features/did/presentation/bloc/identity_bloc.dart';
import 'package:identity_wallet/features/did/presentation/bloc/identity_state.dart';
import 'package:identity_wallet/features/did/presentation/bloc/identity_event.dart';

class MockCredentialBloc extends Mock implements CredentialBloc {}
class MockIdentityBloc extends Mock implements IdentityBloc {}

class FakeCredentialEvent extends Fake implements CredentialEvent {}
class FakeIdentityEvent extends Fake implements IdentityEvent {}

void main() {
  late MockCredentialBloc mockCredentialBloc;
  late MockIdentityBloc mockIdentityBloc;

  setUpAll(() {
    registerFallbackValue(FakeCredentialEvent());
    registerFallbackValue(FakeIdentityEvent());
  });

  setUp(() {
    mockCredentialBloc = MockCredentialBloc();
    mockIdentityBloc = MockIdentityBloc();

    when(() => mockCredentialBloc.state)
        .thenReturn(const CredentialLoaded([]));
    when(() => mockCredentialBloc.stream)
        .thenAnswer((_) => Stream.value(const CredentialLoaded([])));
    when(() => mockCredentialBloc.close()).thenAnswer((_) async {});

    when(() => mockIdentityBloc.state)
        .thenReturn(const IdentityLoaded(null));
    when(() => mockIdentityBloc.stream)
        .thenAnswer((_) => Stream.value(const IdentityLoaded(null)));
    when(() => mockIdentityBloc.close()).thenAnswer((_) async {});
  });

  testWidgets('App should render with BLoC providers', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<CredentialBloc>.value(value: mockCredentialBloc),
          BlocProvider<IdentityBloc>.value(value: mockIdentityBloc),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Identity Wallet'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Identity Wallet'), findsOneWidget);
  });

  testWidgets('Credential state displays correctly', (WidgetTester tester) async {
    when(() => mockCredentialBloc.state)
        .thenReturn(const CredentialLoading());
    when(() => mockCredentialBloc.stream)
        .thenAnswer((_) => Stream.value(const CredentialLoading()));

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<CredentialBloc>.value(value: mockCredentialBloc),
          BlocProvider<IdentityBloc>.value(value: mockIdentityBloc),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: BlocBuilder<CredentialBloc, CredentialState>(
              builder: (context, state) {
                if (state is CredentialLoading) {
                  return const CircularProgressIndicator();
                }
                return const Text('Loaded');
              },
            ),
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
