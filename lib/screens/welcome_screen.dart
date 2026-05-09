import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_settings_provider.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = context.watch<AppSettingsProvider>();
    final isDark = settings.themeMode == ThemeMode.dark;
    final isFr = settings.locale.languageCode == 'fr';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: context.novaBgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  // ── Top bar: theme + language toggles ────────────────
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _TopChip(
                          child: Icon(
                            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                            size: 17,
                            color: isDark ? AppColors.warning : AppColors.primary,
                          ),
                          onTap: () => settings.setThemeMode(
                            isDark ? ThemeMode.light : ThemeMode.dark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _TopChip(
                          child: Text(
                            isFr ? 'ع' : 'FR',
                            style: TextStyle(
                              fontSize: isFr ? 15 : 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          onTap: () => settings.setLocale(
                            isFr ? const Locale('ar') : const Locale('fr'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _HeroIllustration(),
                  const SizedBox(height: 48),
                  Text(
                    l10n.t('welcomeTagline'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: context.novaTextPrimary,
                      height: 1.15,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.t('welcomeSubtitle'),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: context.novaTextSecondary, height: 1.6),
                  ),
                  const SizedBox(height: 40),
                  _FeaturePills(l10n: l10n),
                  const SizedBox(height: 40),
                  GradientButton(
                    label: l10n.t('createAccount'),
                    onPressed: () => context.push('/register'),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => context.push('/login'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                    child: Text(l10n.t('signIn'), style: const TextStyle(color: AppColors.primary)),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    l10n.t('termsAgree'),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: context.novaTextHint),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.15), width: 1),
            ),
          ),
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.25), width: 1),
            ),
          ),
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 40, spreadRadius: 5)],
            ),
            child: const Icon(Icons.shield_rounded, size: 58, color: Colors.white),
          ),
          Positioned(top: 20, right: 30, child: _FloatingBadge(icon: Icons.fingerprint, color: AppColors.accent)),
          Positioned(bottom: 20, left: 30, child: _FloatingBadge(icon: Icons.verified_user, color: AppColors.primary)),
          Positioned(top: 40, left: 40, child: _FloatingBadge(icon: Icons.lock_rounded, color: const Color(0xFFAB47BC))),
        ],
      ),
    );
  }
}

class _FloatingBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _FloatingBadge({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: context.novaSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.novaCardBorder),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 12)],
      ),
      child: Icon(icon, size: 22, color: color),
    );
  }
}

class _FeaturePills extends StatelessWidget {
  final AppLocalizations l10n;
  const _FeaturePills({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final features = [
      (Icons.credit_card_rounded, l10n.t('featIdVerified')),
      (Icons.face_retouching_natural, l10n.t('featFaceMatch')),
      (Icons.lock_outline_rounded, l10n.t('featEncrypted')),
    ];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: features
          .map((f) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: context.novaSurfaceElevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: context.novaCardBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(f.$1, size: 14, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(f.$2, style: TextStyle(fontSize: 12, color: context.novaTextSecondary, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ))
          .toList(),
    );
  }
}

class _TopChip extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _TopChip({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: context.novaSurfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: context.novaCardBorder),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
