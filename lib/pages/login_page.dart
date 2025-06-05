import 'package:flutter/material.dart';
import 'package:studybuddy/sevices/auth_api.dart';
import 'package:studybuddy/sevices/session.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _hasError = false;

  void _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final userData = await AuthApi.login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      await SessionService.saveUser(
        userData['id'],
        userData['username'],
        userData['email'],
        userData['photo_url'],
        // userData['updateAt'],
      );

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _formKey.currentState!.validate();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: _loginForm(),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _loginForm() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome to \nStudyBuddy!",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              "Login to Your Account",
              style: TextStyle(fontSize: 20, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _usernameController,
              onChanged: (_) {
                if (_hasError) {
                  setState(() {
                    _hasError = false;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Username',
                hintText: 'Enter your username',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                fillColor:
                    _hasError
                        ? Colors.red[700]
                        : Color.fromARGB(255, 188, 222, 255),
                filled: true,
              ),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _passwordController,
              onChanged: (_) {
                if (_hasError) {
                  setState(() {
                    _hasError = false;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                fillColor:
                    _hasError
                        ? Colors.red[700]
                        : Color.fromARGB(255, 188, 222, 255),
                filled: true,
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 45, 93, 141),
                  fixedSize: Size(150, 50),
                ),
                child: Text(
                  'Login',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?"),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/register');
                  },
                  child: const Text(
                    'Register here',
                    style: TextStyle(color: Color.fromARGB(255, 45, 93, 141)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
