import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Providers/AuthProvider.dart';
import '../Screens/HomeScreen.dart';
import 'SignUpScreen.dart';
import 'ProfileSetupScreen.dart';
import '../Admin/AdminDashboard.dart';
import '../Services/NotificationService.dart';
import '../Widgets/AuthWidgets.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  AuthTextField(
                    controller: _emailController,
                    label: "Email Address",
                    icon: Icons.email_outlined,
                  ),
                  SizedBox(height: 20),
                  AuthTextField(
                    controller: _passwordController,
                    label: "Password",
                    icon: Icons.lock_outline,
                    isPassword: true,
                    isObscure: _isObscure,
                    isLastField: true,
                    onToggleVisibility: () => setState(() => _isObscure = !_isObscure),
                  ),
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(onPressed: () {}, child: Text("Forgot Password?", style: TextStyle(color: Colors.blue.shade900))),
                  ),
                  SizedBox(height: 30),
                  authProvider.isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () async {
                            String email = _emailController.text.trim();
                            String password = _passwordController.text.trim();

                            // 1. Check for Admin Credentials
                            if (email == "admin@tourism.com" && password == "Sial12345") {
                              // Save Admin FCM Token
                              await NotificationService().saveToken("admin", isAdmin: true);
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminDashboard()));
                              return;
                            }

                            // 2. Normal User Authentication via Firebase
                            String? error = await authProvider.login(email, password);
                            if (error == null) {
                              if (authProvider.userModel!.phone.isEmpty) {
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfileSetupScreen(isEditMode: false)));
                              } else {
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
                            }
                          },
                          style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 60), backgroundColor: Color(0xFF004E92), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                          child: Text("LOGIN", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                  SizedBox(height: 25),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen())),
                    child: RichText(text: TextSpan(text: "New here? ", style: TextStyle(color: Colors.grey), children: [TextSpan(text: "Create Account", style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold))])),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF000428), Color(0xFF004E92)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(50)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.travel_explore, size: 80, color: Colors.amber.shade400),
          SizedBox(height: 20),
          Text("LOGIN", style: GoogleFonts.montserrat(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2)),
          Text("Welcome back, Explorer", style: GoogleFonts.poppins(color: Colors.white60, fontSize: 14)),
        ],
      ),
    );
  }
}

