import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/unauthorized_person.dart';
import '../services/settings_service.dart';

class HttpService {
  static final HttpService _instance = HttpService._internal();
  factory HttpService() => _instance;
  HttpService._internal();

  HttpServer? _server;
  Function(UnauthorizedPerson)? _onUnauthorizedPerson;

  void setUnauthorizedPersonCallback(Function(UnauthorizedPerson) callback) {
    _onUnauthorizedPerson = callback;
  }

  Future<void> startServer() async {
    try {
      _server = await HttpServer.bind('0.0.0.0', 7000);
      print('HTTP Server listening on port 8080 for unauthorized persons');

      await for (HttpRequest request in _server!) {
        if (request.method == 'POST' && request.uri.path == '/unauthorized') {
          try {
            final content = await utf8.decoder.bind(request).join();
            final data = json.decode(content);

            // Create unauthorized person object
            final person = UnauthorizedPerson(
              id: data['person_id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
              imageUrl: data['image_url'] ?? '',
              timestamp: data['timestamp'] != null
                  ? DateTime.parse(data['timestamp'])
                  : DateTime.now(),
            );

            // Call the callback if set
            _onUnauthorizedPerson?.call(person);

            request.response
              ..statusCode = HttpStatus.ok
              ..headers.contentType = ContentType.json
              ..write(json.encode({'status': 'received'}))
              ..close();
          } catch (e) {
            print('Error processing unauthorized person: $e');
            request.response
              ..statusCode = HttpStatus.badRequest
              ..write('Error processing request')
              ..close();
          }
        } else {
          request.response
            ..statusCode = HttpStatus.notFound
            ..write('Not Found')
            ..close();
        }
      }
    } catch (e) {
      print('Failed to start HTTP server: $e');
    }
  }

  Future<bool> registerPerson(String personName, String imageUrl) async {
    try {
      final serverUrl = await SettingsService().getServerUrl();
      final response = await http.post(
        Uri.parse('$serverUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': personName,
          'image_url': imageUrl,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error registering person: $e');
      return false;
    }
  }

  void stop() {
    _server?.close();
  }
}