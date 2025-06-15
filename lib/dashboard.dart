import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_tubes/calendar.dart';
import 'package:flutter_application_tubes/forum.dart';
import 'package:flutter_application_tubes/home_page.dart';
import 'Workshop/workshopAcademic.dart';
import 'Competition/competitionAcademic.dart';
import 'forum.dart';
import 'package:flutter_application_tubes/profil.dart';
import 'calendar.dart';

void main() => runApp(SmartCompApp());

class SmartCompApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartComp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class SmartCompHomePage extends StatelessWidget {
  // Method to handle logout
  Future<void> _handleLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate back to home page and clear all previous routes
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/',
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging out: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
            Text('SmartComp'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              // Handle cart action
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Handle notifications
            },
          ),
          PopupMenuButton<String>(
            onSelected: (String choice) {
              if (choice == 'My Profile') {
                Navigator.pushNamed(context, '/profil');
              } else if (choice == 'Update Profile') {
                Navigator.pushNamed(context, '/updateProfile');
              } else if (choice == 'Logout') {
                _handleLogout(context);
              }
            },
            itemBuilder: (BuildContext context) {
              return {'My Profile', 'Update Profile', 'Logout'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Row(
                    children: [
                      Icon(
                        choice == 'My Profile' ? Icons.person :
                        choice == 'Update Profile' ? Icons.edit :
                        Icons.logout,
                        size: 18,
                      ),
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Categories',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 10),
                  // Show user email if logged in
                  StreamBuilder<User?>(
                    stream: FirebaseAuth.instance.authStateChanges(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data?.email != null) {
                        return Text(
                          'Welcome, ${snapshot.data!.email}',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        );
                      }
                      return Text(
                        'SmartComp Navigation',
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.work),
              title: Text('Workshop'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WorkshopAcademicPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('Calendar'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CalendarScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.emoji_events),
              title: Text('Competitions'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CompetitionAcademicPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.forum),
              title: Text('Forum'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FeedbackScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.school),
              title: Text('Academic'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.book),
              title: Text('Non-Academic'),
              onTap: () {},
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context); // Close drawer first
                _handleLogout(context);
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(
              'Recommended Workshop and Competition from us\nAll the skills you need in one place',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Academic'),
                ),
                OutlinedButton(
                  onPressed: () {},
                  child: Text('Non-Academic'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCard(
                  imageUrl: 'assets1/UI_UX-Designer-img.jpg',
                  title: 'UI/UX Designer For 30 days',
                ),
                _buildCard(
                  imageUrl: 'assets1/Web-Dev-img.jpg',
                  title: 'Web Development Academy',
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCard(
                  imageUrl: 'assets1/Java-Course.jpg',
                  title: 'Java Project for Beginners 2024',
                ),
                _buildCard(
                  imageUrl: 'assets1/IoT-Course.jpg',
                  title: 'IoT Academy',
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              '© 2024 SmartComp. All rights reserved.',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String imageUrl, required String title}) {
    return SizedBox(
      width: 160,
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            imageUrl.startsWith('http')
                ? Image.network(
                    imageUrl,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    imageUrl,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Jelajahi button
              },
              child: Text('Jelajahi'),
            ),
          ],
        ),
      ),
    );
  }
}