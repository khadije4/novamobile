import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../services/identity_service.dart';
import '../../services/auth_service.dart';

class VerificationPendingScreen extends StatefulWidget {
  const VerificationPendingScreen({super.key});

  @override
  State<VerificationPendingScreen> createState() => _VerificationPendingScreenState();
}

class _VerificationPendingScreenState extends State<VerificationPendingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  IdentityStatus? _status;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final status = await IdentityService.getStatus();
    if (mounted) setState(() => _status = status);
  }

  Future<void> _checkStatus() async {
    setState(() => _checking = true);
    final status = await IdentityService.getStatus();
    if (!mounted) return;
    setState(() { _status = status; _checking = false; });

    if (status.isApproved) context.go('/home');
    if (status.isRejected) context.go('/identity/document-type');
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: context.novaBgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (_, __) => Transform.scale(
                    scale: 0.95 + 0.05 * _pulseController.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.warning.withValues(alpha: 0.8 + 0.2 * _pulseController.value),
                            AppColors.primary.withValues(alpha: 0.8 + 0.2 * _pulseController.value),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.warning.withValues(alpha: 0.3 * _pulseController.value),
                            blurRadius: 30,
                            spreadRadius: 10,
                          )
                        ],
                      ),
                      child: const Icon(Icons.hourglass_top_rounded, size: 56, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                Text(
                  l10n.t('verificationInProgress'),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: context.novaTextPrimary, height: 1.2),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.t('pendingSubtitle'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.novaTextSecondary, fontSize: 16, height: 1.6),
                ),
                const SizedBox(height: 40),
                _VerificationTimeline(l10n: l10n),
                const SizedBox(height: 60),
                GradientButton(
                  label: _checking ? l10n.t('checking') : l10n.t('checkStatus'),
                  onPressed: _checking ? null : _checkStatus,
                  isLoading: _checking,
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () async {
                    await AuthService.logout();
                    if (context.mounted) context.go('/welcome');
                  },
                  child: Text(l10n.t('signOut'), style: TextStyle(color: context.novaTextSecondary)),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VerificationTimeline extends StatelessWidget {
  final AppLocalizations l10n;
  const _VerificationTimeline({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final steps = [
      (Icons.upload_rounded, l10n.t('submittedDocs'), true),
      (Icons.search_rounded, l10n.t('identityReview'), true),
      (Icons.verified_rounded, l10n.t('verificationComplete'), false),
    ];
    return Column(
      children: steps.asMap().entries.map((entry) {
        final i = entry.key;
        final step = entry.value;
        return Row(
          children: [
            Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: step.$3 ? AppColors.primary.withValues(alpha: 0.2) : context.novaSurfaceElevated,
                    shape: BoxShape.circle,
                    border: Border.all(color: step.$3 ? AppColors.primary : context.novaCardBorder),
                  ),
                  child: Icon(step.$1, size: 18, color: step.$3 ? AppColors.primary : context.novaTextHint),
                ),
                if (i < steps.length - 1)
                  Container(width: 2, height: 24, color: i == 0 ? AppColors.primary : context.novaCardBorder),
              ],
            ),
            const SizedBox(width: 16),
            Text(
              step.$2,
              style: TextStyle(
                color: step.$3 ? context.novaTextPrimary : context.novaTextHint,
                fontSize: 15,
                fontWeight: step.$3 ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
