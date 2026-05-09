import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../services/identity_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    final result = await AuthService.login(
      identifier: _identifierCtrl.text.trim(),
      password: _passwordCtrl.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (!result.success) {
      setState(() => _error = result.error);
      return;
    }

    if (result.mfaRequired) {
      context.push('/mfa', extra: {
        'mfaToken': result.mfaToken,
        'mfaMethods': result.mfaMethods,
      });
      return;
    }

    final idStatus = await IdentityService.getStatus();
    if (!mounted) return;

    if (!idStatus.hasDocument || idStatus.isRejected) {
      context.go('/identity/document-type');
    } else if (idStatus.isPending) {
      context.go('/identity/pending');
    } else {
      context.go('/home');
    }
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.novaTextSecondary),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.t('welcomeBack'),
                    style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: context.novaTextPrimary, height: 1.2),
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.t('loginSubtitle'), style: TextStyle(color: context.novaTextSecondary, fontSize: 16)),
                  const SizedBox(height: 40),
                  if (_error != null) _ErrorBanner(message: _error!),
                  if (_error != null) const SizedBox(height: 16),
                  TextFormField(
                    controller: _identifierCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: context.novaTextPrimary),
                    decoration: InputDecoration(
                      labelText: l10n.t('emailOrPhone'),
                      prefixIcon: Icon(Icons.person_outline_rounded, color: context.novaTextHint),
                    ),
                    validator: (v) => v == null || v.isEmpty ? l10n.t('required') : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscure,
                    style: TextStyle(color: context.novaTextPrimary),
                    decoration: InputDecoration(
                      labelText: l10n.t('password'),
                      prefixIcon: Icon(Icons.lock_outline_rounded, color: context.novaTextHint),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: context.novaTextHint),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) => v == null || v.isEmpty ? l10n.t('required') : null,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => context.push('/forgot-password'),
                      child: Text(
                        l10n.t('forgotPassword'),
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  GradientButton(label: l10n.t('signIn'), onPressed: _submit, isLoading: _loading),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l10n.t('dontHaveAccount'), style: TextStyle(color: context.novaTextSecondary)),
                      GestureDetector(
                        onTap: () => context.go('/register'),
                        child: Text(l10n.t('createOne'), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ),
                    ],
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
