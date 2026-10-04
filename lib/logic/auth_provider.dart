import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../core/config/app_config.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _hasSeenOnboarding = false;
  bool _isLoading = true;
  String _userName = '';
  String _username = '';
  String _userEmail = '';
  String _userId = '';
  bool _isGuest = false;

  bool get isLoggedIn => _isLoggedIn;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
  bool get isLoading => _isLoading;
  String get userName => _userName;
  String get username => _username;
  String get userEmail => _userEmail;
  String get userId => _userId;
  bool get isGuest => _isGuest;

  
  
  
  
  
  
  
  
  
  
  
  bool get isAdmin {
    final email = _userEmail.toLowerCase().trim();
    if (email.isEmpty) return false;
    if (_adminEmails.contains(email)) return true;
    if (email.contains('mohamedsabae50')) return true;
    
    
    
    return false;
  }

  static const Set<String> _adminEmails = {
    'mohamedsabae50-prog@users.noreply.github.com',
  };

  String get currentUserId => _userId.isEmpty ? 'guest' : _userId;

  bool owns(String? ownerId) =>
      ownerId == null ||
      ownerId.isEmpty ||
      ownerId == 'me' ||
      ownerId == currentUserId;

  AuthProvider() {
    if (AppConfig.supabaseEnabled) {
      Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        final event = data.event;
        if (event == AuthChangeEvent.signedIn ||
            event == AuthChangeEvent.tokenRefreshed) {
          
          
          
          unawaited(_syncFromSupabase());
        } else if (event == AuthChangeEvent.signedOut) {
          _isLoggedIn = false;
          _isGuest = false;
          notifyListeners();
          unawaited(_clearPersistedAuthSnapshot());
        }
      });
    }
  }

  Future<void> _clearPersistedAuthSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('sb_access_token');
    await prefs.remove('sb_refresh_token');
    await prefs.remove('sb_expires_at_ms');
    await prefs.setBool('is_logged_in', false);
    await prefs.setBool('is_guest', false);
  }

  Future<void> bootstrap() => _load();

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

    if (AppConfig.supabaseEnabled) {
      
      
      
      
      
      Session? session = Supabase.instance.client.auth.currentSession;
      session ??= await _tryRefresh();
      session ??= await _waitForInitialSession();
      if (session == null) {
        final restored = await restoreFromPrefsSnapshot();
        if (restored) {
          session = Supabase.instance.client.auth.currentSession;
        }
      }
      if (session?.user != null) {
        await _syncFromSupabase();
        _isLoading = false;
        notifyListeners();
        return;
      }
    }

    _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    _isGuest = prefs.getBool('is_guest') ?? false;
    _userName = prefs.getString('user_name') ?? '';
    _username = prefs.getString('user_username') ?? '';
    _userEmail = prefs.getString('user_email') ?? '';
    _userId = prefs.getString('user_id') ?? '';
    _isLoading = false;
    notifyListeners();
  }

  Future<Session?> _tryRefresh() async {
    try {
      final r = await Supabase.instance.client.auth.refreshSession();
      return r.session;
    } catch (e) {
      debugPrint('AuthProvider._tryRefresh: $e');
      return null;
    }
  }

  Future<Session?> _waitForInitialSession() async {
    final client = Supabase.instance.client.auth;
    final completer = Completer<Session?>();
    late StreamSubscription<AuthState> sub;
    sub = client.onAuthStateChange.listen((state) {
      if (state.event == AuthChangeEvent.initialSession ||
          state.event == AuthChangeEvent.signedIn) {
        if (!completer.isCompleted) {
          completer.complete(state.session);
        }
        unawaited(sub.cancel());
      }
    });
    try {
      return await completer.future.timeout(const Duration(seconds: 5));
    } on TimeoutException {
      if (!completer.isCompleted) completer.complete(null);
      await sub.cancel();
      return null;
    } catch (e) {
      debugPrint('AuthProvider._waitForInitialSession: $e');
      await sub.cancel();
      return null;
    }
  }

  
  
  Future<void> _syncFromSupabase() async {
    final client = Supabase.instance.client.auth;
    final user = client.currentUser;
    final session = client.currentSession;
    if (user == null) return;
    _isLoggedIn = true;
    _isGuest = false;
    _userId = user.id;
    final meta = user.userMetadata ?? const <String, dynamic>{};
    _userName =
        (meta['full_name'] as String?) ??
        (meta['name'] as String?) ??
        (user.email?.split('@').first) ??
        'Explorer';
    _username = (meta['username'] as String?) ?? _username;
    _userEmail = user.email ?? _userEmail;
    notifyListeners();
    await _persistAuthSnapshot(
      accessToken: session?.accessToken,
      refreshToken: session?.refreshToken,
      expiresAtUnixSeconds: session?.expiresAt,
    );
  }

  
  
  
  Future<bool> handleAuthCallback(Uri uri) async {
    if (!AppConfig.supabaseEnabled) return false;
    try {
      await Supabase.instance.client.auth.getSessionFromUrl(uri);
      return true;
    } catch (e) {
      debugPrint('AuthProvider: failed to exchange callback: $e');
      return false;
    }
  }

  Future<String?> signIn({
    String? name,
    String? username,
    required String email,
    required String password,
    required bool isSignUp,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password;
    
    
    
    
    
    
    final cleanUsername = username?.trim() ?? '';
    final cleanName =
        (name?.trim().isNotEmpty ?? false) ? name!.trim() : _emailLocalPart(cleanEmail);
    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      return 'invalid_email';
    }
    if (isSignUp) {
      if (cleanPassword.length < 6) {
        return 'password_too_short';
      }
      if (!_isValidUsername(cleanUsername)) {
        return 'username_invalid';
      }
    }

    
    
    if (AppConfig.supabaseEnabled) {
      try {
        if (isSignUp) {
          await Supabase.instance.client.auth.signUp(
            email: cleanEmail,
            password: cleanPassword,
            data: {
              'full_name': cleanName,
              'username': cleanUsername,
            },
          );
        }
        final res = await Supabase.instance.client.auth
            .signInWithPassword(email: cleanEmail, password: cleanPassword);
        if (res.user != null) {
          _isLoggedIn = true;
          _isGuest = false;
          _userId = res.user!.id;
          _userEmail = res.user!.email ?? cleanEmail;
          final meta = res.user!.userMetadata ?? const <String, dynamic>{};
          _userName =
              (meta['full_name'] as String?) ?? cleanName;
          _username =
              (meta['username'] as String?) ?? cleanUsername;
          await _persistAuthSnapshot(
            accessToken: res.session?.accessToken,
            refreshToken: res.session?.refreshToken,
            expiresAtUnixSeconds: res.session?.expiresAt,
          );
          notifyListeners();
          return null;
        }
        return 'auth_failed';
      } on AuthException catch (e) {
        
        final msg = e.message.toLowerCase();
        if (isSignUp && msg.contains('already registered')) {
          return 'account_exists';
        }
        if (!isSignUp && msg.contains('invalid login')) {
          return 'wrong_password';
        }
        if (msg.contains('email not confirmed')) {
          return 'email_not_confirmed';
        }
        if (msg.contains('rate limit')) {
          return 'rate_limited';
        }
        debugPrint('AuthProvider.signIn error: ${e.message}');
        return 'auth_failed';
      } catch (e) {
        debugPrint('AuthProvider.signIn unexpected: $e');
        
      }
    }

    
    
    final prefs = await SharedPreferences.getInstance();

    if (isSignUp) {
      final existing = prefs.getString('user_email_${cleanEmail}_password');
      if (existing != null) {
        return 'account_exists';
      }
      await prefs.setString('user_email_${cleanEmail}_name', cleanName);
      await prefs.setString('user_email_${cleanEmail}_password', cleanPassword);
    } else {
      final stored = prefs.getString('user_email_${cleanEmail}_password');
      if (stored == null) {
        return 'no_account';
      }
      if (stored != cleanPassword) {
        return 'wrong_password';
      }
    }

    _isLoggedIn = true;
    _isGuest = false;
    _userName = cleanName;
    _username = cleanUsername;
    _userEmail = cleanEmail;
    if (_userId.isEmpty) {
      _userId = const Uuid().v4();
    }
    notifyListeners();
    await prefs.setBool('is_logged_in', true);
    await prefs.setBool('is_guest', false);
    await prefs.setString('user_name', _userName);
    await prefs.setString('user_username', _username);
    await prefs.setString('user_email', _userEmail);
    await prefs.setString('user_id', _userId);
    return null;
  }

  
  
  
  bool _isValidUsername(String u) {
    if (u.length < 3 || u.length > 20) return false;
    if (u.startsWith('.') || u.startsWith('-') || u.startsWith('_')) {
      return false;
    }
    return RegExp(r'^[A-Za-z0-9._-]+$').hasMatch(u);
  }

  
  String _emailLocalPart(String email) {
    final at = email.indexOf('@');
    if (at <= 0) return 'Explorer';
    final local = email.substring(0, at);
    
    final cleaned = local.replaceAll(RegExp(r'[._\-+]'), ' ').trim();
    if (cleaned.isEmpty) return 'Explorer';
    return cleaned
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .map((s) => s[0].toUpperCase() + s.substring(1))
        .join(' ');
  }

  
  
  
  
  Future<void> _persistAuthSnapshot({
    String? accessToken,
    String? refreshToken,
    int? expiresAtUnixSeconds,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (accessToken != null && accessToken.isNotEmpty) {
      await prefs.setString('sb_access_token', accessToken);
    }
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await prefs.setString('sb_refresh_token', refreshToken);
    }
    if (expiresAtUnixSeconds != null) {
      await prefs.setInt('sb_expires_at_s', expiresAtUnixSeconds);
    }
    await prefs.setBool('is_logged_in', true);
    await prefs.setBool('is_guest', false);
    await prefs.setString('user_name', _userName);
    await prefs.setString('user_username', _username);
    await prefs.setString('user_email', _userEmail);
    await prefs.setString('user_id', _userId);
  }

  
  
  Future<bool> restoreFromPrefsSnapshot() async {
    if (!AppConfig.supabaseEnabled) return false;
    final prefs = await SharedPreferences.getInstance();
    final access = prefs.getString('sb_access_token');
    final refresh = prefs.getString('sb_refresh_token');
    if (access == null || refresh == null) return false;
    try {
      final res = await Supabase.instance.client.auth
          .setSession(access); 
      
      return res.session != null;
    } catch (e) {
      debugPrint('AuthProvider.restoreFromPrefsSnapshot: $e');
      return false;
    }
  }

  Future<void> signInAsGuest(String name) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return;
    _isLoggedIn = true;
    _isGuest = true;
    _userName = cleanName;
    _username = '';
    _userEmail = 'guest@streetlore.com';
    if (_userId.isEmpty) {
      _userId = const Uuid().v4();
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setBool('is_guest', true);
    await prefs.setString('user_name', _userName);
    await prefs.setString('user_username', _username);
    await prefs.setString('user_email', _userEmail);
    await prefs.setString('user_id', _userId);
  }

  Future<void> updateGuestName(String newName) async {
    if (newName.trim().isEmpty) return;
    _userName = newName.trim();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _userName);
  }

  Future<void> signOut() async {
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    
    
    _isLoggedIn = false;
    _isGuest = false;
    _userId = '';
    _userName = '';
    _username = '';
    _userEmail = '';
    notifyListeners();

    
    if (AppConfig.supabaseEnabled) {
      try {
        await Supabase.instance.client.auth.signOut();
      } catch (e) {
        debugPrint('AuthProvider.signOut: Supabase signOut failed: $e');
      }
    }

    
    
    
    
    try {
      const secure = FlutterSecureStorage(
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
          resetOnError: true,
        ),
      );
      
      const knownKeys = <String>[
        'supabase_access_token',
        'supabase_refresh_token',
        'supabase_session_data',
        'sb_access_token',
        'sb_refresh_token',
        'sb-tbivoxyxclwjjspwsgvc-auth-token',
        'auth_token',
        'access_token',
        'refresh_token',
        'session',
      ];
      for (final k in knownKeys) {
        try {
          await secure.delete(key: k);
        } catch (_) {}
      }
      
      try {
        final all = await secure.readAll();
        for (final entry in all.entries) {
          try {
            await secure.delete(key: entry.key);
          } catch (_) {}
        }
      } catch (_) {}
    } catch (e) {
      debugPrint('AuthProvider.signOut: secure storage clear failed: $e');
    }

    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    await prefs.setBool('is_guest', false);
    await prefs.remove('user_name');
    await prefs.remove('user_username');
    await prefs.remove('user_email');
    await prefs.remove('user_id');
    await prefs.remove('sb_access_token');
    await prefs.remove('sb_refresh_token');
    await prefs.remove('sb_expires_at_s');
    await prefs.remove('sb_expires_at_ms');
    await prefs.remove('has_seen_onboarding');

    
    
    
    final hostFirstSegment =
        Uri.parse(AppConfig.supabaseUrl).host.split('.').first;
    await prefs.remove('sb-$hostFirstSegment-auth-token');
    for (final k in prefs.getKeys()) {
      if (k.startsWith('sb-')) {
        await prefs.remove(k);
      }
    }
  }

  
  
  Future<String?> signInWithGoogleNative() async {
    if (!AppConfig.supabaseEnabled) return 'supabase_disabled';
    
    
    
    
    
    debugPrint(
      'GoogleSignIn: serverClientId=504340157609-pj8ook9662299u613glititqn4dqa1jp (com.streetlore)',
    );
    try {
      final googleSignIn = GoogleSignIn(
        serverClientId:
            '504340157609-pj8ook9662299u613glititqn4dqa1jp.apps.googleusercontent.com',
        scopes: const ['email', 'profile'],
      );
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return 'cancelled';
      }
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        throw 'No ID Token found.';
      }

      await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: googleAuth.accessToken,
      );
      
      
      await _syncFromSupabase();
      return null;
    } catch (e, st) {
      debugPrint('=== GOOGLE SIGN-IN FAILED ===');
      debugPrint('Error type: ${e.runtimeType}');
      debugPrint('Error: $e');
      debugPrint('Stack: $st');
      
      final msg = e.toString();
      
      if (e is PlatformException) {
        debugPrint('PlatformException code: ${e.code}');
        debugPrint('PlatformException message: ${e.message}');
        debugPrint('PlatformException details: ${e.details}');
        
        if (e.code == 'sign_in_canceled' || e.code == '12501') {
          return 'cancelled';
        }
        if (e.code == '10') {
          debugPrint('CODE 10: SHA-1 fingerprint mismatch!');
          debugPrint('Your applicationId: com.streetlore.app');
          debugPrint('Check: Google Cloud Console > APIs > Credentials');
          debugPrint('Ensure SHA-1 fingerprint matches the release keystore');
          return 'sha1_mismatch';
        }
        if (e.code == '12500') {
          debugPrint('CODE 12500: Google Sign-In config error');
          debugPrint('Check: OAuth consent screen must be configured');
          return 'config_error';
        }
        if (e.code == '7') {
          return 'network_error';
        }
      }
      
      if (msg.contains('sign_in_canceled') || msg.contains('User canceled')) {
        return 'cancelled';
      }
      if (msg.contains('ApiException: 10')) {
        return 'sha1_mismatch';
      }
      
      return 'google_error';
    }
  }

  Future<void> completeOnboarding() async {
    _hasSeenOnboarding = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
  }
}
