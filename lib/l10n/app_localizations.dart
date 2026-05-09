import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const delegate = _AppLocalizationsDelegate();

  String t(String key) {
    final map = _strings[locale.languageCode] ?? _strings['fr']!;
    return map[key] ?? _strings['fr']![key] ?? key;
  }

  // Parametric helper
  String tp(String key, Map<String, String> args) {
    var s = t(key);
    for (final entry in args.entries) {
      s = s.replaceAll('{${entry.key}}', entry.value);
    }
    return s;
  }

  static const Map<String, Map<String, String>> _strings = {
    'fr': {
      // ── Welcome ──────────────────────────────────────────────
      'welcomeTagline': 'Votre identité,\nsécurisée.',
      'welcomeSubtitle':
          'Vérifiez une fois, accédez partout.\nNovaGard garde votre identité numérique sûre et privée.',
      'createAccount': 'Créer un compte',
      'signIn': 'Se connecter',
      'termsAgree':
          'En continuant, vous acceptez nos Conditions et notre Politique de confidentialité',
      'featIdVerified': 'ID Vérifié',
      'featFaceMatch': 'Reconnaissance faciale',
      'featEncrypted': 'Chiffré',

      // ── Login ──────────────────────────────────────────────
      'welcomeBack': 'Bon\nretour ',
      'loginSubtitle': 'Connectez-vous à votre compte NovaGard',
      'emailOrPhone': 'Email ou téléphone',
      'password': 'Mot de passe',
      'forgotPassword': 'Mot de passe oublié ?',
      'dontHaveAccount': "Vous n'avez pas de compte ? ",
      'createOne': 'Créer un',
      'required': 'Obligatoire',

      // ── Register ──────────────────────────────────────────────
      'createAccountTitle': 'Créer\nun compte',
      'registerSubtitle': 'Rejoignez NovaGard et vérifiez votre identité',
      'personalInfo': 'Infos personnelles',
      'firstName': 'Prénom',
      'lastName': 'Nom',
      'emailAddress': 'Adresse email',
      'phone': 'Téléphone (ex. +1234567890)',
      'confirmPassword': 'Confirmer le mot de passe',
      'min8chars': 'Minimum 8 caractères',
      'passwordsNoMatch': 'Les mots de passe ne correspondent pas',
      'invalidEmail': 'Email invalide',
      'continueBtn': 'Continuer',
      'alreadyHaveAccount': 'Vous avez déjà un compte ? ',
      'stepOf': 'Étape {current} sur {total} – {label}',

      // ── MFA ──────────────────────────────────────────────
      'twoFactorTitle': 'Vérification\nà deux facteurs',
      'subtitleTotp':
          "Entrez le code à 6 chiffres de votre application d'authentification.",
      'subtitleEmail':
          'Un code à 6 chiffres a été envoyé à votre adresse email.',
      'subtitleSms':
          'Un code à 6 chiffres a été envoyé à votre numéro de téléphone.',
      'chooseMethod': 'Choisir la méthode',
      'methodAuthenticator': 'Authentificateur',
      'methodEmail': 'Email',
      'methodSms': 'SMS',
      'verificationCode': 'Code de vérification',
      'verify': 'Vérifier',
      'resendCode': 'Renvoyer le code',
      'enterCode': 'Veuillez entrer le code.',
      'codeSentEmail': 'Code envoyé à votre email.',
      'codeSentPhone': 'Code envoyé à votre téléphone.',
      'failedSendCode':
          'Échec de l\'envoi du code. Veuillez réessayer.',

      // ── Forgot Password ──────────────────────────────────────────────
      'resetPasswordTitle': 'Réinitialiser\nle mot de passe',
      'resetPasswordSubtitle':
          "Entrez votre adresse email et nous vous enverrons un lien pour réinitialiser votre mot de passe.",
      'sendResetLink': 'Envoyer le lien',
      'backToSignIn': 'Retour à la connexion',
      'checkEmail': 'Vérifiez votre email',
      'checkEmailBody': 'Nous avons envoyé un lien de réinitialisation à\n{email}',
      'resendEmail': "Renvoyer l'email",
      'enterValidEmail': 'Entrez un email valide',
      'somethingWentWrong': 'Quelque chose s\'est mal passé. Veuillez réessayer.',
      'networkError': 'Erreur réseau. Veuillez réessayer.',

      // ── Document Type ──────────────────────────────────────────────
      'verifyYourIdentity': 'Vérifiez votre\nidentité',
      'docTypeSubtitle':
          "Nous devons vérifier qui vous êtes. Veuillez choisir votre type de document d'identité pour continuer.",
      'nationalIdCard': "Carte nationale d'identité",
      'frontBackRequired': 'Recto et verso requis',
      'passport': 'Passeport',
      'photoPageOnly': 'Page photo uniquement',
      'stepDocType': 'Étape 2 sur 3 – Type de document',
      'securityNote':
          'Vos documents sont chiffrés et stockés en toute sécurité. Nous ne vendons jamais vos données.',

      // ── Review ──────────────────────────────────────────────
      'reviewAndSubmit': 'Vérifier et soumettre',
      'almostThere': 'Presque là ! Vérifiez vos documents avant de soumettre.',
      'documents': 'Documents',
      'selfie': 'Selfie',
      'submitForVerification': 'Soumettre pour vérification',
      'front': 'Recto',
      'back': 'Verso',
      'photoPage': 'Page photo',
      'textVisible': 'Tout le texte est clairement visible',
      'noBlurry': 'Pas d\'images floues ou rognées',
      'selfieMatches': 'Le selfie correspond à la photo du document',

      // ── Verification Pending ──────────────────────────────────────────────
      'verificationInProgress': 'Vérification\nen cours',
      'pendingSubtitle':
          "Notre équipe examine vos documents d'identité. Cela prend généralement 5 à 10 minutes.",
      'submittedDocs': 'Documents soumis',
      'identityReview': "Examen de l'identité",
      'verificationComplete': 'Vérification terminée',
      'checkStatus': 'Vérifier le statut',
      'checking': 'Vérification...',
      'signOut': 'Se déconnecter',

      // ── Home ──────────────────────────────────────────────
      'helloName': 'Bonjour, {name}',
      'welcomeBackHome': 'Bon retour !',
      'identityVerified': 'Identité vérifiée',
      'verificationPending': 'Vérification en attente',
      'notVerified': 'Non vérifié',
      'loading': 'Chargement...',
      'fullyVerified': 'Votre compte est entièrement vérifié et sécurisé',
      'verificationInProgressCard': 'Vérification en cours',
      'teamReviewing': 'Notre équipe examine vos documents',
      'view': 'Voir',
      'verificationRejected': 'Vérification rejetée',
      'resubmitDocs': 'Veuillez soumettre à nouveau vos documents',
      'retry': 'Réessayer',
      'submitDocsVerify': 'Soumettez vos documents pour vérifier votre identité',
      'start': 'Commencer',
      'biometrics': 'Biométrie',
      'enrolled': 'Inscrit',
      'notSet': 'Non configuré',
      'mfa': 'MFA',
      'mfaEnabled': 'Activé',
      'mfaDisabled': 'Désactivé',
      'recentActivity': 'Activité récente',
      'yourServices': 'Vos services',
      'myIdCard': 'Ma carte',
      'myDevices': 'Mes appareils',
      'security': 'Sécurité',
      'activity': 'Activité',
      'settings': 'Paramètres',
      'minutesAgo': 'il y a {m} min',
      'hoursAgo': 'il y a {h} h',
      'daysAgo': 'il y a {d} j',

      // ── Settings sheet ──────────────────────────────────────────────
      'appearance': 'Apparence',
      'language': 'Langue',
      'theme': 'Thème',
      'darkTheme': 'Sombre',
      'lightTheme': 'Clair',
    },

    'ar': {
      // ── Welcome ──────────────────────────────────────────────
      'welcomeTagline': 'هويتك،\nبأمان.',
      'welcomeSubtitle':
          'تحقق مرة واحدة، ادخل في كل مكان.\nيحافظ NovaGard على هويتك الرقمية آمنة وخاصة.',
      'createAccount': 'إنشاء حساب',
      'signIn': 'تسجيل الدخول',
      'termsAgree': 'بالمتابعة، توافق على شروطنا وسياسة الخصوصية',
      'featIdVerified': 'هوية محققة',
      'featFaceMatch': 'مطابقة الوجه',
      'featEncrypted': 'مشفر',

      // ── Login ──────────────────────────────────────────────
      'welcomeBack': 'مرحباً\nبعودتك ',
      'loginSubtitle': 'سجّل الدخول إلى حسابك في NovaGard',
      'emailOrPhone': 'البريد أو الهاتف',
      'password': 'كلمة المرور',
      'forgotPassword': 'نسيت كلمة المرور؟',
      'dontHaveAccount': 'ليس لديك حساب؟ ',
      'createOne': 'أنشئ واحداً',
      'required': 'مطلوب',

      // ── Register ──────────────────────────────────────────────
      'createAccountTitle': 'إنشاء\nحساب',
      'registerSubtitle': 'انضم إلى NovaGard وتحقق من هويتك',
      'personalInfo': 'المعلومات الشخصية',
      'firstName': 'الاسم الأول',
      'lastName': 'الاسم الأخير',
      'emailAddress': 'البريد الإلكتروني',
      'phone': 'الهاتف (مثل +1234567890)',
      'confirmPassword': 'تأكيد كلمة المرور',
      'min8chars': '8 أحرف على الأقل',
      'passwordsNoMatch': 'كلمتا المرور غير متطابقتين',
      'invalidEmail': 'بريد إلكتروني غير صالح',
      'continueBtn': 'متابعة',
      'alreadyHaveAccount': 'لديك حساب بالفعل؟ ',
      'stepOf': 'الخطوة {current} من {total} – {label}',

      // ── MFA ──────────────────────────────────────────────
      'twoFactorTitle': 'التحقق\nبعاملين',
      'subtitleTotp':
          'أدخل الرمز المكون من 6 أرقام من تطبيق المصادقة الخاص بك.',
      'subtitleEmail':
          'تم إرسال رمز مكون من 6 أرقام إلى عنوان بريدك الإلكتروني.',
      'subtitleSms': 'تم إرسال رمز مكون من 6 أرقام إلى رقم هاتفك.',
      'chooseMethod': 'اختر الطريقة',
      'methodAuthenticator': 'تطبيق المصادقة',
      'methodEmail': 'البريد',
      'methodSms': 'رسالة نصية',
      'verificationCode': 'رمز التحقق',
      'verify': 'تحقق',
      'resendCode': 'إعادة إرسال الرمز',
      'enterCode': 'يرجى إدخال الرمز.',
      'codeSentEmail': 'تم إرسال الرمز إلى بريدك.',
      'codeSentPhone': 'تم إرسال الرمز إلى هاتفك.',
      'failedSendCode': 'فشل إرسال الرمز. يرجى المحاولة مرة أخرى.',

      // ── Forgot Password ──────────────────────────────────────────────
      'resetPasswordTitle': 'إعادة تعيين\nكلمة المرور',
      'resetPasswordSubtitle':
          'أدخل بريدك الإلكتروني وسنرسل لك رابطاً لإعادة تعيين كلمة المرور.',
      'sendResetLink': 'إرسال الرابط',
      'backToSignIn': 'العودة لتسجيل الدخول',
      'checkEmail': 'تحقق من بريدك',
      'checkEmailBody': 'أرسلنا رابط إعادة تعيين إلى\n{email}',
      'resendEmail': 'إعادة إرسال البريد',
      'enterValidEmail': 'أدخل بريداً إلكترونياً صالحاً',
      'somethingWentWrong': 'حدث خطأ ما. يرجى المحاولة مرة أخرى.',
      'networkError': 'خطأ في الشبكة. يرجى المحاولة مرة أخرى.',

      // ── Document Type ──────────────────────────────────────────────
      'verifyYourIdentity': 'تحقق من\nهويتك',
      'docTypeSubtitle':
          'نحتاج إلى التحقق من هويتك. يرجى اختيار نوع وثيقة الهوية للمتابعة.',
      'nationalIdCard': 'بطاقة الهوية الوطنية',
      'frontBackRequired': 'الوجه والظهر مطلوبان',
      'passport': 'جواز السفر',
      'photoPageOnly': 'صفحة الصورة فقط',
      'stepDocType': 'الخطوة 2 من 3 – نوع الوثيقة',
      'securityNote':
          'وثائقك مشفرة ومخزنة بأمان. لن نبيع بياناتك أبداً.',

      // ── Review ──────────────────────────────────────────────
      'reviewAndSubmit': 'مراجعة وإرسال',
      'almostThere': 'أوشكت على الانتهاء! راجع وثائقك قبل الإرسال.',
      'documents': 'الوثائق',
      'selfie': 'صورة شخصية',
      'submitForVerification': 'إرسال للتحقق',
      'front': 'الوجه',
      'back': 'الظهر',
      'photoPage': 'صفحة الصورة',
      'textVisible': 'كل النص مرئي بوضوح',
      'noBlurry': 'لا صور ضبابية أو مقصوصة',
      'selfieMatches': 'الصورة الشخصية تطابق صورة الوثيقة',

      // ── Verification Pending ──────────────────────────────────────────────
      'verificationInProgress': 'التحقق\nجارٍ',
      'pendingSubtitle':
          'فريقنا يراجع وثائق هويتك. يستغرق هذا عادةً 5-10 دقائق.',
      'submittedDocs': 'تم رفع الوثائق',
      'identityReview': 'مراجعة الهوية',
      'verificationComplete': 'اكتملت عملية التحقق',
      'checkStatus': 'تحقق من الحالة',
      'checking': 'جارٍ التحقق...',
      'signOut': 'تسجيل الخروج',

      // ── Home ──────────────────────────────────────────────
      'helloName': 'مرحباً، {name}',
      'welcomeBackHome': 'مرحباً بعودتك!',
      'identityVerified': 'الهوية محققة',
      'verificationPending': 'التحقق معلق',
      'notVerified': 'غير محقق',
      'loading': 'جارٍ التحميل...',
      'fullyVerified': 'حسابك محقق بالكامل وآمن',
      'verificationInProgressCard': 'التحقق جارٍ',
      'teamReviewing': 'فريقنا يراجع وثائقك',
      'view': 'عرض',
      'verificationRejected': 'رُفض التحقق',
      'resubmitDocs': 'يرجى إعادة رفع وثائقك',
      'retry': 'إعادة المحاولة',
      'submitDocsVerify': 'ارفع وثائقك للتحقق من هويتك',
      'start': 'ابدأ',
      'biometrics': 'القياسات الحيوية',
      'enrolled': 'مسجّل',
      'notSet': 'غير مضبوط',
      'mfa': 'المصادقة الثنائية',
      'mfaEnabled': 'مفعّل',
      'mfaDisabled': 'معطّل',
      'recentActivity': 'النشاط الأخير',
      'yourServices': 'خدماتك',
      'myIdCard': 'بطاقتي',
      'myDevices': 'أجهزتي',
      'security': 'الأمان',
      'activity': 'النشاط',
      'settings': 'الإعدادات',
      'minutesAgo': 'منذ {m} د',
      'hoursAgo': 'منذ {h} س',
      'daysAgo': 'منذ {d} ي',

      // ── Settings sheet ──────────────────────────────────────────────
      'appearance': 'المظهر',
      'language': 'اللغة',
      'theme': 'السمة',
      'darkTheme': 'داكن',
      'lightTheme': 'فاتح',
    },
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['fr', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
