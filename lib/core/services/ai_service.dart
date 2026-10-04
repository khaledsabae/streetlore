import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../../data/models/ai_trip_plan.dart';
import '../../data/models/place_model.dart';
import 'gemini_rest_client.dart';

class AiService {
  AiService._();
  static final AiService instance = AiService._();

  
  
  
  
  
  
  bool _isArabic(String text) {
    return text.runes.any((r) => r >= 0x0600 && r <= 0x06FF);
  }

  
  
  
  static const String _alexandriaKnowledge = '''
ALEXANDRIA — ANCHOR FACTS (always ground answers here):
- Founded 331 BC by Alexander the Great. Ptolemaic capital. Once the
  largest city in the ancient world and home to the Lighthouse of
  Pharos (one of the Seven Wonders).
- Climate: Mediterranean. Hot dry summers (26-32°C, May-Sep) and mild
  wet winters (12-18°C, Nov-Feb). Sea breeze moderates heat.
- Corniche stretches ~30 km along the harbour — best sunset walks.
- Local currency: Egyptian Pound (EGP). Mid-2024 rate ~50 EGP/USD.
- Best walking districts: Downtown (Mansheya) for cafes and the
  Cecil Hotel legacy, Anfushi for seafood and bay views.
- Famous landmarks: Bibliotheca Alexandrina, Qaitbay Citadel
  (1480), Pompey's Pillar, Catacombs of Kom El Shoqafa, Montaza
  Palace gardens, Stanley Bridge, Abu Qir Bay.
- Signature foods: seafood (sea bass, calamari, shrimp), ful & ta'amiya,
  alexandrian liver (kibda alexandriya), roz bel laban, ice cream
  from Azza, mango juice at Abo Youssef.
- Day-trip options: Rosetta (Rashid) 65 km east, Abu Qir
  (battlefields + fort) 32 km NE, Wadi El Natrun monasteries 100 km.
- Rush hours: 8-10 AM and 4-7 PM. Friday is the weekend — expect
  closures and crowds at mosques mid-day.''';

