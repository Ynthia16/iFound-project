import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class AdvancedSearchFilter extends StatefulWidget {
  final Function(Map<String, dynamic>) onFiltersChanged;
  final Map<String, dynamic> currentFilters;

  const AdvancedSearchFilter({
    super.key,
    required this.onFiltersChanged,
    required this.currentFilters,
  });

  @override
  State<AdvancedSearchFilter> createState() => _AdvancedSearchFilterState();
}

class _AdvancedSearchFilterState extends State<AdvancedSearchFilter> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'all';
  String _selectedDocType = 'all';
  String _selectedSector = 'all';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _showAdvancedFilters = false;

  // Document types
  final List<String> _documentTypes = [
    'all',
    'National ID',
    'Passport',
    'Driver License',
    'Student ID',
    'Bank Card',
    'Insurance Card',
    'Medical Card',
    'Academic Certificate',
    'Birth Certificate',
    'Marriage Certificate',
    'Other',
  ];

  // Sectors (from Rwanda locations)
  final List<String> _sectors = [
    'all',
    'Kigali',
    'Gasabo',
    'Kicukiro',
    'Nyarugenge',
    'Eastern Province',
    'Bugesera',
    'Gatsibo',
    'Kayonza',
    'Kirehe',
    'Ngoma',
    'Nyagatare',
    'Rwamagana',
    'Northern Province',
    'Burera',
    'Gakenke',
    'Gicumbi',
    'Musanze',
    'Rulindo',
    'Southern Province',
    'Gisagara',
    'Huye',
    'Kamonyi',
    'Muhanga',
    'Nyamagabe',
    'Nyanza',
    'Nyaruguru',
    'Ruhango',
    'Western Province',
    'Karongi',
    'Ngororero',
    'Nyabihu',
    'Nyamasheke',
    'Rubavu',
    'Rusizi',
    'Rutsiro',
  ];

  @override
  void initState() {
    super.initState();
    _initializeFilters();
  }

  void _initializeFilters() {
    _searchController.text = widget.currentFilters['search'] ?? '';
    _selectedStatus = widget.currentFilters['status'] ?? 'all';
    _selectedDocType = widget.currentFilters['docType'] ?? 'all';
    _selectedSector = widget.currentFilters['sector'] ?? 'all';
    _startDate = widget.currentFilters['startDate'];
    _endDate = widget.currentFilters['endDate'];
  }

  void _applyFilters() {
    final filters = {
      'search': _searchController.text.trim(),
      'status': _selectedStatus,
      'docType': _selectedDocType,
      'sector': _selectedSector,
      'startDate': _startDate,
      'endDate': _endDate,
    };

    widget.onFiltersChanged(filters);
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedStatus = 'all';
      _selectedDocType = 'all';
      _selectedSector = 'all';
      _startDate = null;
      _endDate = null;
    });

    widget.onFiltersChanged({
      'search': '',
      'status': 'all',
      'docType': 'all',
      'sector': 'all',
      'startDate': null,
      'endDate': null,
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2196F3),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
      _applyFilters();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, document type, or location...'.tr(),
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _applyFilters();
                        },
                        icon: const Icon(Icons.clear_rounded),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF1A1A1A) : Colors.grey[50],
              ),
              onChanged: (value) => _applyFilters(),
            ),
          ),

          // Quick Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildQuickFilter(
                    'Status',
                    _selectedStatus,
                    ['all', 'lost', 'found'],
                    (value) {
                      setState(() => _selectedStatus = value);
                      _applyFilters();
                    },
                    isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickFilter(
                    'Type',
                    _selectedDocType,
                    _documentTypes.take(6).toList(),
                    (value) {
                      setState(() => _selectedDocType = value);
                      _applyFilters();
                    },
                    isDark,
                  ),
                ),
              ],
            ),
          ),

          // Advanced Filters Toggle
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _showAdvancedFilters = !_showAdvancedFilters;
                      });
                    },
                    icon: Icon(
                      _showAdvancedFilters
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                    ),
                    label: Text(
                      _showAdvancedFilters
                          ? 'Hide Advanced Filters'.tr()
                          : 'Show Advanced Filters'.tr(),
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear_all_rounded),
                  label: Text('Clear All'.tr()),
                ),
              ],
            ),
          ),

          // Advanced Filters
          if (_showAdvancedFilters) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A1A) : Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  // Document Type Filter
                  _buildDropdownFilter(
                    'Document Type'.tr(),
                    _selectedDocType,
                    _documentTypes,
                    (value) {
                      setState(() => _selectedDocType = value);
                      _applyFilters();
                    },
                    isDark,
                  ),
                  const SizedBox(height: 16),

                  // Sector Filter
                  _buildDropdownFilter(
                    'Location/Sector'.tr(),
                    _selectedSector,
                    _sectors,
                    (value) {
                      setState(() => _selectedSector = value);
                      _applyFilters();
                    },
                    isDark,
                  ),
                  const SizedBox(height: 16),

                  // Date Range
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateFilter(
                          'From Date'.tr(),
                          _startDate,
                          () => _selectDate(context, true),
                          isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDateFilter(
                          'To Date'.tr(),
                          _endDate,
                          () => _selectDate(context, false),
                          isDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickFilter(
    String label,
    String selectedValue,
    List<String> options,
    Function(String) onChanged,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 14,
          ),
          items: options.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value == 'all' ? 'All $label'.tr() : value.tr(),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
        ),
      ),
    );
  }

  Widget _buildDropdownFilter(
    String label,
    String selectedValue,
    List<String> options,
    Function(String) onChanged,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 14,
              ),
              items: options.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value == 'all' ? 'All'.tr() : value.tr(),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateFilter(
    String label,
    DateTime? selectedDate,
    VoidCallback onTap,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                        : 'Select Date'.tr(),
                    style: TextStyle(
                      color: selectedDate != null
                          ? (isDark ? Colors.white : Colors.black)
                          : Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}