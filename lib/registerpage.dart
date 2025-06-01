import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:food_recipe_finder/Authprovider.dart';
import 'package:food_recipe_finder/LogInScreen.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpasswordController =
      TextEditingController();

  bool verificationSent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFF4A7043), // Mossy hollow
        child: Center(
          child: SingleChildScrollView(
            // Scrolling effect
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
                      'Create Account',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A7043),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    Text(
                      'Join Recipe Finder',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),

                    // Name Field
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(color: Color(0xFF4A7043)),
                        prefixIcon:
                            Icon(Icons.person, color: Color(0xFF4A7043)),
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
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Email Field
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Color(0xFF4A7043)),
                        prefixIcon: Icon(Icons.email, color: Color(0xFF4A7043)),
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
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 16),

                    // Password Field
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Color(0xFF4A7043)),
                        prefixIcon: Icon(Icons.lock, color: Color(0xFF4A7043)),
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
                      ),
                      obscureText: true,
                    ),

                    const SizedBox(height: 16),

                    // Confirm Password Field
                    TextField(
                      controller: confirmpasswordController,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        labelStyle: TextStyle(color: Color(0xFF4A7043)),
                        prefixIcon: Icon(Icons.lock, color: Color(0xFF4A7043)),
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
                      ),
                      obscureText: true,
                    ),

                    const SizedBox(height: 24),

                    // Register Button
                    Consumer<authprovider>(
                      builder: (context, auth, child) {
                        return ElevatedButton(
                          onPressed: auth.isLoading
                              ? null
                              : () async {
                                  if (passwordController.text !=
                                      confirmpasswordController.text) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Confirm password does not match with password',
                                        ),
                                      ),
                                    );
                                  } else {
                                    try {
                                      await context
                                          .read<authprovider>()
                                          .register(
                                            nameController.text,
                                            emailController.text,
                                            passwordController.text,
                                          );

                                      setState(() {
                                        verificationSent = true;
                                      });

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Verification email sent. Check your inbox.'),
                                        ),
                                      );
                                    } on FirebaseException catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text('Registration: $e'),
                                        ),
                                      );
                                    }
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
                                  'Register',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    if (verificationSent) ...[
                      Text(
                        "After clicking the email verification link, click below.",
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade800),
                        textAlign: TextAlign.center,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            final auth = context.read<authprovider>();
                            final User = auth.user;

                            if (User != null) {
                              await auth.checkEmailVerificationAndSaveData(
                                  User.uid,
                                  nameController.text,
                                  emailController.text);
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Email is verified and Data Saved'),
                              ),
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => LogInScreen()),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text("Email not verified yet. Try again."),
                              ),
                            );
                          }
                        },
                        child: Text("I have verified my email"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],

                    const SizedBox(
                      height: 16,
                    ),

                    // Login Link
                    InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LogInScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Already have an account? Click here!',
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              Color(0xFF6B8E23), // Slightly lighter mossy green
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
