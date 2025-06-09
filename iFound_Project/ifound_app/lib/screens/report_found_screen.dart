import 'package:flutter/material.dart';
import '../components/ifound_appbar.dart';
import '../components/report_document_form.dart';
import '../components/ifound_background.dart';
import '../components/post_feed_item.dart';

/// Screen for reporting a found document
class ReportFoundScreen extends StatefulWidget {
  const ReportFoundScreen({super.key});
  @override
  State<ReportFoundScreen> createState() => _ReportFoundScreenState();
}

class _ReportFoundScreenState extends State<ReportFoundScreen> {
  final List<PostFeedItem> foundPosts = [
    PostFeedItem(
      name: 'Alice',
      docType: 'Certificate',
      status: 'found',
      sector: 'Nyarugenge Police Station',
      timeAgo: '1h ago',
    ),
    PostFeedItem(
      name: 'Jane Doe',
      docType: 'National ID',
      status: 'found',
      sector: 'Kacyiru Police Station',
      timeAgo: '2h ago',
    ),
  ];

  void _showAddFoundDocumentForm() {
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
          title: 'Report Found Document',
          buttonText: 'Submit Found Report',
          status: 'found',
          onSubmit: (name, docType, institution, sector) {
            Navigator.of(context).pop();
            setState(() {
              foundPosts.insert(0, PostFeedItem(
                name: name,
                docType: docType,
                status: 'found',
                sector: sector,
                timeAgo: 'just now',
              ));
            });
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Report Submitted'),
                content: const Text('Thank you for reporting! The owner will be notified if a match is found.'),
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
        appBar: const IFoundAppBar(title: 'Found Documents'),
        body: ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: foundPosts.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) => foundPosts[index],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddFoundDocumentForm,
          backgroundColor: Colors.green,
          child: const Icon(Icons.add, color: Colors.white),
          tooltip: 'Add Found Document',
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}