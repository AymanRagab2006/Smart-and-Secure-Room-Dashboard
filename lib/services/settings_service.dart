// lib/services/settings_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  static const String _serverIpKey = 'server_ip';
  static const String _serverPortKey = 'server_port';
  static const String _defaultIp = '192.168.1.100';
  static const String _defaultPort = '7000';

  Future<void> saveServerSettings(String ip, String port) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_serverIpKey, ip);
    await prefs.setString(_serverPortKey, port);
  }

  Future<String> getServerIp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_serverIpKey) ?? _defaultIp;
  }

  Future<String> getServerPort() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_serverPortKey) ?? _defaultPort;
  }

  Future<String> getServerUrl() async {
    final ip = await getServerIp();
    final port = await getServerPort();
    return 'http://$ip:$port';
  }

  Future<String> getVideoFeedUrl() async {
    final baseUrl = await getServerUrl();
    return '$baseUrl/video_feed';
  }

  Future<bool> hasServerSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_serverIpKey);
  }

  Future<void> clearSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_serverIpKey);
    await prefs.remove(_serverPortKey);
  }
}