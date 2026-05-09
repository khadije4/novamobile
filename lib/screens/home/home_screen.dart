import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/app_settings_provider.dart';
import '../../services/auth_service.dart';
import '../../services/identity_service.dart';
import '../../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _user;
  IdentityStatus? _identityStatus;
  bool _biometricEnrolled = false;
  List<Map<String, dynamic>> _activities = [];
  bool _loadingData = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final results = await Future.wait([
      AuthService.getCurrentUser(),
      IdentityService.getStatus(),
      _fetchBiometricStatus(),
      _fetchActivity(),
    ]);
    if (!mounted) return;
    setState(() {
      _user = results[0] as Map<String, dynamic>?;
      _identityStatus = results[1] as IdentityStatus;
      _biometricEnrolled = results[2] as bool;
      _activities = results[3] as List<Map<String, dynamic>>;
      _loadingData = false;
    });
  }

  Future<bool> _fetchBiometricStatus() async {
    try {
      final r = await ApiService.get('/biometric/status/');
      if (r.statusCode == 200) {
        return jsonDecode(r.body)['enrolled'] == true;
      }
    } catch (_) {}
    return false;
  }

  Future<List<Map<String, dynamic>>> _fetchActivity() async {
    try {
      final r = await ApiService.get('/user/activity/');
      if (r.statusCode == 200) {
        final list = jsonDecode(r.body) as List;
        return list.take(5).map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (mounted) context.go('/welcome');
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.novaSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _SettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = context.watch<AppSettingsProvider>();
    final name = _user != null
        ? '${_user!['first_name'] ?? ''} ${_user!['last_name'] ?? ''}'.trim()
        : '';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: context.novaBgGradient),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadAll,
            backgroundColor: context.novaSurface,
            color: AppColors.primary,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildHeader(l10n, name, settings),
                const SizedBox(height: 20),
                _buildIdentityCard(l10n),
                const SizedBox(height: 20),
                _buildStatsRow(l10n),
                const SizedBox(height: 28),
                if (_activities.isNotEmpty) ...[
                  _buildSectionTitle(l10n.t('recentActivity')),
                  const SizedBox(height: 12),
                  _buildActivityList(l10n),
                  const SizedBox(height: 28),
                ],
                _buildSectionTitle(l10n.t('yourServices')),
                const SizedBox(height: 12),
                _buildServicesGrid(l10n),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, String name, AppSettingsProvider settings) {
    final isDark = settings.themeMode == ThemeMode.dark;
    final isFr = settings.locale.languageCode == 'fr';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // ── Logo ───────────────────────────────────────────
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.shield_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 10),
          // ── User info ──────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isNotEmpty
                      ? l10n.tp('helloName', {'name': name})
                      : l10n.t('welcomeBackHome'),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.novaTextPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _identityStatus?.isApproved == true
                      ? l10n.t('identityVerified')
                      : _identityStatus?.isPending == true
                          ? l10n.t('verificationPending')
                          : l10n.t('notVerified'),
                  style: TextStyle(
                    fontSize: 11,
                    color: _identityStatus?.isApproved == true
                        ? AppColors.accent
                        : _identityStatus?.isPending == true
                            ? AppColors.warning
                            : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          // ── Theme toggle ───────────────────────────────────
          _HeaderChip(
            child: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              size: 17,
              color: isDark ? AppColors.warning : AppColors.primary,
            ),
            onTap: () => settings.setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark),
          ),
          const SizedBox(width: 6),
          // ── Language toggle ────────────────────────────────
          _HeaderChip(
            child: Text(
              isFr ? 'ع' : 'FR',
              style: TextStyle(
                fontSize: isFr ? 15 : 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            onTap: () => settings.setLocale(isFr ? const Locale('ar') : const Locale('fr')),
          ),
          const SizedBox(width: 2),
          // ── Logout ─────────────────────────────────────────
          IconButton(
            onPressed: _logout,
            icon: Icon(Icons.logout_rounded, color: context.novaTextSecondary, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentityCard(AppLocalizations l10n) {
    final status = _identityStatus;

    Color cardColor;
    IconData cardIcon;
    String title;
    String subtitle;
    Widget trailingIcon;

    if (status == null || _loadingData) {
      cardColor = AppColors.primary;
      cardIcon = Icons.hourglass_empty_rounded;
      title = l10n.t('loading');
      subtitle = '';
      trailingIcon = const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );
    } else if (status.isApproved) {
      cardColor = AppColors.primary;
      cardIcon = Icons.verified_user_rounded;
      title = l10n.t('identityVerified');
      subtitle = l10n.t('fullyVerified');
      trailingIcon = const Icon(Icons.check_circle_rounded, color: Colors.white, size: 28);
    } else if (status.isPending) {
      cardColor = AppColors.warning;
      cardIcon = Icons.hourglass_top_rounded;
      title = l10n.t('verificationInProgressCard');
      subtitle = l10n.t('teamReviewing');
      trailingIcon = TextButton(
        onPressed: () => context.go('/identity/pending'),
        child: Text(l10n.t('view'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      );
    } else if (status.isRejected) {
      cardColor = AppColors.error;
      cardIcon = Icons.cancel_rounded;
      title = l10n.t('verificationRejected');
      subtitle = status.rejectionReason ?? l10n.t('resubmitDocs');
      trailingIcon = TextButton(
        onPressed: () => context.go('/identity/document-type'),
        child: Text(l10n.t('retry'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      );
    } else {
      cardColor = AppColors.textHint;
      cardIcon = Icons.person_outline_rounded;
      title = l10n.t('notVerified');
      subtitle = l10n.t('submitDocsVerify');
      trailingIcon = TextButton(
        onPressed: () => context.go('/identity/document-type'),
        child: Text(l10n.t('start'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: cardColor.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(cardIcon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.white70), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
            trailingIcon,
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.fingerprint,
              label: l10n.t('biometrics'),
              value: _biometricEnrolled ? l10n.t('enrolled') : l10n.t('notSet'),
              color: _biometricEnrolled ? AppColors.accent : context.novaTextHint,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _StatCard(
              icon: Icons.security_rounded,
              label: l10n.t('mfa'),
              value: _user?['mfa_enabled'] == true ? l10n.t('mfaEnabled') : l10n.t('mfaDisabled'),
              color: _user?['mfa_enabled'] == true ? AppColors.accent : context.novaTextHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.novaTextPrimary),
      ),
    );
  }

  Widget _buildActivityList(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: context.novaSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.novaCardBorder),
        ),
        child: Column(
          children: _activities.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return Column(
              children: [
                _ActivityRow(activity: item, l10n: l10n),
                if (i < _activities.length - 1)
                  Divider(color: context.novaDivider, height: 1, indent: 56),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildServicesGrid(AppLocalizations l10n) {
    final services = [
      _Service(icon: Icons.credit_card_rounded, label: l10n.t('myIdCard'), color: AppColors.primary),
      _Service(icon: Icons.fingerprint, label: l10n.t('biometrics'), color: AppColors.accent),
      _Service(icon: Icons.devices_rounded, label: l10n.t('myDevices'), color: const Color(0xFFAB47BC)),
      _Service(icon: Icons.shield_outlined, label: l10n.t('security'), color: AppColors.warning),
      _Service(icon: Icons.history_rounded, label: l10n.t('activity'), color: AppColors.error),
      _Service(icon: Icons.settings_rounded, label: l10n.t('settings'), color: const Color(0xFF42A5F5), onTap: _openSettings),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.1,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: services.map((s) => _ServiceCard(service: s)).toList(),
      ),
    );
  }
}

// ──────────────────────────────────────────
// Compact header chip (theme / language)
// ──────────────────────────────────────────
class _HeaderChip extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _HeaderChip({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
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

// ──────────────────────────────────────────
// Settings bottom sheet
// ──────────────────────────────────────────
class _SettingsSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = context.watch<AppSettingsProvider>();
    final isDark = settings.themeMode == ThemeMode.dark;
    final isFr = settings.locale.languageCode == 'fr';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.novaCardBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.t('appearance'),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.novaTextPrimary),
          ),
          const SizedBox(height: 24),
          // ── Theme ──────────────────────────────────────────────
          _SectionLabel(label: l10n.t('theme')),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ToggleCard(
                  icon: Icons.dark_mode_rounded,
                  label: l10n.t('darkTheme'),
                  selected: isDark,
                  onTap: () => settings.setThemeMode(ThemeMode.dark),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ToggleCard(
                  icon: Icons.light_mode_rounded,
                  label: l10n.t('lightTheme'),
                  selected: !isDark,
                  onTap: () => settings.setThemeMode(ThemeMode.light),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // ── Language ──────────────────────────────────────────────
          _SectionLabel(label: l10n.t('language')),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ToggleCard(
                  icon: Icons.language_rounded,
                  label: 'Français',
                  selected: isFr,
                  onTap: () => settings.setLocale(const Locale('fr')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ToggleCard(
                  icon: Icons.translate_rounded,
                  label: 'العربية',
                  selected: !isFr,
                  onTap: () => settings.setLocale(const Locale('ar')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.novaTextSecondary, letterSpacing: 0.5),
      ),
    );
  }
}

class _ToggleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.12) : context.novaSurfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : context.novaCardBorder,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? AppColors.primary : context.novaTextSecondary, size: 26),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.primary : context.novaTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// Data model for a service card
// ──────────────────────────────────────────
class _Service {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _Service({required this.icon, required this.label, required this.color, this.onTap});
}

// ──────────────────────────────────────────
// Widgets
// ──────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: context.novaSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.novaCardBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: context.novaTextSecondary)),
              Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final Map<String, dynamic> activity;
  final AppLocalizations l10n;
  const _ActivityRow({required this.activity, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final eventType = activity['event_type'] as String? ?? '';
    final description = activity['description'] as String? ?? '';
    final createdAt = activity['created_at'] as String? ?? '';

    IconData icon;
    Color color;
    switch (eventType) {
      case 'login':
      case 'login_attempt':
        icon = Icons.login_rounded;
        color = AppColors.primary;
        break;
      case 'mfa_success':
        icon = Icons.verified_rounded;
        color = AppColors.accent;
        break;
      case 'biometric_login_failed':
        icon = Icons.fingerprint;
        color = AppColors.error;
        break;
      case 'app_authorized':
        icon = Icons.apps_rounded;
        color = AppColors.warning;
        break;
      default:
        icon = Icons.info_outline_rounded;
        color = context.novaTextSecondary;
    }

    String timeAgo = '';
    try {
      final dt = DateTime.parse(createdAt).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) {
        timeAgo = l10n.tp('minutesAgo', {'m': diff.inMinutes.toString()});
      } else if (diff.inHours < 24) {
        timeAgo = l10n.tp('hoursAgo', {'h': diff.inHours.toString()});
      } else {
        timeAgo = l10n.tp('daysAgo', {'d': diff.inDays.toString()});
      }
    } catch (_) {}

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description.isNotEmpty ? description : eventType.replaceAll('_', ' '),
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: context.novaTextPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (timeAgo.isNotEmpty)
                  Text(timeAgo, style: TextStyle(fontSize: 11, color: context.novaTextHint)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final _Service service;
  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: service.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.novaSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.novaCardBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: service.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(service.icon, color: service.color, size: 26),
            ),
            const SizedBox(height: 12),
            Text(service.label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.novaTextPrimary)),
          ],
        ),
      ),
    );
  }
}
