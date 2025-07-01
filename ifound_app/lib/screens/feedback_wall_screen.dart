import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

class CommunityWallScreen extends StatefulWidget {
  const CommunityWallScreen({super.key});
  @override
  State<CommunityWallScreen> createState() => _CommunityWallScreenState();
}

class _CommunityWallScreenState extends State<CommunityWallScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false;
  int _selectedRating = 0;

  @override
  void initState() {
    super.initState();
    // Removed auto-popup - users will manually trigger rating via FAB
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _showRatingPrompt() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildRatingDialog(),
    );
  }

  Widget _buildRatingDialog() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final padding = isSmallScreen ? 16.0 : 20.0;
    final iconSize = isSmallScreen ? 40.0 : 56.0;
    final starSize = isSmallScreen ? 36.0 : 48.0;
    final titleSize = isSmallScreen ? 18.0 : 22.0;
    final bodySize = isSmallScreen ? 14.0 : 16.0;
    
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + (isSmallScreen ? 16 : 20),
          top: isSmallScreen ? 16 : 20,
          left: padding,
          right: padding,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag indicator
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: isSmallScreen ? 20 : 28),
              
              // Star icon with animation
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.star_rounded,
                  size: iconSize,
                  color: Colors.amber[600],
                ),
              ),
              SizedBox(height: isSmallScreen ? 20 : 24),
              
              // Title
              Text(
                'How was your experience?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: titleSize,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isSmallScreen ? 8 : 12),
              
              // Subtitle
              Text(
                'Your feedback helps us improve iFound for everyone',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: bodySize,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isSmallScreen ? 28 : 36),
              
              // Star rating
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedRating = index + 1);
                      HapticFeedback.lightImpact();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 6 : 8),
                      child: Icon(
                        index < _selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                        size: starSize,
                        color: index < _selectedRating ? Colors.amber[600] : Colors.grey[400],
                      ),
                    ),
                  );
                }),
              ),
              
              // Rating text
              if (_selectedRating > 0) ...[
                SizedBox(height: isSmallScreen ? 16 : 20),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16 : 20,
                    vertical: isSmallScreen ? 8 : 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.amber.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getRatingText(_selectedRating),
                    style: TextStyle(
                      color: Colors.amber[700],
                      fontWeight: FontWeight.w600,
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                ),
              ],
              
              SizedBox(height: isSmallScreen ? 24 : 32),
              
              // Feedback section (always visible)
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            color: Theme.of(context).colorScheme.primary,
                            size: isSmallScreen ? 18 : 20,
                          ),
                          SizedBox(width: isSmallScreen ? 8 : 10),
                          Text(
                            'Share your thoughts (optional)',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      TextField(
                        controller: _feedbackController,
                        maxLines: 4,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Tell us what you think about iFound...',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black38,
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: isDark ? Colors.grey[800] : Colors.white,
                          contentPadding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isSmallScreen ? 20 : 24),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _feedbackController.clear();
                        _selectedRating = 0;
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 14 : 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Skip', 
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 12 : 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (_selectedRating > 0 || _feedbackController.text.trim().isNotEmpty) ? _submitRating : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 14 : 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isSubmitting
                          ? SizedBox(
                              height: isSmallScreen ? 16 : 20,
                              width: isSmallScreen ? 16 : 20,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Submit', 
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 16 : 20),
            ],
          ),
        ),
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }

  void _submitRating() async {
    if (_selectedRating == 0 && _feedbackController.text.trim().isEmpty) return;

    setState(() => _isSubmitting = true);
    final user = FirebaseAuth.instance.currentUser;

    try {
      await _firestoreService.addFeedback(
        userId: user?.uid ?? 'anonymous',
        feedback: _feedbackController.text.trim(),
        rating: _selectedRating,
        userName: user?.displayName ?? 'Anonymous',
      );

      if (mounted) {
        Navigator.of(context).pop();
        _feedbackController.clear();
        _selectedRating = 0;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Thank you for your feedback!'),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit feedback: ${e.toString()}'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Widget _buildStatsCard(bool isSmallScreen) {
    final margin = isSmallScreen ? 12.0 : 16.0;
    final padding = isSmallScreen ? 16.0 : 20.0;
    final iconSize = isSmallScreen ? 24.0 : 32.0;
    final titleSize = isSmallScreen ? 18.0 : 22.0;
    final bodySize = isSmallScreen ? 14.0 : 16.0;
    
    return Container(
      margin: EdgeInsets.all(margin),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2196F3),
            Color(0xFF1976D2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2196F3).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Community Impact',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: titleSize,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 2 : 4),
                    Text(
                      'Join thousands helping each other',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: bodySize,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.people_rounded,
                  color: Colors.white,
                  size: iconSize,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Documents\nFound', '1,234+', Icons.folder_open, isSmallScreen),
              _buildStatItem('Happy\nUsers', '5,678+', Icons.favorite, isSmallScreen),
              _buildStatItem('Success\nRate', '98%', Icons.trending_up, isSmallScreen),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, bool isSmallScreen) {
    final iconSize = isSmallScreen ? 16.0 : 20.0;
    final valueSize = isSmallScreen ? 16.0 : 20.0;
    final labelSize = isSmallScreen ? 12.0 : 14.0;
    
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: iconSize),
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: valueSize,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.9),
            fontSize: labelSize,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeedbackCard(Map<String, dynamic> data, bool isSmallScreen) {
    final rating = data['rating'] ?? 0;
    final feedback = data['feedback'] ?? '';
    final userName = data['userName'] ?? 'Anonymous';
    final timestamp = data['timestamp'] as Timestamp?;
    final likes = List<String>.from(data['likes'] ?? []);
    final replies = List<Map<String, dynamic>>.from(data['replies'] ?? []);
    final feedbackId = data['id'] ?? '';
    final currentUser = FirebaseAuth.instance.currentUser;
    final isLiked = currentUser != null && likes.contains(currentUser.uid);
    
    final margin = isSmallScreen ? 8.0 : 16.0;
    final padding = isSmallScreen ? 12.0 : 16.0;
    final avatarSize = isSmallScreen ? 32.0 : 40.0;
    final starSize = isSmallScreen ? 16.0 : 20.0;
    final iconSize = isSmallScreen ? 18.0 : 20.0;
    final titleSize = isSmallScreen ? 16.0 : 18.0;
    final bodySize = isSmallScreen ? 14.0 : 16.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: margin, vertical: isSmallScreen ? 6 : 8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: avatarSize / 2,
                    backgroundColor: const Color(0xFF2196F3),
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'A',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 8 : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: titleSize,
                          ),
                        ),
                        if (timestamp != null)
                          Text(
                            _formatTimestamp(timestamp),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                              fontSize: isSmallScreen ? 12 : 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (rating > 0) ...[
                SizedBox(height: isSmallScreen ? 8 : 12),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: starSize,
                      color: index < rating ? Colors.amber[600] : Colors.grey[400],
                    );
                  }),
                ),
              ],
              if (feedback.isNotEmpty) ...[
                SizedBox(height: isSmallScreen ? 8 : 12),
                Text(
                  feedback,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: bodySize,
                  ),
                ),
              ],
              SizedBox(height: isSmallScreen ? 12 : 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Like button
                  Flexible(
                    child: GestureDetector(
                      onTap: () {
                        if (currentUser != null) {
                          _firestoreService.toggleFeedbackLike(
                            feedbackId: feedbackId,
                            userId: currentUser.uid,
                          );
                          HapticFeedback.lightImpact();
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            size: iconSize,
                            color: isLiked ? Colors.red[600] : Colors.grey[600],
                          ),
                          SizedBox(width: isSmallScreen ? 3 : 4),
                          Flexible(
                            child: Text(
                              '${likes.length}',
                              style: TextStyle(
                                color: isLiked ? Colors.red[600] : Colors.grey[600],
                                fontWeight: FontWeight.w500,
                                fontSize: isSmallScreen ? 13 : 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 16 : 24),
                  // Reply button
                  Flexible(
                    child: GestureDetector(
                      onTap: () => _showReplyDialog(feedbackId, userName),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.reply_rounded,
                            size: iconSize,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: isSmallScreen ? 3 : 4),
                          Flexible(
                            child: Text(
                              '${replies.length}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                                fontSize: isSmallScreen ? 13 : 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Show replies if any
              if (replies.isNotEmpty) ...[
                SizedBox(height: isSmallScreen ? 8 : 12),
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).dividerTheme.color ?? Colors.grey[300]!,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Replies',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 6 : 8),
                      ...replies.map((reply) => _buildReplyItem(reply, isSmallScreen)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReplyItem(Map<String, dynamic> reply, bool isSmallScreen) {
    final replyText = reply['reply'] ?? '';
    final replyUserName = reply['userName'] ?? 'Anonymous';
    final replyTimestamp = reply['timestamp'] as Timestamp?;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  replyUserName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              if (replyTimestamp != null)
                Flexible(
                  child: Text(
                    _formatTimestamp(replyTimestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                      fontSize: isSmallScreen ? 11 : 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            replyText,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  void _showReplyDialog(String feedbackId, String originalUserName) {
    final replyController = TextEditingController();
    final currentUser = FirebaseAuth.instance.currentUser;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Reply to $originalUserName',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 18 : 22,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: replyController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Your reply',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.reply_rounded, size: isSmallScreen ? 20 : 24),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12 : 16,
                      vertical: isSmallScreen ? 12 : 16,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: replyController.text.trim().isEmpty ? null : () async {
                          final navigator = Navigator.of(context);
                          final scaffoldMessenger = ScaffoldMessenger.of(context);
                          try {
                            await _firestoreService.addFeedbackReply(
                              feedbackId: feedbackId,
                              userId: currentUser?.uid ?? 'anonymous',
                              reply: replyController.text.trim(),
                              userName: currentUser?.displayName ?? 'Anonymous',
                            );
                            if (mounted) {
                              navigator.pop();
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: const Text('Reply posted successfully!'),
                                  backgroundColor: Colors.green[600],
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Text('Failed to post reply: ${e.toString()}'),
                                  backgroundColor: Colors.red[600],
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Post Reply',
                          style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final padding = isSmallScreen ? 16.0 : 20.0;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Community Wall'.tr(),
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            fontWeight: FontWeight.w600,
            fontSize: isSmallScreen ? 16 : 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
        ),
        actions: [
          IconButton(
            onPressed: () => _showRatingPrompt(),
            icon: Icon(
              Icons.rate_review,
              color: const Color(0xFF2196F3),
              size: isSmallScreen ? 20 : 24,
            ),
            tooltip: 'Rate & Review',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatsCard(isSmallScreen),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestoreService.getFeedback(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: isSmallScreen ? 48 : 64,
                          color: isDark ? Colors.grey[600] : Colors.grey[400],
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        Text(
                          'Be the first to share your experience!',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: isDark ? Colors.white70 : Colors.grey[600],
                            fontSize: isSmallScreen ? 16 : 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: isSmallScreen ? 6 : 8),
                        Text(
                          'Your feedback helps us improve iFound',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white54 : Colors.grey[500],
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final docs = snapshot.data!.docs;
                return ListView.builder(
                  padding: EdgeInsets.only(
                    left: padding,
                    right: padding,
                    bottom: isSmallScreen ? 120 : 140
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = {
                      'id': doc.id,
                      ...doc.data() as Map<String, dynamic>,
                    };
                    return _buildFeedbackCard(data, isSmallScreen);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRatingPrompt(),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        icon: Icon(Icons.rate_review, size: isSmallScreen ? 20 : 24),
        label: Text(
          'Rate & Review',
          style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
        ),
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}