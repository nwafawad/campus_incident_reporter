import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/incident_provider.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const CampusCareApp());
}

class CampusCareApp extends StatelessWidget {
  const CampusCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, IncidentProvider>(
          create: (_) => IncidentProvider(),
          update: (_, auth, incidents) => incidents!..start(auth.user?.uid),
        ),
      ],
      child: MaterialApp(
        title: 'CampusCare',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final text = switch (auth.status) {
      AuthStatus.loading => 'Loading…',
      AuthStatus.signedOut => 'Signed out',
      AuthStatus.unverified => 'Check your email',
      AuthStatus.signedIn => 'Hi ${auth.user!.name}',
    };
    return Scaffold(body: Center(child: Text(text)));
  }
}
