import 'package:drivebuy/presentation/app/di/locator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import '../../config/api_config.dart';
import '../services/chat_service.dart';
import '../services/realtime_service.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final Dio _dio;
  final String _baseUrl;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    Dio? dio,
    String? baseUrl,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _dio = dio ?? locator<Dio>(),
        _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  Stream<User?> get user => _firebaseAuth.authStateChanges();

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/users/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
        },
        options: Options(headers: ApiConfig.defaultHeaders),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Failed to register user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final token = await userCredential.user?.getIdToken();
      if (token == null) {
        throw Exception('Failed to get authentication token.');
      }
      final response = await _dio.post(
        '$_baseUrl/users/login',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          ...ApiConfig.defaultHeaders,
        }),
      );
      if (response.statusCode != 200) {
        throw Exception(
            'Failed to sync with backend: ${response.statusCode} ${response.data}');
      }
      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('An unknown error occurred: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    // Clear ChatService and disconnect realtime before signing out
    try {
      final chatService = locator<ChatService>();
      chatService.clearAllChats();
      
      // Disconnect realtime service
      final realtimeService = locator<RealtimeService>();
      await realtimeService.disconnect();
    } catch (e) {
      print('🔍 AuthRepository: Error clearing services: $e');
    }
    
    await _firebaseAuth.signOut();
  }

  Future<String?> getIdToken() async {
    try {
      final user = _firebaseAuth.currentUser;
      print('🔍 AuthRepository: Current user: ${user != null ? 'Yes' : 'No'}');
      
      if (user != null) {
        final token = await user.getIdToken();
        print('🔍 AuthRepository: Token retrieved: ${token != null ? 'Yes' : 'No'}');
        return token;
      } else {
        print('🔍 AuthRepository: No current user');
        return null;
      }
    } catch (e) {
      print('🔍 AuthRepository: Error getting token: $e');
      return null;
    }
  }
} 