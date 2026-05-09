import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../services/identity_service.dart';

class ReviewScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const ReviewScreen({super.key, required this.data});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  bool _loading = false;
  String? _error;

  String get _documentType => widget.data['documentType'] as String;
  Uint8List? get _frontBytes => widget.data['frontImageBytes'] as Uint8List?;
  Uint8List? get _backBytes => widget.data['backImageBytes'] as Uint8List?;
  Uint8List? get _selfieBytes => widget.data['selfieBytes'] as Uint8List?;

  Future<void> _submit() async {
    if (_frontBytes == null || _selfieBytes == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await IdentityService.uploadDocuments(
      documentType: _documentType,
      frontImage: _frontBytes!,
      backImage: _backBytes,
      selfieImage: _selfieBytes!,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (result.success) {
      context.go('/identity/pending');
    } else {
      setState(() => _error = result.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: context.novaBgGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, l10n),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.t('almostThere'),
                        style: TextStyle(color: context.novaTextSecondary, fontSize: 15, height: 1.5),
                      ),
                      const SizedBox(height: 28),
                      if (_error != null) ...[
                        _ErrorBanner(message: _error!),
                        const SizedBox(height: 20),
                      ],
                      _buildDocumentTypeBadge(l10n),
                      const SizedBox(height: 24),
                      Text(l10n.t('documents'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: context.novaTextPrimary)),
                      const SizedBox(height: 12),
                      _buildImageRow(l10n),
                      const SizedBox(height: 24),
                      Text(l10n.t('selfie'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: context.novaTextPrimary)),
                      const SizedBox(height: 12),
                      _SelfiePreview(bytes: _selfieBytes),
                      const SizedBox(height: 28),
                      _buildChecklist(l10n),
                      const SizedBox(height: 32),
                      GradientButton(
                        label: l10n.t('submitForVerification'),
                        onPressed: _submit,
                        isLoading: _loading,
                        icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                      ),
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

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.novaTextSecondary),
              ),
              Expanded(
                child: Text(
                  l10n.t('reviewAndSubmit'),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: context.novaTextPrimary),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentTypeBadge(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified_rounded, color: AppColors.primary, size: 16),
          const SizedBox(width: 6),
          Text(
            _documentType == 'id_card' ? l10n.t('nationalIdCard') : l10n.t('passport'),
            style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildImageRow(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _ImagePreview(
            bytes: _frontBytes,
            label: _documentType == 'passport' ? l10n.t('photoPage') : l10n.t('front'),
            aspectRatio: 1.58,
          ),
        ),
        if (_backBytes != null) ...[
          const SizedBox(width: 12),
          Expanded(
            child: _ImagePreview(
              bytes: _backBytes,
              label: l10n.t('back'),
              aspectRatio: 1.58,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildChecklist(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.novaSurfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.novaCardBorder),
      ),
      child: Column(
        children: [
          _CheckItem(text: l10n.t('textVisible')),
          const SizedBox(height: 8),
          _CheckItem(text: l10n.t('noBlurry')),
          const SizedBox(height: 8),
          _CheckItem(text: l10n.t('selfieMatches')),
        ],
      ),
    );
  }
}

// ========== Helper Widgets ==========

class _ImagePreview extends StatelessWidget {
  final Uint8List? bytes;
  final String label;
  final double aspectRatio;

  const _ImagePreview({required this.bytes, required this.label, required this.aspectRatio});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: context.novaTextSecondary)),
        const SizedBox(height: 8),
        AspectRatio(
          aspectRatio: aspectRatio,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.novaCardBorder),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: bytes != null
                  ? Image.memory(bytes!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const _ImagePlaceholder())
                  : const _ImagePlaceholder(),
            ),
          ),
        ),
      ],
    );
  }
}

class _SelfiePreview extends StatelessWidget {
  final Uint8List? bytes;
  const _SelfiePreview({required this.bytes});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 140,
        height: 170,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(70),
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(70),
            child: bytes != null
                ? Image.memory(bytes!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const _SelfiePlaceholder())
                : const _SelfiePlaceholder(),
          ),
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(Icons.broken_image_outlined, color: context.novaTextHint, size: 40),
    );
  }
}

class _SelfiePlaceholder extends StatelessWidget {
  const _SelfiePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(Icons.face_rounded, size: 60, color: context.novaTextHint),
    );
  }
}

class _CheckItem extends StatelessWidget {
  final String text;
  const _CheckItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 18),
        const SizedBox(width: 10),
        Text(text, style: TextStyle(color: context.novaTextSecondary, fontSize: 14)),
      ],
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
