// Admin/dashboardAdmin.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_tubes/firebase_service.dart';
import 'package:flutter_application_tubes/Admin/competitionManagement.dart';
import 'package:flutter_application_tubes/Admin/workshopManagement.dart';
import 'package:intl/intl.dart';

class SmartCompAdminApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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

// ╔══════════════════════════════════════════╗
// ║           ADMIN DASHBOARD               ║
// ╚══════════════════════════════════════════╝
class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseService _firebaseService = FirebaseService();

  // --- data ---
  List<Map<String, dynamic>> _users = [];
  Map<String, int> _stats = {};
  bool _isLoading = true;

  // filters
  String _searchQuery = '';
  String _filterStatus = 'all';
  String _filterRole  = 'all';

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() => _isLoading = true);
      final results = await Future.wait([
        _firebaseService.getDashboardStats(),
        _firebaseService.getAllUsers(),
      ]);
      setState(() {
        _stats  = results[0] as Map<String,int>;
        _users  = results[1] as List<Map<String,dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnack('Failed to load dashboard: $e', isErr:true);
    }
  }

  // ───────── navigation helpers ─────────
  void _openCompetitions() =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => CompetitionManagement()));

  void _openWorkshops() =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkshopManagement()));

  // ───────── user actions (disable / delete) ─────────
  Future<void> _toggleUser(String uid, String status) async {
    try {
      if (status == 'active') {
        await _firebaseService.disableUser(uid);
      } else {
        await _firebaseService.enableUser(uid);
      }
      _showSnack('User status updated');
      _loadDashboardData();
    } catch (e) {
      _showSnack('Error: $e', isErr:true);
    }
  }

  Future<void> _deleteUser(String uid) async {
    final ok = await _confirm('Delete User',
        'Are you sure you want to delete this user? This action cannot be undone.');
    if (!ok) return;
    try {
      await _firebaseService.deleteUserAccount(uid);
      _showSnack('User deleted');
      _loadDashboardData();
    } catch (e) {
      _showSnack('Error: $e', isErr:true);
    }
  }

  Future<void> _logout() async {
    await _firebaseService.signOut();
    if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  }

  // ───────── filters ─────────
  List<Map<String,dynamic>> get _filteredUsers {
    return _users.where((u) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final name  = '${u['firstName']} ${u['lastName']}'.toLowerCase();
        final email = (u['email'] ?? '').toLowerCase();
        if (!name.contains(q) && !email.contains(q)) return false;
      }
      if (_filterStatus != 'all' && (u['status'] ?? 'active') != _filterStatus) return false;
      if (_filterRole   != 'all' && (u['role']   ?? 'user' ) != _filterRole  ) return false;
      return true;
    }).toList();
  }

  // ═════════════════ UI ═════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Image.asset('assets1/gambar-removebg-preview.png', height: 40),
          const SizedBox(width: 10),
          const Text('SmartComp Admin'),
        ]),
        backgroundColor: const Color(0xFF999AE6),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadDashboardData),
          PopupMenuButton(
            onSelected: (_) => _logout(),
            itemBuilder: (_) => [
              const PopupMenuItem(value:'logout', child: Text('Logout')),
            ],
          )
        ],
      ),
      body: _isLoading
          ? const Center(child:CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
                _buildWelcome(),
                const SizedBox(height:20),
                _buildQuickActionsHorizontal(), // <── horizontal list
                const SizedBox(height:20),
                _buildStatsRow(),
                const SizedBox(height:20),
                const Text('User Management',
                    style: TextStyle(fontSize:24,fontWeight:FontWeight.bold)),
                const SizedBox(height:16),
                _buildSearchFilters(),
                const SizedBox(height:16),
                _buildUsersTable(),
              ]),
            ),
    );
  }

  // ───────── Welcome card ─────────
  Widget _buildWelcome() {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (_, snap) {
        final email = snap.data?.email ?? 'Admin';
        return Card(
          color: const Color(0xFF999AE6).withOpacity(.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children:[
              const Icon(Icons.admin_panel_settings,size:40,color:Color(0xFF999AE6)),
              const SizedBox(width:16),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
                const Text('Welcome, Administrator',
                    style: TextStyle(fontSize:20,fontWeight:FontWeight.bold)),
                Text(email, style: TextStyle(color:Colors.grey[600])),
              ]),
            ]),
          ),
        );
      },
    );
  }

  // ───────── QUICK ACTIONS (horizontal) ─────────
  Widget _buildQuickActionsHorizontal() {
    final actions = [
      _QA('Competitions', Icons.emoji_events, Colors.orange, _openCompetitions,
          'Create, edit & manage competitions'),
      _QA('Workshops', Icons.school, Colors.purple, _openWorkshops,
          'Create, edit & manage workshops'),
      _QA('Users', Icons.people, Colors.blue, (){}, 'View & manage user accounts'),
      _QA('Reports', Icons.analytics, Colors.green, (){}, 'View analytics & reports'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:[
        const Text('Quick Actions',
            style: TextStyle(fontSize:24,fontWeight:FontWeight.bold)),
        const SizedBox(height:12),
        SizedBox(
          height: 140, // fixed height for cards
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: actions.length,
            separatorBuilder: (_, __) => const SizedBox(width:12),
            itemBuilder: (_, i) => _quickActionCard(actions[i]),
          ),
        ),
      ],
    );
  }

  Widget _quickActionCard(_QA qa) {
    return SizedBox(
      width: 220,
      child: Card(
        elevation: 3,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: qa.onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
              Icon(qa.icon, color: qa.color, size:32),
              const Spacer(),
              Text(qa.title,
                  style: const TextStyle(fontSize:16,fontWeight:FontWeight.bold)),
              const SizedBox(height:4),
              Text(qa.subtitle,
                  style: TextStyle(fontSize:12,color:Colors.grey[600])),
            ]),
          ),
        ),
      ),
    );
  }

  // ───────── stats row ─────────
  Widget _buildStatsRow() {
    return Row(children:[
      _stat('Total Users',   _stats['totalUsers']??0,   Icons.people, Colors.blue),
      _stat('Active',        _stats['activeUsers']??0,  Icons.check_circle, Colors.green),
      _stat('Disabled',      _stats['disabledUsers']??0,Icons.block, Colors.red),
      _stat('Admins',        _stats['adminUsers']??0,   Icons.admin_panel_settings, Colors.purple),
    ]);
  }
  Widget _stat(String t,int v,IconData ic,Color c){
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children:[
            Row(mainAxisAlignment:MainAxisAlignment.spaceBetween, children:[
              Icon(ic,color:c),
              Text('$v',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold,color:c)),
            ]),
            const SizedBox(height:6),
            Text(t, style: TextStyle(color:Colors.grey[600])),
          ]),
        ),
      ),
    );
  }

  // ───────── search & filters ─────────
  Widget _buildSearchFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children:[
          TextField(
            decoration: const InputDecoration(
              hintText:'Search users by name or email…',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged:(v)=> setState(()=> _searchQuery = v),
          ),
          const SizedBox(height:16),
          Row(children:[
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _filterStatus,
                decoration: const InputDecoration(labelText:'Status',border:OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value:'all',      child:Text('All')),
                  DropdownMenuItem(value:'active',   child:Text('Active')),
                  DropdownMenuItem(value:'disabled', child:Text('Disabled')),
                ],
                onChanged:(v)=> setState(()=> _filterStatus = v??'all'),
              ),
            ),
            const SizedBox(width:16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _filterRole,
                decoration: const InputDecoration(labelText:'Role',border:OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value:'all',  child:Text('All')),
                  DropdownMenuItem(value:'user', child:Text('User')),
                  DropdownMenuItem(value:'admin',child:Text('Admin')),
                ],
                onChanged:(v)=> setState(()=> _filterRole = v??'all'),
              ),
            ),
          ])
        ]),
      ),
    );
  }

  // ───────── users table (same as before) ─────────
  Widget _buildUsersTable() {
    final list = _filteredUsers;
    if (list.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(children:[
            Icon(Icons.people_outline,size:64,color:Colors.grey[400]),
            const SizedBox(height:16),
            const Text('No users found'),
          ]),
        ),
      );
    }
    return Card(
      child: Column(children:[
        Container(
          color: const Color(0xFF999AE6).withOpacity(.1),
          padding: const EdgeInsets.all(12),
          child: Row(children:[
            Expanded(flex:3,child:_h('User')),
            Expanded(flex:2,child:_h('Role')),
            Expanded(flex:2,child:_h('Status')),
            Expanded(flex:2,child:_h('Joined')),
            const Expanded(flex:2,child:Text('Actions',
              style: _hStyle,textAlign:TextAlign.center)),
          ]),
        ),
        ListView.builder(
          shrinkWrap:true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          itemBuilder: (_,i)=> _row(list[i]),
        ),
      ]),
    );
  }
  static const _hStyle = TextStyle(fontWeight:FontWeight.bold,fontSize:14);
  Widget _h(String t)=> Text(t,style:_hStyle);

  Widget _row(Map<String,dynamic> u) {
    final name  = '${u['firstName']} ${u['lastName']}';
    final email = u['email']??'';
    final role  = u['role']??'user';
    final status= u['status']??'active';
    final joined= u['createdAt']?.toDate() as DateTime?;
    final uid   = u['userId']??'';

    Widget chip(String text, Color c)=> Container(
      padding: const EdgeInsets.symmetric(horizontal:8,vertical:4),
      decoration: BoxDecoration(color:c.withOpacity(.15),borderRadius:BorderRadius.circular(12)),
      child: Text(text,style:TextStyle(color:c,fontSize:11,fontWeight:FontWeight.bold)),
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color:Colors.grey[200]!))),
      child: Row(children:[
        Expanded(flex:3,child:Column(
          crossAxisAlignment:CrossAxisAlignment.start,
          children:[
            Text(name,style:const TextStyle(fontWeight:FontWeight.w600)),
            const SizedBox(height:2),
            Text(email,style:TextStyle(fontSize:12,color:Colors.grey[600])),
          ])),
        Expanded(flex:2,child:chip(role.toUpperCase(), role=='admin'?Colors.purple:Colors.blue)),
        Expanded(flex:2,child:chip(status.toUpperCase(), status=='active'?Colors.green:Colors.red)),
        Expanded(flex:2,child:Text(
          joined!=null? DateFormat('MMM dd, yyyy').format(joined):'N/A',
          style:TextStyle(fontSize:12,color:Colors.grey[600]))),
        Expanded(flex:2,child: Row(mainAxisAlignment:MainAxisAlignment.center, children:[
          InkWell(
            onTap: ()=> _toggleUser(uid,status),
            child: Icon(status=='active'?Icons.block:Icons.check_circle,
                size:20,color: status=='active'?Colors.red:Colors.green),
          ),
          const SizedBox(width:8),
          InkWell(
            onTap: ()=> _deleteUser(uid),
            child: const Icon(Icons.delete,size:20,color:Colors.red),
          ),
        ])),
      ]),
    );
  }

  // ───────── utils ─────────
  void _showSnack(String msg,{bool isErr=false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isErr? Colors.red : Colors.green,
    ));
  }

  Future<bool> _confirm(String title,String msg) async {
    return (await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title), content: Text(msg),
        actions: [
          TextButton(onPressed: ()=>Navigator.pop(context,false), child: const Text('Cancel')),
          ElevatedButton(onPressed: ()=>Navigator.pop(context,true),
              style:ElevatedButton.styleFrom(backgroundColor:Colors.red),
              child: const Text('Confirm')),
        ],
      ),
    )) ?? false;
  }
}

// ───────── helper class for quick action data ─────────
class _QA {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String subtitle;
  _QA(this.title,this.icon,this.color,this.onTap,this.subtitle);
}
