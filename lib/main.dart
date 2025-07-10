import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:food_recipe_finder/Authprovider.dart';
import 'package:food_recipe_finder/LogInScreen.dart';
import 'package:food_recipe_finder/recipe_page.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('Initializing Firebase...');
  try {
    await Firebase.initializeApp();
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed: $e');
  }
  try {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.safetyNet,
      appleProvider: AppleProvider.deviceCheck,
    );
    print('FirebaseAppCheck activated');
  } catch (e) {
    print('FirebaseAppCheck activation failed: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => authprovider(),
      child: MaterialApp(
        title: 'Recipe Finder',
        theme: ThemeData(
          primaryColor: Color(0xFF4A7043), 
          hintColor: Color(0xFFF4A261), 
          scaffoldBackgroundColor: Color(0xFFF8EDE3), 
          textTheme: TextTheme(
            headlineLarge: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A7043), 
            ),
            bodyMedium: TextStyle(
              fontSize: 16,
              color: Color(0xFF5C6B73), 
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFF4A261), 
              foregroundColor: Colors.white, 
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), 
              ),
            ),
          ),
          progressIndicatorTheme: ProgressIndicatorThemeData(
            color: Color(0xFFA8D5BA), 
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize animation
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();

    // Navigate after delay
    Future.delayed(Duration(seconds: 2), () async {
      User? user = FirebaseAuth.instance.currentUser;
      await user?.reload();

      if (user != null && user.emailVerified) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RecipePage()),
        );
      } else {
        if (user != null && !user.emailVerified) {
          await FirebaseAuth.instance.signOut();

        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LogInScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4A7043), 
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.restaurant_menu,
                size: 120,
                color: Color(0xFFF8EDE3), 
              ),
              SizedBox(height: 20),
              Text(
                'Recipe Finder',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF8EDE3), 
                  letterSpacing: 1.2,
                  fontFamily:
                      'Poppins', 
                ),
              ),
              SizedBox(height: 30),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFFA8D5BA), 
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