  Future<AiTripPlan> generateTrip({
    required String prompt,
    required List<PlaceModel> availablePlaces,
    int? daysHint,
    String? budget,
  }) async {
    if (!GeminiRestClient.instance.isAvailable) {
      debugPrint('AiService.generateTrip: using local plan');
      return _localPlan(
        prompt: prompt,
        daysHint: daysHint ?? 2,
        availablePlaces: availablePlaces,
        budget: budget ?? r'$$',
        source: AiSource.local,
      );
    }

    final availablePlaceIds = availablePlaces
        .map((p) => p.id)
        .toList(growable: false);

    final bool isArabic = _isArabic(prompt);

    final placesForContext = availablePlaces
        .map(
          (p) =>
              '{"id":"${p.id}","name":${jsonEncode(p.nameEn)},"category":"${p.category}","description":${jsonEncode(p.descriptionEn)},"address":${jsonEncode(p.address)},"bestTimeToVisit":${jsonEncode(p.bestTimeToVisit ?? '')},"isIndoor":${p.isIndoor},"lat":${p.lat},"lng":${p.lng}}',
        )
        .join(',');

    final seed = DateTime.now().millisecondsSinceEpoch.toString();

    final system =
        """
You are an expert local travel planner who actually lives in Alexandria, Egypt.
Your tone: warm, specific, opinionated — like a friend showing a visitor around.
NEVER give generic filler. Every note, theme, and tip must mention a real
detail (time of day, what to eat, which side to photograph from, etc.).

$_alexandriaKnowledge

USER REQUEST:
- Prompt: ${jsonEncode(prompt)}
- Days: ${daysHint ?? 'auto (pick 2-4 based on the prompt)'}
- Budget: ${budget ?? r'$$'}

OUTPUT SCHEMA (return ONLY this JSON, no markdown fences):
{
  "title": string,
  "summary": string,
  "totalDays": int,
  "estimatedBudget": "\$" | "\$\$" | "\$\$\$" | "\$\$\$\$",
  "days": [
    { "dayNumber": int, "theme": string,
      "stops": [{ "placeId": string, "suggestedTime": string, "note": string }]
    }
  ],
  "tips": [string]
}

STRICT RULES:
- The user's prompt mentions specific themes (sea, fish, seafood, beach,
  history, mosque, family, romantic, photography, hidden gems, budget,
  etc.). You MUST read the `category`, `description`, and `bestTimeToVisit`
  of every place below and ONLY recommend places whose fields directly
  match the user's vibe. If nothing matches, prefer the closest category
  match and explicitly say so in the summary.
- For "sea / beach / corniche / swim" prompts, prefer places with
  `category in {Nature, Beach}` AND whose `description` mentions sea,
  corniche, Mediterranean, beach, or coast.
- For "fish / seafood / food / eat" prompts, prefer places with
  `category in {Food}` AND whose `description` mentions seafood, fish,
  restaurant, kitchen, or local cuisine.
- For "history / ancient / roman" prompts, prefer `category = Historical`.
- For "mosque / prayer / islam" prompts, prefer `category = Mosques`.
- NEVER invent a placeId. Every stop MUST be a placeId from the list
  below. If a place you want to recommend is not in the list, drop it.
- Order stops geographically + chronologically (morning first, sunset last
  where possible). 2-4 stops per day.
- "suggestedTime" must be a real window like "09:00 - 11:00" — use the 24h
  clock. Reflect rush hour, prayer time, sunset, or meal windows. Use the
  place's `bestTimeToVisit` (e.g. "Sunset", "Morning") as a hint, not a
  rule.
- "note" must be <= 18 words, include at least one concrete detail
  pulled from the place's `description` (specific food, time, photo
  angle, or local tip). NO "Visit this place" filler.
- Reflect the budget in tip + summary tone:
    \$    = street food / free attractions
    \$\$  = casual local spots
    \$\$\$ = mid-range restaurants, paid entries
    \$\$\$\$ = premium dining, private tours
- Adapt to the user's vibe: family, romantic, foodie, history, hidden gems,
  photography, budget trip, day trip, etc. Recommendations and notes MUST
  mirror that vibe.
- "tips" must be 3-5 unique local secrets — not generic ("wear sunscreen").
  Mention a real Alexandria detail (e.g. "the rooftop of the Sofitel faces
  the sunset — order a fresh lemon mint at golden hour").
- Language: respond in the SAME language as the user's prompt
  (${isArabic ? 'Arabic — keep proper nouns in Arabic where natural' : 'English'}).
- All title / summary / theme / note / tips text must be unique — no repeats.
- Variety seed: $seed — use as opaque nudge to avoid stock phrasings.

AVAILABLE PLACES (use these placeId values exactly):
[$placesForContext]
""";

    final user =
        'User prompt: ${jsonEncode(prompt)}\n'
        'Days hint: ${daysHint ?? "auto"}\n'
        'Budget: ${budget ?? r"\$\$"}\n'
        'Variety seed: $seed';

    try {
      final result = await GeminiRestClient.instance.generateContent(
        systemInstruction: system,
        userPrompt: user,
        temperature: 0.7,
        maxOutputTokens: 2048,
      );
      if (result == null || !result.isOk) {
        debugPrint(
          'AiService: Gemini call failed (status=${result?.statusCode}, '
          'err=${result?.errorBody}), falling back to local',
        );
        return _localPlan(
          prompt: prompt,
          daysHint: daysHint ?? 2,
          availablePlaces: availablePlaces,
          budget: budget ?? r'$$',
          source: AiSource.local,
        );
      }
      final text = result.text ?? '{}';
      final cleaned = text
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final json = jsonDecode(cleaned) as Map<String, dynamic>;
      final plan = _parsePlan(json, availablePlaceIds);
      plan.source = AiSource.live;
      return plan;
    } catch (e) {
      debugPrint('AiService: Gemini call threw, falling back to local: $e');
      return _localPlan(
        prompt: prompt,
        daysHint: daysHint ?? 2,
        availablePlaces: availablePlaces,
        budget: budget ?? r'$$',
        source: AiSource.local,
      );
    }
  }

  AiTripPlan _parsePlan(
    Map<String, dynamic> json,
    List<String> availablePlaceIds,
  ) {
    final rawDays = (json['days'] as List<dynamic>? ?? const []);
    final days = <AiTripDay>[];
    for (var i = 0; i < rawDays.length; i++) {
      final d = rawDays[i] as Map<String, dynamic>;
      final parsed = (d['dayNumber'] as num?)?.toInt() ?? (i + 1);
      final dayNumber = parsed < 1 ? (i + 1) : parsed;
      final stops = (d['stops'] as List<dynamic>? ?? const [])
          .map((s) {
            final raw = (s as Map<String, dynamic>);
            return AiTripStop(
              placeId: (raw['placeId'] as String?) ?? '',
              suggestedTime: _normalizeTime(
                (raw['suggestedTime'] as String?) ?? 'Flexible',
              ),
              note: (raw['note'] as String?) ?? '',
            );
          })
          .where((s) => availablePlaceIds.contains(s.placeId))
          .toList();
      if (stops.isEmpty) continue;
      days.add(
        AiTripDay(
          dayNumber: dayNumber,
          theme: (d['theme'] as String?) ?? 'Explore',
          stops: stops,
        ),
      );
    }
    return AiTripPlan(
      title: (json['title'] as String?) ?? 'Your Alexandria Adventure',
      summary: (json['summary'] as String?) ?? '',
      totalDays: (json['totalDays'] as num?)?.toInt() ?? days.length,
      estimatedBudget: (json['estimatedBudget'] as String?) ?? r'$$',
      days: days,
      tips: ((json['tips'] as List<dynamic>?) ?? const []).cast<String>(),
    );
  }

