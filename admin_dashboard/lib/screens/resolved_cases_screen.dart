import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResolvedCasesScreen extends StatefulWidget {
  const ResolvedCasesScreen({super.key});

  @override
  State<ResolvedCasesScreen> createState() => _ResolvedCasesScreenState();
}

class _ResolvedCasesScreenState extends State<ResolvedCasesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _reports = [];
  List<Map<String, dynamic>> _filteredReports = [];
  bool _isLoading = true;
  String _searchQuery = '';
  Stream<QuerySnapshot>? _reportsStream;

  @override
  void initState() {
    super.initState();
    _setupStream();
  }

  void _setupStream() {
    _reportsStream = _firestore
        .collection('reports')
        .where('status', whereIn: ['lost', 'matched'])
        .snapshots();
    _reportsStream!.listen((snapshot) {
      final reports = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
      setState(() {
        _reports = reports;
        _filteredReports = reports;
        _isLoading = false;
      });
      _applyFilter();
    });
  }

  void _applyFilter() {
    setState(() {
      _filteredReports = _reports.where((report) {
        final name = report['name']?.toString().toLowerCase() ?? '';
        final docType = report['docType']?.toString().toLowerCase() ?? '';
        return name.contains(_searchQuery.toLowerCase()) ||
            docType.contains(_searchQuery.toLowerCase());
      }).toList();
    });
  }

  Future<void> _markAsResolved(String reportId) async {
    try {
      await _firestore.collection('reports').doc(reportId).update({
        'status': 'resolved',
        'isResolved': true,
        'resolvedAt': DateTime.now().toIso8601String(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Report marked as resolved!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to mark as resolved. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Resolved Cases Management',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mark reports as resolved when items have been successfully returned to their owners.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),

          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search by name or document type',
                hintText: 'Enter name or document type...',
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
                _applyFilter();
              },
            ),
          ),
          const SizedBox(height: 24),

          // Results
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _filteredReports.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 64,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty 
                                  ? 'No unresolved reports found'
                                  : 'No reports match your search',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchQuery.isEmpty 
                                  ? 'All reports have been resolved!'
                                  : 'Try adjusting your search terms',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredReports.length,
                        itemBuilder: (context, index) {
                          final report = _filteredReports[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Icon
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      report['type'] == 'lost' ? Icons.assignment_late : Icons.assignment_turned_in,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  
                                  // Content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          report['name']?.toString() ?? 'Unknown',
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${report['docType']?.toString() ?? 'Unknown'} • ${report['sector']?.toString() ?? 'N/A'}',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Status: ${report['status']?.toString().toUpperCase() ?? 'UNKNOWN'}',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: report['status'] == 'matched' 
                                                ? Colors.orange 
                                                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Action Button
                                  ElevatedButton.icon(
                                    onPressed: () => _markAsResolved(report['id']),
                                    icon: const Icon(Icons.check_circle, size: 18),
                                    label: const Text('Mark Resolved'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
} 