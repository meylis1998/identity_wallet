import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/did_model.dart';
import 'bloc/identity_bloc.dart';
import 'bloc/identity_event.dart';
import 'bloc/identity_state.dart';

class DIDScreen extends StatelessWidget {
  const DIDScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Identity'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showDIDInfo(context),
            tooltip: 'About DIDs',
          ),
        ],
      ),
      body: BlocBuilder<IdentityBloc, IdentityState>(
        builder: (context, state) {
          if (state is IdentityLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is IdentityError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is IdentityLoaded) {
            return state.identity != null
                ? _DIDContent(identity: state.identity!)
                : const _NoDIDContent();
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void _showDIDInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.borderGray,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLg),
                Text(
                  'What is a DID?',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppTheme.spacingMd),
                const Text(
                  'A Decentralized Identifier (DID) is a new type of identifier that enables verifiable, decentralized digital identity.',
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: AppTheme.spacingMd),
                _InfoSection(
                  icon: Icons.security,
                  title: 'Self-Sovereign',
                  description:
                      'You control your DID. No central authority can revoke or modify it without your consent.',
                ),
                _InfoSection(
                  icon: Icons.verified_user,
                  title: 'Cryptographically Secure',
                  description:
                      'Your DID is linked to cryptographic keys that prove you control it.',
                ),
                _InfoSection(
                  icon: Icons.public,
                  title: 'Interoperable',
                  description:
                      'DIDs work across different platforms and services using W3C standards.',
                ),
                _InfoSection(
                  icon: Icons.privacy_tip,
                  title: 'Privacy-Preserving',
                  description:
                      'Share only what you choose. Your DID enables selective disclosure.',
                ),
                const SizedBox(height: AppTheme.spacingLg),
                const Text(
                  'DID Methods',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                const Text(
                  'This wallet uses did:key for demonstration. Production systems may use did:web, did:ion, or other methods.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DIDContent extends StatelessWidget {
  final UserIdentity identity;

  const _DIDContent({required this.identity});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.primaryDark, AppTheme.primaryBlue],
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMd),
                Text(
                  identity.displayName ?? 'My Identity',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingSm,
                    vertical: AppTheme.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'did:${identity.didDocument.method}',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingLg),

          Center(
            child: Column(
              children: [
                const Text(
                  'Share Your DID',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                const Text(
                  'Others can scan this to connect with you',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMd),
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: identity.did,
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingLg),

          const Text(
            'DID DOCUMENT',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textMuted,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),

          _DetailTile(
            icon: Icons.fingerprint,
            label: 'DID',
            value: identity.did,
            isCopiable: true,
          ),
          _DetailTile(
            icon: Icons.key,
            label: 'Method',
            value: 'did:${identity.didDocument.method}',
          ),
          _DetailTile(
            icon: Icons.calendar_today,
            label: 'Created',
            value: _formatDate(identity.createdAt),
          ),
          if (identity.didDocument.verificationMethod.isNotEmpty)
            _DetailTile(
              icon: Icons.verified_user,
              label: 'Verification Method',
              value: identity.didDocument.verificationMethod.first.type,
            ),

          const SizedBox(height: AppTheme.spacingLg),

          Container(
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
                const Icon(
                  Icons.shield,
                  color: AppTheme.verifiedGreen,
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Keys Secured',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.verifiedGreen,
                        ),
                      ),
                      const Text(
                        'Private keys stored in device secure enclave',
                        style: TextStyle(
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

          const SizedBox(height: AppTheme.spacingLg),

          OutlinedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: identity.did));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('DID copied to clipboard')),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy DID'),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          OutlinedButton.icon(
            onPressed: () {
              Clipboard.setData(
                ClipboardData(text: identity.didDocument.toJsonString()),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('DID Document copied to clipboard')),
              );
            },
            icon: const Icon(Icons.code),
            label: const Text('Export DID Document'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _NoDIDContent extends StatelessWidget {
  const _NoDIDContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fingerprint,
                size: 40,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Text(
              'No Identity Yet',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            const Text(
              'Create a decentralized identity to receive and present credentials.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            ElevatedButton.icon(
              onPressed: () {
                context.read<IdentityBloc>().add(
                  const CreateIdentity(displayName: 'My Identity'),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Identity'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isCopiable;

  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
    this.isCopiable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: AppTheme.textMuted),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontFamily: isCopiable ? 'monospace' : 'Inter',
                      fontSize: isCopiable ? 11 : 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (isCopiable)
              IconButton(
                icon: const Icon(Icons.copy, size: 18),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$label copied')),
                  );
                },
                tooltip: 'Copy',
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _InfoSection({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(icon, color: AppTheme.primaryBlue, size: 20),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
