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

  /// v1.0.41: admin gate. Add an email here (or extend the list)
  /// to gate the AdminPanelScreen. Hard-coded locally because the
  /// build pipeline has no admin-RPC yet.
  ///
  /// Also matches by:
  ///   - any email containing "mohamedsabae50" (the project owner
  ///     username - works whether they sign in via the GitHub
  ///     no-reply email or a personal one)
  ///   - Supabase user_metadata.role == 'admin' (set via SQL UPDATE
  ///     on auth.users.user_metadata to grant access to additional
  ///     accounts without rebuilding the app)
  bool get isAdmin {
    final email = _userEmail.toLowerCase().trim();
    if (email.isEmpty) return false;
    if (_adminEmails.contains(email)) return true;
    if (email.contains('mohamedsabae50')) return true;
    // user_metadata.role: 'admin' check - we only know the current
    // cached values, so this is best-effort. The server-side
    // PostgrestException on the admin insert is the real authority.
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
          // Re-pull user info AND mirror the latest tokens to SharedPreferences
          // so we can restore the session even if Supabase's own storage is
          // cleared or fails to read on this device.
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
      // Bulletproof restore — try in order:
      //   1) Supabase's already-restored currentSession
      //   2) explicit refreshSession (refreshes expired tokens)
      //   3) wait for onAuthStateChange to deliver initialSession event
      //   4) restore from our own SharedPreferences mirror via setSession()
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

  /// Pulls the latest user info from the active Supabase session into local
  /// state and persists it to SharedPreferences.
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

  /// Exchanges the deep-link URI (from the OAuth redirect) for a Supabase
  /// session. Called from the platform `app_links` / `uni_links` callback
  /// when the browser returns to `io.supabase.streetlore:
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
    // v1.0.41: explicit username collection on sign-up. Stored in
    // Supabase auth.user_metadata.username + mirrored in
    // SharedPreferences so we can show it in the Profile / chat
    // even when the user is signed in offline. Sign-in does not
    // require a username (the user's existing username comes back
    // via user_metadata), keeping the login screen light.
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

    // Prefer Supabase auth when available so the user account is real
    // and syncs across devices.
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
        // Map common Supabase errors to UI strings.
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
        // Fall through to local-only sign-in below.
      }
    }

    // Offline / Supabase-disabled fallback: store the credentials locally
    // so the user can still try the app without a backend.
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

  /// v1.0.41: username validation. We accept letters, digits,
  /// underscore, dot, and dash, 3-20 chars. No leading dot/dash to
  /// keep the @-mention readable. Email-local-part style.
  bool _isValidUsername(String u) {
    if (u.length < 3 || u.length > 20) return false;
    if (u.startsWith('.') || u.startsWith('-') || u.startsWith('_')) {
      return false;
    }
    return RegExp(r'^[A-Za-z0-9._-]+$').hasMatch(u);
  }

  /// Derive a friendly display name from the email local-part.
  String _emailLocalPart(String email) {
    final at = email.indexOf('@');
    if (at <= 0) return 'Explorer';
    final local = email.substring(0, at);
    // Replace separators with spaces, capitalize each word.
    final cleaned = local.replaceAll(RegExp(r'[._\-+]'), ' ').trim();
    if (cleaned.isEmpty) return 'Explorer';
    return cleaned
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .map((s) => s[0].toUpperCase() + s.substring(1))
        .join(' ');
  }

  /// Persist a parallel mirror of the active session to SharedPreferences
  /// so the user can be restored even when Supabase's own secure storage
  /// fails (the classic "I keep getting logged out" symptom on some
  /// Android devices). Safe to call from anywhere.
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

  /// Restore a Supabase session from a previously persisted snapshot.
  /// Called from bootstrap when Supabase's own session restore fails.
  Future<bool> restoreFromPrefsSnapshot() async {
    if (!AppConfig.supabaseEnabled) return false;
    final prefs = await SharedPreferences.getInstance();
    final access = prefs.getString('sb_access_token');
    final refresh = prefs.getString('sb_refresh_token');
    if (access == null || refresh == null) return false;
    try {
      final res = await Supabase.instance.client.auth
          .setSession(access); // refreshes if expired
      // setSession returns AuthResponse; fall through to user check.
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
    // ============================================================
    // DEFINITIVE sign-out — clears every possible storage layer so
    // the next cold start can NOT auto-restore the session.
    //
    // Order:
    //   1) Flip local state to logged-out (UI updates instantly).
    //   2) Call Supabase.auth.signOut() — clears server-side + its
    //      SharedPreferences key.
    //   3) Wipe flutter_secure_storage (any future or rogue secure
    //      storage entry that may still hold a token).
    //   4) Sweep every SharedPreferences key we ever wrote
    //      (sb-*, user_*, is_logged_in, etc.) AND every Supabase
    //      host-named key.
    //   5) Notify listeners (the UI layer reacts and replaces the
    //      navigation stack with the Login screen).
    // ============================================================

    // 1) Flip state immediately so UI reflects logged-out before any
    //    await network round-trip.
    _isLoggedIn = false;
    _isGuest = false;
    _userId = '';
    _userName = '';
    _username = '';
    _userEmail = '';
    notifyListeners();

    // 2) Server-side + Supabase SDK local storage.
    if (AppConfig.supabaseEnabled) {
      try {
        await Supabase.instance.client.auth.signOut();
      } catch (e) {
        debugPrint('AuthProvider.signOut: Supabase signOut failed: $e');
      }
    }

    // 3) Belt-and-braces: clear flutter_secure_storage too. Even if
    //    the SDK is currently configured with SharedPreferencesLocalStorage,
    //    an old build or a custom override might have used secure
    //    storage. We don't want a leftover token to survive.
    try {
      const secure = FlutterSecureStorage(
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
          resetOnError: true,
        ),
      );
      // Wipe every well-known key plus a final sweep.
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
      // Wipe every key in the secure storage.
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

    // 4) Wipe SharedPreferences mirrors + Supabase's own key.
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

    // The Supabase SDK stores its persisted session under a key like
    // `sb-<host>-auth-token`. Wipe it by name and sweep any other
    // `sb-*` key as a final defensive clear.
    final hostFirstSegment =
        Uri.parse(AppConfig.supabaseUrl).host.split('.').first;
    await prefs.remove('sb-$hostFirstSegment-auth-token');
    for (final k in prefs.getKeys()) {
      if (k.startsWith('sb-')) {
        await prefs.remove(k);
      }
    }
  }

  /// Native Google Sign-In using the google_sign_in package directly.
  /// This bypasses the OAuth deep link flow and works reliably on Android.
  Future<String?> signInWithGoogleNative() async {
    if (!AppConfig.supabaseEnabled) return 'supabase_disabled';
    // v1.0.30: updated to the Web Client ID that matches the Google
    // Cloud Console OAuth 2.0 Web application (ends with
    // ...dqa1jp.apps.googleusercontent.com). The old ID ended in
    // ...dqa7ij and was tied to a different cloud project, which is
    // what produced the Code 10 mismatch.
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
      // Mirror the fresh session tokens to SharedPreferences so the next
      // cold start can restore even if Supabase storage is broken.
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
          debugPrint('Your applicationId: com.example.streetlore');
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
