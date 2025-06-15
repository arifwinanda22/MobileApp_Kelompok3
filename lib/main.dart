// main.dart - Fixed version without AuthWrapper complexity
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_tubes/dashboard.dart';
import 'package:flutter_application_tubes/Admin/dashboardAdmin.dart';
import 'package:flutter_application_tubes/firebase_service.dart';
import 'home_page.dart';
import 'about_page.dart';
import 'help_page.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'forgotpass.dart';
import 'Workshop/workshopAcademic.dart';
import 'Workshop/workshopNonAcademic.dart';
import 'Workshop/workshopDetail.dart';
import 'Competition/competitionAcademic.dart';
import 'Competition/competitionNonAcademic.dart';
import 'Competition/competitionDetail.dart';
import 'profil.dart';
import 'forum.dart';
import 'calendar.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
    
    // Enable persistence for Firestore (optional)
    // FirebaseFirestore.instance.settings = const Settings(
    //   persistenceEnabled: true,
    // );
    
  } catch (e) {
    print('❌ Firebase initialization error: $e');
  }
  
  runApp(const SmartCompApp());
}


class SmartCompApp extends StatelessWidget {
  const SmartCompApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartComp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Montaga',
      ),
      
      // Start with AuthCheck instead of HomePage
      home: AuthCheck(),

      routes: {
        '/home': (context) => HomePage(),
        '/about': (context) => AboutPage(),
        '/help': (context) => HelpPage(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/forgotpass': (context) => ForgotPasswordApp(),
        '/dashboard': (context) => SmartCompHomePage(),
        '/dashboardAdmin': (context) => SmartCompAdminApp(), // Fixed syntax error here
        '/workshopAcademic': (context) => WorkshopAcademicPage(),
        '/workshopNonAcademic': (context) => WorkshopNonAcademicPage(),
        '/competitionAcademic': (context) => CompetitionAcademicPage(),
        '/competitionNonAcademic': (context) => CompetitionNonAcademicPage(),
        '/profil': (context) => ProfilePage(),
        '/forum': (context) => FeedbackScreen(),
        '/calendar': (context) => CalendarScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/workshopDetail') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) {
              return WorkshopDetail(
                title: args['title'],
                imageUrl: args['imageUrl'],
              );
            },
          );
        }
        else if (settings.name == '/competitionDetail') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) {
              return CompetitionDetail(
                title: args['title'],
                imageUrl: args['imageUrl'],
              );
            },
          );
        }
        return null;
      },
    );
  }
}

// Enhanced AuthCheck widget with admin role detection
class AuthCheck extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen();
        }
        
        // If there's an error, show home page
        if (snapshot.hasError) {
          print('Auth stream error: ${snapshot.error}');
          return HomePage();
        }
        
        // If user is logged in, check role and redirect accordingly
        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<Map<String, dynamic>?>(
            future: _firebaseService.getUserProfile(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingScreen();
              }
              
              if (userSnapshot.hasError) {
                print('Error getting user profile: ${userSnapshot.error}');
                return SmartCompHomePage();
              }
              
              // Handle case where user profile doesn't exist yet
              if (!userSnapshot.hasData || userSnapshot.data == null) {
                print('No user profile found, redirecting to regular dashboard');
                return SmartCompHomePage();
              }
              
              final userData = userSnapshot.data!;
              final String role = userData['role'] ?? 'user';
              final String status = userData['status'] ?? 'active';
              
              print('User role: $role, status: $status');
              
              // Check if user account is disabled or deleted
              if (status == 'disabled') {
                // Sign out the user and redirect to login
                _firebaseService.signOut();
                return HomePage();
              }
              
              if (status == 'deleted') {
                // Sign out the user and redirect to login
                _firebaseService.signOut();
                return HomePage();
              }
              
              // Redirect based on role
              if (role == 'admin') {
                print('Redirecting to admin dashboard');
                return SmartCompAdminApp();
              } else {
                print('Redirecting to user dashboard');
                return SmartCompHomePage();
              }
            },
          );
        }
        
        // If user is not logged in, show home page
        print('User is not logged in, showing home page');
        return HomePage();
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF999AE6),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
            SizedBox(height: 24),
            Text(
              'Loading SmartComp...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}