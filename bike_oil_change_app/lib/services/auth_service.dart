import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';

class AuthService {
  static const String _userKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _currentUserKey = 'current_user';

  // Save a user to local storage
  Future<bool> saveUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_userKey) ?? '{}';
      final Map<String, dynamic> users = json.decode(usersJson);
      
      // Store user data by bike number as key
      users[user.bikeNumber] = user.toJson();
      
      await prefs.setString(_userKey, json.encode(users));
      return true;
    } catch (e) {
      print('Error saving user: $e');
      return false;
    }
  }

  // Get a user by bike number (username)
  Future<User?> getUser(String bikeNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_userKey) ?? '{}';
      final Map<String, dynamic> users = json.decode(usersJson);
      
      if (users.containsKey(bikeNumber)) {
        return User.fromJson(users[bikeNumber]);
      }
      
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // Login function
  Future<bool> login(String bikeNumber, String chassisNumber) async {
    try {
      final user = await getUser(bikeNumber);
      
      if (user != null && user.chassisNumber == chassisNumber) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_isLoggedInKey, true);
        await prefs.setString(_currentUserKey, bikeNumber);
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error during login: $e');
      return false;
    }
  }

  // Register a new user
  Future<bool> register(User user) async {
    try {
      final existingUser = await getUser(user.bikeNumber);
      
      if (existingUser != null) {
        return false; // User already exists
      }
      
      return await saveUser(user);
    } catch (e) {
      print('Error during registration: $e');
      return false;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // Get the current logged-in user
  Future<User?> getCurrentUser() async {
    try {
      if (!(await isLoggedIn())) {
        return null;
      }
      
      final prefs = await SharedPreferences.getInstance();
      final currentBikeNumber = prefs.getString(_currentUserKey);
      
      if (currentBikeNumber == null) {
        return null;
      }
      
      return await getUser(currentBikeNumber);
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Logout function
  Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, false);
      await prefs.remove(_currentUserKey);
      return true;
    } catch (e) {
      print('Error during logout: $e');
      return false;
    }
  }

  // Update user information
  Future<bool> updateUser(User user) async {
    return await saveUser(user);
  }
}
