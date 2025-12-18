import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/di/service_locator.dart';
import '../../../shared/widgets/security_widgets.dart';
import '../domain/credential_model.dart';

class SelectiveDisclosureScreen extends StatefulWidget {
  final VerifiableCredential credential;

  const SelectiveDisclosureScreen({
    super.key,
    required this.credential,
  });

  @override
  State<SelectiveDisclosureScreen> createState() =>
      _SelectiveDisclosureScreenState();
}

class _SelectiveDisclosureScreenState
    extends State<SelectiveDisclosureScreen> {
  late Map<String, bool> _selectedClaims;
  bool _isAuthenticating = false;
  bool _showPresentation = false;

  @override
  void initState() {
    super.initState();
    _selectedClaims = {
      for (final claim in widget.credential.claims)
        claim.id: claim.required,
    };
  }

  int get _selectedCount =>
      _selectedClaims.values.where((v) => v).length;

  List<CredentialClaim> get _selectedClaimsList =>
      widget.credential.claims
          .where((c) => _selectedClaims[c.id] == true)
          .toList();

  @override
  Widget build(BuildContext context) {
    if (_showPresentation) {
      return _PresentationView(
        credential: widget.credential,
        selectedClaims: _selectedClaimsList,
        onBack: () => setState(() => _showPresentation = false),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose What to Share'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(AppTheme.spacingMd),
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(
                color: AppTheme.primaryBlue.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.privacy_tip,
                  color: AppTheme.primaryBlue,
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selective Disclosure',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Choose exactly which information to share. Unselected fields will not be revealed.',
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

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
            child: Row(
              children: [
                _CredentialBadge(type: widget.credential.credentialType),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.credential.displayName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        widget.credential.issuerName,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingMd),
          const Divider(),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              children: [
                if (widget.credential.requiredClaims.isNotEmpty) ...[
                  const _SectionHeader(
                    title: 'REQUIRED INFORMATION',
                    subtitle: 'These fields must be shared',
                  ),
                  ...widget.credential.requiredClaims.map(
                    (claim) => _ClaimSelectionTile(
                      claim: claim,
                      isSelected: true,
                      enabled: false,
                      onChanged: null,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLg),
                ],

                if (widget.credential.publicClaims
                    .where((c) => !c.required)
                    .isNotEmpty) ...[
                  const _SectionHeader(
                    title: 'OPTIONAL INFORMATION',
                    subtitle: 'Choose which fields to include',
                  ),
                  ...widget.credential.publicClaims
                      .where((c) => !c.required)
                      .map(
                        (claim) => _ClaimSelectionTile(
                          claim: claim,
                          isSelected: _selectedClaims[claim.id] ?? false,
                          onChanged: (value) {
                            setState(() {
                              _selectedClaims[claim.id] = value ?? false;
                            });
                          },
                        ),
                      ),
                  const SizedBox(height: AppTheme.spacingLg),
                ],

                if (widget.credential.sensitiveClaims.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'SENSITIVE INFORMATION',
                    subtitle: 'Extra privacy protection recommended',
                    icon: Icons.warning_amber,
                    iconColor: AppTheme.warningOrange,
                  ),
                  ...widget.credential.sensitiveClaims.map(
                    (claim) => _ClaimSelectionTile(
                      claim: claim,
                      isSelected: _selectedClaims[claim.id] ?? false,
                      isSensitive: true,
                      onChanged: (value) {
                        setState(() {
                          _selectedClaims[claim.id] = value ?? false;
                        });
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              border: Border(
                top: BorderSide(color: AppTheme.borderGray),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$_selectedCount of ${widget.credential.claims.length} fields selected',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            for (final claim in widget.credential.claims) {
                              _selectedClaims[claim.id] = claim.required;
                            }
                          });
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  BiometricButton(
                    biometricType: 'Face ID',
                    isLoading: _isAuthenticating,
                    onPressed: _generatePresentation,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generatePresentation() async {
    setState(() => _isAuthenticating = true);

    try {
      final biometricService = sl<BiometricService>();
      final result = await biometricService.authenticateForPresentation();

      if (result.success) {
        setState(() {
          _showPresentation = true;
          _isAuthenticating = false;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.errorMessage ?? 'Authentication failed'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
        setState(() => _isAuthenticating = false);
      }
    } catch (e) {
      setState(() {
        _showPresentation = true;
        _isAuthenticating = false;
      });
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;
  final Color? iconColor;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: iconColor ?? AppTheme.textMuted),
                const SizedBox(width: 4),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClaimSelectionTile extends StatelessWidget {
  final CredentialClaim claim;
  final bool isSelected;
  final bool enabled;
  final bool isSensitive;
  final ValueChanged<bool?>? onChanged;

  const _ClaimSelectionTile({
    required this.claim,
    required this.isSelected,
    this.enabled = true,
    this.isSensitive = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      child: InkWell(
        onTap: enabled && onChanged != null
            ? () => onChanged!(!isSelected)
            : null,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Row(
            children: [
              Checkbox(
                value: isSelected,
                onChanged: enabled ? onChanged : null,
                activeColor: AppTheme.primaryBlue,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          claim.label,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: enabled
                                ? AppTheme.textPrimary
                                : AppTheme.textMuted,
                          ),
                        ),
                        if (claim.required) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.textMuted.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Required',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ),
                        ],
                        if (isSensitive) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.warningOrange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.lock,
                                  size: 10,
                                  color: AppTheme.warningOrange,
                                ),
                                const SizedBox(width: 2),
                                const Text(
                                  'Sensitive',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.warningOrange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      claim.value,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: enabled
                            ? AppTheme.textSecondary
                            : AppTheme.textMuted,
                      ),
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
}

class _CredentialBadge extends StatelessWidget {
  final CredentialType type;

  const _CredentialBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getGradientColors(type),
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Icon(
        _getIcon(type),
        color: Colors.white,
        size: 24,
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
}

class _PresentationView extends StatelessWidget {
  final VerifiableCredential credential;
  final List<CredentialClaim> selectedClaims;
  final VoidCallback onBack;

  const _PresentationView({
    required this.credential,
    required this.selectedClaims,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final presentation = {
      '@context': credential.context,
      'type': ['VerifiablePresentation', 'SelectiveDisclosure'],
      'verifiableCredential': {
        'id': credential.id,
        'type': credential.type,
        'issuer': credential.issuer,
        'issuerName': credential.issuerName,
        'issuanceDate': credential.issuanceDate.toIso8601String(),
        'claims': selectedClaims.map((c) => c.toJson()).toList(),
      },
      'holder': credential.holderDid,
      'created': DateTime.now().toIso8601String(),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Present Credential'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.verifiedGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppTheme.verifiedGreen,
                size: 32,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              'Ready to Present',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'Sharing ${selectedClaims.length} of ${credential.claims.length} fields',
              style: Theme.of(context).textTheme.bodyMedium,
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
                data: jsonEncode(presentation),
                version: QrVersions.auto,
                size: 250,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),

            const SecurityBadge(
              isSecure: true,
              label: 'Selective disclosure enabled',
            ),

            const SizedBox(height: AppTheme.spacingLg),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(
                color: AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Information being shared:',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  ...selectedClaims.map((claim) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check,
                          size: 14,
                          color: AppTheme.verifiedGreen,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${claim.label}: ${claim.value}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacingLg),

            Text(
              'Scan this QR code to verify the selected information',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
