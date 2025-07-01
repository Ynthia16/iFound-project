import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IFoundTextField extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool showPasswordToggle;
  
  const IFoundTextField({
    super.key,
    required this.label,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.showPasswordToggle = false,
  });

  @override
  State<IFoundTextField> createState() => _IFoundTextFieldState();
}

class _IFoundTextFieldState extends State<IFoundTextField> {
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final borderColor = isDark ? Colors.grey[600]! : Colors.grey[300]!;
    final labelColor = isDark ? Colors.white70 : Colors.black54;
    final iconColor = isDark ? Colors.white70 : Colors.grey[600]!;
    
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      style: GoogleFonts.poppins(
        fontSize: 16,
        color: textColor,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: GoogleFonts.poppins(
          fontSize: 16,
          color: labelColor,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(width: 2, color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(width: 2, color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(width: 2, color: Color(0xFF2196F3)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        filled: true,
        fillColor: isDark ? const Color(0xFF1A1A1A) : Colors.grey[50],
        suffixIcon: widget.showPasswordToggle ? IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            color: iconColor,
            size: 24,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ) : null,
      ),
    );
  }
} 