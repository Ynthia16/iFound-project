import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/ifound_appbar.dart';
import '../components/ifound_background.dart';

class FeedbackWallScreen extends StatelessWidget {
  const FeedbackWallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock feedback data
    final feedbacks = [
      {
        'name': 'Jane Doe',
        'rating': 5,
        'comment': 'Amazing service! Got my ID back quickly.',
        'time': '2h ago',
      },
      {
        'name': 'John Smith',
        'rating': 4,
        'comment': 'Easy to use and very helpful.',
        'time': '5h ago',
      },
      {
        'name': 'Alice',
        'rating': 5,
        'comment': 'Great community and safe process.',
        'time': '1d ago',
      },
    ];
    final num sum = feedbacks.fold<num>(0, (sum, f) => sum + (f['rating'] as int));
    final avgRating = feedbacks.isNotEmpty ? (sum / feedbacks.length).toStringAsFixed(1) : '0.0';
    return IFoundBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: Theme.of(context).colorScheme.primary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text('Feedback Wall', style: GoogleFonts.poppins(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 36),
                    const SizedBox(width: 12),
                    Text(
                      '$avgRating',
                      style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2196F3)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${feedbacks.length} reviews)',
                      style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ...feedbacks.map((f) => Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Row(
                          children: List.generate(5, (i) => Icon(
                            i < (f['rating'] as int) ? Icons.star_rounded : Icons.star_border_rounded,
                            color: Color(0xFFFFC107),
                            size: 20,
                          )),
                        ),
                        const SizedBox(width: 8),
                        Text(f['name'] as String, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        const Spacer(),
                        Text(f['time'] as String, style: GoogleFonts.poppins(color: Colors.black45, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(f['comment'] as String, style: GoogleFonts.poppins(fontSize: 15)),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}