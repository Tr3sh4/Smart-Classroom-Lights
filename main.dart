import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'providers/light_provider.dart';
import 'services/api_config.dart';

export 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: '.env');
  await ApiConfig.init();
  runApp(
    ChangeNotifierProvider(
      create: (_) => LightProvider(),
      child: const MyApp(),
    ),
  );
}
