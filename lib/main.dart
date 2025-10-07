import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shields/screens/setup_screen.dart';
import 'package:shields/services/http_service.dart';
import 'package:shields/services/settings_service.dart';
import 'models/unauthorized_person.dart';
import 'providers/sensor_provider.dart';
import 'providers/security_provider.dart';
import 'providers/mqtt_provider.dart';
import 'screens/dashboard_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initialize();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late SecurityProvider _securityProvider;

  @override
  void initState() {
    super.initState();
    _securityProvider = SecurityProvider();

    // Start HTTP server and set up callback
    HttpService().setUnauthorizedPersonCallback((person) {
      _securityProvider.addUnauthorizedPerson(person);
      NotificationService().showNotification(
        '⚠️ Unauthorized Person Detected',
        'Someone is trying to access the room. Please check the dashboard.',
      );
    });

    HttpService().startServer();
  }

  @override
  void dispose() {
    HttpService().stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SensorProvider()),
        ChangeNotifierProvider.value(value: _securityProvider),
        ChangeNotifierProxyProvider2<SensorProvider, SecurityProvider, MqttProvider>(
          create: (context) => MqttProvider(
            sensorProvider: context.read<SensorProvider>(),
            securityProvider: context.read<SecurityProvider>(),
          ),
          update: (context, sensor, security, mqtt) => mqtt!,
        ),
      ],
      child: MaterialApp(
        title: 'Smart Room Dashboard',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Color(0xFF0A0E27),
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme.apply(bodyColor: Colors.white),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: FutureBuilder<bool>(
          future: SettingsService().hasServerSettings(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                backgroundColor: Color(0xFF0A0E27),
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // If no settings found, show setup screen
            if (snapshot.data == false) {
              return SetupScreen();
            }

            // Otherwise show dashboard
            return DashboardScreen();
          },
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}