import 'dart:async';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../../data/models/place_model.dart';
import 'gemini_rest_client.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class AITourGuideService {
  AITourGuideService._();
  static final AITourGuideService instance = AITourGuideService._();

  /// Same heuristic as AiService: only ATTEMPT the call when the key looks
  /// real. When the key is obviously invalid, skip the network round-trip
  /// and use the local offline answer.
  ///
  /// Accepts the project-specific `AQ.Ab...` token format the user
  /// provided, in addition to standard Google AI Studio `AIzaSy...` keys.
  bool _looksLikeRealKey(String key) {
    if (key.isEmpty) return false;
    if (key.contains('YOUR_') || key.contains('REPLACE')) return false;
    // Standard Google AI Studio key.
    if (key.startsWith('AIza') && key.length >= 30) return true;
    // Project-specific AQ.* token format.
    if (key.startsWith('AQ.') && key.length >= 30) return true;
    // Vertex-style or other accepted prefix.
    if (key.length < 20) return false;
    if (RegExp(r'^[A-Za-z0-9_\-]+$').hasMatch(key) ||
        key.contains('.') ||
        key.contains('_')) {
      return true;
    }
    return false;
  }

  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  _LiveSession? _session;
  PlaceModel? _currentPlace;
  bool _busy = false;
  bool get isBusy => _busy;

  // ignore_for_file: unnecessary_brace_in_string_interps
  String _buildSystemPrompt(PlaceModel place) {
    final now = DateTime.now();
    final hour = now.hour;
    final isRushHour = (hour >= 8 && hour <= 10) ||
        (hour >= 16 && hour <= 19);
    final isLunchHour = hour >= 12 && hour <= 14;
    final isLateNight = hour >= 22 || hour < 6;
    final todayWeekday = now.weekday;
    final isWeekend =
        todayWeekday == DateTime.friday || todayWeekday == DateTime.saturday;

    return '''You are an enthusiastic LOCAL tour guide for Alexandria, Egypt — you have actually walked these streets for years. You are currently helping a visitor who just opened the detail page for "${place.name}" (category: ${place.category}).

ALEXANDRIA — ANCHOR FACTS (use these as truth anchors):
- Founded 331 BC by Alexander the Great. Ptolemaic capital. Once the largest
  city in the ancient world and home to the Lighthouse of Pharos.
- Climate: Mediterranean. Hot dry summers (26-32°C, May-Sep), mild wet winters
  (12-18°C, Nov-Feb). Sea breeze moderates heat.
- Corniche stretches ~30 km along the harbour — best sunset walks.
- Local currency: Egyptian Pound (EGP). Mid-2024 ~50 EGP/USD.
- Best walking districts: Downtown (Mansheya), Anfushi for seafood + bay views.
- Famous landmarks: Bibliotheca Alexandrina, Qaitbay Citadel (1480),
  Pompey's Pillar, Catacombs of Kom El Shoqafa, Montaza Palace, Stanley Bridge,
  Abu Qir Bay.
- Signature foods: seafood (sea bass, calamari, shrimp), ful & ta'amiya,
  alexandrian liver (kibda alexandriya), roz bel laban, ice cream from Azza,
  mango juice at Abo Youssef.
- Day-trip options: Rosetta (Rashid) 65 km east, Abu Qir (fort + battlefields)
  32 km NE, Wadi El Natrun monasteries 100 km.
- Rush hours: 8-10 AM and 4-7 PM. Friday is the weekend — expect closures and
  crowds at mosques mid-day.

CURRENT CONTEXT (use this to tailor every answer):
- Local time: ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} on weekday #${todayWeekday} (weekend: ${isWeekend ? 'yes' : 'no'})
- Rush hour: ${isRushHour ? 'YES — mention traffic' : 'no'}
- Lunch hour: ${isLunchHour ? 'YES — recommend nearby food' : 'no'}
- Late night: ${isLateNight ? 'YES — most places are closed' : 'no'}

KEY FACTS about this place:
- Description: ${place.description}
- Address: ${place.address}
- Open hours: ${place.openHours}
- Rating: ${place.rating}/5 (${place.reviewCount} reviews)
${place.priceLocalEgp != null ? '- Local price: ${place.priceLocalEgp} EGP\n- Foreigner price: ${place.priceForeignerEgp} EGP' : ''}
- Coordinates: ${place.lat.toStringAsFixed(4)}, ${place.lng.toStringAsFixed(4)}
- Indoor? ${place.isIndoor ? 'yes' : 'no (outdoor)'}

YOUR BEHAVIOR:
1. ALWAYS consider the current local time + day of week when answering
   questions about "now", "today", or "best time" — never give a generic
   answer.
2. If the user asks "is it good now?" or similar, evaluate against the
   place's open hours + the current time + day.
3. If it's rush hour or late night, proactively warn or suggest alternative
   timing (e.g. "come back after 7 PM when the rush dies").
4. Mix English with Egyptian Arabic naturally — use "يا باشا", "إن شاء الله",
   "يلا" sparingly when the user is in Arabic mode or for warmth.
5. Keep answers concise (2-4 sentences) but SPECIFIC to this place and this
   moment. Mention a real detail: a food spot, a photo angle, a time, a
   nearby landmark.
6. Suggest 1-2 nearby activities or food spots whenever relevant. Prefer
   ones from the anchor list above.
7. NEVER make up facts. If unsure, say so honestly.
8. Prefer concrete numbers and times over vague advice ("go before 10 AM"
   beats "go early").

You can answer about: history, best times to visit, what to wear, nearby food,
how to get there, photo tips, similar places in Alexandria, family-friendliness,
safety, and accessibility.''';
  }

  Future<void> start(PlaceModel place) async {
    _currentPlace = place;
    _messages.clear();
    final keys = AppConfig.geminiApiKeys
        .map((k) => k.trim())
        .where((k) => k.isNotEmpty)
        .toList();
    final bool canGoLive =
        AppConfig.geminiEnabled && keys.any(_looksLikeRealKey);
    if (!canGoLive) {
      debugPrint(
        'AITourGuideService.start: using offline welcome '
        '(enabled=${AppConfig.geminiEnabled}, keys=${keys.length})',
      );
      _messages.add(
        ChatMessage(
          text: _offlineWelcome(place),
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
      return;
    }
    // Send each user message as an independent REST call via the
    // shared Gemini REST client which rotates through [apiKeys]. This
    // sidesteps any SDK-level token / header formatting issues.
    _session = _LiveSession(
      apiKeys: keys,
      model: AppConfig.geminiModel,
      systemPrompt: _buildSystemPrompt(place),
    );
    _messages.add(
      ChatMessage(
        text:
            'Marhaba! I\'m your local guide for ${place.name}. Ask me anything — history, tips, what to see nearby, or anything else. بالإنجليزي أو العربي، زي ما تحب. 😊',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  String _offlineWelcome(PlaceModel place) {
    return '👋 مرحباً! أنا دليلك المحلي لـ ${place.name}.\n\n${place.description}\n\nاسألني عن: المواعيد، الأسعار، التاريخ، النصايح، أو العنوان!\n\n(وضع محلي — Gemini API غير مفعّل في الوقت الحالي أو الـ key غير صالح. كل الإجابات هنا من بيانات محلية على الجهاز.)';
  }

  Future<String> send(String userText) async {
    if (_session == null && _currentPlace != null) {
      _busy = true;
      _messages.add(
        ChatMessage(text: userText, isUser: true, timestamp: DateTime.now()),
      );
      final reply = _offlineAnswer(userText, _currentPlace!);
      _messages.add(
        ChatMessage(text: reply, isUser: false, timestamp: DateTime.now()),
      );
      _busy = false;
      return reply;
    }
    if (_session == null) return 'Chat not started. Call start() first.';
    if (_busy) return 'Please wait for the previous reply.';
    _busy = true;
    _messages.add(
      ChatMessage(text: userText, isUser: true, timestamp: DateTime.now()),
    );
    final contextualTurn = _buildContextualUserPrompt(userText);
    try {
      final res = await _session!.sendMessage(contextualTurn);
      final reply = res.text;
      _messages.add(
        ChatMessage(text: reply, isUser: false, timestamp: DateTime.now()),
      );
      return reply;
    } catch (e) {
      debugPrint('AITourGuideService.send error: $e');
      final isArabic = userText.runes.any((r) => r >= 0x0600 && r <= 0x06FF);
      final errBrief = _summarizeError(e);
      final offline = _offlineAnswer(userText, _currentPlace!);
      final reply = isArabic
          ? '⚠️ Gemini API: $errBrief\n\n(إجابة محلية بدون نت)\n\n$offline'
          : '⚠️ Gemini API: $errBrief\n\n(Local offline answer — API call failed)\n\n$offline';
      _messages.add(
        ChatMessage(text: reply, isUser: false, timestamp: DateTime.now()),
      );
      return reply;
    } finally {
      _busy = false;
    }
  }

  String _summarizeError(Object e) {
    if (e is GeminiApiException) {
      final code = e.statusCode;
      if (code == 0) return 'Network error: ${e.message}';
      if (code == 400) {
        return 'Bad request (400): ${_trim(e.message)} — likely invalid API '
            'key or unsupported model name. Check '
            '`AppConfig.geminiApiKey` and `geminiModel`.';
      }
      if (code == 401 || code == 403) {
        return 'Auth denied ($code): ${_trim(e.message)} — API key lacks '
            'permission. Enable the Generative Language API for your key '
            'at https://aistudio.google.com/apikey';
      }
      if (code == 404) {
        return 'Model not found (404): ${_trim(e.message)} — '
            '`AppConfig.geminiModel` is not available for this key.';
      }
      if (code == 429) {
        return 'Rate limited (429): ${_trim(e.message)}';
      }
      return 'HTTP $code: ${_trim(e.message)}';
    }
    final s = e.toString();
    if (s.contains('SocketException') || s.contains('Failed host lookup')) {
      return 'No internet / DNS failed.';
    }
    if (s.contains('TimeoutException')) {
      return 'Request timed out.';
    }
    return _trim(s);
  }

  String _trim(String s) {
    final firstLine = s.split('\n').first;
    return firstLine.length > 220
        ? '${firstLine.substring(0, 220)}...'
        : firstLine;
  }

  /// Wrap the raw user text with fresh context (current time, day,
  /// placeholder for weather) so every reply reflects the actual moment
  /// the user is asking about.
  String _buildContextualUserPrompt(String userText) {
    final now = DateTime.now();
    return '''
[Live context — use this to answer]
- Local time: ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}
- Day: weekday ${now.weekday}
- Place rating: ${_currentPlace?.rating ?? '-'} / 5
- Current open-hour check (best-effort): '${_currentPlace?.openHours ?? ''}'

[User question]
$userText''';
  }

  String _offlineAnswer(String q, PlaceModel place) {
    final lower = q.toLowerCase();
    final isArabic = q.runes.any((r) => r >= 0x0600 && r <= 0x06FF);

    if (lower.contains('hour') ||
        lower.contains('open') ||
        lower.contains('time') ||
        lower.contains('وقت') ||
        lower.contains('مفتوح') ||
        lower.contains('ساعة') ||
        lower.contains('متى') ||
        lower.contains('when')) {
      final localHour = DateTime.now().hour;
      String timeHint;
      if (localHour >= 8 && localHour <= 10) {
        timeHint = isArabic
            ? 'دلوقتي وقت الذروة — جرب بعد الـ7.'
            : 'Right now it\'s rush hour — try after 7 PM.';
      } else if (localHour >= 12 && localHour <= 14) {
        timeHint = isArabic
            ? 'وقت الغدا — ممكن تستنى 30 دقيقة أو تجرب قبل 12.'
            : 'Lunch hour — wait 30 min or arrive before noon.';
      } else if (localHour >= 22 || localHour < 6) {
        timeHint = isArabic
            ? 'المكان غالباً مقفول دلوقتي — الصبح أحسن وقت.'
            : 'Most places are closed now — morning is best.';
      } else {
        timeHint = isArabic
            ? 'وقت مناسب للزيارة دلوقتي.'
            : 'Good time to visit right now.';
      }
      return isArabic
          ? '🕐 ${place.name} مفتوح: ${place.openHours}.\n$timeHint'
          : '🕐 ${place.name} hours: ${place.openHours}.\n$timeHint';
    }
    if (lower.contains('price') ||
        lower.contains('cost') ||
        lower.contains('ticket') ||
        lower.contains('سعر') ||
        lower.contains('تذكرة') ||
        lower.contains('تكلف') ||
        lower.contains('بكام') ||
        lower.contains('فلوس')) {
      if (place.isFree) {
        return isArabic
            ? '🎉 ${place.name} دخوله مجاناً!'
            : '🎉 ${place.name} is FREE entry!';
      }
      final local = place.priceLocalEgp ?? '?';
      final foreign = place.priceForeignerEgp ?? '?';
      return isArabic
          ? '🎟️ أسعار الدخول:\n• مصريون: $local جنيه\n• أجانب: $foreign جنيه'
          : '🎟️ Entry prices:\n• Egyptians: $local EGP\n• Foreigners: $foreign EGP';
    }
    if (lower.contains('address') ||
        lower.contains('where') ||
        lower.contains('location') ||
        lower.contains('كيف') ||
        lower.contains('الوصول') ||
        lower.contains('عنوان') ||
        lower.contains('فين') ||
        lower.contains('موقع')) {
      return isArabic
          ? '📍 ${place.name} موجود في: ${place.address}.\nتقدر تضغط على زر "Go" في صفحة المكان علشان يفتحلك خريطة.'
          : '📍 ${place.name} is located at: ${place.address}.\nTap the "Go" button on the place page to open directions.';
    }
    if (lower.contains('history') ||
        lower.contains('about') ||
        lower.contains('tell') ||
        lower.contains('بني') ||
        lower.contains('عمر') ||
        lower.contains('متى') ||
        lower.contains('when built') ||
        lower.contains('تاريخ') ||
        lower.contains('عن') ||
        lower.contains('إيه') ||
        lower.contains('حك')) {
      return isArabic
          ? '🏛️ ${place.description}\n\nتقييم المكان: ⭐ ${place.rating}/5 من ${place.reviewCount} زيارة.'
          : '🏛️ ${place.description}\n\nRating: ⭐ ${place.rating}/5 from ${place.reviewCount} visits.';
    }
    if (lower.contains('tip') ||
        lower.contains('advice') ||
        lower.contains('recommend') ||
        lower.contains('best') ||
        lower.contains('visit') ||
        lower.contains('when to') ||
        lower.contains('نصيحة') ||
        lower.contains('نصايح') ||
        lower.contains('توصية') ||
        lower.contains('الأفضل') ||
        lower.contains('أحسن')) {
      return isArabic
          ? '💡 نصايح لزيارة ${place.name}:\n• زور قبل الـ9 الصبح — البحر هادي والشوارع فاضية\n• خد معك مية واقي شمس (إسكندرية حارة الشتا قصاد)\n• أحسن وقت للتصوير: قبل الغروب بساعة من الجهة الشمالية\n• المواعيد: ${place.openHours}'
          : '💡 Tips for ${place.name}:\n• Arrive before 9 AM — calm sea and quiet streets\n• Bring water + sunblock (Alex sun is stronger than it feels)\n• Best photos: 1 hour before sunset, north-facing angle\n• Hours: ${place.openHours}';
    }
    if (lower.contains('rating') ||
        lower.contains('review') ||
        lower.contains('star') ||
        lower.contains('تقييم') ||
        lower.contains('رأي') ||
        lower.contains('نجوم')) {
      return isArabic
          ? '⭐ تقييم ${place.name}: ${place.rating}/5 من ${place.reviewCount} زيارة.\nالمكان من أفضل أماكن ${place.category} في الإسكندرية.'
          : '⭐ ${place.name} rating: ${place.rating}/5 from ${place.reviewCount} reviews.\nIt\'s one of the top ${place.category} spots in Alexandria.';
    }
    if (lower.contains('family') ||
        lower.contains('kids') ||
        lower.contains('children') ||
        lower.contains('عيلة') ||
        lower.contains('أطفال') ||
        lower.contains('عائلي')) {
      return isArabic
          ? '👨‍👩‍👧 ${place.name} مناسب للعائلات: ${place.isFree ? 'الدخول مجاني' : 'التذكرة رمزية'}.\nيوجد مكان مفتوح للاسترخاء. المواعيد: ${place.openHours}'
          : '👨‍👩‍👧 ${place.name} is family-friendly: ${place.isFree ? 'free entry' : 'affordable ticket'}.\nOpen spaces for kids. Hours: ${place.openHours}';
    }
    if (lower.contains('photo') ||
        lower.contains('picture') ||
        lower.contains('camera') ||
        lower.contains('صورة') ||
        lower.contains('تصوير') ||
        lower.contains('كاميرا')) {
      return isArabic
          ? '📸 أحسن مكان للتصوير في ${place.name}: الواجهة الأمامية وقت الغروب (الساعة 5-6 مساءً). الإضاءة الذهبية بتدي صور رائعة.\nالكاميرا: فون عادي أو كاميرا DSLR.'
          : '📸 Best photo spots at ${place.name}: the front facade around sunset (5-6 PM) gives golden-hour light.\nAny phone camera or DSLR works great here.';
    }
    if (lower.contains('nearby') ||
        lower.contains('close') ||
        lower.contains('next') ||
        lower.contains('قريب') ||
        lower.contains('مجاور') ||
        lower.contains('جنب')) {
      return isArabic
          ? '🗺️ الأماكن القريبة من ${place.name} هتظهر في صفحة المكان تحت الخريطة. أو من شاشة Discover استكشف أماكن قريبة بالعافية.'
          : '🗺️ Nearby spots from ${place.name} are listed on the Place Details page under the map. The Discover screen also surfaces close-by places with current open status.';
    }
    if (lower.contains('parking') ||
        lower.contains('باص') ||
        lower.contains('مترو') ||
        lower.contains('park') ||
        lower.contains('مترو')) {
      return isArabic
          ? '🚗 ${place.name} - الوصول: ${place.address}.\nفي الغالب فيه مواقف سيارات قريبة. تقدر تستخدم "الذهاب" في الخريطة للوصول من موقعك.'
          : '🚗 ${place.name} access: ${place.address}.\nThere\'s usually nearby parking. Use the "Go" button on the map for turn-by-turn directions.';
    }
    final description =
        isArabic &&
            place.descriptionAr != null &&
            place.descriptionAr!.isNotEmpty
        ? place.descriptionAr!
        : place.description;
    final localHour = DateTime.now().hour;
    final liveHint = (localHour >= 8 && localHour <= 10)
        ? (isArabic ? '⏰ دلوقتي ذروة — الزحمة كبيرة.' : '⏰ Rush hour right now — traffic is heavy.')
        : (localHour >= 12 && localHour <= 14)
            ? (isArabic ? '🍽️ وقت الغدا.' : '🍽️ Lunch hour.')
            : (localHour >= 22 || localHour < 6)
                ? (isArabic ? '🌙 معظم الأماكن مقفولة.' : '🌙 Most places closed now.')
                : (isArabic ? '☀️ وقت مناسب للزيارة.' : '☀️ Good time to be out.');
    return isArabic
        ? '🌟 $description\n\n⭐ التقييم: ${place.rating}/5 من ${place.reviewCount} زيارة\n🕐 المواعيد: ${place.openHours}\n📍 العنوان: ${place.address}\n$liveHint\n\nاسألني عن: الأسعار، المواعيد، العنوان، التاريخ، نصايح الزيارة، أو أحسن وقت للتصوير!'
        : '🌟 $description\n\n⭐ Rating: ${place.rating}/5 from ${place.reviewCount} visits\n🕐 Hours: ${place.openHours}\n📍 Address: ${place.address}\n$liveHint\n\nAsk me about: prices, opening hours, address, history, visiting tips, or the best photo times!';
  }

  void clear() {
    _messages.clear();
    _session = null;
  }

  /// Single-shot "general" Alexandria expert call. Used by the
  /// General AI Tour Guide screen on the Home page for free-form
  /// questions that are NOT tied to a specific place.
  ///
  /// The system prompt is the only thing the model sees, so we keep it
  /// tight to save tokens and stay on-topic: ONLY Alexandria tourism,
  /// no coding / math / general chat. Polite decline for everything
  /// else.
  static Future<String> askAlexandria(String userText) async {
    final system = '''You are the street-level Alexandria tourism expert inside the "Streetlore" app. You answer questions about travel, places, food, history, and culture in Alexandria, Egypt.

STRICT RULES:
1. ONLY answer questions related to travel, places, history, culture, food, or tourism in Alexandria, Egypt.
2. If the user asks about coding, mathematics, general chat, politics, news, medical advice, or any non-tourism topic, politely decline and state your specific role (e.g. "I'm your Alexandria tourism guide — I can only help with travel, places, history, and culture here.").
3. Be concise but COMPLETE. Never cut a sentence mid-thought. If you would run out of tokens, wrap the answer cleanly with a final full sentence.
4. Use specific Alexandria details when possible (neighborhoods like Anfushi, Mansheya, Stanley, Moharam Bek, Attarin; landmarks like Bibliotheca Alexandrina, Qaitbay Citadel, Pompey's Pillar, Catacombs of Kom El Shoqafa, Montaza).
5. Never invent places that don't exist. If unsure, say so and suggest the user open the app map.
6. Speak directly to the user ("you") — friendly, opinionated, like a local friend showing them around.''';
    final keys = AppConfig.geminiApiKeys
        .map((k) => k.trim())
        .where((k) => k.isNotEmpty)
        .toList();
    if (keys.isEmpty || !AppConfig.geminiEnabled) {
      throw GeminiApiException(
        statusCode: 0,
        message: 'AI not configured',
      );
    }
    final result = await GeminiRestClient.instance.generateContent(
      apiKeys: keys,
      model: AppConfig.geminiModel,
      systemInstruction: system,
      userPrompt: userText,
      temperature: 0.7,
      maxOutputTokens: 800,
    );
    if (result == null) {
      throw GeminiApiException(
        statusCode: 0,
        message: 'AI not configured',
      );
    }
    // v1.0.38: when ALL keys × ALL models failed the Gemini client
    // returns a friendly fallback text in `result.text` and the
    // sentinel statusCode 599. We surface that directly into the
    // chat bubble instead of throwing the raw API crash log.
    if (result.statusCode == 599) {
      return result.text ??
          "Sorry, I am currently unavailable. Please try again in a moment.";
    }
    if (!result.isOk) {
      throw GeminiApiException(
        statusCode: result.statusCode,
        message: result.errorBody ?? 'unknown error',
        raw: result.raw,
      );
    }
    final text = (result.text ?? '').trim();
    return text.isEmpty ? '...' : text;
  }
}

/// Lightweight session wrapper that forwards every `sendMessage` call to
/// the Gemini REST endpoint with `?key=API_KEY` in the URL — the format
/// the Gemini Developer API documents for API-key auth. Replaces the
/// google_generative_ai SDK call so we control the auth header path.
class _LiveSession {
  _LiveSession({
    required this.apiKeys,
    required this.model,
    required this.systemPrompt,
  });

  final List<String> apiKeys;
  final String model;
  final String systemPrompt;

  Future<_LiveReply> sendMessage(String userText) async {
    final result = await GeminiRestClient.instance.generateContent(
      apiKeys: apiKeys,
      model: model,
      systemInstruction: systemPrompt,
      userPrompt: userText,
      temperature: 0.7,
      maxOutputTokens: 1024,
    );
    if (result == null) {
      throw GeminiApiException(
        statusCode: 0,
        message: 'AI not configured',
      );
    }
    // v1.0.38: same friendly-fallback detection as the static
    // `askOnce` path above. Sentinel statusCode 599 means every
    // (key, model) attempt failed and GeminiRestClient has already
    // packaged a human-readable message in `result.text`.
    if (result.statusCode == 599) {
      return _LiveReply(
        text: result.text ??
            "Sorry, I am currently unavailable. Please try again in a moment.",
      );
    }
    if (!result.isOk) {
      throw GeminiApiException(
        statusCode: result.statusCode,
        message: result.errorBody ?? 'unknown error',
        raw: result.raw,
      );
    }
    return _LiveReply(text: result.text ?? '');
  }
}

class _LiveReply {
  final String text;
  const _LiveReply({required this.text});
}

class GeminiApiException implements Exception {
  final int statusCode;
  final String message;
  final String? raw;
  GeminiApiException({
    required this.statusCode,
    required this.message,
    this.raw,
  });
  @override
  String toString() =>
      'GeminiApiException(status=$statusCode): $message';
}
