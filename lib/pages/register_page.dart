import 'package:flutter/material.dart';
import 'package:chatgram/pages/chat_page.dart';
import 'package:chatgram/pages/login_page.dart';
import 'package:chatgram/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Register page
///
/// This page allows the user to register to the app.
///
/// Examples:
/// ```dart
/// Navigator.of(context).push(RegisterPage.route());
/// ```
///
/// ```dart
/// Navigator.of(context).pushAndRemoveUntil(RegisterPage.route(), (route) => false);
/// ```
///
class RegisterPage extends StatefulWidget {
  /// Creates a register page

  /// Creates a route for this page
  const RegisterPage({Key? key, required this.isRegistering}) : super(key: key);

  static Route<void> route({bool isRegistering = false}) {
    return MaterialPageRoute(
      builder: (context) => RegisterPage(isRegistering: isRegistering),
    );
  }

  final bool isRegistering;

  /// Creates a route for this page with a transition
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

/// State of the register page
///
/// This state allows the user to register to the app.
///
class _RegisterPageState extends State<RegisterPage> {
  /// Creates a state of the register page
  final bool _isLoading = false;

  /// Form key for validation
  final _formKey = GlobalKey<FormState>();

  /// Email controller
  final _emailController = TextEditingController();
  /// Username controller
  final _usernameController = TextEditingController();
  /// Password controller
  final _passwordController = TextEditingController();
  /// Confirm password controller
  final _confirmPasswordController = TextEditingController();

  /// Creates a route for this page with a transition
  Future<void> _signUp() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    final email = _emailController.text;
    final username = _usernameController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    if (password != confirmPassword) {
      context.showErrorSnackBar(message: 'Passwords do not match');
      return;
    }
    try {
      await supabase.auth.signUp(
          email: email, password: confirmPassword, data: {'username': username});
      if (!mounted) return;
      Navigator.of(context)
          .pushAndRemoveUntil(ChatPage.route(), (route) => false);
    } on AuthException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (error) {
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }
  }
  /// Creates a route for this page with a transition
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: formPadding,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                label: Text('Email'),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Required';
                }
                return null;
              },
              keyboardType: TextInputType.emailAddress,
            ),
            formSpacer,
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                label: Text('Username'),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Required';
                }
                final isValid = RegExp(r'^[A-Za-z0-9_]{3,24}$').hasMatch(val);
                if (!isValid) {
                  return '3-24 long with alphanumeric or underscore';
                }
                return null;
              },
            ),
            formSpacer,
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                label: Text('Password'),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Required';
                }
                if (val.length < 6) {
                  return '6 characters minimum';
                }
                return null;
              },
            ),
            formSpacer,
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                label: Text('Repeat Password'),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Required';
                }
                if (val.length < 6) {
                  return '6 characters minimum';
                }
                if (val != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            formSpacer,
            ElevatedButton(
              onPressed: _isLoading ? null : _signUp,
              child: const Text('Register'),
            ),
            formSpacer,
            TextButton(
              onPressed: () {
                Navigator.of(context).push(LoginPage.route());
              },
              child: const Text('I already have an account'),
            )
          ],
        ),
      ),
    );
  }
}
