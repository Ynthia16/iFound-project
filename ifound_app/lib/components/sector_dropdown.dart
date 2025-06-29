import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class SectorDropdown extends StatefulWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  const SectorDropdown({super.key, this.value, required this.onChanged});

  @override
  State<SectorDropdown> createState() => _SectorDropdownState();
}

class _SectorDropdownState extends State<SectorDropdown> {
  List<String> _sectors = [];
  String? _selected;
  bool _loading = true;
  bool _isOther = false;
  final TextEditingController _otherController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSectors();
    _selected = widget.value;
  }

  Future<void> _loadSectors() async {
    final data = await rootBundle.loadString('assets/rwanda_locations.json');
    final json = jsonDecode(data);
    final List<String> sectors = [];
    for (final province in json['provinces']) {
      for (final district in province['districts']) {
        for (final sector in district['sectors']) {
          sectors.add(sector['name']);
        }
      }
    }
    // Will later add  some common police stations or make it a space to write instead of selecting
    sectors.addAll([
      'Kacyiru Police Station',
      'Remera Police Station',
      'Nyarugenge Police Station',
      'Gasabo Police Station',
      'Other',
    ]);
    sectors.sort();
    setState(() {
      _sectors = sectors;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text == '') {
              return _sectors;
            }
            return _sectors.where((s) => s.toLowerCase().contains(textEditingValue.text.toLowerCase()));
          },
          initialValue: TextEditingValue(text: _selected ?? ''),
          onSelected: (String selection) {
            setState(() {
              _selected = selection;
              _isOther = selection == 'Other';
            });
            widget.onChanged(selection);
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            controller.text = _selected ?? '';
            return TextField(
              controller: controller,
              focusNode: focusNode,
              style: GoogleFonts.poppins(fontSize: 16),
              decoration: InputDecoration(
                labelText: 'Sector/Station',
                labelStyle: GoogleFonts.poppins(fontSize: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(width: 2, color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(width: 2, color: Color(0xFF2196F3)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              onChanged: (val) {
                setState(() {
                  _selected = val;
                  _isOther = val == 'Other';
                });
                widget.onChanged(val);
              },
            );
          },
        ),
        if (_isOther)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: TextField(
              controller: _otherController,
              style: GoogleFonts.poppins(fontSize: 16),
              decoration: InputDecoration(
                labelText: 'Enter sector or police station',
                labelStyle: GoogleFonts.poppins(fontSize: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(width: 2, color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(width: 2, color: Color(0xFF2196F3)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              onChanged: (val) {
                setState(() {
                  _selected = val;
                });
                widget.onChanged(val);
              },
            ),
          ),
      ],
    );
  }
}