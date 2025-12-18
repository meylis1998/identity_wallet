import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/theme/app_theme.dart';
import '../../credentials/domain/credential_model.dart';
import '../../credentials/presentation/bloc/credential_bloc.dart';
import '../../credentials/presentation/bloc/credential_event.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isProcessing = false;
  String? _lastScannedCode;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Scan QR Code',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, state, child) {
                return Icon(
                  state.torchState == TorchState.on
                      ? Icons.flash_on
                      : Icons.flash_off,
                  color: Colors.white,
                );
              },
            ),
            onPressed: () => _controller.toggleTorch(),
            tooltip: 'Toggle flash',
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
            onPressed: () => _controller.switchCamera(),
            tooltip: 'Switch camera',
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          _ScannerOverlay(isProcessing: _isProcessing),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Point your camera at a QR code',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    const Text(
                      'Scan credential offers or verification requests',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.spacingLg),
                    OutlinedButton.icon(
                      onPressed: _showDemoOptions,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                      ),
                      icon: const Icon(Icons.science),
                      label: const Text('Demo: Simulate Scan'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: AppTheme.spacingMd),
                    Text(
                      'Processing...',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final code = barcodes.first.rawValue;
    if (code == null || code == _lastScannedCode) return;

    _lastScannedCode = code;
    _processQRCode(code);
  }

  Future<void> _processQRCode(String data) async {
    setState(() => _isProcessing = true);

    try {
      final json = jsonDecode(data);

      if (json is Map<String, dynamic>) {
        if (json.containsKey('type') || json.containsKey('@context')) {
          await _handleCredentialOffer(json);
        }
        else if (json.containsKey('verificationRequest')) {
          await _handleVerificationRequest(json);
        }
        else {
          _showError('Unknown QR code format');
        }
      }
    } catch (e) {
      if (data.startsWith('http')) {
        _showError('URL-based credential offers not yet supported in demo');
      } else {
        _showError('Invalid QR code format');
      }
    } finally {
      setState(() => _isProcessing = false);
      await Future.delayed(const Duration(seconds: 2));
      _lastScannedCode = null;
    }
  }

  Future<void> _handleCredentialOffer(Map<String, dynamic> json) async {
    try {
      final credential = VerifiableCredential.fromJson(json);

      final shouldAdd = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Add Credential?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Credential: ${credential.displayName}'),
              const SizedBox(height: 8),
              Text('From: ${credential.issuerName}'),
              const SizedBox(height: 8),
              Text('Claims: ${credential.claims.length} fields'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Add'),
            ),
          ],
        ),
      );

      if (shouldAdd == true && mounted) {
        context.read<CredentialBloc>().add(AddCredential(credential));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${credential.displayName} added!')),
          );
          context.pop();
        }
      }
    } catch (e) {
      _showError('Invalid credential format: $e');
    }
  }

  Future<void> _handleVerificationRequest(Map<String, dynamic> json) async {
    if (mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
        ),
        builder: (context) => _VerificationRequestSheet(request: json),
      );
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  void _showDemoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Demo Options',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            const Text(
              'Simulate scanning different types of QR codes:',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            ListTile(
              leading: const Icon(Icons.add_card, color: AppTheme.primaryBlue),
              title: const Text('Receive New Credential'),
              subtitle: const Text('Simulate receiving a credential offer'),
              onTap: () {
                Navigator.pop(context);
                _simulateCredentialOffer();
              },
            ),
            ListTile(
              leading: const Icon(Icons.verified_user, color: AppTheme.accentGreen),
              title: const Text('Verification Request'),
              subtitle: const Text('Simulate a credential verification request'),
              onTap: () {
                Navigator.pop(context);
                _simulateVerificationRequest();
              },
            ),
            const SizedBox(height: AppTheme.spacingMd),
          ],
        ),
      ),
    );
  }

  void _simulateCredentialOffer() {
    final demoCredential = {
      '@context': ['https://www.w3.org/2018/credentials/v1'],
      'type': ['VerifiableCredential', 'ProfessionalLicenseCredential'],
      'issuer': 'did:web:dca.ca.gov',
      'issuerName': 'CA Dept. of Consumer Affairs',
      'issuerLogoUrl': '',
      'issuanceDate': DateTime.now().toIso8601String(),
      'expirationDate': DateTime.now().add(const Duration(days: 365)).toIso8601String(),
      'claims': [
        {'id': 'name', 'label': 'Name', 'value': 'Alex Johnson', 'required': true},
        {'id': 'licenseType', 'label': 'License Type', 'value': 'Software Engineer', 'required': true},
        {'id': 'licenseNumber', 'label': 'License #', 'value': 'SE-2024-78901'},
        {'id': 'status', 'label': 'Status', 'value': 'Active'},
      ],
      'status': 'valid',
      'credentialType': 'custom',
    };

    _handleCredentialOffer(demoCredential);
  }

  void _simulateVerificationRequest() {
    final request = {
      'verificationRequest': true,
      'verifier': 'State Government Portal',
      'purpose': 'Age verification for online services',
      'requestedClaims': ['over21', 'firstName', 'lastName'],
    };

    _handleVerificationRequest(request);
  }
}

