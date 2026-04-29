import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../Providers/AuthProvider.dart';
import '../Services/DatabaseService.dart';
import 'HomeScreen.dart';

class ProfileSetupScreen extends StatefulWidget {
  final bool isEditMode;
  const ProfileSetupScreen({Key? key, this.isEditMode = true}) : super(key: key);

  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  String _completePhoneNumber = '';
  XFile? _image;
  bool _isLoading = false;
  bool _isPickerActive = false;
  bool _isObscure = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).userModel;
      if (user != null) {
        setState(() {
          _nameController.text = user.name;
          _emailController.text = user.email;
          _completePhoneNumber = user.phone;
        });
      }
    });
  }

  Future<void> _pickImage() async {
    if (_isPickerActive) return;
    setState(() => _isPickerActive = true);
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
      if (pickedFile != null) {
        setState(() {
          _image = pickedFile;
        });
      }
    } finally {
      setState(() => _isPickerActive = false);
    }
  }

  void _saveProfile() async {
    if (_nameController.text.isEmpty || _completePhoneNumber.isEmpty || (widget.isEditMode && _passwordController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all required fields")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final db = DatabaseService();
      final user = FirebaseAuth.instance.currentUser;

      if (user == null || user.email == null) throw "No user logged in!";

      if (widget.isEditMode) {
        // 1. Verify Password with the active user's email
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!, 
          password: _passwordController.text.trim()
        );
        
        await user.reauthenticateWithCredential(credential);
      }

      // 2. Handle Image Upload
      String profilePicUrl = authProvider.userModel?.profilePic ?? '';
      if (_image != null) profilePicUrl = await db.uploadImage(_image!, 'profile_pics');

      await authProvider.updateUserProfileExtended(_nameController.text.trim(), _completePhoneNumber, profilePicUrl);

      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile Updated!"), backgroundColor: Colors.green));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      String msg = e.toString();
      if (msg.contains('invalid-credential') || msg.contains('wrong-password')) {
        msg = "Incorrect password! Identity not verified.";
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).userModel;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF000428), Color(0xFF004E92)]),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.isEditMode ? "EDIT PROFILE" : "SETUP PROFILE", style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(25),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: _image != null 
                          ? (kIsWeb ? NetworkImage(_image!.path) as ImageProvider : FileImage(File(_image!.path)))
                          : (user?.profilePic != null && user!.profilePic.isNotEmpty 
                              ? CachedNetworkImageProvider(DatabaseService.getCORSProxyUrl(user!.profilePic)) 
                              : null),
                      child: _image == null && (user?.profilePic.isEmpty ?? true) ? Icon(Icons.person, size: 60, color: Colors.grey) : null,
                    ),
                  ),
                  Positioned(bottom: 0, right: 0, child: CircleAvatar(backgroundColor: Colors.blue.shade900, radius: 18, child: Icon(Icons.camera_alt, color: Colors.white, size: 18))),
                ],
              ),
            ),
            SizedBox(height: 30),
            _buildInputCard(),
            SizedBox(height: 30),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 55),
                      backgroundColor: Colors.blue.shade900,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 5,
                    ),
                    child: Text("SAVE CHANGES", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)]),
      child: Column(
        children: [
          _buildTextField(_nameController, "Full Name", Icons.person_outline),
          SizedBox(height: 15),
          _buildTextField(_emailController, "Email Address", Icons.email_outlined, readOnly: true),
          SizedBox(height: 15),
          IntlPhoneField(
            initialValue: Provider.of<AuthProvider>(context, listen: false).userModel?.phone != '' ? Provider.of<AuthProvider>(context, listen: false).userModel?.phone : null,
            decoration: InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)), filled: true, fillColor: Colors.grey.shade50),
            initialCountryCode: 'PK',
            onChanged: (phone) => setState(() => _completePhoneNumber = phone.completeNumber),
          ),
          if (widget.isEditMode) ...[
            Divider(height: 40),
            Text("Confirm Identity", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.redAccent)),
            SizedBox(height: 10),
            _buildTextField(_passwordController, "Login Password", Icons.lock_outline, isPassword: true),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool readOnly = false, bool isPassword = false}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      obscureText: isPassword && _isObscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade900),
        suffixIcon: isPassword ? IconButton(icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _isObscure = !_isObscure)) : null,
        filled: true,
        fillColor: readOnly ? Colors.grey.shade100 : Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}
