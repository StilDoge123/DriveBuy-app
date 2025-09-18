import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import '../../domain/models/car_ad.dart';
import '../../config/api_config.dart';
import '../../presentation/app/di/locator.dart';

class UserRepository {
  final String baseUrl;
  final FirebaseAuth _firebaseAuth;
  final Dio _dio;

  UserRepository({
    String? baseUrl,
    FirebaseAuth? firebaseAuth,
    Dio? dio,
  })  : baseUrl = baseUrl ?? ApiConfig.baseUrl,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _dio = dio ?? locator<Dio>();

  Future<Map<String, dynamic>> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('No user is currently logged in');
    }
    final token = await user.getIdToken();
    if (token == null) {
      throw Exception('Failed to get authentication token');
    }
    final response = await _dio.get(
      '$baseUrl/users/me',
      options: Options(headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      }),
    );
    if (response.statusCode == 200) {
      return response.data;
    } else if (response.statusCode == 403) {
      throw Exception('User account not found in backend. Please register first or contact support.');
    } else {
      throw Exception('Failed to load current user data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getUser(String id) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('No user is currently logged in');
    }
    final token = await user.getIdToken();
    if (token == null) {
      throw Exception('Failed to get authentication token');
    }
    
    print('🔍 UserRepository: Getting user $id');
    final response = await _dio.get(
      '$baseUrl/users/$id',
      options: Options(headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      }),
    );
    
    print('🔍 UserRepository: User response status: ${response.statusCode}');
    print('🔍 UserRepository: User response data: ${response.data}');
    
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to load user: ${response.statusCode}');
    }
  }

  Future<List<CarAd>> getSavedAds() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('No user is currently logged in');
    final userId = user.uid;
    final token = await user.getIdToken();
    if (token == null) {
      throw Exception('Failed to get authentication token');
    }
    final response = await _dio.get(
      '$baseUrl/users/$userId/saved-ads',
      options: Options(headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      }),
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = response.data;
      return jsonList.map((json) => CarAd.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load saved ads: ${response.statusCode}');
    }
  }

  Future<List<CarAd>> getListedAds() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('No user is currently logged in');
    final userId = user.uid;
    final token = await user.getIdToken();
    if (token == null) {
      throw Exception('Failed to get authentication token');
    }
    final response = await _dio.get(
      '$baseUrl/ads/user/$userId',
      options: Options(headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      }),
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = response.data;
      return jsonList.map((json) => CarAd.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load listed ads: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> updateUser(
    String userId, {
    String? name,
    String? email,
    String? phone,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('No user is currently logged in');
    final token = await user.getIdToken();
    if (token == null) {
      throw Exception('Failed to get authentication token');
    }
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (email != null) body['email'] = email;
    if (phone != null) body['phone'] = phone;
    final response = await _dio.patch(
      '$baseUrl/users/$userId',
      data: json.encode(body),
      options: Options(headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      }),
    );
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to update user: ${response.statusCode}');
    }
  }
} 