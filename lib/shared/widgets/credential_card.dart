import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../features/credentials/domain/credential_model.dart';

class CredentialCard extends StatelessWidget {
  final VerifiableCredential credential;
  final VoidCallback? onTap;
  final bool showDetails;

  const CredentialCard({
    super.key,
    required this.credential,
    this.onTap,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    final status = credential.effectiveStatus;

    return Semantics(
      label: '${credential.displayName} from ${credential.issuerName}, '
          'Status: ${_getStatusLabel(status)}',
      button: onTap != null,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _getGradientColors(credential.credentialType),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            credential.displayName,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        _StatusBadge(status: status),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingXs),
                    Row(
                      children: [
                        const Icon(
                          Icons.verified_outlined,
                          size: 16,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: AppTheme.spacingXs),
                        Expanded(
                          child: Text(
                            credential.issuerName,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (credential.publicClaims.isNotEmpty) ...[
                      ...credential.publicClaims.take(showDetails ? 10 : 2).map(
                        (claim) => Padding(
                          padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 100,
                                child: Text(
                                  claim.label,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  claim.value,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (!showDetails && credential.publicClaims.length > 2)
                      Padding(
                        padding: const EdgeInsets.only(top: AppTheme.spacingXs),
                        child: Text(
                          '+${credential.publicClaims.length - 2} more fields',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ),
                    const SizedBox(height: AppTheme.spacingSm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _DateInfo(
                          label: 'Issued',
                          date: credential.issuanceDate,
                        ),
                        if (credential.expirationDate != null)
                          _DateInfo(
                            label: 'Expires',
                            date: credential.expirationDate!,
                            isExpired: credential.isExpired,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

  String _getStatusLabel(CredentialStatus status) {
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

class _StatusBadge extends StatelessWidget {
  final CredentialStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: AppTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.9),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(status),
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            _getStatusText(status),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(CredentialStatus status) {
    switch (status) {
      case CredentialStatus.valid:
        return AppTheme.verifiedGreen;
      case CredentialStatus.expired:
        return AppTheme.warningOrange;
      case CredentialStatus.revoked:
        return AppTheme.revokedRed;
      case CredentialStatus.pending:
        return AppTheme.pendingYellow;
    }
  }

  IconData _getStatusIcon(CredentialStatus status) {
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

  String _getStatusText(CredentialStatus status) {
    switch (status) {
      case CredentialStatus.valid:
        return 'VALID';
      case CredentialStatus.expired:
        return 'EXPIRED';
      case CredentialStatus.revoked:
        return 'REVOKED';
      case CredentialStatus.pending:
        return 'PENDING';
    }
  }
}

class _DateInfo extends StatelessWidget {
  final String label;
  final DateTime date;
  final bool isExpired;

  const _DateInfo({
    required this.label,
    required this.date,
    this.isExpired = false,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('MMM d, yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          formatter.format(date),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isExpired ? AppTheme.errorRed : AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class CredentialCardCompact extends StatelessWidget {
  final VerifiableCredential credential;
  final VoidCallback? onTap;
  final Widget? trailing;

  const CredentialCardCompact({
    super.key,
    required this.credential,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${credential.displayName} from ${credential.issuerName}',
      button: onTap != null,
      child: Card(
        child: ListTile(
          onTap: onTap,
          leading: _CredentialIcon(type: credential.credentialType),
          title: Text(
            credential.displayName,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: Text(
            credential.issuerName,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          trailing: trailing ?? _StatusDot(status: credential.effectiveStatus),
        ),
      ),
    );
  }
}

class _CredentialIcon extends StatelessWidget {
  final CredentialType type;

  const _CredentialIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _getColor(type).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Icon(
        _getIcon(type),
        color: _getColor(type),
      ),
    );
  }

  IconData _getIcon(CredentialType type) {
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

  Color _getColor(CredentialType type) {
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
}

class _StatusDot extends StatelessWidget {
  final CredentialStatus status;

  const _StatusDot({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getColor(status),
      ),
    );
  }

  Color _getColor(CredentialStatus status) {
    switch (status) {
      case CredentialStatus.valid:
        return AppTheme.verifiedGreen;
      case CredentialStatus.expired:
        return AppTheme.warningOrange;
      case CredentialStatus.revoked:
        return AppTheme.revokedRed;
      case CredentialStatus.pending:
        return AppTheme.pendingYellow;
    }
  }
}
