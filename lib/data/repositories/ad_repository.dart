import 'dart:convert';
import 'package:dio/dio.dart';
import '../../domain/models/car_ad.dart';
import '../../domain/models/car_ad_with_seller.dart';
import '../../domain/models/car_search_filter.dart';
import '../../config/api_config.dart';
import '../../presentation/app/di/locator.dart';

class AdRepository {
  final String baseUrl;
  final Dio _dio;

  AdRepository({
    String? baseUrl,
    Dio? dio,
  })  : baseUrl = baseUrl ?? ApiConfig.baseUrl,
        _dio = dio ?? locator<Dio>();

  Future<Response> _getWithAuth(String url) async {
    try {
      final response = await _dio.get(url);
      print('🔍 AdRepository: Response received: ${response.statusCode}');
      return response;
    } catch (e) {
      print('🔍 AdRepository: Error in _getWithAuth: ${e.toString()}');
      rethrow;
    }
  }

  Future<CarAd> getAd(int id) async {
    final response = await _getWithAuth('$baseUrl/ads/$id');
    if (response.statusCode == 200) {
      return CarAd.fromJson(response.data);
    } else {
      throw Exception('Failed to load ad');
    }
  }

  Future<List<CarAd>> getAds() async {
    try {
      print('🔍 AdRepository: Attempting to fetch ads from $baseUrl/ads/all');
      final response = await _getWithAuth('$baseUrl/ads/all');
      print('🔍 AdRepository: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        print('🔍 AdRepository: Successfully loaded ${jsonList.length} ads');
        return jsonList.map((json) => CarAd.fromJson(json)).toList();
      } else {
        print('🔍 AdRepository: HTTP ${response.statusCode}');
        throw Exception('Failed to load ads: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('🔍 AdRepository: Exception caught: ${e.toString()}');
      rethrow;
    }
  }



  Future<List<CarAd>> searchAds(CarSearchFilter filter) async {
    final queryParams = <String, dynamic>{};

    if (filter.make != null) queryParams['make'] = filter.make!;
    if (filter.model != null) queryParams['model'] = filter.model!;
    if (filter.keywordSearch != null) queryParams['keyword'] = filter.keywordSearch!;
    if (filter.yearFrom != null) queryParams['minYear'] = filter.yearFrom!;
    if (filter.yearTo != null) queryParams['maxYear'] = filter.yearTo!;
    if (filter.minPrice != null) queryParams['minPrice'] = filter.minPrice!;
    if (filter.maxPrice != null) queryParams['maxPrice'] = filter.maxPrice!;
    if (filter.minHp != null) queryParams['minHp'] = filter.minHp!;
    if (filter.maxHp != null) queryParams['maxHp'] = filter.maxHp!;
    if (filter.minDisplacement != null) queryParams['minDisplacement'] = filter.minDisplacement!;
    if (filter.maxDisplacement != null) queryParams['maxDisplacement'] = filter.maxDisplacement!;
    if (filter.minMileage != null) queryParams['minMileage'] = filter.minMileage!;
    if (filter.maxMileage != null) queryParams['maxMileage'] = filter.maxMileage!;
    if (filter.minOwnerCount != null) queryParams['minOwnerCount'] = filter.minOwnerCount!;
    if (filter.maxOwnerCount != null) queryParams['maxOwnerCount'] = filter.maxOwnerCount!;
    if (filter.region != null) queryParams['region'] = filter.region!;
    if (filter.city != null) queryParams['city'] = filter.city!;
    if (filter.color != null) queryParams['color'] = filter.color!;
    if (filter.transmissionType != null) queryParams['transmissionType'] = filter.transmissionType!;
    if (filter.fuelType != null) queryParams['fuelType'] = filter.fuelType!;
    if (filter.bodyType != null) queryParams['bodyType'] = filter.bodyType!;
    if (filter.doorCount != null) queryParams['doorCount'] = filter.doorCount!;
    if (filter.driveType != null) queryParams['driveType'] = filter.driveType!;
    if (filter.features != null && filter.features!.isNotEmpty) {
      queryParams['features'] = filter.features!.join(',');
    }
    if (filter.conditions != null && filter.conditions!.isNotEmpty) {
      queryParams['conditions'] = filter.conditions!.join(',');
    }
    if (filter.sortBy != null) queryParams['sortBy'] = filter.sortBy!;

    final uri = '$baseUrl/ads/filter';
    final response = await _dio.get(uri, queryParameters: queryParams);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = response.data;
      return jsonList.map((json) => CarAd.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search ads');
    }
  }

  Future<List<CarAd>> getAdsByUserId(String userId) async {
    try {
      print('🔍 AdRepository: Fetching ads for user $userId from $baseUrl/ads/user/$userId');
      final response = await _getWithAuth('$baseUrl/ads/user/$userId');
      print('🔍 AdRepository: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        print('🔍 AdRepository: Successfully loaded ${jsonList.length} ads for user $userId');
        return jsonList.map((json) => CarAd.fromJson(json)).toList();
      } else {
        print('🔍 AdRepository: HTTP ${response.statusCode}');
        throw Exception('Failed to load user ads: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('🔍 AdRepository: Exception caught while fetching user ads: ${e.toString()}');
      rethrow;
    }
  }

  Future<CarAd> updateAd(int adId, Map<String, dynamic> adData, List<String>? newImagePaths, List<String>? imagesToDelete) async {
    try {
      print('🔍 AdRepository: Updating ad $adId');
      
      final formData = FormData();
      
      formData.fields.add(MapEntry('data', jsonEncode(adData)));
      
      if (newImagePaths != null && newImagePaths.isNotEmpty) {
        for (final imagePath in newImagePaths) {
          final file = await MultipartFile.fromFile(imagePath);
          formData.files.add(MapEntry('newImages', file));
        }
      }
      
      if (imagesToDelete != null && imagesToDelete.isNotEmpty) {
        for (final imageUrl in imagesToDelete) {
          formData.fields.add(MapEntry('imagesToDelete', imageUrl));
        }
      }
      
      final response = await _dio.patch(
        '$baseUrl/ads/$adId',
        data: formData,
      );
      
      if (response.statusCode == 200) {
        print('🔍 AdRepository: Successfully updated ad $adId');
        return CarAd.fromJson(response.data);
      } else {
        throw Exception('Failed to update ad: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('🔍 AdRepository: Exception caught while updating ad: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> deleteAd(int adId) async {
    try {
      print('🔍 AdRepository: Deleting ad $adId');
      final response = await _dio.delete('$baseUrl/ads/$adId');
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        print('🔍 AdRepository: Successfully deleted ad $adId');
      } else {
        throw Exception('Failed to delete ad: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('🔍 AdRepository: Exception caught while deleting ad: ${e.toString()}');
      rethrow;
    }
  }

  // New methods using the with-user-info endpoints
  Future<CarAdWithSeller> getAdWithSeller(int id) async {
    final response = await _getWithAuth('$baseUrl/ads/$id/with-user-info');
    if (response.statusCode == 200) {
      return CarAdWithSeller.fromJson(response.data);
    } else {
      throw Exception('Failed to load ad with seller info');
    }
  }

  Future<List<CarAdWithSeller>> getAdsWithSeller() async {
    try {
      print('🔍 AdRepository: Attempting to fetch ads with seller info from $baseUrl/ads/with-user-info');
      final response = await _getWithAuth('$baseUrl/ads/with-user-info');
      print('🔍 AdRepository: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        print('🔍 AdRepository: Successfully loaded ${jsonList.length} ads with seller info');
        return jsonList.map((json) => CarAdWithSeller.fromJson(json)).toList();
      } else {
        print('🔍 AdRepository: HTTP ${response.statusCode}');
        throw Exception('Failed to load ads with seller info: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('🔍 AdRepository: Exception caught: ${e.toString()}');
      rethrow;
    }
  }

  Future<List<CarAdWithSeller>> searchAdsWithSeller(CarSearchFilter filter) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (filter.make != null) queryParams['make'] = filter.make;
      if (filter.model != null) queryParams['model'] = filter.model;
      if (filter.keywordSearch != null) queryParams['keyword'] = filter.keywordSearch;
      if (filter.color != null) queryParams['color'] = filter.color;
      if (filter.yearFrom != null) queryParams['minYear'] = filter.yearFrom;
      if (filter.yearTo != null) queryParams['maxYear'] = filter.yearTo;
      if (filter.minPrice != null) queryParams['minPrice'] = filter.minPrice;
      if (filter.maxPrice != null) queryParams['maxPrice'] = filter.maxPrice;
      if (filter.hpFrom != null) queryParams['minHp'] = filter.hpFrom;
      if (filter.hpTo != null) queryParams['maxHp'] = filter.hpTo;
      if (filter.displacementFrom != null) queryParams['minDisplacement'] = filter.displacementFrom;
      if (filter.displacementTo != null) queryParams['maxDisplacement'] = filter.displacementTo;
      if (filter.mileageFrom != null) queryParams['minMileage'] = filter.mileageFrom;
      if (filter.mileageTo != null) queryParams['maxMileage'] = filter.mileageTo;
      if (filter.ownerCountFrom != null) queryParams['minOwnerCount'] = filter.ownerCountFrom;
      if (filter.ownerCountTo != null) queryParams['maxOwnerCount'] = filter.ownerCountTo;
      if (filter.transmissionType != null) queryParams['transmissionType'] = filter.transmissionType;
      if (filter.fuelType != null) queryParams['fuelType'] = filter.fuelType;
      if (filter.bodyType != null) queryParams['bodyType'] = filter.bodyType;
      if (filter.steeringPosition != null) queryParams['steeringPosition'] = filter.steeringPosition;
      if (filter.cylinderCount != null) queryParams['cylinderCount'] = filter.cylinderCount;
      if (filter.driveType != null) queryParams['driveType'] = filter.driveType;
      if (filter.region != null) queryParams['region'] = filter.region;
      if (filter.city != null) queryParams['city'] = filter.city;
      if (filter.features != null && filter.features!.isNotEmpty) {
        queryParams['features'] = filter.features!.join(',');
      }
      if (filter.conditions != null && filter.conditions!.isNotEmpty) {
        queryParams['conditions'] = filter.conditions!.join(',');
      }

      print('🔍 AdRepository: Searching ads with seller info with params: $queryParams');
      
      final response = await _dio.get(
        '$baseUrl/ads/with-user-info',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        print('🔍 AdRepository: Successfully loaded ${jsonList.length} filtered ads with seller info');
        return jsonList.map((json) => CarAdWithSeller.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search ads with seller info: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('🔍 AdRepository: Exception in searchAdsWithSeller: ${e.toString()}');
      rethrow;
    }
  }
} 