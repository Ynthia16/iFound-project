import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLost = status == 'lost';
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark 
              ? Colors.black.withOpacity(0.2)
              : Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // TODO: Navigate to report details
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isLost 
                      ? Colors.red.withOpacity(isDark ? 0.2 : 0.1)
                      : Colors.green.withOpacity(isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Icon(
                    isLost ? Icons.search_rounded : Icons.check_circle_rounded,
                    color: isLost ? Colors.red[400] : Colors.green[400],
                    size: 28,
                  ),
                ),
                const SizedBox(width: 18),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        isLost ? 'Lost: $docType' : 'Found: $docType',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 18,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Details
                      Text(
                        '$name • $sector',
                        style: GoogleFonts.poppins(
                          color: isDark ? Colors.grey[300] : Colors.grey[600],
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Time
                      Text(
                        timeAgo,
                        style: GoogleFonts.poppins(
                          color: isDark ? Colors.grey[400] : Colors.grey[500],
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow indicator
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: isDark ? Colors.grey[400] : Colors.grey[300],
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 