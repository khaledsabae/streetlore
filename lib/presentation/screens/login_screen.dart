import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/animations/app_animations.dart';
import '../../core/config/app_config.dart';
import '../../core/constants/app_colors.dart';
import '../../l10n/app_strings.dart';
import '../../logic/auth_provider.dart';
import '../widgets/compass_brand.dart';
import 'main_navigation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _usernameFocus = FocusNode();
  bool _isLoading = false;
  bool _isSignUp = false;
  bool _obscurePassword = true;
  String? _focusedField;

  late final AnimationController _animCtrl;
  late final Animation<double> _bgBlob1;
  late final Animation<double> _bgBlob2;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
    _bgBlob1 = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.linear));
    _bgBlob2 = Tween<double>(
      begin: 0.5,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.linear));
    _emailFocus.addListener(
      () =>
          setState(() => _focusedField = _emailFocus.hasFocus ? 'email' : null),
    );
    _passwordFocus.addListener(
      () => setState(
        () => _focusedField = _passwordFocus.hasFocus ? 'password' : null,
      ),
    );
    _usernameFocus.addListener(
      () => setState(
        () => _focusedField = _usernameFocus.hasFocus ? 'username' : null,
      ),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _usernameCtrl.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _usernameFocus.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    final errorKey = await context.read<AuthProvider>().signIn(
      email: _emailCtrl.text,
      password: _passwordCtrl.text,
      username: _usernameCtrl.text,
      isSignUp: _isSignUp,
    );

    if (!mounted) return;
    if (errorKey != null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_authErrorMessage(errorKey)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    _goToMain();
  }

  String _authErrorMessage(String key) {
    switch (key) {
      case 'account_exists':
        return context.tr('login_err_account_exists');
      case 'no_account':
        return context.tr('login_err_no_account');
      case 'wrong_password':
        return context.tr('login_err_wrong_password');
      case 'password_too_short':
        return context.tr('login_err_password_short');
      case 'network_error':
        return context.tr('google_network_error');
      default:
        return context.tr('login_err_unknown');
    }
  }

  
  

  void _goToMain() {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (ctx, a, second) => const MainNavigation(),
        transitionDuration: const Duration(milliseconds: 550),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        transitionsBuilder: (ctx, a, second, child) =>
            PageTransitions.fadeScale(ctx, a, second, child),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      body: Stack(
        children: [
          if (!context.isDark)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _animCtrl,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _BlobPainter(
                        phase: _bgBlob1.value,
                        phase2: _bgBlob2.value,
                      ),
                    );
                  },
                ),
              ),
            ),
          SafeArea(
            child: SingleChildScrollView(
              clipBehavior: Clip.none,
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),

                    Center(
                      child: PopIn(
                        duration: const Duration(milliseconds: 700),
                        child: const CompassBrandIntro(
                          size: 220,
                          totalDuration: Duration(milliseconds: 4200),
                          loop: false,
                          spinCompass: true,
                          compassSpinDuration: Duration(seconds: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      child: Text(
                        context.tr('login_welcome'),
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: context.textPri,
                          height: 1.15,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    FadeInUp(
                      delay: const Duration(milliseconds: 280),
                      child: Text(
                        context.tr('login_subtitle'),
                        style: TextStyle(
                          fontSize: 15,
                          color: context.textSec,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          FadeInUp(
                            delay: const Duration(milliseconds: 360),
                            child: _InputField(
                              controller: _emailCtrl,
                              focusNode: _emailFocus,
                              isFocused: _focusedField == 'email',
                              label: context.tr('login_email'),
                              hint: context.tr('login_email_hint'),
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return context.tr('login_err_email');
                                }
                                if (!v.contains('@')) {
                                  return context.tr('login_err_email_invalid');
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          
                          
                          
                          if (_isSignUp) ...[
                            FadeInUp(
                              delay: const Duration(milliseconds: 420),
                              child: _InputField(
                                controller: _usernameCtrl,
                                focusNode: _usernameFocus,
                                isFocused: _focusedField == 'username',
                                label: context.tr('login_username'),
                                hint: context.tr('login_username_hint'),
                                icon: Icons.alternate_email_rounded,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                autocorrect: false,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return context.tr('login_err_username_empty');
                                  }
                                  final u = v.trim();
                                  if (u.length < 3 || u.length > 20) {
                                    return context.tr('login_err_username_length');
                                  }
                                  if (!RegExp(r'^[A-Za-z0-9._-]+$')
                                      .hasMatch(u)) {
                                    return context.tr('login_err_username_chars');
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          FadeInUp(
                            delay: const Duration(milliseconds: 480),
                            child: _InputField(
                              controller: _passwordCtrl,
                              focusNode: _passwordFocus,
                              isFocused: _focusedField == 'password',
                              label: context.tr('login_password'),
                              hint: _isSignUp
                                  ? context.tr('login_password_hint_signup')
                                  : context.tr('login_password_hint'),
                              icon: Icons.lock_outline_rounded,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  size: 20,
                                  color: context.textSec,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                              validator: (v) {
                                if (!_isSignUp) return null;
                                if (v == null || v.length < 8) {
                                  return context.tr('login_err_password_short');
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 14),
                          FadeInUp(
                            delay: const Duration(milliseconds: 510),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _isSignUp
                                      ? context.tr('login_have_account')
                                      : context.tr('login_no_account'),
                                  style: TextStyle(
                                    color: context.textSec,
                                    fontSize: 13,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      setState(() => _isSignUp = !_isSignUp),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    _isSignUp
                                        ? context.tr('login_sign_in')
                                        : context.tr('login_sign_up'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          FadeInUp(
                            delay: const Duration(milliseconds: 520),
                            child: _GradientButton(
                              isLoading: _isLoading,
                              onTap: _signIn,
                              label: _isSignUp
                                  ? context.tr('login_sign_up')
                                  : context.tr('login_sign_in'),
                              icon: _isSignUp
                                  ? Icons.person_add_rounded
                                  : Icons.login_rounded,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeInUp(
                      delay: const Duration(milliseconds: 600),
                      child: Row(
                        children: [
                          Expanded(child: Divider(color: context.borderColor)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              context.tr('login_or'),
                              style: TextStyle(
                                color: context.textSec,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: context.borderColor)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeInUp(
                      delay: const Duration(milliseconds: 660),
                      child: Row(
                        children: [
                          Expanded(
                            child: _SocialButton(
                              label: context.tr('login_google'),
                              icon: Icons.g_mobiledata_rounded,
                              color: const Color(0xFFEA4335),
                              onTap: () async {
                                final messenger = ScaffoldMessenger.of(context);
                                final auth = context.read<AuthProvider>();
                                if (!AppConfig.supabaseEnabled) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        context.tr('login_google_unavailable'),
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  return;
                                }

                                if (auth.isLoggedIn) {
                                  _goToMain();
                                  return;
                                }

                                setState(() => _isLoading = true);
                                HapticFeedback.lightImpact();

                                try {
                                  if (kIsWeb) {
                                    final redirectTo = kReleaseMode
                                        ? AppConfig.webRedirectUrl
                                        : Uri.base.origin;
                                    await Supabase.instance.client.auth
                                        .signInWithOAuth(
                                          OAuthProvider.google,
                                          redirectTo: redirectTo,
                                          authScreenLaunchMode:
                                              LaunchMode.platformDefault,
                                        )
                                        .timeout(const Duration(minutes: 2));

                                    if (auth.isLoggedIn && mounted) {
                                      _goToMain();
                                    }
                                  } else {
                                    final errorKey = await auth.signInWithGoogleNative();
                                    if (!context.mounted) return;
                                    if (errorKey != null) {
                                      if (errorKey == 'cancelled') {
                                        setState(() => _isLoading = false);
                                        return;
                                      }
                                      String errMsg;
                                      if (errorKey == 'sha1_mismatch') {
                                        errMsg = context.tr('google_sha1_error');
                                      } else if (errorKey == 'config_error') {
                                        errMsg = context.tr('google_config_error');
                                      } else if (errorKey == 'network_error') {
                                        errMsg = context.tr('google_network_error');
                                      } else {
                                        errMsg = context.tr('google_general_error');
                                      }
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text(errMsg),
                                          backgroundColor: AppColors.error,
                                        ),
                                      );
                                      setState(() => _isLoading = false);
                                      return;
                                    }
                                    if (mounted) {
                                      _goToMain();
                                    }
                                  }
                                } on TimeoutException {
                                  if (!context.mounted) return;
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        context.tr('login_google_timeout'),
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                } catch (e, st) {
                                  debugPrint('Google sign-in error: $e');
                                  debugPrint('Stack: $st');
                                  if (!context.mounted) return;

                                  final errorStr = e.toString().toLowerCase();
                                  String message;
                                  bool showDetails = false;

                                  if (errorStr.contains('api exception: 10') ||
                                      errorStr.contains('developer_error') ||
                                      errorStr.contains('10:')) {
                                    message =
                                        'Google sign-in failed (code 10).\n'
                                        'Likely cause: SHA-1 fingerprint mismatch.\n'
                                        'Add this Android debug SHA-1 to Google Cloud Console '
                                        'OAuth client for com.example.streetlore.';
                                    showDetails = true;
                                  } else if (errorStr.contains('network') ||
                                      errorStr.contains('socket') ||
                                      errorStr.contains('timeout')) {
                                    message = context.tr(
                                      'login_google_timeout',
                                    );
                                  } else if (errorStr.contains('platform') ||
                                      errorStr.contains('sign_in_failed')) {
                                    message =
                                        'Google sign-in failed (Platform).\n'
                                        'Check that io.supabase.streetlore://login-callback/ '
                                        'is registered as a redirect URL in your Supabase project.';
                                    showDetails = true;
                                  } else {
                                    message = context.tr('login_google_failed');
                                    showDetails = true;
                                  }

                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(message),
                                          if (showDetails)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 6,
                                              ),
                                              child: Text(
                                                e.toString(),
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.white70,
                                                  fontFamily: 'monospace',
                                                ),
                                                maxLines: 4,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                        ],
                                      ),
                                      backgroundColor: AppColors.error,
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(seconds: 8),
                                    ),
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() => _isLoading = false);
                                  }
                                }
                              },
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
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool isFocused;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool autocorrect;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _InputField({
    required this.controller,
    this.focusNode,
    this.isFocused = false,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.autocorrect = true,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        autocorrect: autocorrect,
        obscureText: obscureText,
        style: TextStyle(
          color: context.textPri,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(color: context.textSec, fontSize: 14),
          hintStyle: TextStyle(color: context.hintColor, fontSize: 14),
          prefixIcon: AnimatedScale(
            scale: isFocused ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              icon,
              color: isFocused ? AppColors.primary : context.textSec,
              size: 20,
            ),
          ),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: context.cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: context.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: context.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
        ),
        validator: validator,
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;
  final String label;
  final IconData icon;

  const _GradientButton({
    required this.isLoading,
    required this.onTap,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: isLoading ? null : onTap,
      pressedScale: 0.97,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: isLoading
              ? const LinearGradient(
                  colors: [Color(0xFF64748B), Color(0xFF475569)],
                )
              : AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isLoading
              ? []
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      pressedScale: 0.96,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: context.textPri,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlobPainter extends CustomPainter {
  final double phase;
  final double phase2;
  _BlobPainter({required this.phase, required this.phase2});

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..shader =
          RadialGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.18),
              AppColors.primary.withValues(alpha: 0.0),
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(
                size.width * (0.2 + 0.15 * _wave(phase)),
                size.height * (0.25 + 0.1 * _wave(phase + 0.3)),
              ),
              radius: 200,
            ),
          );
    canvas.drawCircle(
      Offset(
        size.width * (0.2 + 0.15 * _wave(phase)),
        size.height * (0.25 + 0.1 * _wave(phase + 0.3)),
      ),
      200,
      paint1,
    );

    final paint2 = Paint()
      ..shader =
          RadialGradient(
            colors: [
              AppColors.accent.withValues(alpha: 0.16),
              AppColors.accent.withValues(alpha: 0.0),
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(
                size.width * (0.85 - 0.1 * _wave(phase2)),
                size.height * (0.7 - 0.05 * _wave(phase2 + 0.5)),
              ),
              radius: 240,
            ),
          );
    canvas.drawCircle(
      Offset(
        size.width * (0.85 - 0.1 * _wave(phase2)),
        size.height * (0.7 - 0.05 * _wave(phase2 + 0.5)),
      ),
      240,
      paint2,
    );

    final paint3 = Paint()
      ..shader =
          RadialGradient(
            colors: [
              AppColors.success.withValues(alpha: 0.10),
              AppColors.success.withValues(alpha: 0.0),
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(
                size.width * (0.5 + 0.2 * _wave(phase2 + 0.7)),
                size.height * (1.1 - 0.2 * _wave(phase + 0.2)),
              ),
              radius: 280,
            ),
          );
    canvas.drawCircle(
      Offset(
        size.width * (0.5 + 0.2 * _wave(phase2 + 0.7)),
        size.height * (1.1 - 0.2 * _wave(phase + 0.2)),
      ),
      280,
      paint3,
    );
  }

  double _wave(double t) {
    return 0.5 - 0.5 * (1 - t % 1) * 2 + (t % 1) * 2 - 1;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
