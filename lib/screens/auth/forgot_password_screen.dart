import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    try {
      final response = await ApiService.post(
        '/password-reset/request/',
        {'email': _emailCtrl.text.trim()},
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        setState(() { _sent = true; _loading = false; });
      } else {
        setState(() { _error = l10n.t('somethingWentWrong'); _loading = false; });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() { _error = context.l10n.t('networkError'); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: context.novaBgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: _sent ? _buildSuccess(context.l10n) : _buildForm(context.l10n),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(AppLocalizations l10n) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Builder(builder: (context) => IconButton(
            onPressed: () => context.pop(),
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.novaTextSecondary),
          )),
          const SizedBox(height: 24),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8)),
              ],
            ),
            child: const Icon(Icons.lock_reset_rounded, size: 36, color: Colors.white),
          ),
          const SizedBox(height: 28),
          Builder(builder: (context) => Text(
            l10n.t('resetPasswordTitle'),
            style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: context.novaTextPrimary, height: 1.2),
          )),
          const SizedBox(height: 10),
          Builder(builder: (context) => Text(
            l10n.t('resetPasswordSubtitle'),
            style: TextStyle(color: context.novaTextSecondary, fontSize: 15, height: 1.5),
          )),
          const SizedBox(height: 36),
          if (_error != null) ...[
            _ErrorBanner(message: _error!),
            const SizedBox(height: 16),
          ],
          Builder(builder: (context) => TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: context.novaTextPrimary),
            decoration: InputDecoration(
              labelText: l10n.t('emailAddress'),
              prefixIcon: Icon(Icons.email_outlined, color: context.novaTextHint),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return l10n.t('required');
              if (!v.contains('@')) return l10n.t('enterValidEmail');
              return null;
            },
          )),
          const SizedBox(height: 36),
          GradientButton(
            label: l10n.t('sendResetLink'),
            onPressed: _submit,
            isLoading: _loading,
            icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(height: 24),
          Builder(builder: (context) => Center(
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Text(
                l10n.t('backToSignIn'),
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
          )),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSuccess(AppLocalizations l10n) {
    return Builder(builder: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 80),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.4), width: 2),
          ),
          child: const Icon(Icons.mark_email_read_rounded, size: 52, color: AppColors.accent),
        ),
        const SizedBox(height: 32),
        Text(
          l10n.t('checkEmail'),
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: context.novaTextPrimary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          l10n.tp('checkEmailBody', {'email': _emailCtrl.text.trim()}),
          style: TextStyle(color: context.novaTextSecondary, fontSize: 15, height: 1.6),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        GradientButton(
          label: l10n.t('backToSignIn'),
          onPressed: () => context.go('/login'),
          icon: const Icon(Icons.login_rounded, color: Colors.white, size: 18),
        ),
        const SizedBox(height: 20),
        Center(
          child: GestureDetector(
            onTap: _submit,
            child: Text(
              l10n.t('resendEmail'),
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ),
      ],
    ));
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: const TextStyle(color: AppColors.error, fontSize: 14))),
        ],
      ),
    );
  }
}
