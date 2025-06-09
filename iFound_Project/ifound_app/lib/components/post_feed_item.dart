import 'package:flutter/material.dart';

class PostFeedItem extends StatelessWidget {
  final String name;
  final String docType;
  final String status; // 'lost' or 'found'
  final String sector;
  final String timeAgo;
  const PostFeedItem({
    super.key,
    required this.name,
    required this.docType,
    required this.status,
    required this.sector,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    final isLost = status == 'lost';
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isLost ? Colors.red[100] : Colors.green[100],
          child: Icon(
            isLost ? Icons.search_rounded : Icons.check_circle_rounded,
            color: isLost ? Colors.red : Colors.green,
          ),
        ),
        title: Text(
          isLost ? 'Lost: $docType' : 'Found: $docType',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('$name • $sector\n$timeAgo'),
        isThreeLine: true,
      ),
    );
  }
} 