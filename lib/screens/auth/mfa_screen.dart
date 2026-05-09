import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../services/identity_service.dart';

class MfaScreen extends StatefulWidget {
  final String mfaToken;
  final List<String> mfaMethods;

  const MfaScreen({
    super.key,
    required this.mfaToken,
    required this.mfaMethods,
  });

  @override
  State<MfaScreen> createState() => _MfaScreenState();
}

class _MfaScreenState extends State<MfaScreen> {
  late String _selectedMethod;
  final _codeCtrl = TextEditingController();
  bool _loading = false;
  bool _sending = false;
  bool _codeSent = false;
  String? _error;
  String? _info;

  @override
  void initState() {
    super.initState();
    if (widget.mfaMethods.contains('totp')) {
      _selectedMethod = 'totp';
    } else if (widget.mfaMethods.contains('email')) {
      _selectedMethod = 'email';
    } else {
      _selectedMethod = widget.mfaMethods.first;
    }
    if (_selectedMethod != 'totp') {
      WidgetsBinding.instance.addPostFrameCallback((_) => _sendOtp());
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final l10n = context.l10n;
    setState(() { _sending = true; _error = null; _info = null; });
    final ok = await AuthService.sendOtp(
      mfaToken: widget.mfaToken,
      method: _selectedMethod,
    );
    if (!mounted) return;
    setState(() {
      _sending = false;
      _codeSent = ok;
      _info = ok
          ? (_selectedMethod == 'email' ? l10n.t('codeSentEmail') : l10n.t('codeSentPhone'))
          : null;
      if (!ok) _error = l10n.t('failedSendCode');
    });
  }

  Future<void> _verify() async {
    final l10n = context.l10n;
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) {
      setState(() => _error = l10n.t('enterCode'));
      return;
    }
    setState(() { _loading = true; _error = null; });

    final result = await AuthService.verifyMfa(
      mfaToken: widget.mfaToken,
      code: code,
      method: _selectedMethod,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (!result.success) {
      setState(() => _error = result.error);
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

  void _switchMethod(String method) {
    if (method == _selectedMethod) return;
    setState(() {
      _selectedMethod = method;
      _codeCtrl.clear();
      _error = null;
      _info = null;
      _codeSent = false;
    });
    if (method != 'totp') _sendOtp();
  }

  String _subtitle(AppLocalizations l10n) {
    switch (_selectedMethod) {
      case 'totp': return l10n.t('subtitleTotp');
      case 'email': return l10n.t('subtitleEmail');
      case 'sms': return l10n.t('subtitleSms');
      default: return l10n.t('subtitleTotp');
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                IconButton(
                  onPressed: () => context.pop(),
                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.novaTextSecondary),
                ),
                const SizedBox(height: 24),
                _buildIcon(),
                const SizedBox(height: 28),
                Text(
                  l10n.t('twoFactorTitle'),
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: context.novaTextPrimary, height: 1.2),
                ),
                const SizedBox(height: 10),
                Text(
                  _subtitle(l10n),
                  style: TextStyle(color: context.novaTextSecondary, fontSize: 15, height: 1.5),
                ),
                const SizedBox(height: 32),
                if (widget.mfaMethods.length > 1) ...[
                  _MethodSelector(
                    methods: widget.mfaMethods,
                    selected: _selectedMethod,
                    onSelect: _switchMethod,
                    l10n: l10n,
                  ),
                  const SizedBox(height: 28),
                ],
                if (_error != null) ...[
                  _Banner(message: _error!, isError: true),
                  const SizedBox(height: 16),
                ],
                if (_info != null) ...[
                  _Banner(message: _info!, isError: false),
                  const SizedBox(height: 16),
                ],
                _buildCodeField(l10n),
                const SizedBox(height: 32),
                GradientButton(
                  label: l10n.t('verify'),
                  onPressed: _verify,
                  isLoading: _loading,
                  icon: const Icon(Icons.verified_rounded, color: Colors.white, size: 20),
                ),
                if (_selectedMethod != 'totp') ...[
                  const SizedBox(height: 20),
                  Center(
                    child: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textSecondary),
                          )
                        : TextButton(
                            onPressed: _sendOtp,
                            child: Text(
                              l10n.t('resendCode'),
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                            ),
                          ),
                  ),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final icon = _selectedMethod == 'totp'
        ? Icons.qr_code_rounded
        : _selectedMethod == 'email'
            ? Icons.mark_email_read_rounded
            : Icons.sms_rounded;

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Icon(icon, size: 36, color: Colors.white),
    );
  }

  Widget _buildCodeField(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.t('verificationCode'), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.novaTextSecondary)),
        const SizedBox(height: 10),
        TextFormField(
          controller: _codeCtrl,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: context.novaTextPrimary,
            letterSpacing: 12,
          ),
          decoration: InputDecoration(
            counterText: '',
            hintText: '––––––',
            hintStyle: TextStyle(fontSize: 28, color: context.novaTextHint, letterSpacing: 12),
            filled: true,
            fillColor: context.novaSurfaceElevated,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: context.novaCardBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: context.novaCardBorder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
            contentPadding: const EdgeInsets.symmetric(vertical: 20),
          ),
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
        ),
      ],
    );
  }
}

class _MethodSelector extends StatelessWidget {
  final List<String> methods;
  final String selected;
  final ValueChanged<String> onSelect;
  final AppLocalizations l10n;

  const _MethodSelector({
    required this.methods,
    required this.selected,
    required this.onSelect,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.t('chooseMethod'), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.novaTextSecondary)),
        const SizedBox(height: 10),
        Row(
          children: methods.map((m) {
            final isSelected = m == selected;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: m != methods.last ? 10 : 0),
                child: GestureDetector(
                  onTap: () => onSelect(m),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : context.novaSurfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : context.novaCardBorder,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(_methodIcon(m), color: isSelected ? AppColors.primary : context.novaTextSecondary, size: 22),
                        const SizedBox(height: 4),
                        Text(
                          _methodLabel(m),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? AppColors.primary : context.novaTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  IconData _methodIcon(String m) {
    switch (m) {
      case 'totp': return Icons.qr_code_rounded;
      case 'email': return Icons.email_rounded;
      default: return Icons.sms_rounded;
    }
  }

  String _methodLabel(String m) {
    switch (m) {
      case 'totp': return l10n.t('methodAuthenticator');
      case 'email': return l10n.t('methodEmail');
      default: return l10n.t('methodSms');
    }
  }
}

class _Banner extends StatelessWidget {
  final String message;
  final bool isError;
  const _Banner({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) {
    final color = isError ? AppColors.error : AppColors.accent;
    final icon = isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: TextStyle(color: color, fontSize: 14))),
        ],
      ),
    );
  }
}
