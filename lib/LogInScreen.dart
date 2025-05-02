import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_recipe_finder/recipe_page.dart';
import 'package:food_recipe_finder/registerpage.dart';
import 'package:provider/provider.dart';
import 'Authprovider.dart';

class LogInScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  LogInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFF4A7043), // Mossy hollow
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: Colors.white.withOpacity(0.94), // Subtle translucency
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header with Logo
                      Icon(
                        Icons.restaurant_menu,
                        size: 60,
                        color: Color(0xFF4A7043),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A7043),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Log in to Recipe Finder',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),
                      // Email Field
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Color(0xFF4A7043)),
                          prefixIcon:
                              Icon(Icons.email, color: Color(0xFF4A7043)),
                          filled: true,
                          fillColor: Color(0xFFE8F0E8), // Light mossy green
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: Color(0xFF4A7043), width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.red.shade700),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Colors.red.shade700, width: 2),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Password Field
                      TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Color(0xFF4A7043)),
                          prefixIcon:
                              Icon(Icons.lock, color: Color(0xFF4A7043)),
                          filled: true,
                          fillColor: Color(0xFFE8F0E8), // Light mossy green
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: Color(0xFF4A7043), width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.red.shade700),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Colors.red.shade700, width: 2),
                          ),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      // Login Button
                      Consumer<authprovider>(
                        builder: (context, auth, child) {
                          return ElevatedButton(
                            onPressed: auth.isLoading
                                ? null
                                : () async {
                                    print('Login button pressed');
                                    if (_formKey.currentState!.validate()) {
                                      print(
                                          'Form validated, attempting login with email: ${emailController.text}');
                                      try {
                                        await context
                                            .read<authprovider>()
                                            .logIn(
                                              emailController.text.trim(),
                                              passwordController.text.trim(),
                                            );
                                        print(
                                            'Login successful, current user: ${FirebaseAuth.instance.currentUser?.uid}');
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content:
                                                  Text('LogIn Successfully')),
                                        );
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  RecipePage()),
                                        );
                                      } on FirebaseAuthException catch (e) {
                                        print(
                                            'FirebaseAuthException: ${e.code} - ${e.message}');
                                        String errorMessage;
                                        switch (e.code) {
                                          case 'wrong-password':
                                            errorMessage =
                                                'Incorrect password. Please try again.';
                                            break;
                                          case 'user-not-found':
                                            errorMessage =
                                                'No account found with this email.';
                                            break;
                                          case 'invalid-email':
                                            errorMessage =
                                                'Invalid email format.';
                                            break;
                                          case 'too-many-requests':
                                            errorMessage =
                                                'Too many login attempts. Please try again later.';
                                            break;
                                          case 'network-request-failed':
                                            errorMessage =
                                                'Network error. Please check your connection.';
                                            break;
                                          case 'invalid-credential':
                                            errorMessage =
                                                'Invalid credentials. Please check your email and password.';
                                            break;
                                          default:
                                            errorMessage =
                                                'Login failed: ${e.message ?? e.toString()}';
                                        }
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(content: Text(errorMessage)),
                                        );
                                      } catch (e) {
                                        print('Unexpected error: $e');
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content:
                                                  Text('Login failed: $e')),
                                        );
                                      }
                                    } else {
                                      print('Form validation failed');
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF4A7043),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 6,
                              shadowColor: Colors.black.withOpacity(0.3),
                            ),
                            child: auth.isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text(
                                    'Login',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      // Register Button
                      TextButton(
                        onPressed: () {
                          print('Register button pressed');
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => RegisterScreen()),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor:
                              Color(0xFF6B8E23), // Slightly lighter mossy green
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        child: const Text('Register'),
                      ),
                    ],
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
