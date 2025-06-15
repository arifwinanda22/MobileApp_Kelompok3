import 'package:flutter/material.dart';
import 'package:flutter_application_tubes/Competition/competitionAcademic.dart';
import 'package:flutter_application_tubes/calendar.dart';
import 'package:flutter_application_tubes/dashboard.dart';
import 'package:flutter_application_tubes/forum.dart';
import 'workshopNonAcademic.dart';
import 'workshopDetail.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartComp',
      theme: ThemeData(
        primaryColor: const Color(0xFF999AE6),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF999AE6)),
        useMaterial3: true,
        fontFamily: 'Open Sans',
      ),
      home: const WorkshopAcademicPage(),
    );
  }
}

class WorkshopCard {
  final String imageUrl;
  final String title;

  WorkshopCard({
    required this.imageUrl,
    required this.title,
  });
}

class WorkshopAcademicPage extends StatefulWidget {
  const WorkshopAcademicPage({Key? key}) : super(key: key);

  @override
  State<WorkshopAcademicPage> createState() => _WorkshopAcademicPageState();
}

class _WorkshopAcademicPageState extends State<WorkshopAcademicPage> {
  final List<WorkshopCard> workshops = [
    WorkshopCard(
      imageUrl: 'assets1/UI_UX-Designer-img.jpg',
      title: 'UI/UX Designer For 30 days',
    ),
    WorkshopCard(
      imageUrl: 'assets1/Web-Dev-img.jpg',
      title: 'The Complete Web Development Academy',
    ),
    WorkshopCard(
      imageUrl: 'assets1/Java-Course.jpg',
      title: 'Project Development Using JAVA for Beginners',
    ),
    WorkshopCard(
      imageUrl: 'assets1/IoT-Course.jpg',
      title: 'IoT Study Club Academy',
    ),
    WorkshopCard(
      imageUrl: 'assets1/KTI-img.jpg',
      title: 'Membuat Karya Tulis Ilmiah dari 0',
    ),
  ];

  int _selectedIndex = 1; // Set to 1 for Workshop tab

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF999AE6),
        title: Row(
          children: [
            Image.asset(
              'assets1/gambar-removebg-preview.png',
              height: 40,
            ),
            const SizedBox(width: 8),
            const Text(
              'SmartComp',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SmartCompHomePage()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              _showNotificationsDrawer(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              _showProfileMenu(context);
            },
          ),
        ],
      ),
      drawer: _buildCategoriesDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSearchBar(),
            _buildCategoriesButton(),
            _buildTypeSelector(),
            _buildWorkshopGrid(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Workshops',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Competitions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: 'Forum',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF999AE6),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    // If selecting the current tab, do nothing
    if (index == _selectedIndex) return;

    // Handle navigation based on selected tab
    Widget targetPage;
    switch (index) {
      case 0:
        targetPage = SmartCompApp();
        break;
      case 1:
        targetPage = WorkshopAcademicPage();
        break;
      case 2:
        targetPage = CompetitionAcademicPage();
        break;
      case 3:
        targetPage = FeedbackScreen();
        break;
      case 4:
        // Profile page - we'll just keep it as the current page for now
        targetPage = WorkshopAcademicPage();
        break;
      default:
        targetPage = SmartCompApp();
    }

    // Use pushReplacement to replace the current route
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => targetPage),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search for competition or workshop',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCategoriesButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF999AE6),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        ),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
        child: const Text('Categories'),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            'Recommended Workshop and Competition from us\nAll the skills you need in one place',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.0),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B0C634A),
                foregroundColor: Colors.white,
              ),
              onPressed: () {},
              child: const Text('Academic'),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBC3AF462),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WorkshopNonAcademicPage()),
                );
              },
              child: const Text('Non-Academic'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWorkshopGrid() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 0.7,
        ),
        itemCount: workshops.length,
        itemBuilder: (context, index) {
          return _buildWorkshopCard(workshops[index]);
        },
      ),
    );
  }

  Widget _buildWorkshopCard(WorkshopCard workshop) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(8.0)),
            child: Image.asset(
              workshop.imageUrl,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 120,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, size: 50),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              workshop.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF999AE6),
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkshopDetail(
                      title: workshop.title,
                      imageUrl: workshop.imageUrl,
                    ),
                  ),
                );
              },
              child: const Text('Jelajahi'),
            ),
          ),
        ],
      ),
    );
  }

  Drawer _buildCategoriesDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF999AE6),
            ),
            child: const Text(
              'Categories',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SmartCompApp()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Workshop'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              // Already on workshop page
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Calendar'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CalendarScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.emoji_events),
            title: const Text('Competitions'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => CompetitionAcademicPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.forum),
            title: const Text('Forum'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => FeedbackScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('Academic'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              // Already on academic workshop page
            },
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('Non-Academic'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => WorkshopNonAcademicPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showNotificationsDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Notifikasi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      children: [
                        const Text(
                          'Notifikasi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _buildNotificationCard(
                          'Dibuka pendaftaran lomba UI/UX',
                          '2 menit yang lalu',
                        ),
                        _buildNotificationCard(
                          'Dibuka pendaftaran lomba UI/UX',
                          '2 menit yang lalu',
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Pengingat Jadwal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _buildNotificationCard(
                          'Mentoring',
                          '29 Oktober 2077, 10:00 AM',
                        ),
                        _buildNotificationCard(
                          'Mentoring',
                          '29 Oktober 2077, 10:00 AM',
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Artikel Terkait',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _buildNotificationCard(
                          'Mengenal Jenis-jenis Lomba dan Kriterianya',
                          'Panduan untuk memilih lomba yang tepat',
                        ),
                        _buildNotificationCard(
                          'Mengenal Jenis-jenis Lomba dan Kriterianya',
                          'Panduan untuk memilih lomba yang tepat',
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Tips',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _buildNotificationCard(
                          'Tips Produktivitas',
                          '5 cara meningkatkan fokus kerja',
                        ),
                        _buildNotificationCard(
                          'Tips Produktivitas',
                          '5 cara meningkatkan fokus kerja',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNotificationCard(String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      items: [
        const PopupMenuItem(
          value: 'profile',
          child: Text('My Profile'),
        ),
        const PopupMenuItem(
          value: 'update',
          child: Text('Update Profile'),
        ),
      ],
      elevation: 8.0,
    ).then((value) {
      if (value == null) return;
      // Handle menu selection
    });
  }
}
