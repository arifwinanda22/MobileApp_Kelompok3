// Admin/competitionManagement.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_tubes/firebase_service.dart';
import 'package:flutter_application_tubes/Admin/dashboardAdmin.dart';
import 'package:intl/intl.dart';

class CompetitionManagement extends StatefulWidget {
  @override
  _CompetitionManagementState createState() => _CompetitionManagementState();
}

class _CompetitionManagementState extends State<CompetitionManagement> {
  final FirebaseService _firebaseService = FirebaseService();
  
  List<Map<String, dynamic>> _competitions = [];
  Map<String, int> _competitionStats = {};
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterStatus = 'all'; // all, active, inactive, draft
  String _filterCategory = 'all'; // all, akademik, non-akademik

  @override
  void initState() {
    super.initState();
    _loadCompetitionData();
  }

  Future<void> _loadCompetitionData() async {
    try {
      setState(() => _isLoading = true);
      
      // Simulate loading competitions and stats
      // Replace with actual Firebase service calls
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay
      
      setState(() {
        // Mock data - replace with actual Firebase calls
        _competitionStats = {
          'totalCompetitions': 15,
          'activeCompetitions': 8,
          'inactiveCompetitions': 4,
          'draftCompetitions': 3,
        };
        
        _competitions = [
          {
            'id': '1',
            'title': 'Programming Contest 2024',
            'description': 'Annual programming competition for students',
            'category': 'non-akademik',
            'prize': 'Rp 10.000.000',
            'imageUrl': 'https://example.com/image1.jpg',
            'deadline': DateTime.now().add(Duration(days: 30)),
            'status': 'active',
            'participants': 125,
            'createdAt': DateTime.now().subtract(Duration(days: 5)),
          },
          {
            'id': '2',
            'title': 'Essay Writing Competition',
            'description': 'Academic essay writing competition for students',
            'category': 'akademik',
            'prize': 'Rp 7.500.000',
            'imageUrl': 'https://example.com/image2.jpg',
            'deadline': DateTime.now().add(Duration(days: 45)),
            'status': 'active',
            'participants': 89,
            'createdAt': DateTime.now().subtract(Duration(days: 10)),
          },
        ];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load competition data: ${e.toString()}');
    }
  }

  Future<void> _toggleCompetitionStatus(String competitionId, String currentStatus) async {
    try {
      // Implement toggle competition status logic
      _showSuccessSnackBar('Competition status updated successfully');
      _loadCompetitionData(); // Refresh data
    } catch (e) {
      _showErrorSnackBar('Failed to update competition status: ${e.toString()}');
    }
  }

  Future<void> _deleteCompetition(String competitionId) async {
    final confirmed = await _showConfirmDialog(
      'Delete Competition',
      'Are you sure you want to delete this competition? This action cannot be undone.',
    );
    
    if (confirmed) {
      try {
        // Implement delete competition logic
        _showSuccessSnackBar('Competition deleted successfully');
        _loadCompetitionData(); // Refresh data
      } catch (e) {
        _showErrorSnackBar('Failed to delete competition: ${e.toString()}');
      }
    }
  }

  void _showAddCompetitionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _AddCompetitionDialog(
          onCompetitionAdded: () {
            _loadCompetitionData();
          },
        );
      },
    );
  }

  void _showEditCompetitionDialog(Map<String, dynamic> competition) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _EditCompetitionDialog(
          competition: competition,
          onCompetitionUpdated: () {
            _loadCompetitionData();
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> get _filteredCompetitions {
    return _competitions.where((competition) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final title = (competition['title'] ?? '').toLowerCase();
        final category = (competition['category'] ?? '').toLowerCase();
        if (!title.contains(query) && !category.contains(query)) {
          return false;
        }
      }
      
      // Status filter
      if (_filterStatus != 'all') {
        final status = competition['status'] ?? 'active';
        if (status != _filterStatus) return false;
      }
      
      // Category filter
      if (_filterCategory != 'all') {
        final category = competition['category'] ?? 'akademik';
        if (category != _filterCategory) return false;
      }
      
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // Logo dari assets
            Container(
              width: 32,
              height: 32,
              child: Image.asset(
                'assets1/gambar-removebg-preview.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback ke ikon default jika gambar tidak ditemukan
                  return Icon(Icons.emoji_events, size: 28);
                },
              ),
            ),
            SizedBox(width: 10),
            Text('Competition Management'),
          ],
        ),
        backgroundColor: const Color(0xFF999AE6),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadCompetitionData,
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddCompetitionDialog,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statistics Cards
                  _buildStatisticsSection(),
                  
                  SizedBox(height: 20),
                  
                  // Search and Filter Section
                  _buildSearchAndFilterSection(),
                  
                  SizedBox(height: 20),
                  
                  // Competitions List
                  _buildCompetitionsList(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatisticsSection() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Competition Statistics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Competitions',
                  _competitionStats['totalCompetitions']?.toString() ?? '0',
                  Colors.blue,
                  Icons.emoji_events,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Active',
                  _competitionStats['activeCompetitions']?.toString() ?? '0',
                  Colors.green,
                  Icons.play_circle_fill,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Inactive',
                  _competitionStats['inactiveCompetitions']?.toString() ?? '0',
                  Colors.orange,
                  Icons.pause_circle_filled,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Draft',
                  _competitionStats['draftCompetitions']?.toString() ?? '0',
                  Colors.grey,
                  Icons.drafts,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Search Bar
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search competitions...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          
          SizedBox(height: 12),
          
          // Filter Row
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _filterStatus,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: [
                    DropdownMenuItem(value: 'all', child: Text('All Status')),
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                    DropdownMenuItem(value: 'draft', child: Text('Draft')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filterStatus = value ?? 'all';
                    });
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _filterCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: [
                    DropdownMenuItem(value: 'all', child: Text('All Categories')),
                    DropdownMenuItem(value: 'akademik', child: Text('Akademik')),
                    DropdownMenuItem(value: 'non-akademik', child: Text('Non-Akademik')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filterCategory = value ?? 'all';
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompetitionsList() {
    final filteredCompetitions = _filteredCompetitions;
    
    if (filteredCompetitions.isEmpty) {
      return Container(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No competitions found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Competitions (${filteredCompetitions.length})',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: filteredCompetitions.length,
            itemBuilder: (context, index) {
              return _buildCompetitionCard(filteredCompetitions[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompetitionCard(Map<String, dynamic> competition) {
    final DateTime deadline = competition['deadline'] ?? DateTime.now();
    final String status = competition['status'] ?? 'active';
    final int participants = competition['participants'] ?? 0;
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Competition Header
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Competition Image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Color(0xFF999AE6).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.emoji_events,
                    color: Color(0xFF999AE6),
                    size: 30,
                  ),
                ),
                SizedBox(width: 12),
                
                // Competition Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              competition['title'] ?? 'Untitled Competition',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ),
                          _buildStatusChip(status),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        competition['description'] ?? 'No description',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.category, size: 16, color: Colors.grey[500]),
                          SizedBox(width: 4),
                          Text(
                            _getCategoryDisplayName(competition['category']),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(width: 16),
                          Icon(Icons.people, size: 16, color: Colors.grey[500]),
                          SizedBox(width: 4),
                          Text(
                            '$participants participants',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Competition Details
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Registration fee',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            competition['prize'] ?? 'TBD',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Deadline',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            DateFormat('MMM dd, yyyy').format(deadline),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showEditCompetitionDialog(competition),
                        icon: Icon(Icons.edit, size: 16),
                        label: Text('Edit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF999AE6),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _toggleCompetitionStatus(
                          competition['id'] ?? '',
                          status,
                        ),
                        icon: Icon(
                          status == 'active' ? Icons.pause : Icons.play_arrow,
                          size: 16,
                        ),
                        label: Text(status == 'active' ? 'Pause' : 'Activate'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: status == 'active' ? Colors.orange : Colors.green,
                          side: BorderSide(
                            color: status == 'active' ? Colors.orange : Colors.green,
                          ),
                          padding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _deleteCompetition(competition['id'] ?? ''),
                      icon: Icon(Icons.delete, color: Colors.red),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryDisplayName(String? category) {
    switch (category) {
      case 'akademik':
        return 'Akademik';
      case 'non-akademik':
        return 'Non-Akademik';
      default:
        return 'Akademik';
    }
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;
    
    switch (status.toLowerCase()) {
      case 'active':
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        icon = Icons.play_circle_fill;
        break;
      case 'inactive':
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        icon = Icons.pause_circle_filled;
        break;
      case 'draft':
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
        icon = Icons.drafts;
        break;
      default:
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        icon = Icons.info;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          SizedBox(width: 4),
          Text(
            status.capitalize(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Confirm'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// Add Competition Dialog
class _AddCompetitionDialog extends StatefulWidget {
  final VoidCallback onCompetitionAdded;

  const _AddCompetitionDialog({
    Key? key,
    required this.onCompetitionAdded,
  }) : super(key: key);

  @override
  _AddCompetitionDialogState createState() => _AddCompetitionDialogState();
}

class _AddCompetitionDialogState extends State<_AddCompetitionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prizeController = TextEditingController();
  
  String _selectedCategory = 'akademik';
  DateTime _selectedDeadline = DateTime.now().add(Duration(days: 30));
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add New Competition'),
      content: Container(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Competition Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: 'akademik', child: Text('Akademik')),
                    DropdownMenuItem(value: 'non-akademik', child: Text('Non-Akademik')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value ?? 'akademik';
                    });
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _prizeController,
                  decoration: InputDecoration(
                    labelText: 'Prize Pool',
                    border: OutlineInputBorder(),
                    prefixText: 'Rp ',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a prize amount';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                ListTile(
                  title: Text('Deadline'),
                  subtitle: Text(DateFormat('MMM dd, yyyy').format(_selectedDeadline)),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDeadline,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        _selectedDeadline = date;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _addCompetition,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF999AE6),
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text('Add Competition'),
        ),
      ],
    );
  }

  Future<void> _addCompetition() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Simulate adding competition
      await Future.delayed(Duration(seconds: 1));
      
      // TODO: Implement actual Firebase service call
      // await _firebaseService.addCompetition({
      //   'title': _titleController.text.trim(),
      //   'description': _descriptionController.text.trim(),
      //   'category': _selectedCategory,
      //   'prize': 'Rp ${_prizeController.text.trim()}',
      //   'deadline': _selectedDeadline,
      //   'status': 'draft',
      //   'participants': 0,
      //   'createdAt': DateTime.now(),
      // });

      Navigator.of(context).pop();
      widget.onCompetitionAdded();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Competition added successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add competition: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _prizeController.dispose();
    super.dispose();
  }
}

// Edit Competition Dialog
class _EditCompetitionDialog extends StatefulWidget {
  final Map<String, dynamic> competition;
  final VoidCallback onCompetitionUpdated;

  const _EditCompetitionDialog({
    Key? key,
    required this.competition,
    required this.onCompetitionUpdated,
  }) : super(key: key);

  @override
  _EditCompetitionDialogState createState() => _EditCompetitionDialogState();
}

class _EditCompetitionDialogState extends State<_EditCompetitionDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _prizeController;
  
  late String _selectedCategory;
  late DateTime _selectedDeadline;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.competition['title'] ?? '');
    _descriptionController = TextEditingController(text: widget.competition['description'] ?? '');
    _prizeController = TextEditingController(
      text: (widget.competition['prize'] ?? '').toString().replaceAll('Rp ', ''),
    );
    _selectedCategory = widget.competition['category'] ?? 'akademik';
    _selectedDeadline = widget.competition['deadline'] ?? DateTime.now().add(Duration(days: 30));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Competition'),
      content: Container(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Competition Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: 'akademik', child: Text('Akademik')),
                    DropdownMenuItem(value: 'non-akademik', child: Text('Non-Akademik')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value ?? 'akademik';
                    });
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _prizeController,
                  decoration: InputDecoration(
                    labelText: 'Prize Pool',
                    border: OutlineInputBorder(),
                    prefixText: 'Rp ',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a prize amount';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                ListTile(
                  title: Text('Deadline'),
                  subtitle: Text(DateFormat('MMM dd, yyyy').format(_selectedDeadline)),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDeadline,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        _selectedDeadline = date;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateCompetition,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF999AE6),
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text('Update Competition'),
        ),
      ],
    );
  }

  Future<void> _updateCompetition() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Simulate updating competition
      await Future.delayed(Duration(seconds: 1));
      
      // TODO: Implement actual Firebase service call
      // await _firebaseService.updateCompetition(widget.competition['id'], {
      //   'title': _titleController.text.trim(),
      //   'description': _descriptionController.text.trim(),
      //   'category': _selectedCategory,
      //   'prize': 'Rp ${_prizeController.text.trim()}',
      //   'deadline': _selectedDeadline,
      //   'updatedAt': DateTime.now(),
      // });

      Navigator.of(context).pop();
      widget.onCompetitionUpdated();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Competition updated successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update competition: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _prizeController.dispose();
    super.dispose();
  }
}

