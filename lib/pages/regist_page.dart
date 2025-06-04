import 'package:flutter/material.dart';
import 'package:studybuddy/sevices/auth_api.dart';
import 'package:studybuddy/sevices/session.dart';

class RegistPage extends StatefulWidget {
  const RegistPage({super.key});

  @override
  State<RegistPage> createState() => _RegistPageState();
}

class _RegistPageState extends State<RegistPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  String? _emailError;
  String? _usernameError;
  String? _passwordError;

  void _register() async {
    setState(() {
      _isLoading = true;
      _emailError = null;
      _usernameError = null;
      _passwordError = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final userData = await AuthApi.register(
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      await SessionService.saveUser(
        userData['id'],
        userData['username'],
        userData['email'],
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _emailError = null;
        _usernameError = null;
        _passwordError = null;

        if (e is Map<String, dynamic>) {
          _emailError = e['email'];
          _usernameError = e['username'];
          _passwordError = e['password'];
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Registration failed: $e')));
        }

        _formKey.currentState!.validate();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: _registForm(),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _registForm() {
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
              "Register New Account Now!",
              style: TextStyle(fontSize: 20, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              validator: (value) {
                if (_emailError != null) return _emailError;
                if (value == null || !value.contains('@'))
                  return 'Invalid email';
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                fillColor: Color.fromARGB(255, 188, 222, 255),
                filled: true,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _usernameController,
              validator: (value) {
                if (_usernameError != null) return _usernameError;
                if (value != null && value.trim().isNotEmpty) return null;
                return 'Username is required';
              },
              decoration: InputDecoration(
                labelText: 'Username',
                hintText: 'Enter your username',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                fillColor: Color.fromARGB(255, 188, 222, 255),
                filled: true,
              ),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _passwordController,
              validator: (value) {
                if (_passwordError != null) return _passwordError;
                if (value != null && value.length >= 6) return null;
                return 'Password must be at least 6 characters';
              },
              // validator:
              //     (value) =>
              //         value != null && value.length >= 6
              //             ? null
              //             : 'Password must be at least 6 characters',
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                fillColor: Color.fromARGB(255, 188, 222, 255),
                filled: true,
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 45, 93, 141),
                  fixedSize: Size(150, 50),
                ),
                child: Text(
                  'Register',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account?"),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text(
                    'Login here',
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
