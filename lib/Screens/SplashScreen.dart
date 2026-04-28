import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Providers/AuthProvider.dart';
import 'WelcomeScreen.dart';
import 'HomeScreen.dart';
import 'ProfileSetupScreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 2000));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
    _navigateToNext();
  }

  void _navigateToNext() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Wait for animation and auth init
    await Future.wait([
      Future.delayed(Duration(seconds: 3)),
      _waitForInit(authProvider),
    ]);

    if (!mounted) return;
    
    if (authProvider.userModel != null) {
      if (authProvider.userModel!.phone.isEmpty) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfileSetupScreen(isEditMode: false)));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
      }
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => WelcomeScreen()));
    }
  }

  Future<void> _waitForInit(AuthProvider auth) async {
    while (!auth.isInitialised) {
      await Future.delayed(Duration(milliseconds: 100));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF000428), Color(0xFF004E92), Color(0xFF000428)],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white10,
                  border: Border.all(color: Colors.white24),
                ),
                child: Icon(Icons.travel_explore, size: 80, color: Colors.amber.shade400),
              ),
              SizedBox(height: 30),
              Text(
                "SMART TOURISM",
                style: GoogleFonts.montserrat(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 4,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "DISCOVER THE UNKNOWN",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white60,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: 60),
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  color: Colors.amber.shade400,
                  strokeWidth: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
