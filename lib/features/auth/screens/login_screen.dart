import 'package:agamudayar_admin/features/auth/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:web/web.dart' as web;
import '../../../config/theme.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      await authProvider.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        context,
      );

      if (!mounted) return;

      // Show error message only if login failed
      if (!authProvider.isLoggedIn && authProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage!),
            backgroundColor: const Color(0xFFF44336),
          ),
        );
      }
      // Navigation is now handled by router redirect logic
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Admin', //Agamudayar
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E5631),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Content Approval System',
                          style: TextStyle(fontSize: 16, color: AppColors.grey),
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            border: const OutlineInputBorder(),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _login(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            return SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: authProvider.isLoading
                                    ? null
                                    : _login,
                                child: authProvider.isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text('Login'),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 30),
                        DunsTrustBadge(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Define the unique element ID for the browser's DOM
const String dunsElementId = 'duns-trust-badge-iframe';

class DunsTrustBadge extends StatelessWidget {
  const DunsTrustBadge({super.key});

  // The actual HTML iframe code
  static const String htmlContent =
      "<iframe id='Iframe1' src='https://dunsregistered.dnb.com/SealAuthentication.aspx?Cid=1' " +
      "width='114px' height='97px' frameborder='0' scrolling='no' allowtransparency='true' ></iframe>";

  @override
  Widget build(BuildContext context) {
    // We register the HTML element once.
    // This part of the code needs to check if it's running on the web
    if (web.window.document.getElementById(dunsElementId) == null) {
      // 1. Create a container element (a <div>)
      final div = web.document.createElement('div');
      div.id = dunsElementId;

      // 2. Set its inner HTML to be the iframe code
      div.innerHTML = htmlContent;

      // 3. Append the element to the body of the HTML document
      web.document.body?.appendChild(div);
    }

    // We render a placeholder in Flutter's widget tree
    // The actual content is rendered by the browser into the HTML body.
    return const SizedBox(
      width: 114,
      height: 40,
      // Note: We use a placeholder here. We no longer use HtmlElementView.
      child: Center(
        child: Text('D&B Trust Seal', style: TextStyle(fontSize: 10)),
      ),
    );
  }
}
