// Enhanced Admin Dashboard dengan Networking Service
// File: Admin/enhanced_dashboard_admin.dart

/*import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_tubes/firebase_service.dart';
import 'package:flutter_application_tubes/networking_service.dart'; // Import networking service
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EnhancedAdminDashboard extends StatefulWidget {
  @override
  _EnhancedAdminDashboardState createState() => _EnhancedAdminDashboardState();
}

class _EnhancedAdminDashboardState extends State<EnhancedAdminDashboard> {
  final FirebaseService _firebaseService = FirebaseService();
  final NetworkingService _networkingService = NetworkingService();
  final EnhancedFirebaseService _enhancedFirebaseService = EnhancedFirebaseService();
  
  List<Map<String, dynamic>> _users = [];
  Map<String, int> _stats = {};
  bool _isLoading = true;
  bool _useNetworking = false; // Toggle untuk menggunakan networking atau Firebase
  String _searchQuery = '';
  String _filterStatus = 'all';
  String _filterRole = 'all';
  
  // Network monitoring
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  NetworkTestResult? _networkTestResult;
  NetworkSpeedResult? _networkSpeedResult;
  bool _networkTestInProgress = false;

  @override
  void initState() {
    super.initState();
    _initializeNetworkMonitoring();
    _loadDashboardData();
  }

  // Initialize network monitoring
  void _initializeNetworkMonitoring() {
    // Monitor connectivity changes
    _networkingService.connectivityStream.listen((ConnectivityResult result) {
      setState(() {
        _connectionStatus = result;
      });
    });
    
    // Get initial connectivity
    _checkInitialConnectivity();
  }

  Future<void> _checkInitialConnectivity() async {
    final result = await _networkingService.getCurrentConnectivity();
    setState(() {
      _connectionStatus = result;
    });
  }

  // Test network connection
  Future<void> _testNetworkConnection() async {
    if (_networkTestInProgress) return;
    
    setState(() {
      _networkTestInProgress = true;
    });

    try {
      // Test connection ke server lokal
      final testResult = await _networkingService.testNetworkConnection();
      final speedResult = await _networkingService.testNetworkSpeed();
      
      setState(() {
        _networkTestResult = testResult;
        _networkSpeedResult = speedResult;
        _networkTestInProgress = false;
      });

      if (testResult.isConnected) {
        _showSuccessSnackBar('Network test successful! Server is reachable.');
      } else {
        _showErrorSnackBar('Network test failed: ${testResult.error}');
      }
    } catch (e) {
      setState(() {
        _networkTestInProgress = false;
      });
      _showErrorSnackBar('Network test error: ${e.toString()}');
    }
  }

  // Load dashboard data dengan opsi networking atau Firebase
  Future<void> _loadDashboardData() async {
    try {
      setState(() => _isLoading = true);
      
      if (_useNetworking) {
        await _loadDataFromAPI();
      } else {
        await _loadDataFromFirebase();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load dashboard data: ${e.toString()}');
    }
  }

  // Load data menggunakan API (networking)
  Future<void> _loadDataFromAPI() async {
    try {
      // Test API connection first
      final testResponse = await _enhancedFirebaseService.testApiConnection();
      
      if (!testResponse.isSuccess) {
        throw Exception('API not available: ${testResponse.error}');
      }

      // Load stats
      final statsResponse = await _enhancedFirebaseService.getDashboardStatsWithNetworking();
      
      // Load users
      final usersResponse = await _enhancedFirebaseService.getUsersWithNetworking(
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        status: _filterStatus != 'all' ? _filterStatus : null,
        role: _filterRole != 'all' ? _filterRole : null,
      );

      setState(() {
        if (statsResponse.isSuccess) {
          _stats = statsResponse.data!;
        }
        
        if (usersResponse.isSuccess) {
          _users = usersResponse.data!.users;
        }
        
        _isLoading = false;
      });

      if (!statsResponse.isSuccess) {
        _showErrorSnackBar('Failed to load stats: ${statsResponse.error}');
      }
      if (!usersResponse.isSuccess) {
        _showErrorSnackBar('Failed to load users: ${usersResponse.error}');
      }

    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('API Error: ${e.toString()}');
    }
  }

  // Load data menggunakan Firebase (original method)
  Future<void> _loadDataFromFirebase() async {
    try {
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
      _showErrorSnackBar('Firebase Error: ${e.toString()}');
    }
  }

  // Toggle user status dengan networking atau Firebase
  Future<void> _toggleUserStatus(String userId, String currentStatus) async {
    try {
      final newStatus = currentStatus == 'active' ? 'disabled' : 'active';
      
      if (_useNetworking) {
        final response = await _enhancedFirebaseService.updateUserStatusWithNetworking(
          userId, 
          newStatus,
        );
        
        if (response.isSuccess) {
          _showSuccessSnackBar('User ${newStatus} successfully via API');
        } else {
          throw Exception(response.error);
        }
      } else {
        if (currentStatus == 'active') {
          await _firebaseService.disableUser(userId);
          _showSuccessSnackBar('User disabled successfully via Firebase');
        } else {
          await _firebaseService.enableUser(userId);
          _showSuccessSnackBar('User enabled successfully via Firebase');
        }
      }
      
      _loadDashboardData(); // Refresh data
    } catch (e) {
      _showErrorSnackBar('Failed to update user status: ${e.toString()}');
    }
  }

  // Delete user dengan networking atau Firebase
  Future<void> _deleteUser(String userId) async {
    final confirmed = await _showConfirmDialog(
      'Delete User',
      'Are you sure you want to delete this user? This action cannot be undone.',
    );
    
    if (confirmed) {
      try {
        if (_useNetworking) {
          final response = await _enhancedFirebaseService.deleteUserWithNetworking(userId);
          
          if (response.isSuccess) {
            _showSuccessSnackBar('User deleted successfully via API');
          } else {
            throw Exception(response.error);
          }
        } else {
          await _firebaseService.deleteUserAccount(userId);
          _showSuccessSnackBar('User deleted successfully via Firebase');
        }
        
        _loadDashboardData(); // Refresh data
      } catch (e) {
        _showErrorSnackBar('Failed to delete user: ${e.toString()}');
      }
    }
  }

  // Handle logout
  Future<void> _handleLogout() async {
    try {
      await _firebaseService.signOut();
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } catch (e) {
      _showErrorSnackBar('Error logging out: ${e.toString()}');
    }
  }

  // Filtered users getter
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
            // Network status indicator
            SizedBox(width: 20),
            _buildNetworkStatusIndicator(),
          ],
        ),
        backgroundColor: const Color(0xFF999AE6),
        foregroundColor: Colors.white,
        actions: [
          // Toggle data source
          IconButton(
            icon: Icon(_useNetworking ? Icons.cloud : Icons.local_fire_department),
            tooltip: _useNetworking ? 'Using API' : 'Using Firebase',
            onPressed: () {
              setState(() {
                _useNetworking = !_useNetworking;
              });
              _loadDashboardData();
            },
          ),
          // Network test button
          IconButton(
            icon: _networkTestInProgress 
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(Icons.network_check),
            tooltip: 'Test Network',
            onPressed: _testNetworkConnection,
          ),
          // Refresh button
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
          // Menu
          PopupMenuButton<String>(
            onSelected: (String choice) {
              if (choice == 'Logout') {
                _handleLogout();
              } else if (choice == 'Network Info') {
                _showNetworkInfoDialog();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'Network Info',
                  child: Row(
                    children: [
                      Icon(Icons.info, size: 18),
                      SizedBox(width: 8),
                      Text('Network Info'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'Logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 18),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
              ];
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
                  // Welcome section dengan network info
                  _buildWelcomeSection(),
                  
                  SizedBox(height: 20),
                  
                  // Network status card
                  if (_networkTestResult != null || _networkSpeedResult != null)
                    _buildNetworkStatusCard(),
                  
                  SizedBox(height: 20),
                  
                  // Statistics cards
                  _buildStatsSection(),
                  
                  SizedBox(height: 20),
                  
                  // Data source indicator
                  _buildDataSourceIndicator(),
                  
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

  // Network status indicator widget
  Widget _buildNetworkStatusIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: NetworkUtils.getConnectionColor(_connectionStatus).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            NetworkUtils.getConnectionIcon(_connectionStatus),
            size: 16,
            color: NetworkUtils.getConnectionColor(_connectionStatus),
          ),
          SizedBox(width: 4),
          Text(
            _connectionStatus.toString().split('.').last.toUpperCase(),
            style: TextStyle(
              color: NetworkUtils.getConnectionColor(_connectionStatus),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced welcome section
  Widget _buildWelcomeSection() {
    return StreamBuilder<User?>(
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
                      SizedBox(height: 4),
                      Text(
                        'Data Source: ${_useNetworking ? "API Server" : "Firebase"}',
                        style: TextStyle(
                          color: _useNetworking ? Colors.blue : Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
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
    );
  }

  // Network status card
  Widget _buildNetworkStatusCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.network_check, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Network Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (_networkTestResult != null) ...[
              Row(
                children: [
                  Icon(
                    _networkTestResult!.isConnected ? Icons.check_circle : Icons.error,
                    color: _networkTestResult!.isConnected ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Server Connection: ${_networkTestResult!.isConnected ? "Connected" : "Failed"}',
                    style: TextStyle(
                      color: _networkTestResult!.isConnected ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                'Response Time: ${_networkTestResult!.responseTime}ms',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              if (_networkTestResult!.error != null) ...[
                SizedBox(height: 4),
                Text(
                  'Error: ${_networkTestResult!.error}',
                  style: TextStyle(fontSize: 12, color: Colors.red),
                ),
              ],
            ],
            if (_networkSpeedResult != null && _networkSpeedResult!.isSuccess) ...[
              SizedBox(height: 8),
              Text(
                'Network Speed: ${_networkSpeedResult!.speedFormatted}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Data source indicator
  Widget _buildDataSourceIndicator() {
    return Card(
      color: (_useNetworking ? Colors.blue : Colors.orange).withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              _useNetworking ? Icons.cloud : Icons.local_fire_department,
              color: _useNetworking ? Colors.blue : Colors.orange,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Data Source: ${_useNetworking ? "API Server" : "Firebase"}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _useNetworking ? Colors.blue : Colors.orange,
                    ),
                  ),
                  Text(
                    _useNetworking 
                        ? 'Data fetched from REST API (http://192.168.56.1:8000/api)'
                        : 'Data fetched from Firebase Firestore',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _useNetworking,
              onChanged: (value) {
                setState(() {
                  _useNetworking = value;
                });
                _loadDashboardData();
              },
              activeColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  // Network info dialog
  void _showNetworkInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Network Information'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Connection Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(_connectionStatus.toString().split('.').last.toUpperCase()),
                SizedBox(height: 16),
                if (_networkTestResult != null) ...[
                  Text('Server Test:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Status: ${_networkTestResult!.isConnected ? "Connected" : "Failed"}'),
                  Text('Response Time: ${_networkTestResult!.responseTime}ms'),
                  Text('Test URL: ${_networkTestResult!.testUrl}'),
                  if (_networkTestResult!.error != null)
                    Text('Error: ${_networkTestResult!.error}', style: TextStyle(color: Colors.red)),
                  SizedBox(height: 16),
                ],
                if (_networkSpeedResult != null) ...[
                  Text('Speed Test:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Speed: ${_networkSpeedResult!.speedFormatted}'),
                  Text('Response Time: ${_networkSpeedResult!.responseTime}ms'),
                  Text('Data Transferred: ${NetworkUtils.formatBytes(_networkSpeedResult!.bytesTransferred)}'),
                  SizedBox(height: 16),
                ],
                Text('API Base URL:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('http://192.168.56.1:8000/api'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  // Rest of the methods remain the same...
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
                // Auto-refresh untuk API, debounce untuk Firebase
                if (_useNetworking) {
                  _loadDashboardData();
                }
              },
            ),
            SizedBox(height: 16),
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
                      if (_useNetworking) {
                        _loadDashboardData();
                      }
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
                      if (_useNetworking) {
                        _loadDashboardData();
                      }
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
          Container(
            color: const Color(0xFF999AE6).withOpacity(0.1),
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text('User', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                Expanded(flex: 2, child: Text('Role', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                Expanded(flex: 2, child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                Expanded(flex: 2, child: Text('Joined', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                Expanded(flex: 2, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center)),
              ],
            ),
          ),
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
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$firstName $lastName', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                SizedBox(height: 2),
                Text(email, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
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
          Expanded(
            flex: 2,
            child: TextreatedAt != null
                ? DateFormat('dd/MM/yyyy').format(createdAt)
                : 'N/A',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ),
        Expanded(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Toggle status button
              Tooltip(
                message: status == 'active' ? 'Disable User' : 'Enable User',
                child: IconButton(
                  icon: Icon(
                    status == 'active' ? Icons.block : Icons.check_circle,
                    color: status == 'active' ? Colors.red : Colors.green,
                    size: 18,
                  ),
                  onPressed: () => _toggleUserStatus(userId, status),
                ),
              ),
              SizedBox(width: 4),
              // Delete user button
              if (role != 'admin') // Prevent deleting admin users
                Tooltip(
                  message: 'Delete User',
                  child: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red, size: 18),
                    onPressed: () => _deleteUser(userId),
                  ),
                ),
              SizedBox(width: 4),
              // More options button
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, size: 18),
                onSelected: (String choice) {
                  _handleUserAction(choice, user);
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'view_details',
                    child: Row(
                      children: [
                        Icon(Icons.visibility, size: 16),
                        SizedBox(width: 8),
                        Text('View Details'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'edit_role',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 16),
                        SizedBox(width: 8),
                        Text('Edit Role'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'reset_password',
                    child: Row(
                      children: [
                        Icon(Icons.lock_reset, size: 16),
                        SizedBox(width: 8),
                        Text('Reset Password'),
                      ],
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

  // Handle user actions from popup menu
  Future<void> _handleUserAction(String action, Map<String, dynamic> user) async {
    switch (action) {
      case 'view_details':
        _showUserDetailsDialog(user);
        break;
      case 'edit_role':
        _showEditRoleDialog(user);
        break;
      case 'reset_password':
        _resetUserPassword(user['userId']);
        break;
    }
  }

  // Show user details dialog
  void _showUserDetailsDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('User Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Name', '${user['firstName']} ${user['lastName']}'),
                _buildDetailRow('Email', user['email'] ?? 'N/A'),
                _buildDetailRow('Phone', user['phoneNumber'] ?? 'N/A'),
                _buildDetailRow('Address', user['address'] ?? 'N/A'),
                _buildDetailRow('Role', user['role'] ?? 'user'),
                _buildDetailRow('Status', user['status'] ?? 'active'),
                _buildDetailRow('User ID', user['userId'] ?? 'N/A'),
                _buildDetailRow(
                  'Created At',
                  user['createdAt'] != null
                      ? DateFormat('dd/MM/yyyy HH:mm').format(user['createdAt'].toDate())
                      : 'N/A',
                ),
                _buildDetailRow(
                  'Last Updated',
                  user['updatedAt'] != null
                      ? DateFormat('dd/MM/yyyy HH:mm').format(user['updatedAt'].toDate())
                      : 'N/A',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  // Build detail row for user details dialog
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  // Show edit role dialog
  void _showEditRoleDialog(Map<String, dynamic> user) {
    String currentRole = user['role'] ?? 'user';
    String newRole = currentRole;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit User Role'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('User: ${user['firstName']} ${user['lastName']}'),
                  Text('Email: ${user['email']}'),
                  SizedBox(height: 16),
                  Text('Select new role:'),
                  SizedBox(height: 8),
                  RadioListTile<String>(
                    title: Text('User'),
                    value: 'user',
                    groupValue: newRole,
                    onChanged: (value) {
                      setState(() {
                        newRole = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text('Admin'),
                    value: 'admin',
                    groupValue: newRole,
                    onChanged: (value) {
                      setState(() {
                        newRole = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  child: Text('Update Role'),
                  onPressed: newRole != currentRole
                      ? () {
                          Navigator.of(context).pop();
                          _updateUserRole(user['userId'], newRole);
                        }
                      : null,
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Update user role
  Future<void> _updateUserRole(String userId, String newRole) async {
    try {
      if (_useNetworking) {
        final response = await _enhancedFirebaseService.updateUserRoleWithNetworking(
          userId,
          newRole,
        );
        
        if (response.isSuccess) {
          _showSuccessSnackBar('User role updated successfully via API');
        } else {
          throw Exception(response.error);
        }
      } else {
        await _firebaseService.updateUserRole(userId, newRole);
        _showSuccessSnackBar('User role updated successfully via Firebase');
      }
      
      _loadDashboardData(); // Refresh data
    } catch (e) {
      _showErrorSnackBar('Failed to update user role: ${e.toString()}');
    }
  }

  // Reset user password
  Future<void> _resetUserPassword(String userId) async {
    final confirmed = await _showConfirmDialog(
      'Reset Password',
      'Are you sure you want to reset this user\'s password? A new temporary password will be sent to their email.',
    );
    
    if (confirmed) {
      try {
        if (_useNetworking) {
          final response = await _enhancedFirebaseService.resetUserPasswordWithNetworking(userId);
          
          if (response.isSuccess) {
            _showSuccessSnackBar('Password reset email sent successfully via API');
          } else {
            throw Exception(response.error);
          }
        } else {
          await _firebaseService.resetUserPassword(userId);
          _showSuccessSnackBar('Password reset email sent successfully via Firebase');
        }
      } catch (e) {
        _showErrorSnackBar('Failed to reset password: ${e.toString()}');
      }
    }
  }

  // Show confirmation dialog
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

  // Show success snackbar
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  // Show error snackbar
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
        duration: Duration(seconds: 5),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up resources
    super.dispose();
  }
}

// Enhanced Firebase Service class for networking functionality
class EnhancedFirebaseService {
  static const String _baseUrl = 'http://192.168.56.1:8000/api';
  
  // Test API connection
  Future<ApiResponse<bool>> testApiConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));
      
      return ApiResponse.success(response.statusCode == 200);
    } catch (e) {
      return ApiResponse.error('Connection failed: ${e.toString()}');
    }
  }
  
  // Get dashboard stats with networking
  Future<ApiResponse<Map<String, int>>> getDashboardStatsWithNetworking() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/stats'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse.success(Map<String, int>.from(data['stats']));
      } else {
        return ApiResponse.error('Failed to load stats: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Get users with networking
  Future<ApiResponse<UsersResponse>> getUsersWithNetworking({
    String? search,
    String? status,
    String? role,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (search != null) queryParams['search'] = search;
      if (status != null) queryParams['status'] = status;
      if (role != null) queryParams['role'] = role;
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();

      final uri = Uri.parse('$_baseUrl/admin/users').replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse.success(UsersResponse.fromJson(data));
      } else {
        return ApiResponse.error('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Update user status with networking
  Future<ApiResponse<bool>> updateUserStatusWithNetworking(String userId, String status) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/admin/users/$userId/status'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': status}),
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return ApiResponse.success(true);
      } else {
        final data = json.decode(response.body);
        return ApiResponse.error(data['message'] ?? 'Failed to update status');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Update user role with networking
  Future<ApiResponse<bool>> updateUserRoleWithNetworking(String userId, String role) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/admin/users/$userId/role'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'role': role}),
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return ApiResponse.success(true);
      } else {
        final data = json.decode(response.body);
        return ApiResponse.error(data['message'] ?? 'Failed to update role');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Delete user with networking
  Future<ApiResponse<bool>> deleteUserWithNetworking(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/admin/users/$userId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return ApiResponse.success(true);
      } else {
        final data = json.decode(response.body);
        return ApiResponse.error(data['message'] ?? 'Failed to delete user');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // Reset user password with networking
  Future<ApiResponse<bool>> resetUserPasswordWithNetworking(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/admin/users/$userId/reset-password'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return ApiResponse.success(true);
      } else {
        final data = json.decode(response.body);
        return ApiResponse.error(data['message'] ?? 'Failed to reset password');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
}

// API Response wrapper class
class ApiResponse<T> {
  final bool isSuccess;
  final T? data;
  final String? error;

  ApiResponse.success(this.data) : isSuccess = true, error = null;
  ApiResponse.error(this.error) : isSuccess = false, data = null;
}

// Users response model
class UsersResponse {
  final List<Map<String, dynamic>> users;
  final int totalCount;
  final int currentPage;
  final int totalPages;

  UsersResponse({
    required this.users,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
  });

  factory UsersResponse.fromJson(Map<String, dynamic> json) {
    return UsersResponse(
      users: List<Map<String, dynamic>>.from(json['users'] ?? []),
      totalCount: json['totalCount'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}

// Network utilities class
class NetworkUtils {
  static IconData getConnectionIcon(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return Icons.wifi;
      case ConnectivityResult.mobile:
        return Icons.signal_cellular_4_bar;
      case ConnectivityResult.ethernet:
        return Icons.ethernet;
      case ConnectivityResult.bluetooth:
        return Icons.bluetooth;
      default:
        return Icons.signal_wifi_off;
    }
  }

  static Color getConnectionColor(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.ethernet:
        return Colors.green;
      case ConnectivityResult.bluetooth:
        return Colors.blue;
      default:
        return Colors.red;
    }
  }

  static String formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (bytes.bitLength - 1) ~/ 10;
    return '${(bytes / (1 << (i * 10))).toStringAsFixed(1)} ${suffixes[i]}';
  }
}
*/