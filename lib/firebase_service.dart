// firebase_service.dart - Enhanced with Competition Management
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

enum UserRole { user, admin }

// Competition Model (inline definition)
class Competition {
  final String id;
  final String title;
  final String description;
  final String category;
  final String imageUrl;
  final String registrationUrl;
  final DateTime deadline;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? organizer;
  final List<String>? requirements;
  final String? prize;
  final String? contactInfo;

  Competition({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.registrationUrl,
    required this.deadline,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.organizer,
    this.requirements,
    this.prize,
    this.contactInfo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'registrationUrl': registrationUrl,
      'deadline': deadline.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'organizer': organizer,
      'requirements': requirements,
      'prize': prize,
      'contactInfo': contactInfo,
    };
  }

  factory Competition.fromMap(Map<String, dynamic> map) {
    return Competition(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      registrationUrl: map['registrationUrl'] ?? '',
      deadline: DateTime.parse(map['deadline']),
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      organizer: map['organizer'],
      requirements: map['requirements'] != null ? List<String>.from(map['requirements']) : null,
      prize: map['prize'],
      contactInfo: map['contactInfo'],
    );
  }

  Competition copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? imageUrl,
    String? registrationUrl,
    DateTime? deadline,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? organizer,
    List<String>? requirements,
    String? prize,
    String? contactInfo,
  }) {
    return Competition(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      registrationUrl: registrationUrl ?? this.registrationUrl,
      deadline: deadline ?? this.deadline,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      organizer: organizer ?? this.organizer,
      requirements: requirements ?? this.requirements,
      prize: prize ?? this.prize,
      contactInfo: contactInfo ?? this.contactInfo,
    );
  }
}

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection names
  static const String usersCollection = 'users';
  static const String competitionsCollection = 'competitions';

  // Singleton pattern untuk menghindari multiple instances
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // Get current user
  User? get currentUser {
    try {
      return _auth.currentUser;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Auth state changes stream dengan error handling
  Stream<User?> get authStateChanges {
    return _auth.authStateChanges().handleError((error) {
      print('Auth state change error: $error');
      return null;
    });
  }

  // Determine user role based on email
  UserRole determineUserRole(String email) {
    if (email.toLowerCase().endsWith('@admin.ac.id')) {
      return UserRole.admin;
    } else {
      return UserRole.user;
    }
  }

  // Get user role string
  String getUserRoleString(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'admin';
      case UserRole.user:
        return 'user';
    }
  }

  // Check if current user is admin
  Future<bool> isCurrentUserAdmin() async {
    try {
      final user = currentUser;
      if (user == null) return false;

      final userDoc = await _firestore.collection(usersCollection).doc(user.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        return data['role'] == 'admin';
      }
      
      // Fallback to email check
      return determineUserRole(user.email ?? '') == UserRole.admin;
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  // Sign up with email and password
  Future<User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      print('Creating user with email: $email');
      
      // Validasi input
      if (email.trim().isEmpty || password.trim().isEmpty) {
        throw FirebaseAuthException(
          code: 'invalid-input',
          message: 'Email and password cannot be empty',
        );
      }

      if (firstName.trim().isEmpty || lastName.trim().isEmpty) {
        throw FirebaseAuthException(
          code: 'invalid-input',
          message: 'First name and last name cannot be empty',
        );
      }

      // Validate email domain
      final emailLower = email.toLowerCase().trim();
      if (!emailLower.endsWith('@gmail.com') && !emailLower.endsWith('@admin.ac.id')) {
        throw FirebaseAuthException(
          code: 'invalid-email-domain',
          message: 'Email must be either @gmail.com for users or @admin.ac.id for administrators',
        );
      }
      
      // Determine user role
      final userRole = determineUserRole(emailLower);
      final roleString = getUserRoleString(userRole);
      
      // Create user with Firebase Auth
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailLower,
        password: password,
      );
      
      final User? user = userCredential.user;
      
      if (user != null) {
        print('User created successfully: ${user.uid} with role: $roleString');
        
        // Update display name dengan retry mechanism
        await _updateDisplayNameWithRetry(user, '$firstName $lastName');
        
        // Save additional user data to Firestore with role
        await _saveUserToFirestore(user, firstName, lastName, emailLower, userRole);
        
        return user;
      }
      
      return null;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException in signUp: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected error in signUp: $e');
      print('Error type: ${e.runtimeType}');
      // Re-throw as FirebaseAuthException for consistent handling
      throw FirebaseAuthException(
        code: 'unknown',
        message: 'An unexpected error occurred during registration: ${e.toString()}',
      );
    }
  }

  // Helper method untuk update display name dengan retry
  Future<void> _updateDisplayNameWithRetry(User user, String displayName) async {
    int retryCount = 0;
    const maxRetries = 3;
    
    while (retryCount < maxRetries) {
      try {
        await user.updateDisplayName(displayName);
        print('Display name updated successfully');
        break;
      } catch (e) {
        retryCount++;
        print('Attempt $retryCount failed to update display name: $e');
        
        if (retryCount >= maxRetries) {
          print('Failed to update display name after $maxRetries attempts');
        } else {
          await Future.delayed(Duration(milliseconds: 500 * retryCount));
        }
      }
    }
  }

  // Helper method untuk save user ke Firestore dengan role
  Future<void> _saveUserToFirestore(User user, String firstName, String lastName, String email, UserRole userRole) async {
    try {
      final roleString = getUserRoleString(userRole);
      
      await _firestore.collection(usersCollection).doc(user.uid).set({
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'email': email.trim(),
        'role': roleString,
        'status': 'active', // active, disabled, deleted
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'displayName': '$firstName $lastName'.trim(),
        'phone': '',
        'softSkills': '',
        'hardSkills': '',
        'profilePictureUrl': '',
        'emailVerified': user.emailVerified,
        'uid': user.uid,
        // Add userId field for compatibility with dashboard admin
        'userId': user.uid,
      });
      print('User data saved to Firestore with role: $roleString');
    } catch (firestoreError) {
      print('Warning: Could not save to Firestore: $firestoreError');
      throw firestoreError; // Throw error for role-based system
    }
  }

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      print('Attempting to sign in with email: $email');
      
      // Validasi input
      if (email.trim().isEmpty || password.trim().isEmpty) {
        throw FirebaseAuthException(
          code: 'invalid-input',
          message: 'Email and password cannot be empty',
        );
      }
      
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      final User? user = userCredential.user;
      
      if (user != null) {
        print('User signed in successfully: ${user.uid}');
        
        // Check if user account is disabled
        final userDoc = await _firestore.collection(usersCollection).doc(user.uid).get();
        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          final status = data['status'] ?? 'active';
          
          if (status == 'disabled') {
            await _auth.signOut(); // Sign out immediately
            throw FirebaseAuthException(
              code: 'user-disabled',
              message: 'Your account has been disabled by an administrator',
            );
          }
          
          if (status == 'deleted') {
            await _auth.signOut(); // Sign out immediately
            throw FirebaseAuthException(
              code: 'user-disabled',
              message: 'Your account has been deleted',
            );
          }

          // Update last login
          await _firestore.collection(usersCollection).doc(user.uid).update({
            'lastLogin': FieldValue.serverTimestamp(),
          });
        } else {
          // Ensure user document exists
          await _ensureUserDocumentExists(user);
        }
        
        return user;
      }
      
      return null;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException in signIn: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected error in signIn: $e');
      throw FirebaseAuthException(
        code: 'unknown',
        message: 'An unexpected error occurred during sign in: ${e.toString()}',
      );
    }
  }

  // Ensure user document exists in Firestore
  Future<void> _ensureUserDocumentExists(User user) async {
    try {
      final userDoc = await _firestore.collection(usersCollection).doc(user.uid).get();
      
      if (!userDoc.exists) {
        print('User document does not exist, creating...');
        
        // Determine role from email
        final userRole = determineUserRole(user.email ?? '');
        final roleString = getUserRoleString(userRole);
        
        // Split display name into first and last name
        final displayName = user.displayName ?? 'User Name';
        final nameParts = displayName.split(' ');
        final firstName = nameParts.isNotEmpty ? nameParts.first : 'User';
        final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : 'Name';
        
        await _firestore.collection(usersCollection).doc(user.uid).set({
          'firstName': firstName,
          'lastName': lastName,
          'email': user.email ?? '',
          'role': roleString,
          'status': 'active',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
          'displayName': displayName,
          'phone': '',
          'softSkills': '',
          'hardSkills': '',
          'profilePictureUrl': user.photoURL ?? '',
          'emailVerified': user.emailVerified,
          'uid': user.uid,
          // Add userId field for compatibility
          'userId': user.uid,
        });
        print('User document created in Firestore with role: $roleString');
      } else {
        print('User document already exists');
        // Update last login time and ensure userId field exists
        await _firestore.collection(usersCollection).doc(user.uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
          'userId': user.uid, // Ensure userId field exists for compatibility
        });
      }
    } catch (e) {
      print('Error ensuring user document exists: $e');
      // Don't throw error, just log it
    }
  }

  // ===== USER MANAGEMENT FUNCTIONS =====

  // Admin Functions - Get all users (Updated for dashboard admin compatibility)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final isAdmin = await isCurrentUserAdmin();
      if (!isAdmin) {
        throw FirebaseAuthException(
          code: 'permission-denied',
          message: 'Only administrators can access user data',
        );
      }

      print('Loading all users...');

      // PERBAIKAN: Gunakan query sederhana tanpa whereNotIn + orderBy
      final QuerySnapshot querySnapshot = await _firestore
          .collection(usersCollection)
          .orderBy('createdAt', descending: true)
          .get();

      List<Map<String, dynamic>> users = [];
      
      // Filter di client side untuk menghindari composite index
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final status = data['status'] ?? 'active';
        
        // Skip deleted users (filter di client side)
        if (status == 'deleted') {
          continue;
        }
        
        // Add both id and docId for compatibility with dashboard admin
        data['id'] = doc.id;
        data['docId'] = doc.id;
        
        // Ensure userId field exists
        if (!data.containsKey('userId') || 
            data['userId'] == null || 
            data['userId'].toString().trim().isEmpty) {
          data['userId'] = doc.id;
        }
        
        // Ensure required fields exist with defaults
        data['firstName'] = data['firstName'] ?? '';
        data['lastName'] = data['lastName'] ?? '';
        data['email'] = data['email'] ?? '';
        data['role'] = data['role'] ?? 'user';
        data['status'] = status;
        
        users.add(data);
      }

      print('Loaded ${users.length} users successfully');
      return users;
      
    } catch (e) {
      print('Error getting all users: $e');
      rethrow;
    }
  }

  // Admin Functions - Get dashboard statistics (PERBAIKAN - query sederhana)
  Future<Map<String, int>> getDashboardStats() async {
    try {
      final isAdmin = await isCurrentUserAdmin();
      if (!isAdmin) {
        throw FirebaseAuthException(
          code: 'permission-denied',
          message: 'Only administrators can access dashboard statistics',
        );
      }

      print('Loading dashboard statistics...');

      // PERBAIKAN: Gunakan query sederhana tanpa filter kompleks
      final QuerySnapshot allUsers = await _firestore
          .collection(usersCollection)
          .get();
      
      int totalUsers = 0;
      int activeUsers = 0;
      int disabledUsers = 0;
      int adminUsers = 0;
      int regularUsers = 0;

      // Hitung statistik di client side
      for (var doc in allUsers.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final status = data['status'] ?? 'active';
        final role = data['role'] ?? 'user';

        // Only count non-deleted users
        if (status != 'deleted') {
          totalUsers++;
          
          if (status == 'active') {
            activeUsers++;
          } else if (status == 'disabled') {
            disabledUsers++;
          }

          if (role == 'admin') {
            adminUsers++;
          } else {
            regularUsers++;
          }
        }
      }

      Map<String, int> stats = {
        'totalUsers': totalUsers,
        'activeUsers': activeUsers,
        'disabledUsers': disabledUsers,
        'adminUsers': adminUsers,
        'regularUsers': regularUsers,
      };

      print('Dashboard statistics loaded: $stats');
      return stats;
      
    } catch (e) {
      print('Error getting dashboard stats: $e');
      rethrow;
    }
  }

  // TAMBAHAN: Method alternatif jika masih ada masalah dengan orderBy
  Future<List<Map<String, dynamic>>> getAllUsersSimple() async {
    try {
      final isAdmin = await isCurrentUserAdmin();
      if (!isAdmin) {
        throw FirebaseAuthException(
          code: 'permission-denied',
          message: 'Only administrators can access user data',
        );
      }

      print('Loading all users (simple query)...');

      // Query paling sederhana tanpa ordering
      final QuerySnapshot querySnapshot = await _firestore
          .collection(usersCollection)
          .get();

      List<Map<String, dynamic>> users = [];
      
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final status = data['status'] ?? 'active';
        
        // Skip deleted users
        if (status == 'deleted') {
          continue;
        }
        
        // Add required fields
        data['id'] = doc.id;
        data['docId'] = doc.id;
        data['userId'] = data['userId'] ?? doc.id;
        data['firstName'] = data['firstName'] ?? '';
        data['lastName'] = data['lastName'] ?? '';
        data['email'] = data['email'] ?? '';
        data['role'] = data['role'] ?? 'user';
        data['status'] = status;
        
        users.add(data);
      }

      // Sort di client side berdasarkan createdAt jika ada
      users.sort((a, b) {
        final aTime = a['createdAt'] as Timestamp?;
        final bTime = b['createdAt'] as Timestamp?;
        
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        
        return bTime.compareTo(aTime); // Descending order
      });

      print('Loaded ${users.length} users successfully');
      return users;
      
    } catch (e) {
      print('Error getting all users (simple): $e');
      rethrow;
    }
  }

  // Admin Functions - Disable user (ADDED - This was missing!)
  Future<void> disableUser(String userId) async {
    try {
      final isAdmin = await isCurrentUserAdmin();
      if (!isAdmin) {
        throw FirebaseAuthException(
          code: 'permission-denied',
          message: 'Only administrators can disable users',
        );
      }

      // Validate userId
      if (userId.trim().isEmpty) {
        throw FirebaseAuthException(
          code: 'invalid-user-id',
          message: 'Invalid user ID provided',
        );
      }

      // Check if user document exists
      final userDoc = await _firestore.collection(usersCollection).doc(userId).get();
      if (!userDoc.exists) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'User not found',
        );
      }

      // Don't allow admin to disable themselves
      if (userId == currentUser?.uid) {
        throw FirebaseAuthException(
          code: 'cannot-disable-self',
          message: 'You cannot disable your own account',
        );
      }

      await _firestore.collection(usersCollection).doc(userId).update({
        'status': 'disabled',
        'updatedAt': FieldValue.serverTimestamp(),
        'disabledBy': currentUser?.uid,
        'disabledAt': FieldValue.serverTimestamp(),
      });

      print('User disabled successfully: $userId');
    } catch (e) {
      print('Error disabling user: $e');
      rethrow;
    }
  }

  // Admin Functions - Enable user (Updated with better error handling)
  Future<void> enableUser(String userId) async {
    try {
      final isAdmin = await isCurrentUserAdmin();
      if (!isAdmin) {
        throw FirebaseAuthException(
          code: 'permission-denied',
          message: 'Only administrators can enable users',
        );
      }

      // Validate userId
      if (userId.trim().isEmpty) {
        throw FirebaseAuthException(
          code: 'invalid-user-id',
          message: 'Invalid user ID provided',
        );
      }

      // Check if user document exists
      final userDoc = await _firestore.collection(usersCollection).doc(userId).get();
      if (!userDoc.exists) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'User not found',
        );
      }

      await _firestore.collection(usersCollection).doc(userId).update({
        'status': 'active',
        'updatedAt': FieldValue.serverTimestamp(),
        'enabledBy': currentUser?.uid,
        'enabledAt': FieldValue.serverTimestamp(),
      });

      print('User enabled successfully: $userId');
    } catch (e) {
      print('Error enabling user: $e');
      rethrow;
    }
  }

  // Admin Functions - Delete user (Updated with better error handling)
  Future<void> deleteUserAccount(String userId) async {
    try {
      final isAdmin = await isCurrentUserAdmin();
      if (!isAdmin) {
        throw FirebaseAuthException(
          code: 'permission-denied',
          message: 'Only administrators can delete users',
        );
      }

      // Validate userId
      if (userId.trim().isEmpty) {
        throw FirebaseAuthException(
          code: 'invalid-user-id',
          message: 'Invalid user ID provided',
        );
      }

      // Check if user document exists
      final userDoc = await _firestore.collection(usersCollection).doc(userId).get();
      if (!userDoc.exists) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'User not found',
        );
      }

      // Don't allow admin to delete themselves
      if (userId == currentUser?.uid) {
        throw FirebaseAuthException(
          code: 'cannot-delete-self',
          message: 'You cannot delete your own account',
        );
      }

      await _firestore.collection(usersCollection).doc(userId).update({
        'status': 'deleted',
        'updatedAt': FieldValue.serverTimestamp(),
        'deletedBy': currentUser?.uid,
        'deletedAt': FieldValue.serverTimestamp(),
      });

      print('User deleted successfully: $userId');
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }

  // Get user profile from Firestore
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = currentUser;
      if (user == null) {
        print('No current user found');
        return null;
      }

      print('Getting user profile for: ${user.uid}');
      
      final DocumentSnapshot userDoc = await _firestore
          .collection(usersCollection)
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>?;
        print('User profile loaded from Firestore: ${data?.keys}');
        return data;
      } else {
        print('User document does not exist in Firestore');
        await _ensureUserDocumentExists(user);
        
        final newUserDoc = await _firestore
            .collection(usersCollection)
            .doc(user.uid)
            .get();
            
        if (newUserDoc.exists) {
          final data = newUserDoc.data() as Map<String, dynamic>?;
          print('User profile created and loaded: ${data?.keys}');
          return data;
        }
      }
      
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      rethrow;
    }
  }

  // Update user profile in Firestore
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'no-current-user',
          message: 'No user is currently signed in',
        );
      }

      print('Updating user profile for: ${user.uid}');
      print('Update data: $data');

      // Add timestamp and ensure userId field
      data['updatedAt'] = FieldValue.serverTimestamp();
      data['userId'] = user.uid;

      // Update Firestore document
      await _firestore.collection(usersCollection).doc(user.uid).update(data);
      
      print('User profile updated successfully in Firestore');

      // If display name is being updated, also update Firebase Auth
      if (data.containsKey('firstName') && data.containsKey('lastName')) {
        final newDisplayName = '${data['firstName']} ${data['lastName']}'.trim();
        if (newDisplayName.isNotEmpty && newDisplayName != user.displayName) {
          try {
            await user.updateDisplayName(newDisplayName);
            print('Display name updated in Firebase Auth');
          } catch (e) {
            print('Warning: Could not update display name in Firebase Auth: $e');
          }
        }
      }

    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // ===== COMPETITION MANAGEMENT FUNCTIONS =====

  // Get all competitions
  Stream<List<Competition>> getAllCompetitions() {
    return _firestore
        .collection(competitionsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Competition.fromMap(doc.data()))
            .toList());
  }

  // Get competitions by category
  Stream<List<Competition>> getCompetitionsByCategory(String category) {
    return _firestore
        .collection(competitionsCollection)
        .where('category', isEqualTo: category)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Competition.fromMap(doc.data()))
            .toList());
  }

  // Get active competitions
  Stream<List<Competition>> getActiveCompetitions() {
    return _firestore
        .collection(competitionsCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Competition.fromMap(doc.data()))
            .toList());
  }

  // Get competition by ID
  Future<Competition?> getCompetitionById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(competitionsCollection)
          .doc(id)
          .get();
      
      if (doc.exists) {
        return Competition.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting competition: $e');
      throw FirebaseAuthException(
        code: 'competition-not-found',
        message: 'Error getting competition: $e',
      );
    }
  }

  // Add new competition (Admin only)
  Future<String> addCompetition(Competition competition) async {
    try {
      final isAdmin = await isCurrentUserAdmin();
      if (!isAdmin) {
        throw FirebaseAuthException(
          code: 'permission-denied',
          message: 'Only administrators can add competitions',
        );
      }

      DocumentReference docRef = await _firestore
          .collection(competitionsCollection)
          .add(competition.toMap());
      
      // Update the document with its ID
      await docRef.update({'id': docRef.id});
      
      print('Competition added successfully: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error adding competition: $e');
      rethrow;
    }
  }

  // Update competition (Admin only)
  Future<void> updateCompetition(Competition competition) async {
    try {
      final isAdmin = await isCurrentUserAdmin();
      if (!isAdmin) {
        throw FirebaseAuthException(
          code: 'permission-denied',
          message: 'Only administrators can update competitions', );
     }

     await _firestore
         .collection(competitionsCollection)
         .doc(competition.id)
         .update(competition.copyWith(updatedAt: DateTime.now()).toMap());
     
     print('Competition updated successfully: ${competition.id}');
   } catch (e) {
     print('Error updating competition: $e');
     rethrow;
   }
 }

 // Delete competition (Admin only)
 Future<void> deleteCompetition(String competitionId) async {
   try {
     final isAdmin = await isCurrentUserAdmin();
     if (!isAdmin) {
       throw FirebaseAuthException(
         code: 'permission-denied',
         message: 'Only administrators can delete competitions',
       );
     }

     await _firestore
         .collection(competitionsCollection)
         .doc(competitionId)
         .delete();
     
     print('Competition deleted successfully: $competitionId');
   } catch (e) {
     print('Error deleting competition: $e');
     rethrow;
   }
 }

 // Toggle competition status (Admin only)
 Future<void> toggleCompetitionStatus(String competitionId) async {
   try {
     final isAdmin = await isCurrentUserAdmin();
     if (!isAdmin) {
       throw FirebaseAuthException(
         code: 'permission-denied',
         message: 'Only administrators can toggle competition status',
       );
     }

     DocumentSnapshot doc = await _firestore
         .collection(competitionsCollection)
         .doc(competitionId)
         .get();
     
     if (doc.exists) {
       final data = doc.data() as Map<String, dynamic>;
       final currentStatus = data['isActive'] ?? true;
       
       await _firestore
           .collection(competitionsCollection)
           .doc(competitionId)
           .update({
         'isActive': !currentStatus,
         'updatedAt': DateTime.now().toIso8601String(),
       });
       
       print('Competition status toggled: $competitionId -> ${!currentStatus}');
     }
   } catch (e) {
     print('Error toggling competition status: $e');
     rethrow;
   }
 }

 // Get competition statistics (Admin only)
 Future<Map<String, int>> getCompetitionStats() async {
   try {
     final isAdmin = await isCurrentUserAdmin();
     if (!isAdmin) {
       throw FirebaseAuthException(
         code: 'permission-denied',
         message: 'Only administrators can access competition statistics',
       );
     }

     final QuerySnapshot allCompetitions = await _firestore
         .collection(competitionsCollection)
         .get();

     int totalCompetitions = 0;
     int activeCompetitions = 0;
     int inactiveCompetitions = 0;
     int expiredCompetitions = 0;
     Map<String, int> categoryCounts = {};

     final now = DateTime.now();

     for (var doc in allCompetitions.docs) {
       final data = doc.data() as Map<String, dynamic>;
       final isActive = data['isActive'] ?? true;
       final deadline = DateTime.parse(data['deadline']);
       final category = data['category'] ?? 'Other';

       totalCompetitions++;

       if (isActive) {
         if (deadline.isAfter(now)) {
           activeCompetitions++;
         } else {
           expiredCompetitions++;
         }
       } else {
         inactiveCompetitions++;
       }

       // Count by category
       categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
     }

     return {
       'totalCompetitions': totalCompetitions,
       'activeCompetitions': activeCompetitions,
       'inactiveCompetitions': inactiveCompetitions,
       'expiredCompetitions': expiredCompetitions,
       ...categoryCounts.map((key, value) => MapEntry('category_$key', value)),
     };
   } catch (e) {
     print('Error getting competition stats: $e');
     rethrow;
   }
 }

 // Search competitions
 Future<List<Competition>> searchCompetitions(String query) async {
   try {
     if (query.trim().isEmpty) {
       return [];
     }

     final QuerySnapshot snapshot = await _firestore
         .collection(competitionsCollection)
         .where('isActive', isEqualTo: true)
         .get();

     List<Competition> competitions = [];
     final searchQuery = query.toLowerCase();

     for (var doc in snapshot.docs) {
       final data = doc.data() as Map<String, dynamic>;
       final competition = Competition.fromMap(data);
       
       // Search in title, description, category, and organizer
       if (competition.title.toLowerCase().contains(searchQuery) ||
           competition.description.toLowerCase().contains(searchQuery) ||
           competition.category.toLowerCase().contains(searchQuery) ||
           (competition.organizer?.toLowerCase().contains(searchQuery) ?? false)) {
         competitions.add(competition);
       }
     }

     // Sort by relevance (title matches first, then description, etc.)
     competitions.sort((a, b) {
       int scoreA = 0;
       int scoreB = 0;
       
       if (a.title.toLowerCase().contains(searchQuery)) scoreA += 3;
       if (a.category.toLowerCase().contains(searchQuery)) scoreA += 2;
       if (a.description.toLowerCase().contains(searchQuery)) scoreA += 1;
       
       if (b.title.toLowerCase().contains(searchQuery)) scoreB += 3;
       if (b.category.toLowerCase().contains(searchQuery)) scoreB += 2;
       if (b.description.toLowerCase().contains(searchQuery)) scoreB += 1;
       
       return scoreB.compareTo(scoreA);
     });

     return competitions;
   } catch (e) {
     print('Error searching competitions: $e');
     throw FirebaseAuthException(
       code: 'search-error',
       message: 'Error searching competitions: $e',
     );
   }
 }

 // Get upcoming competitions (deadline within next 30 days)
 Stream<List<Competition>> getUpcomingCompetitions() {
   final now = DateTime.now();
   final thirtyDaysFromNow = now.add(Duration(days: 30));
   
   return _firestore
       .collection(competitionsCollection)
       .where('isActive', isEqualTo: true)
       .where('deadline', isGreaterThan: now.toIso8601String())
       .where('deadline', isLessThan: thirtyDaysFromNow.toIso8601String())
       .orderBy('deadline')
       .snapshots()
       .map((snapshot) => snapshot.docs
           .map((doc) => Competition.fromMap(doc.data()))
           .toList());
 }

 // ===== AUTHENTICATION & UTILITY FUNCTIONS =====

 // Sign out
 Future<void> signOut() async {
   try {
     await _auth.signOut();
     print('User signed out successfully');
   } catch (e) {
     print('Error signing out: $e');
     throw FirebaseAuthException(
       code: 'sign-out-error',
       message: 'Error signing out: $e',
     );
   }
 }

 // Send password reset email
 Future<void> sendPasswordResetEmail(String email) async {
   try {
     if (email.trim().isEmpty) {
       throw FirebaseAuthException(
         code: 'invalid-email',
         message: 'Email cannot be empty',
       );
     }

     await _auth.sendPasswordResetEmail(email: email.trim());
     print('Password reset email sent to: $email');
   } on FirebaseAuthException catch (e) {
     print('FirebaseAuthException in sendPasswordResetEmail: ${e.code} - ${e.message}');
     rethrow;
   } catch (e) {
     print('Unexpected error in sendPasswordResetEmail: $e');
     throw FirebaseAuthException(
       code: 'unknown',
       message: 'An unexpected error occurred: ${e.toString()}',
     );
   }
 }

 // Change password
 Future<void> changePassword(String currentPassword, String newPassword) async {
   try {
     final user = currentUser;
     if (user == null) {
       throw FirebaseAuthException(
         code: 'no-current-user',
         message: 'No user is currently signed in',
       );
     }

     // Validate input
     if (currentPassword.trim().isEmpty || newPassword.trim().isEmpty) {
       throw FirebaseAuthException(
         code: 'invalid-input',
         message: 'Current password and new password cannot be empty',
       );
     }

     if (newPassword.length < 6) {
       throw FirebaseAuthException(
         code: 'weak-password',
         message: 'New password must be at least 6 characters long',
       );
     }

     // Re-authenticate user
     final credential = EmailAuthProvider.credential(
       email: user.email!,
       password: currentPassword,
     );
     
     await user.reauthenticateWithCredential(credential);
     
     // Update password
     await user.updatePassword(newPassword);
     
     print('Password changed successfully');
   } on FirebaseAuthException catch (e) {
     print('FirebaseAuthException in changePassword: ${e.code} - ${e.message}');
     rethrow;
   } catch (e) {
     print('Unexpected error in changePassword: $e');
     throw FirebaseAuthException(
       code: 'unknown',
       message: 'An unexpected error occurred: ${e.toString()}',
     );
   }
 }

 // Delete current user account
 Future<void> deleteCurrentUserAccount(String password) async {
   try {
     final user = currentUser;
     if (user == null) {
       throw FirebaseAuthException(
         code: 'no-current-user',
         message: 'No user is currently signed in',
       );
     }

     // Re-authenticate user
     final credential = EmailAuthProvider.credential(
       email: user.email!,
       password: password,
     );
     
     await user.reauthenticateWithCredential(credential);
     
     // Mark user as deleted in Firestore
     await _firestore.collection(usersCollection).doc(user.uid).update({
       'status': 'deleted',
       'deletedAt': FieldValue.serverTimestamp(),
       'deletedBy': user.uid,
     });
     
     // Delete the user account
     await user.delete();
     
     print('User account deleted successfully');
   } on FirebaseAuthException catch (e) {
     print('FirebaseAuthException in deleteCurrentUserAccount: ${e.code} - ${e.message}');
     rethrow;
   } catch (e) {
     print('Unexpected error in deleteCurrentUserAccount: $e');
     throw FirebaseAuthException(
       code: 'unknown',
       message: 'An unexpected error occurred: ${e.toString()}',
     );
   }
 }

 // Check if email exists
 Future<bool> checkEmailExists(String email) async {
   try {
     final methods = await _auth.fetchSignInMethodsForEmail(email.trim());
     return methods.isNotEmpty;
   } catch (e) {
     print('Error checking email existence: $e');
     return false;
   }
 }

 // Get user document stream
 Stream<DocumentSnapshot> getUserDocumentStream() {
   final user = currentUser;
   if (user == null) {
     return Stream.empty();
   }
   
   return _firestore
       .collection(usersCollection)
       .doc(user.uid)
       .snapshots();
 }

 // Batch operations helper
 WriteBatch getBatch() {
   return _firestore.batch();
 }

 // Execute batch operations
 Future<void> commitBatch(WriteBatch batch) async {
   try {
     await batch.commit();
     print('Batch operation completed successfully');
   } catch (e) {
     print('Error executing batch operation: $e');
     rethrow;
   }
 }

 // ===== VALIDATION HELPERS =====
 
 // Validate email format
 bool isValidEmail(String email) {
   return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
 }

 // Validate password strength
 Map<String, bool> validatePasswordStrength(String password) {
   return {
     'minLength': password.length >= 8,
     'hasUppercase': password.contains(RegExp(r'[A-Z]')),
     'hasLowercase': password.contains(RegExp(r'[a-z]')),
     'hasNumbers': password.contains(RegExp(r'[0-9]')),
     'hasSpecialChars': password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
   };
 }

 // Get password strength score
 int getPasswordStrengthScore(String password) {
   final validation = validatePasswordStrength(password);
   return validation.values.where((v) => v).length;
 }

 // ===== ERROR HANDLING HELPERS =====
 
 // Get user-friendly error message
 String getErrorMessage(FirebaseAuthException e) {
   switch (e.code) {
     case 'user-not-found':
       return 'No user found with this email address.';
     case 'wrong-password':
       return 'Incorrect password. Please try again.';
     case 'email-already-in-use':
       return 'An account already exists with this email address.';
     case 'weak-password':
       return 'Password is too weak. Use at least 6 characters.';
     case 'invalid-email':
       return 'Please enter a valid email address.';
     case 'user-disabled':
       return 'This account has been disabled.';
     case 'too-many-requests':
       return 'Too many failed attempts. Please try again later.';
     case 'network-request-failed':
       return 'Network error. Please check your connection.';
     case 'invalid-email-domain':
       return 'Email must be @gmail.com for users or @admin.ac.id for administrators.';
     case 'permission-denied':
       return 'You don\'t have permission to perform this action.';
     case 'cannot-disable-self':
       return 'You cannot disable your own account.';
     case 'cannot-delete-self':
       return 'You cannot delete your own account.';
     default:
       return e.message ?? 'An error occurred. Please try again.';
   }
 }

 Future<void> resetPassword(String email) async {
  try {
    if (email.trim().isEmpty) {
      throw FirebaseAuthException(
        code: 'invalid-email',
        message: 'Email cannot be empty',
      );
    }

    // Validasi format email
    if (!isValidEmail(email.trim())) {
      throw FirebaseAuthException(
        code: 'invalid-email',
        message: 'Please enter a valid email address',
      );
    }

    // Validasi domain email
    final emailLower = email.toLowerCase().trim();
    if (!emailLower.endsWith('@gmail.com') && !emailLower.endsWith('@admin.ac.id')) {
      throw FirebaseAuthException(
        code: 'invalid-email-domain',
        message: 'Email must be either @gmail.com for users or @admin.ac.id for administrators',
      );
    }

    // Check if email exists in our system
    final emailExists = await checkEmailExists(emailLower);
    if (!emailExists) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No account found with this email address',
      );
    }

    // Send password reset email
    await _auth.sendPasswordResetEmail(email: emailLower);
    print('Password reset email sent to: $emailLower');
    
  } on FirebaseAuthException catch (e) {
    print('FirebaseAuthException in resetPassword: ${e.code} - ${e.message}');
    rethrow;
  } catch (e) {
    print('Unexpected error in resetPassword: $e');
    throw FirebaseAuthException(
      code: 'unknown',
      message: 'An unexpected error occurred: ${e.toString()}',
    );
  }
}
}