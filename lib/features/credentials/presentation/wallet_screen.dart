import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/credential_card.dart';
import '../../../shared/widgets/security_widgets.dart';
import 'bloc/credential_bloc.dart';
import 'bloc/credential_event.dart';
import 'bloc/credential_state.dart';
import '../../did/presentation/bloc/identity_bloc.dart';
import '../../did/presentation/bloc/identity_state.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => context.push('/scan'),
            tooltip: 'Scan QR Code',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<CredentialBloc>().add(const LoadCredentials());
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: BlocBuilder<IdentityBloc, IdentityState>(
                builder: (context, state) {
                  if (state is IdentityLoading) {
                    return const _IdentityHeaderSkeleton();
                  }
                  if (state is IdentityLoaded && state.identity != null) {
                    return _IdentityHeader(
                      did: state.identity!.did,
                      displayName: state.identity!.displayName,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),

            const SliverToBoxAdapter(
              child: _SecurityBanner(),
            ),

            const SliverToBoxAdapter(
              child: SectionHeader(title: 'CREDENTIALS'),
            ),

            BlocBuilder<CredentialBloc, CredentialState>(
              builder: (context, state) {
                if (state is CredentialLoading) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (state is CredentialError) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Text('Error loading credentials: ${state.message}'),
                    ),
                  );
                }
                if (state is CredentialLoaded) {
                  if (state.credentials.isEmpty) {
                    return SliverFillRemaining(
                      child: EmptyState(
                        icon: Icons.wallet,
                        title: 'No Credentials Yet',
                        message:
                            'Your digital credentials will appear here once issued.',
                        actionLabel: 'Scan QR to Add',
                        onAction: () => context.push('/scan'),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingMd,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final credential = state.credentials[index];
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppTheme.spacingMd,
                            ),
                            child: CredentialCard(
                              credential: credential,
                              onTap: () => context.push(
                                '/credential/${credential.id}',
                                extra: credential,
                              ),
                            ),
                          );
                        },
                        childCount: state.credentials.length,
                      ),
                    ),
                  );
                }
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              },
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/scan'),
        icon: const Icon(Icons.add),
        label: const Text('Add Credential'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _IdentityHeader extends StatelessWidget {
  final String did;
  final String? displayName;

  const _IdentityHeader({
    required this.did,
    this.displayName,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Your identity: ${displayName ?? 'User'}',
      child: Container(
        margin: const EdgeInsets.all(AppTheme.spacingMd),
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primaryDark, AppTheme.primaryBlue],
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName ?? 'My Identity',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXs),
                  Row(
                    children: [
                      const Icon(
                        Icons.fingerprint,
                        size: 14,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _formatDid(did),
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.qr_code, color: Colors.white),
              onPressed: () {
                context.push('/did');
              },
              tooltip: 'Show DID',
            ),
          ],
        ),
      ),
    );
  }

  String _formatDid(String did) {
    if (did.length <= 30) return did;
    return '${did.substring(0, 20)}...${did.substring(did.length - 8)}';
  }
}

class _IdentityHeaderSkeleton extends StatelessWidget {
  const _IdentityHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppTheme.spacingMd),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      height: 88,
      decoration: BoxDecoration(
        color: AppTheme.borderGray,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
    );
  }
}

class _SecurityBanner extends StatelessWidget {
  const _SecurityBanner();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Your credentials are protected with encryption and biometric authentication',
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: AppTheme.verifiedGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(
            color: AppTheme.verifiedGreen.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.verifiedGreen.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shield,
                color: AppTheme.verifiedGreen,
                size: 20,
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Secured Wallet',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.verifiedGreen,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Protected with encryption & biometrics',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
