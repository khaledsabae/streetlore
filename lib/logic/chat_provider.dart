import 'dart:async';
import 'package:flutter/foundation.dart';

import '../core/services/supabase_service.dart';
import '../data/models/chat_message.dart';

class ChatProvider extends ChangeNotifier {
  final Map<String, List<ChatMessage>> _byPlace = {};
  final Map<String, StreamSubscription> _subs = {};
  final SupabaseService _supa = SupabaseService.instance;

  List<ChatMessage> messagesFor(String placeId) =>
      _byPlace[placeId] ?? const [];

  Future<void> load(String placeId) async {
    final msgs = await _supa.fetchMessages(placeId);
    _byPlace[placeId] = msgs;
    notifyListeners();
    _subscribe(placeId);
  }

  void _subscribe(String placeId) {
    _subs[placeId]?.cancel();
    final stream = _supa.streamMessages(placeId);
    if (stream == null) return;
    _subs[placeId] = stream.listen((rows) {
      _byPlace[placeId] = rows;
      notifyListeners();
    });
  }

  /// Stops listening to a place's chat (call when its screen closes).
  void leave(String placeId) {
    _subs.remove(placeId)?.cancel();
  }

  Future<void> send(ChatMessage message) async {
    final list = List<ChatMessage>.from(_byPlace[message.placeId] ?? const []);
    list.add(message);
    _byPlace[message.placeId] = list;
    notifyListeners();
    await _supa.postMessage(message);
  }

  void appendLocal(ChatMessage message) {
    final list = List<ChatMessage>.from(_byPlace[message.placeId] ?? const []);
    list.add(message);
    _byPlace[message.placeId] = list;
    notifyListeners();
  }

  @override
  void dispose() {
    for (final s in _subs.values) {
      s.cancel();
    }
    super.dispose();
  }
}
