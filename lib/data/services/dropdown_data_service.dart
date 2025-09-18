import 'package:dio/dio.dart';
import '../../config/api_config.dart';
import '../../presentation/app/di/locator.dart';

class DropdownDataService {
  final String baseUrl;
  final Dio dio;

  DropdownDataService({Dio? dio}) 
    : baseUrl = ApiConfig.baseUrl,
      dio = dio ?? locator<Dio>();

  Future<List<String>> getTransmissionTypes() async {
    try {
      final response = await dio.get('$baseUrl/transmissionTypes');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((e) => e['transmissionTypeName'].toString()).toList();
      }
      throw Exception('Failed to load transmission types');
    } catch (e) {
      print('🔍 DropdownService: Error loading transmission types: ${e.toString()}');
      return []; // Return empty list instead of crashing
    }
  }

  Future<List<String>> getFuelTypes() async {
    try {
      final response = await dio.get('$baseUrl/fuelTypes');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((e) => e['fuelTypeName'].toString()).toList();
      }
      throw Exception('Failed to load fuel types');
    } catch (e) {
      print('🔍 DropdownService: Error loading fuel types: ${e.toString()}');
      return []; // Return empty list instead of crashing
    }
  }

  Future<List<String>> getBodyTypes() async {
    try {
      final response = await dio.get('$baseUrl/bodyTypes');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((e) => e['bodyTypeName'].toString()).toList();
      }
      throw Exception('Failed to load body types');
    } catch (e) {
      print('🔍 DropdownService: Error loading body types: ${e.toString()}');
      return []; // Return empty list instead of crashing
    }
  }

  Future<List<String>> getDoorCounts() async {
    try {
      final response = await dio.get('$baseUrl/doorCounts');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((e) => e['doorCount'].toString()).toList();
      }
      throw Exception('Failed to load door counts');
    } catch (e) {
      print('🔍 DropdownService: Error loading door counts: ${e.toString()}');
      return []; // Return empty list instead of crashing
    }
  }

  Future<List<String>> getBrands() async {
    try {
      print('🔍 DropdownService: Fetching brands from $baseUrl/brands');
      final response = await dio.get('$baseUrl/brands');
      print('🔍 DropdownService: Brands response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        print('🔍 DropdownService: Successfully loaded ${data.length} brands');
        return data.map((e) => e['brandName'].toString()).toList();
      }
      throw Exception('Failed to load brands: ${response.statusCode}');
    } catch (e) {
      print('🔍 DropdownService: Error loading brands: ${e.toString()}');
      print('🔍 DropdownService: Returning empty list to allow app to continue');
      return []; // Return empty list instead of crashing
    }
  }

  Future<List<Map<String, dynamic>>> getBrandsWithIds() async {
    try {
      print('🔍 DropdownService: Fetching brands with IDs from $baseUrl/brands');
      final response = await dio.get('$baseUrl/brands');
      print('🔍 DropdownService: Brands response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        print('🔍 DropdownService: Successfully loaded ${data.length} brands with IDs');
        return data.map((e) => {
          'id': e['id'].toString(),
          'name': e['brandName'].toString()
        }).toList();
      }
      throw Exception('Failed to load brands: ${response.statusCode}');
    } catch (e) {
      print('🔍 DropdownService: Error loading brands: ${e.toString()}');
      print('🔍 DropdownService: Returning empty list to allow app to continue');
      return []; // Return empty list instead of crashing
    }
  }

  Future<List<String>> getModels(String brandId) async {
    final response = await dio.get('$baseUrl/models/brandId/$brandId');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((e) => e['modelName'].toString()).toList();
    }
    throw Exception('Failed to load models');
  }

  Future<List<String>> getFeatures() async {
    final response = await dio.get('$baseUrl/carFeatures');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((e) => e['featureName'].toString()).toList();
    }
    throw Exception('Failed to load features');
  }

  Future<List<String>> getSteeringPositions() async {
    final response = await dio.get('$baseUrl/steeringPositions');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((e) => e['steeringPositionName'].toString()).toList();
    }
    throw Exception('Failed to load steering positions');
  }

  Future<List<String>> getCylinderCounts() async {
    final response = await dio.get('$baseUrl/cylinderCounts');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((e) => e['cylinderCount'].toString()).toList();
    }
    throw Exception('Failed to load cylinder counts');
  }

  Future<List<String>> getDriveTypes() async {
    try {
      final response = await dio.get('$baseUrl/driveTypes');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((e) => e['driveTypeName'].toString()).toList();
      }
      throw Exception('Failed to load drive types');
    } catch (e) {
      print('🔍 DropdownService: Error loading drive types: ${e.toString()}');
      return []; // Return empty list instead of crashing
    }
  }

  Future<List<String>> getCarConditions() async {
    final response = await dio.get('$baseUrl/carConditions');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((e) => e['conditionName'].toString()).toList();
    }
    throw Exception('Failed to load car conditions');
  }

  Future<List<String>> getColors() async {
    final response = await dio.get('$baseUrl/colors');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((e) => e['colorName'].toString()).toList();
    }
    throw Exception('Failed to load colors');
  }

  Future<List<Map<String, dynamic>>> getRegions() async {
    final response = await dio.get('$baseUrl/locations/regions');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((e) => {'id': e['id'], 'name': e['regionName']}).toList();
    }
    throw Exception('Failed to load regions');
  }

  Future<List<Map<String, dynamic>>> getCitiesByRegion(String regionId) async {
    final response = await dio.get('$baseUrl/locations/regions/$regionId/cities');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((e) => {'id': e['id'], 'name': e['cityName']}).toList();
    }
    throw Exception('Failed to load cities');
  }
} 