extension StringExtension on String {
  String capitalize() {
    return this.isNotEmpty ? '${this[0].toUpperCase()}${this.substring(1)}' : '';
  }
}

// Payment Management Screen
class PaymentManagement extends StatefulWidget {
  @override
  _PaymentManagementState createState() => _PaymentManagementState();
}

class _PaymentManagementState extends State<PaymentManagement> {
  final FirebaseService _firebaseService = FirebaseService();
  
  List<Map<String, dynamic>> _payments = [];
  Map<String, int> _paymentStats = {};
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterStatus = 'all'; // all, pending, approved, rejected
  String _filterCompetition = 'all'; // all, specific competition

  @override
  void initState() {
    super.initState();
    _loadPaymentData();
  }

  Future<void> _loadPaymentData() async {
    try {
      setState(() => _isLoading = true);
      
      // Simulate loading payments and stats
      await Future.delayed(Duration(seconds: 1));
      
      setState(() {
        _paymentStats = {
          'totalPayments': 45,
          'pendingPayments': 12,
          'approvedPayments': 28,
          'rejectedPayments': 5,
        };
        
        _payments = [
          {
            'id': 'pay_001',
            'userId': 'user_123',
            'userName': 'John Doe',
            'userEmail': 'john@example.com',
            'competitionId': 'comp_001',
            'competitionTitle': 'Programming Contest 2024',
            'amount': 150000,
            'paymentMethod': 'Bank Transfer',
            'paymentProof': 'https://example.com/proof1.jpg',
            'status': 'pending',
            'submittedAt': DateTime.now().subtract(Duration(hours: 2)),
            'notes': 'Payment for competition registration',
          },
          {
            'id': 'pay_002',
            'userId': 'user_456',
            'userName': 'Jane Smith',
            'userEmail': 'jane@example.com',
            'competitionId': 'comp_002',
            'competitionTitle': 'Essay Writing Competition',
            'amount': 100000,
            'paymentMethod': 'E-Wallet',
            'paymentProof': 'https://example.com/proof2.jpg',
            'status': 'approved',
            'submittedAt': DateTime.now().subtract(Duration(days: 1)),
            'processedAt': DateTime.now().subtract(Duration(hours: 22)),
            'processedBy': 'admin_001',
            'notes': 'Payment approved - registration fee',
          },
          {
            'id': 'pay_003',
            'userId': 'user_789',
            'userName': 'Bob Wilson',
            'userEmail': 'bob@example.com',
            'competitionId': 'comp_001',
            'competitionTitle': 'Programming Contest 2024',
            'amount': 150000,
            'paymentMethod': 'Bank Transfer',
            'paymentProof': 'https://example.com/proof3.jpg',
            'status': 'rejected',
            'submittedAt': DateTime.now().subtract(Duration(days: 2)),
            'processedAt': DateTime.now().subtract(Duration(days: 1, hours: 12)),
            'processedBy': 'admin_001',
            'rejectionReason': 'Invalid payment proof',
            'notes': 'Payment rejected - unclear payment proof',
          },
        ];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load payment data: ${e.toString()}');
    }
  }

  Future<void> _approvePayment(String paymentId) async {
    final confirmed = await _showConfirmDialog(
      'Approve Payment',
      'Are you sure you want to approve this payment?',
    );
    
    if (confirmed) {
      try {
        // TODO: Implement Firebase service call
        await Future.delayed(Duration(seconds: 1));
        
        _showSuccessSnackBar('Payment approved successfully');
        _loadPaymentData();
      } catch (e) {
        _showErrorSnackBar('Failed to approve payment: ${e.toString()}');
      }
    }
  }

  Future<void> _rejectPayment(String paymentId) async {
    final reason = await _showRejectDialog();
    
    if (reason != null && reason.isNotEmpty) {
      try {
        // TODO: Implement Firebase service call with rejection reason
        await Future.delayed(Duration(seconds: 1));
        
        _showSuccessSnackBar('Payment rejected successfully');
        _loadPaymentData();
      } catch (e) {
        _showErrorSnackBar('Failed to reject payment: ${e.toString()}');
      }
    }
  }

  void _viewPaymentProof(String proofUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: double.maxFinite,
            height: 500,
            child: Column(
              children: [
                AppBar(
                  title: Text('Payment Proof'),
                  backgroundColor: Color(0xFF999AE6),
                  foregroundColor: Colors.white,
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Payment Proof Image',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Image preview would be displayed here',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Implement image download or external view
                            },
                            icon: Icon(Icons.open_in_new),
                            label: Text('Open Full Image'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF999AE6),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> get _filteredPayments {
    return _payments.where((payment) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final userName = (payment['userName'] ?? '').toLowerCase();
        final userEmail = (payment['userEmail'] ?? '').toLowerCase();
        final competitionTitle = (payment['competitionTitle'] ?? '').toLowerCase();
        if (!userName.contains(query) && 
            !userEmail.contains(query) && 
            !competitionTitle.contains(query)) {
          return false;
        }
      }
      
      // Status filter
      if (_filterStatus != 'all') {
        final status = payment['status'] ?? 'pending';
        if (status != _filterStatus) return false;
      }
      
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              child: Icon(Icons.payment, size: 28),
            ),
            SizedBox(width: 10),
            Text('Payment Management'),
          ],
        ),
        backgroundColor: const Color(0xFF999AE6),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadPaymentData,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statistics Cards
                  _buildStatisticsSection(),
                  
                  SizedBox(height: 20),
                  
                  // Search and Filter Section
                  _buildSearchAndFilterSection(),
                  
                  SizedBox(height: 20),
                  
                  // Payments List
                  _buildPaymentsList(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatisticsSection() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Statistics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Payments',
                  _paymentStats['totalPayments']?.toString() ?? '0',
                  Colors.blue,
                  Icons.payment,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Pending',
                  _paymentStats['pendingPayments']?.toString() ?? '0',
                  Colors.orange,
                  Icons.hourglass_empty,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Approved',
                  _paymentStats['approvedPayments']?.toString() ?? '0',
                  Colors.green,
                  Icons.check_circle,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Rejected',
                  _paymentStats['rejectedPayments']?.toString() ?? '0',
                  Colors.red,
                  Icons.cancel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Search Bar
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search payments by user or competition...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          
          SizedBox(height: 12),
          
          // Filter Row
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _filterStatus,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: [
                    DropdownMenuItem(value: 'all', child: Text('All Status')),
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'approved', child: Text('Approved')),
                    DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filterStatus = value ?? 'all';
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsList() {
    final filteredPayments = _filteredPayments;
    
    if (filteredPayments.isEmpty) {
      return Container(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.payment_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No payments found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payments (${filteredPayments.length})',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: filteredPayments.length,
            itemBuilder: (context, index) {
              return _buildPaymentCard(filteredPayments[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> payment) {
    final String status = payment['status'] ?? 'pending';
    final double amount = (payment['amount'] ?? 0).toDouble();
    final DateTime submittedAt = payment['submittedAt'] ?? DateTime.now();
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Payment Header
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            payment['userName'] ?? 'Unknown User',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                          Text(
                            payment['userEmail'] ?? 'No email',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildPaymentStatusChip(status),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  payment['competitionTitle'] ?? 'Unknown Competition',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF666666),
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.attach_money, size: 16, color: Colors.green),
                    SizedBox(width: 4),
                    Text(
                      'Rp ${NumberFormat('#,###').format(amount)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(width: 16),
                    Icon(Icons.payment, size: 16, color: Colors.grey[500]),
                    SizedBox(width: 4),
                    Text(
                      payment['paymentMethod'] ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: Colors.grey[500]),
                    SizedBox(width: 4),
                    Text(
                      'Submitted: ${DateFormat('MMM dd, yyyy HH:mm').format(submittedAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                if (payment['processedAt'] != null) ...[
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.done, size: 16, color: Colors.grey[500]),
                      SizedBox(width: 4),
                      Text(
                        'Processed: ${DateFormat('MMM dd, yyyy HH:mm').format(payment['processedAt'])}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
                if (payment['rejectionReason'] != null) ...[
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Rejection Reason: ${payment['rejectionReason']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Action Buttons
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewPaymentProof(payment['paymentProof'] ?? ''),
                    icon: Icon(Icons.image, size: 16),
                    label: Text('View Proof'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Color(0xFF999AE6),
                      side: BorderSide(color: Color(0xFF999AE6)),
                      padding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                if (status == 'pending') ...[
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _approvePayment(payment['id'] ?? ''),
                      icon: Icon(Icons.check, size: 16),
                      label: Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _rejectPayment(payment['id'] ?? ''),
                      icon: Icon(Icons.close, size: 16),
                      label: Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;
    
    switch (status.toLowerCase()) {
      case 'pending':
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        icon = Icons.hourglass_empty;
        break;
      case 'approved':
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'rejected':
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        icon = Icons.info;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          SizedBox(width: 6),
          Text(
            status.capitalize(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text('Confirm'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  Future<String?> _showRejectDialog() async {
    final TextEditingController reasonController = TextEditingController();
    
    return await showDialog<String>(
      context: context ,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reject Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Please provide a reason for rejecting this payment:'),
              SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter rejection reason...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final reason = reasonController.text.trim();
                if (reason.isNotEmpty) {
                  Navigator.of(context).pop(reason);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Reject'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}