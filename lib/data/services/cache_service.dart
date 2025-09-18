import 'dart:async';
import '../../domain/models/car_ad.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  // Cache storage
  final Map<String, CacheEntry> _cache = {};
  
  // Cache durations
  static const Duration _profileCacheDuration = Duration(hours: 1);
  static const Duration _savedAdsCacheDuration = Duration(minutes: 30);
  static const Duration _listingsCacheDuration = Duration(minutes: 15);
  static const Duration _adDetailsCacheDuration = Duration(hours: 2);

  /// Cache profile information
  Future<void> cacheProfile(String userId, Map<String, dynamic> profile) async {
    _cache['profile_$userId'] = CacheEntry(
      data: profile,
      expiry: DateTime.now().add(_profileCacheDuration),
    );
  }

  /// Get cached profile information
  Map<String, dynamic>? getCachedProfile(String userId) {
    final entry = _cache['profile_$userId'];
    if (entry != null && !entry.isExpired) {
      return entry.data as Map<String, dynamic>;
    }
    _cache.remove('profile_$userId');
    return null;
  }

  /// Cache saved ads
  Future<void> cacheSavedAds(String userId, List<int> savedAdIds) async {
    _cache['saved_ads_$userId'] = CacheEntry(
      data: savedAdIds,
      expiry: DateTime.now().add(_savedAdsCacheDuration),
    );
  }

  /// Get cached saved ads
  List<int>? getCachedSavedAds(String userId) {
    final entry = _cache['saved_ads_$userId'];
    if (entry != null && !entry.isExpired) {
      return entry.data as List<int>;
    }
    _cache.remove('saved_ads_$userId');
    return null;
  }

  /// Cache user listings
  Future<void> cacheUserListings(String userId, List<CarAd> listings) async {
    _cache['listings_$userId'] = CacheEntry(
      data: listings,
      expiry: DateTime.now().add(_listingsCacheDuration),
    );
  }

  /// Get cached user listings
  List<CarAd>? getCachedUserListings(String userId) {
    final entry = _cache['listings_$userId'];
    if (entry != null && !entry.isExpired) {
      return entry.data as List<CarAd>;
    }
    _cache.remove('listings_$userId');
    return null;
  }

  /// Cache ad details
  Future<void> cacheAdDetails(int adId, CarAd ad) async {
    _cache['ad_$adId'] = CacheEntry(
      data: ad,
      expiry: DateTime.now().add(_adDetailsCacheDuration),
    );
  }

  /// Get cached ad details
  CarAd? getCachedAdDetails(int adId) {
    final entry = _cache['ad_$adId'];
    if (entry != null && !entry.isExpired) {
      return entry.data as CarAd;
    }
    _cache.remove('ad_$adId');
    return null;
  }

  /// Cache marketplace ads
  Future<void> cacheMarketplaceAds(List<CarAd> ads) async {
    _cache['marketplace_ads'] = CacheEntry(
      data: ads,
      expiry: DateTime.now().add(const Duration(minutes: 10)),
    );
  }

  /// Get cached marketplace ads
  List<CarAd>? getCachedMarketplaceAds() {
    final entry = _cache['marketplace_ads'];
    if (entry != null && !entry.isExpired) {
      return entry.data as List<CarAd>;
    }
    _cache.remove('marketplace_ads');
    return null;
  }

  /// Invalidate specific cache entries
  void invalidateProfile(String userId) {
    _cache.remove('profile_$userId');
  }

  void invalidateSavedAds(String userId) {
    _cache.remove('saved_ads_$userId');
  }

  void invalidateUserListings(String userId) {
    _cache.remove('listings_$userId');
  }

  void invalidateAdDetails(int adId) {
    _cache.remove('ad_$adId');
  }

  void invalidateMarketplaceAds() {
    _cache.remove('marketplace_ads');
  }

  /// Invalidate all cache entries for a user
  void invalidateUserCache(String userId) {
    invalidateProfile(userId);
    invalidateSavedAds(userId);
    invalidateUserListings(userId);
  }

  /// Invalidate all ad-related caches when an ad is updated
  void invalidateAdCaches(int adId, String? userId) {
    // Invalidate the specific ad details cache
    invalidateAdDetails(adId);
    
    // Invalidate marketplace ads cache (since the ad list might have changed)
    invalidateMarketplaceAds();
    
    // Invalidate user listings cache if we have the userId
    if (userId != null) {
      invalidateUserListings(userId);
    }
  }

  /// Clear all expired cache entries
  void _cleanupExpiredEntries() {
    final expiredKeys = <String>[];
    
    for (final entry in _cache.entries) {
      if (entry.value.isExpired) {
        expiredKeys.add(entry.key);
      }
    }
    
    for (final key in expiredKeys) {
      _cache.remove(key);
    }
  }

  /// Start periodic cleanup of expired cache entries
  void startCleanupTimer() {
    Timer.periodic(const Duration(minutes: 30), (_) {
      _cleanupExpiredEntries();
    });
  }

  /// Clear all cache
  void clearAll() {
    _cache.clear();
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    int expiredCount = 0;
    int activeCount = 0;
    
    for (final entry in _cache.values) {
      if (entry.isExpired) {
        expiredCount++;
      } else {
        activeCount++;
      }
    }
    
    return {
      'totalEntries': _cache.length,
      'activeEntries': activeCount,
      'expiredEntries': expiredCount,
    };
  }
}

class CacheEntry {
  final dynamic data;
  final DateTime expiry;

  CacheEntry({
    required this.data,
    required this.expiry,
  });

  bool get isExpired => DateTime.now().isAfter(expiry);
}
