import 'package:flutter/material.dart';
import 'db_helper.dart';

class SignupScreen extends StatefulWidget {
  final VoidCallback onLoginTap;
  final VoidCallback onSignupSuccess;
  const SignupScreen({super.key, required this.onLoginTap, required this.onSignupSuccess});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;
  bool _loading = false;

  Future<void> _signup() async {
    setState(() { _loading = true; _error = null; });
    try {
      final success = await DBHelper().signup(_emailController.text, _passwordController.text);
      if (success) {
        widget.onSignupSuccess();
      } else {
        setState(() { _error = 'Signup failed (maybe email already exists)'; });
      }
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            _loading ? const CircularProgressIndicator() : ElevatedButton(onPressed: _signup, child: const Text('Sign Up')),
            TextButton(onPressed: widget.onLoginTap, child: const Text('Already have an account? Login')),
          ],
        ),
      ),
    );
  }
}
