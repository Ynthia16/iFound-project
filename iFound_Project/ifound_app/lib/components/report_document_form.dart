import 'package:flutter/material.dart';
import 'ifound_textfield.dart';
import 'ifound_dropdown.dart';
import 'ifound_button.dart';
import 'sector_dropdown.dart';

class ReportDocumentForm extends StatefulWidget {
  final String title;
  final String buttonText;
  final void Function(String name, String docType, String institution, String sector) onSubmit;
  final String status; // 'lost' or 'found'
  const ReportDocumentForm({
    super.key,
    required this.title,
    required this.buttonText,
    required this.onSubmit,
    this.status = 'lost',
  });

  @override
  State<ReportDocumentForm> createState() => _ReportDocumentFormState();
}

class _ReportDocumentFormState extends State<ReportDocumentForm> {
  final nameController = TextEditingController();
  String? docType;
  String? institution;
  String? sector;

  final docTypes = const [
    'National ID',
    'School Card',
    'Certificate',
    'Passport',
    'Other',
  ];
  final institutions = const [
    'None',
    'University of Rwanda',
    'Kigali Independent University',
    'High School',
    'Other',
  ];
  final sectors = const [
    'Kacyiru Police Station',
    'Remera Sector Office',
    'Nyarugenge Police Station',
    'Gasabo Sector Office',
    'Other',
  ];

  bool get isValid =>
      nameController.text.isNotEmpty && docType != null && institution != null && sector != null;

  @override
  Widget build(BuildContext context) {
    final isLost = widget.status == 'lost';
    final accentColor = isLost ? Colors.red : Colors.green;
    return Center(
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(isLost ? Icons.search_rounded : Icons.check_circle_rounded, color: accentColor, size: 32),
                  const SizedBox(width: 12),
                  Text(
                    widget.title,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: accentColor),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              IFoundTextField(
                label: 'Full Name on Document',
                controller: nameController,
              ),
              const SizedBox(height: 16),
              IFoundDropdown<String>(
                label: 'Document Type',
                value: docType,
                items: docTypes.map((type) => DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(Icons.description_rounded, color: accentColor, size: 20),
                      const SizedBox(width: 8),
                      Text(type),
                    ],
                  ),
                )).toList(),
                onChanged: (val) => setState(() => docType = val),
              ),
              const SizedBox(height: 16),
              IFoundDropdown<String>(
                label: 'Institution (if any)',
                value: institution,
                items: institutions.map((inst) => DropdownMenuItem(
                  value: inst,
                  child: Row(
                    children: [
                      Icon(Icons.school_rounded, color: Colors.blue[300], size: 20),
                      const SizedBox(width: 8),
                      Text(inst),
                    ],
                  ),
                )).toList(),
                onChanged: (val) => setState(() => institution = val),
              ),
              const SizedBox(height: 16),
              SectorDropdown(
                value: sector,
                onChanged: (val) => setState(() => sector = val),
              ),
              const SizedBox(height: 32),
              IFoundButton(
                text: widget.buttonText,
                onPressed: isValid
                    ? () {
                        widget.onSubmit(
                          nameController.text,
                          docType!,
                          institution!,
                          sector!,
                        );
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 