import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

class DocumentTypeScreen extends StatelessWidget {
  const DocumentTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: context.novaBgGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildStepHeader(context, l10n),
                  const SizedBox(height: 36),
                  Text(
                    l10n.t('verifyYourIdentity'),
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: context.novaTextPrimary, height: 1.2),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.t('docTypeSubtitle'),
                    style: TextStyle(color: context.novaTextSecondary, fontSize: 15, height: 1.5),
                  ),
                  const SizedBox(height: 40),
                  _DocumentCard(
                    type: 'id_card',
                    icon: Icons.credit_card_rounded,
                    title: l10n.t('nationalIdCard'),
                    subtitle: l10n.t('frontBackRequired'),
                    onTap: () => context.push(
                      '/identity/capture-document',
                      extra: {'documentType': 'id_card', 'side': 'front'},
                    ),
                  ),
                  const SizedBox(height: 16),
                  _DocumentCard(
                    type: 'passport',
                    icon: Icons.menu_book_rounded,
                    title: l10n.t('passport'),
                    subtitle: l10n.t('photoPageOnly'),
                    onTap: () => context.push(
                      '/identity/capture-document',
                      extra: {'documentType': 'passport', 'side': 'front'},
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.novaSurfaceElevated,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: context.novaCardBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_rounded, color: AppColors.accent, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.t('securityNote'),
                            style: TextStyle(color: context.novaTextSecondary, fontSize: 13, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepHeader(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: List.generate(
                  3,
                  (i) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: i < 2 ? 6 : 0),
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: i == 0 ? AppColors.primary : context.novaCardBorder,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.t('stepDocType'),
                style: TextStyle(fontSize: 12, color: context.novaTextSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final String type;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DocumentCard({
    required this.type,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.novaSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.novaCardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: context.novaTextPrimary)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 13, color: context.novaTextSecondary)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: context.novaTextSecondary, size: 16),
          ],
        ),
      ),
    );
  }
}