class _ScannerOverlay extends StatelessWidget {
  final bool isProcessing;

  const _ScannerOverlay({required this.isProcessing});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ScannerOverlayPainter(isProcessing: isProcessing),
      child: const SizedBox.expand(),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  final bool isProcessing;

  _ScannerOverlayPainter({required this.isProcessing});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 50);
    final frameSize = size.width * 0.7;
    final frameRect = Rect.fromCenter(
      center: center,
      width: frameSize,
      height: frameSize,
    );

    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(frameRect, const Radius.circular(20)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(
      overlayPath,
      Paint()..color = Colors.black.withOpacity(0.6),
    );

    final framePaint = Paint()
      ..color = isProcessing ? AppTheme.accentGreen : Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRRect(
      RRect.fromRectAndRadius(frameRect, const Radius.circular(20)),
      framePaint,
    );

    final cornerLength = 30.0;
    final cornerPaint = Paint()
      ..color = isProcessing ? AppTheme.accentGreen : AppTheme.primaryBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(frameRect.left, frameRect.top + cornerLength),
      Offset(frameRect.left, frameRect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(frameRect.left, frameRect.top),
      Offset(frameRect.left + cornerLength, frameRect.top),
      cornerPaint,
    );

    canvas.drawLine(
      Offset(frameRect.right - cornerLength, frameRect.top),
      Offset(frameRect.right, frameRect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(frameRect.right, frameRect.top),
      Offset(frameRect.right, frameRect.top + cornerLength),
      cornerPaint,
    );

    canvas.drawLine(
      Offset(frameRect.left, frameRect.bottom - cornerLength),
      Offset(frameRect.left, frameRect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(frameRect.left, frameRect.bottom),
      Offset(frameRect.left + cornerLength, frameRect.bottom),
      cornerPaint,
    );

    canvas.drawLine(
      Offset(frameRect.right - cornerLength, frameRect.bottom),
      Offset(frameRect.right, frameRect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(frameRect.right, frameRect.bottom),
      Offset(frameRect.right, frameRect.bottom - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(_ScannerOverlayPainter oldDelegate) =>
      oldDelegate.isProcessing != isProcessing;
}

class _VerificationRequestSheet extends StatelessWidget {
  final Map<String, dynamic> request;

  const _VerificationRequestSheet({required this.request});

  @override
  Widget build(BuildContext context) {
    final verifier = request['verifier'] as String? ?? 'Unknown';
    final purpose = request['purpose'] as String? ?? 'Identity verification';
    final requestedClaims = List<String>.from(request['requestedClaims'] ?? []);

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
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
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_user,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Verification Request',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'From: $verifier',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingLg),
                Text(
                  'Purpose: $purpose',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMd),
                const Text(
                  'Requested Information:',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                ...requestedClaims.map((claim) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check, size: 16, color: AppTheme.accentGreen),
                      const SizedBox(width: 8),
                      Text(claim),
                    ],
                  ),
                )),
                const SizedBox(height: AppTheme.spacingLg),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Verification shared (demo)')),
                    );
                  },
                  child: const Text('Share Information'),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Decline'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