  String _normalizeTime(String raw) {
    final t = raw.trim();
    if (t.isEmpty || t.toLowerCase() == 'flexible') return t;
    final parts = t.split('-');
    if (parts.length != 2) return t;
    final a = _parseHHmm(parts[0]);
    final b = _parseHHmm(parts[1]);
    if (a == null || b == null) return t;
    if (b < a) {
      return '${_fmtHHmm(b)} - ${_fmtHHmm(a)}';
    }
    return '${_fmtHHmm(a)} - ${_fmtHHmm(b)}';
  }

  int? _parseHHmm(String s) {
    final m = RegExp(r'(\d{1,2})[:.:](\d{2})').firstMatch(s.trim());
    if (m == null) return null;
    final h = int.tryParse(m.group(1)!);
    final min = int.tryParse(m.group(2)!);
    if (h == null || min == null) return null;
    if (h < 0 || h > 24 || min < 0 || min > 59) return null;
    return h * 60 + min;
  }

  String _fmtHHmm(int totalMinutes) {
    final h = (totalMinutes ~/ 60).toString().padLeft(2, '0');
    final m = (totalMinutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  AiTripPlan _localPlan({
    required String prompt,
    required int daysHint,
    required List<PlaceModel> availablePlaces,
    required String budget,
    AiSource source = AiSource.local,
  }) {
    final isArabic = _isArabic(prompt);
    final all = availablePlaces;
    if (all.isEmpty) {
      return AiTripPlan(
        title: isArabic
            ? 'مفيش أماكن متاحة'
            : 'No places available',
        summary: isArabic
            ? 'اتصل بالنت أو ضيف أماكن علشان تبدأ تخطط لرحلتك.'
            : 'Connect to the network or add places to start planning your trip.',
        totalDays: daysHint,
        estimatedBudget: budget,
        days: const [],
        source: source,
        tips: isArabic
            ? const [
                'اسحب لتحديث الصفحة وحاول تاني لما الأماكن تظهر.',
                'حمل التطبيق أحدث نسخة من الموقع علشان تشوف أماكن جديدة.',
              ]
            : const [
                'Pull to refresh and try again once places are loaded.',
                'Update the app to see newly added places.',
              ],
      );
    }

    final q = prompt.toLowerCase();

    const categoryKeywords = <String, List<String>>{
      'Historical': [
        'history',
        'historical',
        'castle',
        'fort',
        'ancient',
        'roman',
        'ruins',
        'citadel',
        'ØªØ§Ø±ÙŠØ®',
        'ØªØ§Ø±ÙŠØ®ÙŠ',
        'Ù‚Ù„Ø¹Ø©',
        'Ø¢Ø«Ø§Ø±',
        'Ø­ØµÙ†',
      ],
      'Culture': [
        'culture',
        'museum',
        'art',
        'library',
        'Ø«Ù‚Ø§ÙØ©',
        'Ø«Ù‚Ø§ÙÙŠ',
        'Ù…ØªØ­Ù',
        'ÙÙ†',
        'Ù…ÙƒØªØ¨Ø©',
      ],
      'Food': [
        'food',
        'seafood',
        'restaurant',
        'eat',
        'fish',
        'cafe',
        'cafÃ©',
        'coffee',
        'dinner',
        'lunch',
        'Ø£ÙƒÙ„',
        'Ø§ÙƒÙ„',
        'Ø³Ù…Ùƒ',
        'Ù…Ø·Ø¹Ù…',
        'Ù…Ø£ÙƒÙˆÙ„Ø§Øª',
        'Ù‚Ù‡ÙˆØ©',
        'ÙƒØ§ÙÙŠÙ‡',
      ],
      'Nature': [
        'nature',
        'beach',
        'park',
        'garden',
        'sea',
        'corniche',
        'Ø·Ø¨ÙŠØ¹Ø©',
        'Ø´Ø§Ø·Ø¦',
        'Ø¨Ø­Ø±',
        'Ø¬Ù†ÙŠÙ†Ø©',
        'Ø­Ø¯ÙŠÙ‚Ø©',
        'ÙƒÙˆØ±Ù†ÙŠØ´',
      ],
      'Shopping': [
        'shopping',
        'shop',
        'market',
        'bazaar',
        'Ø³ÙˆÙ‚',
        'ØªØ³ÙˆÙ‚',
      ],
      'Mosques': ['mosque', 'Ù…Ø³Ø¬Ø¯', 'Ø¬Ø§Ù…Ø¹', 'Ù…Ø³Ø§Ø¬Ø¯'],
      'Churches': ['church', 'ÙƒÙ†ÙŠØ³Ø©', 'ÙƒÙ†Ø§Ø¦Ø³'],
      'Streets': [
        'street',
        'walk',
        'downtown',
        'stroll',
        'Ø´Ø§Ø±Ø¹',
        'Ø´ÙˆØ§Ø±Ø¹',
        'Ù…Ù…Ø´Ù‰',
        'ÙˆØ³Ø· Ø§Ù„Ø¨Ù„Ø¯',
      ],
    };

    final wantsHidden = [
      'hidden',
      'gem',
      'gems',
      'Ù…Ø®ÙÙŠ',
      'Ù…Ø®ÙÙŠØ©',
      'Ø¬ÙˆØ§Ù‡Ø±',
    ].any(q.contains);

    double score(PlaceModel p) {
      var s = p.rating;
      final kws = categoryKeywords[p.category] ?? const <String>[];
      for (final k in kws) {
        if (q.contains(k)) {
          s += 6;
          break;
        }
      }
      if (wantsHidden && p.isHiddenGem) s += 6;
      if (budget == r'$') {
        if (p.isFree) {
          s += 3;
        } else if (p.priceLevel == PriceLevel.cheap) {
          s += 1.5;
        } else {
          s -= 2;
        }
      } else if (budget == r'$$$$' && p.priceLevel == PriceLevel.expensive) {
        s += 2;
      }
      return s;
    }

    final ranked = [...all]..sort((a, b) => score(b).compareTo(score(a)));

    final perDay = (ranked.length / daysHint).ceil().clamp(2, 4);
    final days = <AiTripDay>[];
    var index = 0;
    for (var d = 0; d < daysHint && index < ranked.length; d++) {
      final end = (index + perDay).clamp(0, ranked.length);
      final slice = ranked.sublist(index, end);
      index = end;
      final ordered = _geoOrder(slice);
      days.add(
        AiTripDay(
          dayNumber: d + 1,
          theme: _themeFor(ordered, d, isArabic: isArabic),
          stops: [
            for (var j = 0; j < ordered.length; j++)
              AiTripStop(
                placeId: ordered[j].id,
                suggestedTime:
                    '${(9 + j * 3).toString().padLeft(2, '0')}:00 - ${(11 + j * 3).toString().padLeft(2, '0')}:00',
                note: _noteFor(ordered[j], isArabic: isArabic),
              ),
          ],
        ),
      );
    }
    return AiTripPlan(
      title: isArabic
          ? 'خطتك لـ $daysHint يوم في الإسكندرية'
          : 'Your $daysHint-Day Alexandria Plan',
      summary: isArabic
          ? 'خطة مخصصة لإسكندرية بناءً على طلبك: أماكن مختارة ورتبتها جغرافياً ووقت الذروة علشان كل يوم يكون مشي واحد سلس من الصبح للّهِلة.'
          : 'A local-style $daysHint-day Alexandria plan built from your '
                'request: hand-picked places, geo-sorted so each day is one '
                'walkable route from morning to sunset.',
      totalDays: daysHint,
      estimatedBudget: budget,
      days: days,
      tips: isArabic
          ? const [
              'ابدأ الصبح قبل الـ9 — البحر بيكون هادي والشوارع فاضية.',
              'الكورنيش وقت الغروب (الساعة 6 تقريباً) أحلى وقت للتصوير من الجهة الشمالية.',
              'لو بتفكر تجرب سي فود، Anfushi فيها أكل بحري أضمن من وسط البلد.',
              'اشرب عصير مانجو من Abo Youssef — من أحسن العصائر في إسكندرية.',
              'الجمعة بكون زحمة عند الجوامع — اتجنب وسط البلد الضهر.',
            ]
          : const [
              'Start before 9 AM — the sea is calm and the streets are quiet.',
              'Corniche at sunset (~6 PM) is the best golden-hour photo spot.',
              'For reliable seafood, head to Anfushi — better than downtown.',
              'Mango juice from Abo Youssef is the city\'s best cold drink.',
              'Avoid downtown at noon on Fridays — mosque crowds and traffic.',
            ],
      source: source,
    );
  }

  List<PlaceModel> _geoOrder(List<PlaceModel> places) {
    final remaining = [...places]..sort((a, b) => b.lat.compareTo(a.lat));
    final ordered = <PlaceModel>[];
    var current = remaining.removeAt(0);
    ordered.add(current);
    while (remaining.isNotEmpty) {
      remaining.sort((a, b) => _dist(current, a).compareTo(_dist(current, b)));
      current = remaining.removeAt(0);
      ordered.add(current);
    }
    return ordered;
  }

  double _dist(PlaceModel a, PlaceModel b) {
    final dx = a.lat - b.lat;
    final dy = a.lng - b.lng;
    return dx * dx + dy * dy;
  }

  String _themeFor(
    List<PlaceModel> dayPlaces,
    int dayIndex, {
    bool isArabic = false,
  }) {
    final counts = <String, int>{};
    for (final p in dayPlaces) {
      counts[p.category] = (counts[p.category] ?? 0) + 1;
    }
    var top = '';
    var topN = -1;
    counts.forEach((cat, n) {
      if (n > topN) {
        top = cat;
        topN = n;
      }
    });
    switch (top) {
      case 'Historical':
        return isArabic ? 'أبرز المواقع التاريخية' : 'Historical Highlights';
      case 'Food':
        return isArabic ? 'نكهات المدينة' : 'Tastes of the City';
      case 'Nature':
        return isArabic ? 'الطبيعة ونسيم البحر' : 'Nature & Sea Breeze';
      case 'Culture':
        return isArabic ? 'الثقافة والمتاحف' : 'Culture & Museums';
      case 'Shopping':
        return isArabic ? 'الأسواق والتسوق' : 'Markets & Shopping';
      case 'Mosques':
        return isArabic ? 'المعالم الدينية' : 'Spiritual Landmarks';
      case 'Churches':
        return isArabic ? 'العمارة المقدسة' : 'Sacred Architecture';
      case 'Streets':
        return isArabic ? 'شوارع وحياة محلية' : 'Streets & Local Life';
      default:
        return isArabic
            ? (dayIndex == 0 ? 'أيقونات المدينة' : 'زوايا خفية')
            : (dayIndex == 0 ? 'City Icons' : 'Hidden Corners');
    }
  }

  String _noteFor(PlaceModel p, {bool isArabic = false}) {
    if (p.isHiddenGem) {
      return isArabic
          ? 'جوهرة خفية، السكان المحليين بيزوروها أكتر من السياح.'
          : 'Local-favorite hidden gem — worth the detour off the main route.';
    }
    switch (p.category) {
      case 'Historical':
        return isArabic
            ? 'تأخدلها ساعة، وخد جاكيت خفيف لو بتمشي في الكورنيش بعدها.'
            : 'Allow an hour inside; pair with a Corniche walk afterwards.';
      case 'Food':
        return isArabic
            ? 'اطلب السمك الطازة المحلي — أحسن من المنيو المجمّد.'
            : 'Order the fresh catch of the day — better than the set menu.';
      case 'Nature':
        return isArabic
            ? 'وقت الغروب أحلى وقت هنا، والإضاءة الذهبية بتفرق في الصور.'
            : 'Sunset is magic here — golden hour makes the photos sing.';
      case 'Culture':
        return isArabic
            ? 'خد جولة مع الدليل المحلي أو حمّل الإلي دي بسرعة قبل الدخول.'
            : 'Grab a free audio guide at the door — worth the 10 minutes.';
      case 'Shopping':
        return isArabic
            ? 'فوّت على الأسعار الأولى — اسأل السكان المحليين عن المحلات المعتمدة.'
            : 'Skip the first prices — ask a local for the trusted shop.';
      case 'Mosques':
        return isArabic
            ? 'البس محتشم، واطلع من الجزمة قبل الدخول.'
            : 'Dress modestly and remove shoes before entering.';
      case 'Churches':
        return isArabic
            ? 'ادخل من الباب الرئيسي واسأل عن مواعيد القداس.'
            : 'Enter via the main door; ask about service times on arrival.';
      case 'Streets':
        return isArabic
            ? 'امشي ببطء — أحلى تجارب إسكندرية في تفاصيل الشوارع.'
            : 'Walk slowly — Alexandrian magic hides in street-level detail.';
      default:
        return isArabic
            ? 'وجهة ${p.category} مميزة ومُقيَّمة بعلامة عالية.'
            : 'Top-rated ${p.category.toLowerCase()} stop worth your time.';
    }
  }
}
