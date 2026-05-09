import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/identity_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  IdentityStatus? _idStatus;
  bool _biometricEnrolled = false;
  List<String> _mfaMethods = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiService.get('/user/me/'),
        IdentityService.getStatus(),
        ApiService.get('/biometric/status/'),
        ApiService.get('/mfa-methods/'),
      ]);

      final userResp = results[0];
      final idStatus = results[1] as IdentityStatus;
      final bioResp = results[2];
      final mfaResp = results[3];

      if (!mounted) return;
      setState(() {
        if (userResp.statusCode == 200) _user = jsonDecode(userResp.body);
        _idStatus = idStatus;
        if (bioResp.statusCode == 200) {
          _biometricEnrolled = jsonDecode(bioResp.body)['enrolled'] == true;
        }
        if (mfaResp.statusCode == 200) {
          final list = jsonDecode(mfaResp.body) as List;
          _mfaMethods = list
              .where((m) => m['is_active'] == true)
              .map((m) => m['method_type'] as String)
              .toList();
        }
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final name = _user != null
        ? '${_user!['first_name'] ?? ''} ${_user!['last_name'] ?? ''}'.trim()
        : '';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: context.novaBgGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context, l10n),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : RefreshIndicator(
                        onRefresh: _loadAll,
                        backgroundColor: context.novaSurface,
                        color: AppColors.primary,
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          children: [
                            _buildAvatar(name),
                            const SizedBox(height: 28),
                            _SectionHeader(label: l10n.t('personalInfo')),
                            const SizedBox(height: 12),
                            _buildInfoCard(l10n),
                            const SizedBox(height: 24),
                            _SectionHeader(label: l10n.t('security')),
                            const SizedBox(height: 12),
                            _buildMfaCard(l10n),
                            const SizedBox(height: 12),
                            _buildChangePasswordCard(l10n),
                            const SizedBox(height: 24),
                            _SectionHeader(label: l10n.t('biometrics')),
                            const SizedBox(height: 12),
                            _buildBiometricCard(l10n),
                            const SizedBox(height: 24),
                            _SectionHeader(label: l10n.t('myIdCard')),
                            const SizedBox(height: 12),
                            _buildIdentityCard(l10n),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.novaTextSecondary, size: 20),
          ),
          Expanded(
            child: Text(
              l10n.t('myProfile'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.novaTextPrimary),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildAvatar(String name) {
    final initials = name.isNotEmpty
        ? name.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase()
        : '?';
    return Center(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: Center(
              child: Text(initials, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name.isNotEmpty ? name : (_user?['email'] ?? ''),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.novaTextPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            _user?['email'] ?? '',
            style: TextStyle(fontSize: 13, color: context.novaTextSecondary),
          ),
        ],
      ),
    );
  }

  // ── Personal info ─────────────────────────────────────────────────────────

  Widget _buildInfoCard(AppLocalizations l10n) {
    return _Card(
      child: Column(
        children: [
          _InfoTile(
            icon: Icons.badge_outlined,
            label: l10n.t('firstName'),
            value: _user?['first_name'] ?? '—',
            onEdit: () => _editField(l10n, 'first_name', l10n.t('firstName'), _user?['first_name'] ?? ''),
          ),
          Divider(color: context.novaDivider, height: 1),
          _InfoTile(
            icon: Icons.badge_outlined,
            label: l10n.t('lastName'),
            value: _user?['last_name'] ?? '—',
            onEdit: () => _editField(l10n, 'last_name', l10n.t('lastName'), _user?['last_name'] ?? ''),
          ),
          Divider(color: context.novaDivider, height: 1),
          _InfoTile(
            icon: Icons.email_outlined,
            label: l10n.t('emailAddress'),
            value: _user?['email'] ?? '—',
          ),
          Divider(color: context.novaDivider, height: 1),
          _InfoTile(
            icon: Icons.phone_outlined,
            label: l10n.t('phone'),
            value: _user?['phone'] ?? '—',
            onEdit: () => _editField(l10n, 'phone', l10n.t('phone'), _user?['phone'] ?? ''),
          ),
        ],
      ),
    );
  }

  Future<void> _editField(AppLocalizations l10n, String field, String label, String current) async {
    final ctrl = TextEditingController(text: current);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.novaSurface,
        title: Text(label, style: TextStyle(color: context.novaTextPrimary)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: TextStyle(color: context.novaTextPrimary),
          decoration: InputDecoration(labelText: label),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.t('cancel'), style: const TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: Text(l10n.t('save'), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (result == null || result == current) return;
    final resp = await ApiService.patch('/user/me/', {field: result});
    if (!mounted) return;
    if (resp.statusCode == 200) {
      setState(() => _user = jsonDecode(resp.body));
      _showSnack(l10n.t('saved'));
    } else {
      _showSnack(l10n.t('errorOccurred'), error: true);
    }
  }

  // ── MFA ───────────────────────────────────────────────────────────────────

  Widget _buildMfaCard(AppLocalizations l10n) {
    return _Card(
      child: Column(
        children: [
          _MfaTile(
            icon: Icons.qr_code_rounded,
            label: l10n.t('methodAuthenticator'),
            subtitle: 'TOTP',
            enabled: _mfaMethods.contains('totp'),
            onToggle: () => _mfaMethods.contains('totp') ? _disableTotp(l10n) : _enableTotp(l10n),
          ),
          Divider(color: context.novaDivider, height: 1),
          _MfaTile(
            icon: Icons.email_rounded,
            label: l10n.t('methodEmail'),
            subtitle: l10n.t('subtitleEmail'),
            enabled: _mfaMethods.contains('email'),
            onToggle: () => _mfaMethods.contains('email') ? _disableMfaMethod('email', l10n) : _enableEmailMfa(l10n),
          ),
          Divider(color: context.novaDivider, height: 1),
          _MfaTile(
            icon: Icons.sms_rounded,
            label: l10n.t('methodSms'),
            subtitle: l10n.t('subtitleSms'),
            enabled: _mfaMethods.contains('sms'),
            onToggle: () => _mfaMethods.contains('sms') ? _disableMfaMethod('sms', l10n) : _enableSmsMfa(l10n),
          ),
        ],
      ),
    );
  }

  Future<void> _enableTotp(AppLocalizations l10n) async {
    final resp = await ApiService.get('/mfa/totp/enable/');
    if (!mounted || resp.statusCode != 200) { _showSnack(l10n.t('errorOccurred'), error: true); return; }
    final data = jsonDecode(resp.body);
    final secret = data['secret'] as String;
    final qrBase64 = data['qr_code'] as String;

    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.novaSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _TotpSetupSheet(
        secret: secret,
        qrBase64: qrBase64,
        l10n: l10n,
        onVerified: (code) async {
          final r = await ApiService.post('/mfa/totp/enable/', {'secret': secret, 'code': code});
          if (!mounted) return false;
          if (r.statusCode == 200) {
            setState(() { if (!_mfaMethods.contains('totp')) _mfaMethods.add('totp'); });
            _showSnack(l10n.t('mfaEnabled'));
            return true;
          }
          return false;
        },
      ),
    );
  }

  Future<void> _disableTotp(AppLocalizations l10n) async {
    final ctrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.novaSurface,
        title: Text(l10n.t('disableMfa'), style: TextStyle(color: context.novaTextPrimary)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          maxLength: 6,
          style: TextStyle(color: context.novaTextPrimary),
          decoration: InputDecoration(labelText: l10n.t('verificationCode')),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.t('cancel'))),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.t('confirm'), style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final resp = await ApiService.post('/mfa/totp/disable/', {'code': ctrl.text.trim()});
    if (!mounted) return;
    if (resp.statusCode == 200) {
      setState(() => _mfaMethods.remove('totp'));
      _showSnack(l10n.t('mfaDisabled'));
    } else {
      _showSnack(l10n.t('invalidCode'), error: true);
    }
  }

  Future<void> _enableEmailMfa(AppLocalizations l10n) async {
    final resp = await ApiService.get('/mfa/email/enable/');
    if (!mounted || resp.statusCode != 200) { _showSnack(l10n.t('errorOccurred'), error: true); return; }
    final data = jsonDecode(resp.body);
    final masked = data['email'] as String? ?? '';
    _showSnack('${l10n.t("codeSentEmail")} $masked');
    await _verifyOtpAndEnable('/mfa/email/enable/', 'email', l10n);
  }

  Future<void> _enableSmsMfa(AppLocalizations l10n) async {
    final resp = await ApiService.get('/mfa/sms/enable/');
    if (!mounted || resp.statusCode != 200) { _showSnack(l10n.t('errorOccurred'), error: true); return; }
    final data = jsonDecode(resp.body);
    final masked = data['phone'] as String? ?? '';
    _showSnack('${l10n.t("codeSentPhone")} $masked');
    await _verifyOtpAndEnable('/mfa/sms/enable/', 'sms', l10n);
  }

  Future<void> _verifyOtpAndEnable(String path, String method, AppLocalizations l10n) async {
    final ctrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.novaSurface,
        title: Text(l10n.t('verificationCode'), style: TextStyle(color: context.novaTextPrimary)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          maxLength: 6,
          style: TextStyle(color: context.novaTextPrimary),
          decoration: InputDecoration(labelText: l10n.t('enterCode')),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.t('cancel'))),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.t('confirm'), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final resp = await ApiService.post(path, {'code': ctrl.text.trim()});
    if (!mounted) return;
    if (resp.statusCode == 200) {
      setState(() { if (!_mfaMethods.contains(method)) _mfaMethods.add(method); });
      _showSnack(l10n.t('mfaEnabled'));
    } else {
      _showSnack(l10n.t('invalidCode'), error: true);
    }
  }

  Future<void> _disableMfaMethod(String method, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.novaSurface,
        title: Text(l10n.t('disableMfa'), style: TextStyle(color: context.novaTextPrimary)),
        content: Text(l10n.t('disableMfaConfirm'), style: TextStyle(color: context.novaTextSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.t('cancel'))),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.t('disable'), style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    // Delete via MFA method endpoint
    final listResp = await ApiService.get('/mfa-methods/');
    if (!mounted || listResp.statusCode != 200) return;
    final list = jsonDecode(listResp.body) as List;
    final match = list.firstWhere((m) => m['method_type'] == method && m['is_active'] == true, orElse: () => null);
    if (match == null) return;
    final delResp = await ApiService.delete('/mfa-methods/${match["id"]}/');
    if (!mounted) return;
    if (delResp.statusCode == 204) {
      setState(() => _mfaMethods.remove(method));
      _showSnack(l10n.t('mfaDisabled'));
    } else {
      _showSnack(l10n.t('errorOccurred'), error: true);
    }
  }

  // ── Change password ───────────────────────────────────────────────────────

  Widget _buildChangePasswordCard(AppLocalizations l10n) {
    return _Card(
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.lock_reset_rounded, color: AppColors.warning, size: 20),
        ),
        title: Text(l10n.t('changePassword'), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.novaTextPrimary)),
        trailing: Icon(Icons.chevron_right_rounded, color: context.novaTextHint),
        onTap: () => _showChangePasswordSheet(l10n),
      ),
    );
  }

  Future<void> _showChangePasswordSheet(AppLocalizations l10n) async {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.novaSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 32, left: 24, right: 24, top: 24),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: context.novaCardBorder, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text(l10n.t('changePassword'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.novaTextPrimary)),
              const SizedBox(height: 20),
              TextFormField(
                controller: currentCtrl,
                obscureText: true,
                style: TextStyle(color: context.novaTextPrimary),
                decoration: InputDecoration(labelText: l10n.t('currentPassword'), prefixIcon: Icon(Icons.lock_outline_rounded, color: context.novaTextHint)),
                validator: (v) => v == null || v.isEmpty ? l10n.t('required') : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: newCtrl,
                obscureText: true,
                style: TextStyle(color: context.novaTextPrimary),
                decoration: InputDecoration(labelText: l10n.t('newPassword'), prefixIcon: Icon(Icons.lock_rounded, color: context.novaTextHint)),
                validator: (v) => (v == null || v.length < 8) ? l10n.t('min8chars') : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  label: l10n.t('save'),
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final resp = await ApiService.post('/user/change-password/', {
                      'current_password': currentCtrl.text,
                      'new_password': newCtrl.text,
                    });
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    if (resp.statusCode == 200) {
                      _showSnack(l10n.t('saved'));
                    } else {
                      final err = jsonDecode(resp.body)['error'] ?? l10n.t('errorOccurred');
                      _showSnack(err, error: true);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Biometric ─────────────────────────────────────────────────────────────

  Widget _buildBiometricCard(AppLocalizations l10n) {
    return _Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (_biometricEnrolled ? AppColors.accent : context.novaTextHint).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.fingerprint, color: _biometricEnrolled ? AppColors.accent : context.novaTextHint, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _biometricEnrolled ? l10n.t('biometricEnrolled') : l10n.t('biometricNotEnrolled'),
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.novaTextPrimary),
                      ),
                      Text(
                        _biometricEnrolled ? l10n.t('biometricEnrolledSub') : l10n.t('biometricNotEnrolledSub'),
                        style: TextStyle(fontSize: 12, color: context.novaTextSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_biometricEnrolled)
              OutlinedButton.icon(
                onPressed: () => _deleteBiometric(l10n),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: Text(l10n.t('biometricRemove')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size(double.infinity, 44),
                ),
              )
            else
              GradientButton(
                label: l10n.t('biometricEnroll'),
                onPressed: () => _enrollBiometric(l10n),
                icon: const Icon(Icons.add_a_photo_rounded, color: Colors.white, size: 18),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _enrollBiometric(AppLocalizations l10n) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera, preferredCameraDevice: CameraDevice.front, imageQuality: 90);
    if (picked == null || !mounted) return;
    final bytes = await picked.readAsBytes();
    final resp = await ApiService.multipartPost('/biometric/enroll/', fields: {}, bytes: {'image': bytes});
    if (!mounted) return;
    if (resp.statusCode == 200) {
      setState(() => _biometricEnrolled = true);
      _showSnack(l10n.t('biometricEnrolled'));
    } else {
      final err = jsonDecode(resp.body)['error'] ?? l10n.t('errorOccurred');
      _showSnack(err, error: true);
    }
  }

  Future<void> _deleteBiometric(AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.novaSurface,
        title: Text(l10n.t('biometricRemove'), style: TextStyle(color: context.novaTextPrimary)),
        content: Text(l10n.t('biometricRemoveConfirm'), style: TextStyle(color: context.novaTextSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.t('cancel'))),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.t('remove'), style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final resp = await ApiService.delete('/biometric/delete/');
    if (!mounted) return;
    if (resp.statusCode == 200) {
      setState(() => _biometricEnrolled = false);
      _showSnack(l10n.t('biometricRemoved'));
    } else {
      _showSnack(l10n.t('errorOccurred'), error: true);
    }
  }

  // ── Identity document ─────────────────────────────────────────────────────

  Widget _buildIdentityCard(AppLocalizations l10n) {
    final status = _idStatus;
    if (status == null) return const SizedBox.shrink();

    Color color;
    IconData icon;
    String title;
    String sub;
    if (status.isApproved) {
      color = AppColors.accent; icon = Icons.verified_rounded;
      title = l10n.t('identityVerified'); sub = l10n.t('fullyVerified');
    } else if (status.isPending) {
      color = AppColors.warning; icon = Icons.hourglass_top_rounded;
      title = l10n.t('verificationInProgress'); sub = l10n.t('teamReviewing');
    } else if (status.isRejected) {
      color = AppColors.error; icon = Icons.cancel_rounded;
      title = l10n.t('verificationRejected'); sub = status.rejectionReason ?? l10n.t('resubmitDocs');
    } else {
      color = context.novaTextHint; icon = Icons.person_outline_rounded;
      title = l10n.t('notVerified'); sub = l10n.t('submitDocsVerify');
    }

    return _Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.novaTextPrimary)),
                      Text(sub, style: TextStyle(fontSize: 12, color: context.novaTextSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
            if (!status.isApproved) ...[
              const SizedBox(height: 14),
              GradientButton(
                label: status.isPending ? l10n.t('view') : l10n.t('start'),
                onPressed: () => context.push(status.isPending ? '/identity/pending' : '/identity/document-type'),
                icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showSnack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppColors.error : AppColors.accent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.novaTextSecondary, letterSpacing: 0.8),
  );
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: context.novaSurface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: context.novaCardBorder),
    ),
    clipBehavior: Clip.antiAlias,
    child: child,
  );
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onEdit;
  const _InfoTile({required this.icon, required this.label, required this.value, this.onEdit});

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: AppColors.primary, size: 20),
    title: Text(label, style: TextStyle(fontSize: 11, color: context.novaTextSecondary)),
    subtitle: Text(value.isNotEmpty ? value : '—', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: context.novaTextPrimary)),
    trailing: onEdit != null ? IconButton(icon: Icon(Icons.edit_rounded, size: 18, color: context.novaTextHint), onPressed: onEdit) : null,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  );
}

