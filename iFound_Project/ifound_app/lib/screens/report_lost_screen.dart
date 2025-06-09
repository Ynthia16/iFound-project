import 'package:flutter/material.dart';
import '../components/ifound_appbar.dart';
import '../components/report_document_form.dart';
import '../components/ifound_background.dart';
import '../components/post_feed_item.dart';

/// Screen for reporting a lost document
class ReportLostScreen extends StatefulWidget {
  const ReportLostScreen({super.key});
  @override
  State<ReportLostScreen> createState() => _ReportLostScreenState();
}

class _ReportLostScreenState extends State<ReportLostScreen> {
  final List<PostFeedItem> lostPosts = [
    PostFeedItem(
      name: 'John Smith',
      docType: 'School Card',
      status: 'lost',
      sector: 'Remera Sector Office',
      timeAgo: '3h ago',
    ),
    PostFeedItem(
      name: 'Jane Doe',
      docType: 'National ID',
      status: 'lost',
      sector: 'Kacyiru Police Station',
      timeAgo: '5h ago',
    ),
  ];

  void _showAddLostDocumentForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ReportDocumentForm(
          title: 'Report Lost Document',
          buttonText: 'Submit Lost Report',
          status: 'lost',
          onSubmit: (name, docType, institution, sector) {
            Navigator.of(context).pop();
            setState(() {
              lostPosts.insert(0, PostFeedItem(
                name: name,
                docType: docType,
                status: 'lost',
                sector: sector,
                timeAgo: 'just now',
              ));
            });
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Report Submitted'),
                content: const Text('Your lost document report has been submitted. We will notify you if a match is found.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IFoundBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const IFoundAppBar(title: 'Lost Documents'),
        body: ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: lostPosts.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) => lostPosts[index],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddLostDocumentForm,
          backgroundColor: Colors.red,
          child: const Icon(Icons.add, color: Colors.white),
          tooltip: 'Add Lost Document',
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}