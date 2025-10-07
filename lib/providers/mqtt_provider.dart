import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:convert';
import 'dart:io';
import '../models/unauthorized_person.dart';
import '../services/notification_service.dart';
import '../services/settings_service.dart';
import 'sensor_provider.dart';
import 'security_provider.dart';

class MqttProvider extends ChangeNotifier {
  MqttServerClient? client;
  bool isConnected = false;
  final SensorProvider sensorProvider;
  final SecurityProvider securityProvider;

  // HiveMQ Cloud Configuration
  static const String MQTT_BROKER = '65e275a531cf4f5eb698af1ff09c51a7.s1.eu.hivemq.cloud';
  static const int MQTT_PORT = 8883;
  static const String MQTT_USERNAME = 'hivemq.webclient.1758974031560';
  static const String MQTT_PASSWORD = 'n8!0I9&aNUF>Yw4zs<vM';

  // Topic definitions (simplified)
  static const String TOPIC_DATA = 'room/monitor/data';
  static const String TOPIC_DOOR = 'room/door/open';

  MqttProvider({
    required this.sensorProvider,
    required this.securityProvider,
  });

  Future<void> connect() async {
    client = MqttServerClient.withPort(
        MQTT_BROKER,
        'flutter-dashboard-${DateTime.now().millisecondsSinceEpoch}',
        MQTT_PORT
    );

    // Configure for HiveMQ Cloud
    client!.secure = true;
    client!.securityContext = SecurityContext.defaultContext;
    client!.logging(on: true);
    client!.keepAlivePeriod = 60;
    client!.onConnected = onConnected;
    client!.onDisconnected = onDisconnected;
    client!.onSubscribed = onSubscribed;
    client!.autoReconnect = true;
    client!.setProtocolV311();

    // Connection message with authentication
    final connMessage = MqttConnectMessage()
        .withClientIdentifier('flutter-dashboard-${DateTime.now().millisecondsSinceEpoch}')
        .authenticateAs(MQTT_USERNAME, MQTT_PASSWORD)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);

    client!.connectionMessage = connMessage;

    try {
      print('Connecting to HiveMQ Cloud...');
      await client!.connect();
    } catch (e) {
      print('MQTT Connection error: $e');
      client!.disconnect();
      rethrow;
    }
  }

  void onConnected() {
    print('Connected to HiveMQ Cloud successfully!');
    isConnected = true;
    subscribeToTopics();

    // Set up message listener
    client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? messages) {
      messages!.forEach((MqttReceivedMessage<MqttMessage?> message) {
        final topic = message.topic;
        final payload = MqttPublishPayload.bytesToStringAsString(
            (message.payload as MqttPublishMessage).payload.message);

        print('Received message: $payload from topic: $topic');
        handleMessage(topic, payload);
      });
    });

    notifyListeners();
  }

  void onDisconnected() {
    print('Disconnected from HiveMQ Cloud');
    isConnected = false;
    notifyListeners();
  }

  void onSubscribed(String topic) {
    print('Successfully subscribed to $topic');
  }

  void subscribeToTopics() {
    print('Subscribing to topics...');
    client!.subscribe(TOPIC_DATA, MqttQos.atLeastOnce);
  }

  void handleMessage(String topic, String payload) {
    try {
      print('Received on topic $topic: $payload');
      final data = json.decode(payload);

      if (topic == TOPIC_DATA) {
        sensorProvider.updateMonitorData(data);
      }
    } catch (e) {
      print('Error handling message: $e');
    }
  }

  void publishCommand(String topic, Map<String, dynamic> data) {
    if (!isConnected) {
      print('Not connected to MQTT broker');
      return;
    }

    final builder = MqttClientPayloadBuilder();
    builder.addString(json.encode(data));
    client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    print('Published to $topic: ${json.encode(data)}');
  }

  void disconnect() {
    print('Disconnecting from MQTT...');
    client?.disconnect();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}