class _MfaTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool enabled;
  final VoidCallback onToggle;
  const _MfaTile({required this.icon, required this.label, required this.subtitle, required this.enabled, required this.onToggle});

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: (enabled ? AppColors.accent : context.novaTextHint).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: enabled ? AppColors.accent : context.novaTextHint, size: 20),
    ),
    title: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.novaTextPrimary)),
    subtitle: Text(subtitle, style: TextStyle(fontSize: 11, color: context.novaTextSecondary)),
    trailing: Switch.adaptive(
      value: enabled,
      onChanged: (_) => onToggle(),
      activeColor: AppColors.accent,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// TOTP QR setup bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _TotpSetupSheet extends StatefulWidget {
  final String secret;
  final String qrBase64;
  final AppLocalizations l10n;
  final Future<bool> Function(String code) onVerified;
  const _TotpSetupSheet({required this.secret, required this.qrBase64, required this.l10n, required this.onVerified});

  @override
  State<_TotpSetupSheet> createState() => _TotpSetupSheetState();
}

class _TotpSetupSheetState extends State<_TotpSetupSheet> {
  final _ctrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    // Strip data:image/png;base64, prefix if present
    final rawBase64 = widget.qrBase64.contains(',') ? widget.qrBase64.split(',').last : widget.qrBase64;
    Uint8List? qrBytes;
    try { qrBytes = base64Decode(rawBase64); } catch (_) {}

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 32, left: 24, right: 24, top: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: context.novaCardBorder, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Text(l10n.t('methodAuthenticator'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.novaTextPrimary)),
          const SizedBox(height: 16),
          if (qrBytes != null)
            Container(
              width: 180, height: 180,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.all(8),
              child: Image.memory(qrBytes, fit: BoxFit.contain),
            ),
          const SizedBox(height: 12),
          Text(l10n.t('totpScanHint'), textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: context.novaTextSecondary)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: context.novaSurfaceElevated, borderRadius: BorderRadius.circular(8)),
              child: Text(widget.secret, style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: AppColors.primary, letterSpacing: 2)),
            ),
          ),
          const SizedBox(height: 20),
          if (_error != null) ...[
            Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
            const SizedBox(height: 8),
          ],
          TextField(
            controller: _ctrl,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: context.novaTextPrimary, letterSpacing: 10),
            decoration: InputDecoration(counterText: '', hintText: '——————', hintStyle: TextStyle(color: context.novaTextHint, letterSpacing: 10)),
          ),
          const SizedBox(height: 20),
          GradientButton(
            label: l10n.t('verify'),
            isLoading: _loading,
            onPressed: _loading ? null : () async {
              setState(() { _loading = true; _error = null; });
              final ok = await widget.onVerified(_ctrl.text.trim());
              if (!mounted) return;
              if (ok) {
                Navigator.pop(context);
              } else {
                setState(() { _loading = false; _error = l10n.t('invalidCode'); });
              }
            },
          ),
        ],
      ),
    );
  }
}
