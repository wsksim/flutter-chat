import 'package:flutter/material.dart';
import 'package:chatgram/pages/chat_page.dart';
import 'package:chatgram/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Login page
///
/// This page allows the user to login to the app.
///
/// Examples:
/// ```dart
/// Navigator.of(context).push(LoginPage.route());
/// ```
///
/// ```dart
/// final route = MaterialPageRoute(builder: (context) => LoginPage());
/// Navigator.of(context).push(route);
/// ```
///
class LoginPage extends StatefulWidget {
  /// Creates a login page
  const LoginPage({Key? key}) : super(key: key);

  /// Creates a route for this page
  static Route<void> route() {
    return MaterialPageRoute(builder: (context) => const LoginPage());
  }

  /// Creates a route for this page with a transition
  @override
  LoginPageState createState() => LoginPageState();
}

/// State of the login page
///
/// This state allows the user to login to the app.
///
class LoginPageState extends State<LoginPage> {
  /// Creates a state of the login page
  bool _isLoading = false;

  /// Email controller
  final _emailController = TextEditingController();
  /// Password controller
  final _passwordController = TextEditingController();

  /// Creates a route for this page with a transition
  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await supabase.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context)
          .pushAndRemoveUntil(ChatPage.route(), (route) => false);
    } on AuthException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (_) {
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
  }

  /// Creates a route for this page with a transition
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Creates a route for this page with a transition
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: ListView(
        padding: formPadding,
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          formSpacer,
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          formSpacer,
          ElevatedButton(
            onPressed: _isLoading ? null : _signIn,
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}
