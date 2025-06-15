// Admin/dashboardAdmin.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_tubes/firebase_service.dart';
import 'package:intl/intl.dart';

class SmartCompAdminApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartComp Admin',
      theme: ThemeData(
        primaryColor: const Color(0xFF999AE6),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF999AE6),
          primary: const Color(0xFF999AE6),
        ),
        fontFamily: 'Montserrat',
      ),
      home: AdminDashboard(),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseService _firebaseService = FirebaseService();
  
  List<Map<String, dynamic>> _users = [];
  Map<String, int> _stats = {};
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterStatus = 'all'; // all, active, disabled
  String _filterRole = 'all'; // all, admin, user

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() => _isLoading = true);
      
      // Load statistics and users concurrently
      final results = await Future.wait([
        _firebaseService.getDashboardStats(),
        _firebaseService.getAllUsers(),
      ]);
      
      setState(() {
        _stats = results[0] as Map<String, int>;
        _users = results[1] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load dashboard data: ${e.toString()}');
    }
  }

  Future<void> _toggleUserStatus(String userId, String currentStatus) async {
    try {
      if (currentStatus == 'active') {
        await _firebaseService.disableUser(userId);
        _showSuccessSnackBar('User disabled successfully');
      } else {
        await _firebaseService.enableUser(userId);
        _showSuccessSnackBar('User enabled successfully');
      }
      _loadDashboardData(); // Refresh data
    } catch (e) {
      _showErrorSnackBar('Failed to update user status: ${e.toString()}');
    }
  }

  Future<void> _deleteUser(String userId) async {
    final confirmed = await _showConfirmDialog(
      'Delete User',
      'Are you sure you want to delete this user? This action cannot be undone.',
    );
    
    if (confirmed) {
      try {
        await _firebaseService.deleteUserAccount(userId);
        _showSuccessSnackBar('User deleted successfully');
        _loadDashboardData(); // Refresh data
      } catch (e) {
        _showErrorSnackBar('Failed to delete user: ${e.toString()}');
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      await _firebaseService.signOut();
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } catch (e) {
      _showErrorSnackBar('Error logging out: ${e.toString()}');
    }
  }

  List<Map<String, dynamic>> get _filteredUsers {
    return _users.where((user) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final name = '${user['firstName']} ${user['lastName']}'.toLowerCase();
        final email = (user['email'] ?? '').toLowerCase();
        if (!name.contains(query) && !email.contains(query)) {
          return false;
        }
      }
      
      // Status filter
      if (_filterStatus != 'all') {
        final status = user['status'] ?? 'active';
        if (status != _filterStatus) return false;
      }
      
      // Role filter
      if (_filterRole != 'all') {
        final role = user['role'] ?? 'user';
        if (role != _filterRole) return false;
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
            Image.asset(
              'assets1/gambar-removebg-preview.png',
              height: 40,
            ),
            SizedBox(width: 10),
            Text('SmartComp Admin'),
          ],
        ),
        backgroundColor: const Color(0xFF999AE6),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
          PopupMenuButton<String>(
            onSelected: (String choice) {
              if (choice == 'Logout') {
                _handleLogout();
              }
            },
            itemBuilder: (BuildContext context) {
              return {'Logout'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 18),
                      SizedBox(width: 8),
                      Text(choice),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome section
                  StreamBuilder<User?>(
                    stream: FirebaseAuth.instance.authStateChanges(),
                    builder: (context, snapshot) {
                      final email = snapshot.data?.email ?? 'Admin';
                      return Card(
                        color: const Color(0xFF999AE6).withOpacity(0.1),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.admin_panel_settings, 
                                   size: 40, 
                                   color: const Color(0xFF999AE6)),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome, Administrator',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      email,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Statistics cards
                  _buildStatsSection(),
                  
                  SizedBox(height: 20),
                  
                  // User management section
                  Text(
                    'User Management',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Search and filters
                  _buildSearchAndFilters(),
                  
                  SizedBox(height: 16),
                  
                  // Users table
                  _buildUsersTable(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Users',
            _stats['totalUsers']?.toString() ?? '0',
            Icons.people,
            Colors.blue,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Active Users',
            _stats['activeUsers']?.toString() ?? '0',
            Icons.check_circle,
            Colors.green,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Disabled Users',
            _stats['disabledUsers']?.toString() ?? '0',
            Icons.block,
            Colors.red,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Admins',
            _stats['adminUsers']?.toString() ?? '0',
            Icons.admin_panel_settings,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search users by name or email...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            
            SizedBox(height: 16),
            
            // Filters
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _filterStatus,
                    decoration: InputDecoration(
                      labelText: 'Filter by Status',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: [
                      DropdownMenuItem(value: 'all', child: Text('All Status')),
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                      DropdownMenuItem(value: 'disabled', child: Text('Disabled')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _filterStatus = value!;
                      });
                    },
                  ),
                ),
                
                SizedBox(width: 16),
                
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _filterRole,
                    decoration: InputDecoration(
                      labelText: 'Filter by Role',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: [
                      DropdownMenuItem(value: 'all', child: Text('All Roles')),
                      DropdownMenuItem(value: 'user', child: Text('User')),
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _filterRole = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTable() {
    final filteredUsers = _filteredUsers;
    
    if (filteredUsers.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.people_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                'No users found',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                'Try adjusting your search or filter criteria',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          // Table header
          Container(
            color: const Color(0xFF999AE6).withOpacity(0.1),
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'User',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Role',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Status',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Joined',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Actions',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          
          // Table rows
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              return _buildUserRow(filteredUsers[index]);
            },
          ),
        ],
      ),
    );
  }

  
  // Perbaikan untuk bagian Actions di _buildUserRow
Widget _buildUserRow(Map<String, dynamic> user) {
  final String firstName = user['firstName'] ?? '';
  final String lastName = user['lastName'] ?? '';
  final String email = user['email'] ?? '';
  final String role = user['role'] ?? 'user';
  final String status = user['status'] ?? 'active';
  final DateTime? createdAt = user['createdAt']?.toDate();
  final String userId = user['userId'] ?? '';

  return Container(
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
    ),
    padding: EdgeInsets.all(12),
    child: Row(
      children: [
        // User info
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$firstName $lastName',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 2),
              Text(
                email,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        
        // Role
        Expanded(
          flex: 2,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: role == 'admin' ? Colors.purple[100] : Colors.blue[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              role.toUpperCase(),
              style: TextStyle(
                color: role == 'admin' ? Colors.purple[800] : Colors.blue[800],
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        
        // Status
        Expanded(
          flex: 2,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: status == 'active' ? Colors.green[100] : Colors.red[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status.toUpperCase(),
              style: TextStyle(
                color: status == 'active' ? Colors.green[800] : Colors.red[800],
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        
        // Joined date
        Expanded(
          flex: 2,
          child: Text(
            createdAt != null 
                ? DateFormat('MMM dd, yyyy').format(createdAt)
                : 'N/A',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ),
        
        // Actions - PERBAIKAN DISINI
        Expanded(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Toggle status button dengan InkWell untuk area tap yang lebih besar
              InkWell(
                onTap: () => _toggleUserStatus(userId, status),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (status == 'active' ? Colors.red : Colors.green).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    status == 'active' ? Icons.block : Icons.check_circle,
                    size: 20,
                    color: status == 'active' ? Colors.red : Colors.green,
                  ),
                ),
              ),
              
              SizedBox(width: 8),
              
              // Delete button dengan InkWell untuk area tap yang lebih besar
              InkWell(
                onTap: () => _deleteUser(userId),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.delete,
                    size: 20,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ALTERNATIF LAIN: Menggunakan PopupMenuButton untuk actions yang lebih responsive
Widget _buildAlternativeActions(String userId, String status) {
  return PopupMenuButton<String>(
    onSelected: (String choice) {
      switch (choice) {
        case 'toggle':
          _toggleUserStatus(userId, status);
          break;
        case 'delete':
          _deleteUser(userId);
          break;
      }
    },
    itemBuilder: (BuildContext context) => [
      PopupMenuItem<String>(
        value: 'toggle',
        child: Row(
          children: [
            Icon(
              status == 'active' ? Icons.block : Icons.check_circle,
              size: 18,
              color: status == 'active' ? Colors.red : Colors.green,
            ),
            SizedBox(width: 8),
            Text(status == 'active' ? 'Disable User' : 'Enable User'),
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'delete',
        child: Row(
          children: [
            Icon(Icons.delete, size: 18, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete User'),
          ],
        ),
      ),
    ],
    child: Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        Icons.more_vert,
        size: 20,
        color: Colors.grey[600],
      ),
    ),
  );
}

// ATAU gunakan ElevatedButton dengan ukuran yang lebih besar
Widget _buildButtonActions(String userId, String status) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      // Toggle status button
      SizedBox(
        width: 36,
        height: 36,
        child: ElevatedButton(
          onPressed: () => _toggleUserStatus(userId, status),
          style: ElevatedButton.styleFrom(
            backgroundColor: (status == 'active' ? Colors.red : Colors.green).withOpacity(0.1),
            foregroundColor: status == 'active' ? Colors.red : Colors.green,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            elevation: 0,
          ),
          child: Icon(
            status == 'active' ? Icons.block : Icons.check_circle,
            size: 18,
          ),
        ),
      ),
      
      SizedBox(width: 8),
      
      // Delete button
      SizedBox(
        width: 36,
        height: 36,
        child: ElevatedButton(
          onPressed: () => _deleteUser(userId),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.withOpacity(0.1),
            foregroundColor: Colors.red,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            elevation: 0,
          ),
          child: Icon(
            Icons.delete,
            size: 18,
          ),
        ),
      ),
    ],
  );
}

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
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
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              child: Text('Confirm'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    ) ?? false;
  }
}