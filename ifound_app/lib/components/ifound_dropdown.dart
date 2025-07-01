import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IFoundDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  const IFoundDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final borderColor = isDark ? Colors.grey[600]! : Colors.grey[300]!;
    final labelColor = isDark ? Colors.white70 : Colors.black54;
    
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      isExpanded: true,
      style: GoogleFonts.poppins(
        fontSize: 16,
        color: textColor,
      ),
      dropdownColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: isDark ? Colors.white70 : Colors.black54,
      ),
      decoration: InputDecoration(
        labelText: label,
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
      ),
    );
  }
} 