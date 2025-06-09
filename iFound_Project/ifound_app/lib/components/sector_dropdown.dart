import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      return const CircularProgressIndicator();
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
            widget.onChanged(selection == 'Other' ? null : selection);
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            controller.text = _selected ?? '';
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: const InputDecoration(
                labelText: 'Sector/Station',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                setState(() {
                  _selected = val;
                  _isOther = val == 'Other';
                });
                if (val != 'Other') widget.onChanged(val);
              },
            );
          },
        ),
        if (_isOther)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: TextField(
              controller: _otherController,
              decoration: const InputDecoration(
                labelText: 'Enter sector or police station',
                border: OutlineInputBorder(),
              ),
              onChanged: widget.onChanged,
            ),
          ),
      ],
    );
  }
}