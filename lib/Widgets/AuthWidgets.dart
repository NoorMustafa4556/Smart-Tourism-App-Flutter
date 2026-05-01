import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;
  final bool isLastField;
  final VoidCallback? onToggleVisibility;
  final bool isObscure;

  AuthTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.isLastField = false,
    this.onToggleVisibility,
    this.isObscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword && isObscure,
      textInputAction: isLastField ? TextInputAction.done : TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade900),
        suffixIcon: isPassword 
            ? IconButton(
                icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility), 
                onPressed: onToggleVisibility
              ) 
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.blue.shade900, width: 1.5)),
      ),
    );
  }
}
