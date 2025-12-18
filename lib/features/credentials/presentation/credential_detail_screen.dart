import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/security_widgets.dart';
import '../domain/credential_model.dart';
import 'bloc/credential_bloc.dart';
import 'bloc/credential_event.dart';

class CredentialDetailScreen extends StatelessWidget {
  final String credentialId;
  final VerifiableCredential? credential;

  const CredentialDetailScreen({
    super.key,
    required this.credentialId,
    this.credential,
  });

  @override
  Widget build(BuildContext context) {
    final cred = credential;
    if (cred == null) {
      return const Scaffold(
        body: Center(child: Text('Credential not found')),
      );
    }

    final status = cred.effectiveStatus;
    final dateFormat = DateFormat('MMMM d, yyyy');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: _getHeaderColor(cred.credentialType),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () => _showPresentOptions(context, cred),
                tooltip: 'Present Credential',
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) => _handleMenuAction(context, value, cred),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'export',
                    child: ListTile(
                      leading: Icon(Icons.download),
                      title: Text('Export JSON'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'verify',
                    child: ListTile(
                      leading: Icon(Icons.verified_user),
                      title: Text('Verify Credential'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: AppTheme.errorRed),
                      title: Text('Delete', style: TextStyle(color: AppTheme.errorRed)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _getGradientColors(cred.credentialType),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _getCredentialIcon(cred.credentialType),
                              color: Colors.white,
                              size: 32,
                            ),
                            const Spacer(),
                            _StatusChip(status: status),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacingSm),
                        Text(
                          cred.displayName,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingXs),
                        Row(
                          children: [
                            const Icon(
                              Icons.verified_outlined,
                              size: 16,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              cred.issuerName,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.qr_code,
                          label: 'Present',
                          onTap: () => _showPresentOptions(context, cred),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingSm),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.tune,
                          label: 'Selective Share',
                          onTap: () => context.push(
                            '/credential/${cred.id}/selective-disclosure',
                            extra: cred,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingLg),

                  const Text(
                    'CREDENTIAL DETAILS',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMuted,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),

                  ...cred.publicClaims.map((claim) => _ClaimTile(
                    label: claim.label,
                    value: claim.value,
                    required: claim.required,
                  )),

                  if (cred.sensitiveClaims.isNotEmpty) ...[
                    const SizedBox(height: AppTheme.spacingMd),
                    const Divider(),
                    const SizedBox(height: AppTheme.spacingMd),
                    Row(
                      children: [
                        const Icon(
                          Icons.privacy_tip,
                          size: 16,
                          color: AppTheme.warningOrange,
                        ),
                        const SizedBox(width: AppTheme.spacingSm),
                        const Text(
                          'SENSITIVE INFORMATION',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.warningOrange,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    ...cred.sensitiveClaims.map((claim) => _ClaimTile(
                      label: claim.label,
                      value: claim.value,
                      sensitive: true,
                    )),
                  ],

                  const SizedBox(height: AppTheme.spacingLg),
                  const Divider(),
                  const SizedBox(height: AppTheme.spacingLg),

                  const Text(
                    'ISSUANCE INFORMATION',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMuted,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),

                  _InfoTile(
                    icon: Icons.calendar_today,
                    label: 'Issued',
                    value: dateFormat.format(cred.issuanceDate),
                  ),
                  if (cred.expirationDate != null)
                    _InfoTile(
                      icon: Icons.event,
                      label: 'Expires',
                      value: dateFormat.format(cred.expirationDate!),
                      isWarning: cred.isExpired,
                    ),
                  _InfoTile(
                    icon: Icons.business,
                    label: 'Issuer DID',
                    value: cred.issuer,
                    isMonospace: true,
                  ),
                  _InfoTile(
                    icon: Icons.tag,
                    label: 'Credential ID',
                    value: cred.id,
                    isMonospace: true,
                  ),

                  const SizedBox(height: AppTheme.spacingXl),

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
                          Icons.verified_user,
                          color: AppTheme.verifiedGreen,
                        ),
                        const SizedBox(width: AppTheme.spacingMd),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cryptographically Signed',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.verifiedGreen,
                                ),
                              ),
                              Text(
                                'This credential is secured with a digital signature',
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

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: ElevatedButton.icon(
            onPressed: () => _showPresentOptions(context, cred),
            icon: const Icon(Icons.qr_code),
            label: const Text('Present Credential'),
          ),
        ),
      ),
    );
  }

  void _showPresentOptions(BuildContext context, VerifiableCredential cred) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
      ),
      builder: (context) => _PresentationSheet(credential: cred),
    );
  }

  void _handleMenuAction(
    BuildContext context,
    String action,
    VerifiableCredential cred,
  ) {
    switch (action) {
      case 'export':
        Clipboard.setData(ClipboardData(text: cred.toJsonString()));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credential JSON copied to clipboard')),
        );
        break;
      case 'verify':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credential verification simulated')),
        );
        break;
      case 'delete':
        _showDeleteDialog(context, cred);
        break;
    }
  }

  void _showDeleteDialog(
    BuildContext context,
    VerifiableCredential cred,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Credential?'),
        content: Text(
          'Are you sure you want to delete "${cred.displayName}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CredentialBloc>().add(RemoveCredential(cred.id));
              Navigator.pop(dialogContext);
              context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _getHeaderColor(CredentialType type) {
    switch (type) {
      case CredentialType.driversLicense:
        return const Color(0xFF1E40AF);
      case CredentialType.stateId:
        return const Color(0xFF7C3AED);
      case CredentialType.voterRegistration:
        return const Color(0xFF059669);
      case CredentialType.vaccination:
        return const Color(0xFFDC2626);
      case CredentialType.education:
        return const Color(0xFFD97706);
      case CredentialType.custom:
        return const Color(0xFF475569);
    }
  }

  List<Color> _getGradientColors(CredentialType type) {
    switch (type) {
      case CredentialType.driversLicense:
        return [const Color(0xFF1E40AF), const Color(0xFF3B82F6)];
      case CredentialType.stateId:
        return [const Color(0xFF7C3AED), const Color(0xFFA78BFA)];
      case CredentialType.voterRegistration:
        return [const Color(0xFF059669), const Color(0xFF34D399)];
      case CredentialType.vaccination:
        return [const Color(0xFFDC2626), const Color(0xFFF87171)];
      case CredentialType.education:
        return [const Color(0xFFD97706), const Color(0xFFFBBF24)];
      case CredentialType.custom:
        return [const Color(0xFF475569), const Color(0xFF94A3B8)];
    }
  }

  IconData _getCredentialIcon(CredentialType type) {
    switch (type) {
      case CredentialType.driversLicense:
        return Icons.drive_eta;
      case CredentialType.stateId:
        return Icons.badge;
      case CredentialType.voterRegistration:
        return Icons.how_to_vote;
      case CredentialType.vaccination:
        return Icons.vaccines;
      case CredentialType.education:
        return Icons.school;
      case CredentialType.custom:
        return Icons.description;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final CredentialStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIcon(),
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            _getText(),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (status) {
      case CredentialStatus.valid:
        return Icons.check_circle;
      case CredentialStatus.expired:
        return Icons.schedule;
      case CredentialStatus.revoked:
        return Icons.cancel;
      case CredentialStatus.pending:
        return Icons.hourglass_empty;
    }
  }

  String _getText() {
    switch (status) {
      case CredentialStatus.valid:
        return 'Valid';
      case CredentialStatus.expired:
        return 'Expired';
      case CredentialStatus.revoked:
        return 'Revoked';
      case CredentialStatus.pending:
        return 'Pending';
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            children: [
              Icon(icon, color: AppTheme.primaryBlue),
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClaimTile extends StatelessWidget {
  final String label;
  final String value;
  final bool required;
  final bool sensitive;

  const _ClaimTile({
    required this.label,
    required this.value,
    this.required = false,
    this.sensitive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Row(
              children: [
                if (sensitive)
                  const Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Icon(
                      Icons.lock,
                      size: 12,
                      color: AppTheme.warningOrange,
                    ),
                  ),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isMonospace;
  final bool isWarning;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.isMonospace = false,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: isWarning ? AppTheme.errorRed : AppTheme.textMuted,
          ),
          const SizedBox(width: AppTheme.spacingSm),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: isMonospace
                  ? const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    )
                  : Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isWarning ? AppTheme.errorRed : null,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PresentationSheet extends StatelessWidget {
  final VerifiableCredential credential;

  const _PresentationSheet({required this.credential});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.borderGray,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLg),
                Text(
                  'Present ${credential.displayName}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppTheme.spacingSm),
                Text(
                  'Scan this QR code to share your credential',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingLg),
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
                    data: credential.toJsonString(),
                    version: QrVersions.auto,
                    size: 250,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLg),
                const SecurityBadge(
                  isSecure: true,
                  label: 'Encrypted presentation',
                ),
                const SizedBox(height: AppTheme.spacingLg),
                OutlinedButton.icon(
                  onPressed: () {
                    context.pop();
                    context.push(
                      '/credential/${credential.id}/selective-disclosure',
                      extra: credential,
                    );
                  },
                  icon: const Icon(Icons.tune),
                  label: const Text('Choose what to share'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
