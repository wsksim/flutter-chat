import 'package:flutter/material.dart';
import 'package:chatgram/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:chatgram/pages/splash_page.dart';

/// Main function
///
/// This function initializes Supabase and dotenv, and runs the app.
///
Future<void> main() async {
  /// Ensure that binding is initialized before calling Supabase and dotenv
  WidgetsFlutterBinding.ensureInitialized();

  /// Load dotenv file
  await dotenv.load(fileName: "dotenv");

  /// Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  /// Run app
  runApp(const MyApp());
}

/// Main app
///
/// This widget is the root of application.
///
/// Examples:
/// ```dart
///  MaterialApp(
///  runApp(const MyApp());
///  );
///  ```
///
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  /// This widget is the root of application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatGram', /// Title of the app
      theme: appTheme, /// Theme defined in utils/constants.dart
      home: const SplashPage(), /// First page to load
    );
  }
}
