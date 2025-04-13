import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;

class GoogleCalendarService {
  static const _webClientId = '255065638939-qtkhr8dm195k2e7qq10u2p1vgp53nu0e.apps.googleusercontent.com';
  static const _iosClientId = '255065638939-fbfv75mb6h2nhg4o9cqvru697f6h43pj.apps.googleusercontent.com';
  late final GoogleSignIn _googleSignIn;
  calendar.CalendarApi? _calendarApi;

  GoogleCalendarService() {
    if (kIsWeb) {
      _googleSignIn = GoogleSignIn(
        clientId: _webClientId,
        scopes: ['https://www.googleapis.com/auth/calendar.readonly'],
        hostedDomain: "",
        signInOption: SignInOption.standard,
      );
    } else if (Platform.isIOS) {
      _googleSignIn = GoogleSignIn(
        clientId: _iosClientId,
        scopes: [calendar.CalendarApi.calendarReadonlyScope],
      );
    } else {
      _googleSignIn = GoogleSignIn(
        scopes: [calendar.CalendarApi.calendarReadonlyScope],
      );
    }
  }

  Future<List<calendar.Event>> fetchEvents() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) return [];

      final GoogleSignInAuthentication auth = await account.authentication;
      final accessToken = auth.accessToken;
      if (accessToken == null) {
        throw Exception('Failed to get access token');
      }

      final client = GoogleAuthClient(accessToken);
      _calendarApi = calendar.CalendarApi(client);

      final now = DateTime.now();
      final calendar.Events events = await _calendarApi!.events.list(
        'primary',
        timeMin: now.toUtc(),
        timeMax: now.add(const Duration(days: 1)).toUtc(),
        singleEvents: true,
        orderBy: 'startTime',
      );

      return events.items ?? [];
    } catch (e) {
      debugPrint('Error fetching events: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _calendarApi = null;
  }
}

class GoogleAuthClient extends http.BaseClient {
  final String _accessToken;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._accessToken);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $_accessToken';
    return _client.send(request);
  }

  @override
  void close() {
    _client.close();
  }
} 