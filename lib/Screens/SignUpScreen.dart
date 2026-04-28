import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Providers/AuthProvider.dart';
import 'ProfileSetupScreen.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
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
                  _buildTextField(_nameController, "Full Name", Icons.person_outline),
                  SizedBox(height: 20),
                  _buildTextField(_emailController, "Email Address", Icons.email_outlined),
                  SizedBox(height: 20),
                  _buildTextField(_passwordController, "Password", Icons.lock_outline, isPassword: true),
                  SizedBox(height: 40),
                  authProvider.isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () async {
                            String? error = await authProvider.signUp(
                              _emailController.text,
                              _passwordController.text,
                              _nameController.text,
                            );
                            if (error == null) {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfileSetupScreen(isEditMode: false)));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
                            }
                          },
                          style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 60), backgroundColor: Color(0xFF004E92), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                          child: Text("CREATE ACCOUNT", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                  SizedBox(height: 25),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: RichText(text: TextSpan(text: "Already a member? ", style: TextStyle(color: Colors.grey), children: [TextSpan(text: "Login", style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold))])),
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
      height: 260,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF000428), Color(0xFF004E92)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(50)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_add_outlined, size: 60, color: Colors.amber.shade400),
          SizedBox(height: 15),
          Text("JOIN US", style: GoogleFonts.montserrat(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2)),
          Text("Begin your luxury journey today", style: GoogleFonts.poppins(color: Colors.white60, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword && _isObscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade900),
        suffixIcon: isPassword ? IconButton(icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _isObscure = !_isObscure)) : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.blue.shade900, width: 1.5)),
      ),
    );
  }
}
