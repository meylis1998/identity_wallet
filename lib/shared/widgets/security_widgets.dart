import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class SecurityBadge extends StatelessWidget {
  final bool isSecure;
  final String? label;

  const SecurityBadge({
    super.key,
    this.isSecure = true,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: isSecure ? 'Secured with encryption' : 'Security warning',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingSm,
          vertical: AppTheme.spacingXs,
        ),
        decoration: BoxDecoration(
          color: isSecure
              ? AppTheme.verifiedGreen.withOpacity(0.1)
              : AppTheme.warningOrange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(
            color: isSecure
                ? AppTheme.verifiedGreen.withOpacity(0.3)
                : AppTheme.warningOrange.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSecure ? Icons.lock : Icons.lock_open,
              size: 14,
              color: isSecure ? AppTheme.verifiedGreen : AppTheme.warningOrange,
            ),
            if (label != null) ...[
              const SizedBox(width: AppTheme.spacingXs),
              Text(
                label!,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSecure ? AppTheme.verifiedGreen : AppTheme.warningOrange,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class PrivacyConsentTile extends StatelessWidget {
  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final bool required;
  final bool sensitive;

  const PrivacyConsentTile({
    super.key,
    required this.title,
    required this.description,
    required this.value,
    this.onChanged,
    this.required = false,
    this.sensitive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title: $description. ${required ? "Required" : "Optional"}',
      checked: value,
      child: Card(
        child: InkWell(
          onTap: onChanged != null && !required
              ? () => onChanged!(!value)
              : null,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: value,
                  onChanged: required ? null : onChanged,
                  activeColor: AppTheme.primaryBlue,
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          if (required)
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
                          if (sensitive && !required)
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
                                    Icons.privacy_tip,
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
                      ),
                      const SizedBox(height: AppTheme.spacingXs),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BiometricButton extends StatelessWidget {
  final String biometricType;
  final VoidCallback? onPressed;
  final bool isLoading;

  const BiometricButton({
    super.key,
    required this.biometricType,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Authenticate with $biometricType',
      button: true,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(_getBiometricIcon(biometricType)),
        label: Text(
          isLoading ? 'Authenticating...' : 'Authenticate with $biometricType',
        ),
      ),
    );
  }

  IconData _getBiometricIcon(String type) {
    switch (type.toLowerCase()) {
      case 'face id':
        return Icons.face;
      case 'touch id':
        return Icons.fingerprint;
      default:
        return Icons.security;
    }
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

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
              child: Icon(
                icon,
                size: 40,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppTheme.spacingLg),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          if (action != null)
            TextButton(
              onPressed: onAction,
              child: Text(action!),
            ),
        ],
      ),
    );
  }
}
