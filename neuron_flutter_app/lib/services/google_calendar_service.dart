import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class GoogleCalendarService {
  static final GoogleCalendarService _instance = GoogleCalendarService._internal();
  factory GoogleCalendarService() => _instance;

  GoogleCalendarService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      calendar.CalendarApi.calendarScope,
    ],
  );

  calendar.CalendarApi? _calendarApi;

  Future<void> _ensureCalendarApiInitialized() async {
    if (_calendarApi != null) return;

    try {
      final account = await _googleSignIn.signIn();
      if (account == null) throw Exception('Google Sign In failed');

      final auth = await account.authentication;
      final client = GoogleAuthClient(auth);
      _calendarApi = calendar.CalendarApi(client);
    } catch (e) {
      debugPrint('Google Calendar initialization error: $e');
      throw Exception('Failed to initialize Google Calendar API: $e');
    }
  }

  Future<List<calendar.Event>> fetchEvents() async {
    await _ensureCalendarApiInitialized();
    if (_calendarApi == null) throw Exception('Calendar API not initialized');

    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final events = await _calendarApi!.events.list(
        'primary',
        timeMin: startOfDay.toUtc(),
        timeMax: endOfDay.toUtc(),
        orderBy: 'startTime',
        singleEvents: true,
      );

      return events.items ?? [];
    } catch (e) {
      debugPrint('Error fetching events: $e');
      throw Exception('Failed to fetch calendar events');
    }
  }

  Future<calendar.Event> addEvent(String title, String description, DateTime start, DateTime end) async {
    await _ensureCalendarApiInitialized();
    if (_calendarApi == null) throw Exception('Calendar API not initialized');

    try {
      final event = calendar.Event()
        ..summary = title
        ..description = description
        ..start = (calendar.EventDateTime()..dateTime = start.toUtc())
        ..end = (calendar.EventDateTime()..dateTime = end.toUtc());

      return await _calendarApi!.events.insert(event, 'primary');
    } catch (e) {
      debugPrint('Error adding event: $e');
      throw Exception('Failed to add calendar event');
    }
  }

  Future<void> deleteEvent(String eventId) async {
    await _ensureCalendarApiInitialized();
    if (_calendarApi == null) throw Exception('Calendar API not initialized');

    try {
      await _calendarApi!.events.delete('primary', eventId);
    } catch (e) {
      debugPrint('Error deleting event: $e');
      throw Exception('Failed to delete calendar event');
    }
  }

  Future<calendar.Event> updateEvent(
    String eventId,
    String title,
    String description,
    DateTime start,
    DateTime end,
  ) async {
    await _ensureCalendarApiInitialized();
    if (_calendarApi == null) throw Exception('Calendar API not initialized');

    try {
      final event = calendar.Event()
        ..summary = title
        ..description = description
        ..start = (calendar.EventDateTime()..dateTime = start.toUtc())
        ..end = (calendar.EventDateTime()..dateTime = end.toUtc());

      return await _calendarApi!.events.update(event, 'primary', eventId);
    } catch (e) {
      debugPrint('Error updating event: $e');
      throw Exception('Failed to update calendar event');
    }
  }
}

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;

  GoogleAuthClient(GoogleSignInAuthentication auth)
      : _headers = {'Authorization': 'Bearer ${auth.accessToken}'};

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return http.Client().send(request);
  }
} 