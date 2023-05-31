import 'package:flutter/material.dart';
import 'package:chatgram/pages/chat_page.dart';
import 'package:chatgram/pages/register_page.dart';
import 'package:chatgram/utils/constants.dart';

/// Page to redirect users to the appropriate page depending on the initial auth state
///
/// This page redirects the user to the appropriate page depending on the initial auth state.
///
/// Examples:
/// ```dart
/// MaterialApp(
///   title: 'ChatGram',
///   theme: appTheme,
///   home: const SplashPage(),
/// );
/// ```
///
class SplashPage extends StatefulWidget {
  /// Creates a splash page

  /// Creates a splash page
  const SplashPage({Key? key}) : super(key: key);

  /// Creates a route for this page
  @override
  SplashPageState createState() => SplashPageState();
}

/// State of the splash page
///
/// This state redirects the user to the appropriate page depending on the initial auth state.
///
class SplashPageState extends State<SplashPage> {
  /// Creates a state of the splash page
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    // await for for the widget to mount
    await Future.delayed(Duration.zero);

    final session = supabase.auth.currentSession;
    if (!mounted) return;
    if (session == null) {
      Navigator.of(context)
          .pushAndRemoveUntil(RegisterPage.route(), (route) => false);
    } else {
      Navigator.of(context)
          .pushAndRemoveUntil(ChatPage.route(), (route) => false);
    }
  }
  /// Creates a route for this page with a transition
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: preloader);
  }
}
