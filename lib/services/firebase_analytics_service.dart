import 'dart:math';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_database_service.dart';

class FirebaseAnalyticsService {
  static final FirebaseAnalyticsService _i =
      FirebaseAnalyticsService._internal();
  factory FirebaseAnalyticsService() => _i;
  FirebaseAnalyticsService._internal();

  final FirebaseAnalytics _fa = FirebaseAnalytics.instance;
  final FirebaseDatabaseService _fdb = FirebaseDatabaseService();

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _fa);

  Future<void> _log(String name,
      {Map<String, Object>? params,
      String userId = 'anon',
      String role = 'unknown'}) async {
    try {
      await _fa.logEvent(name: name, parameters: params);
    } catch (_) {}
    try {
      await _fdb.analyticsRef.push().set({
        'eventName': name,
        'params': params?.map((k, v) => MapEntry(k, v.toString())),
        'userId': userId,
        'userRole': role,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (_) {}
  }

  Future<void> logScreenView(String screen,
      {String userId = 'anon', String role = 'unknown'}) async {
    try {
      await _fa.logScreenView(screenName: screen);
    } catch (_) {}
    await _log('screen_view',
        params: {'screen_name': screen}, userId: userId, role: role);
  }

  Future<void> logEventRegistration(
      String eventId, String eventTitle, String userId, String role) async {
    try {
      await _fa.logEvent(
        name: 'event_registration',
        parameters: {
          'event_id': eventId,
          'event_title': eventTitle.substring(0, min(100, eventTitle.length)),
        },
      );
    } catch (_) {}
    await _log('event_registration',
        params: {
          'event_id': eventId,
          'event_title': eventTitle.substring(0, min(100, eventTitle.length)),
        },
        userId: userId,
        role: role);
  }

  Future<void> logEventUnregistration(
      String eventId, String eventTitle, String userId) async {
    await _log('event_unregistration',
        params: {'event_id': eventId, 'event_title': eventTitle},
        userId: userId);
  }

  Future<void> logEventView(
      String eventId, String eventTitle, String userId) async {
    try {
      await _fa.logViewItem(
        currency: 'GBP',
        value: 0,
        items: [
          AnalyticsEventItem(
            itemId: eventId,
            itemName: eventTitle.substring(0, min(100, eventTitle.length)),
            itemCategory: 'event',
          )
        ],
      );
    } catch (_) {}
    await _log('event_view',
        params: {'event_id': eventId, 'event_title': eventTitle},
        userId: userId);
  }

  Future<void> logSearch(String query, {String userId = 'anon'}) async {
    try {
      await _fa.logSearch(searchTerm: query);
    } catch (_) {}
    await _log('search', params: {'query': query}, userId: userId);
  }

  Future<void> logSaveEvent(
      String eventId, String eventTitle, String userId) async {
    await _log('save_event',
        params: {'event_id': eventId, 'event_title': eventTitle},
        userId: userId);
  }

  Future<void> logTabView(String tab, String userId) async {
    await _log('tab_view', params: {'tab': tab}, userId: userId);
  }

  Future<void> logShareEvent(
      String eventId, String eventTitle, String userId) async {
    try {
      await _fa.logShare(
          contentType: 'event', itemId: eventId, method: 'clipboard');
    } catch (_) {}
    await _log('share_event',
        params: {'event_id': eventId, 'event_title': eventTitle},
        userId: userId);
  }

  Future<void> setUser(String userId, String role) async {
    try {
      await _fa.setUserId(id: userId);
      await _fa.setUserProperty(name: 'user_role', value: role);
    } catch (_) {}
  }
}
