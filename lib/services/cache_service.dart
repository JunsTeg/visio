import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String _userCacheKey = 'user_cache';
  static const String _settingsCacheKey = 'settings_cache';
  static const Duration _defaultExpiry = Duration(hours: 1);

  // Cache en mémoire pour les données fréquemment utilisées
  static final Map<String, _CacheEntry> _memoryCache = {};

  // Sauvegarder des données dans le cache
  static Future<void> setData(
    String key,
    dynamic data, {
    Duration? expiry,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final entry = _CacheEntry(
      data: data,
      timestamp: DateTime.now(),
      expiry: expiry ?? _defaultExpiry,
    );

    // Cache en mémoire
    _memoryCache[key] = entry;

    // Cache persistant
    await prefs.setString(key, jsonEncode(entry.toJson()));
  }

  // Récupérer des données du cache
  static Future<T?> getData<T>(String key) async {
    // Vérifier d'abord le cache en mémoire
    if (_memoryCache.containsKey(key)) {
      final entry = _memoryCache[key]!;
      if (!entry.isExpired) {
        return entry.data as T;
      } else {
        _memoryCache.remove(key);
      }
    }

    // Vérifier le cache persistant
    final prefs = await SharedPreferences.getInstance();
    final cachedString = prefs.getString(key);

    if (cachedString != null) {
      try {
        final entry = _CacheEntry.fromJson(jsonDecode(cachedString));
        if (!entry.isExpired) {
          // Remettre en cache mémoire
          _memoryCache[key] = entry;
          return entry.data as T;
        } else {
          // Supprimer les données expirées
          await prefs.remove(key);
        }
      } catch (e) {
        // En cas d'erreur de parsing, supprimer les données corrompues
        await prefs.remove(key);
      }
    }

    return null;
  }

  // Supprimer des données du cache
  static Future<void> removeData(String key) async {
    _memoryCache.remove(key);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // Vider tout le cache
  static Future<void> clearCache() async {
    _memoryCache.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Vérifier si des données existent dans le cache
  static Future<bool> hasData(String key) async {
    return await getData(key) != null;
  }

  // Méthodes spécialisées pour les utilisateurs
  static Future<void> cacheUser(dynamic userData) async {
    await setData(_userCacheKey, userData, expiry: const Duration(hours: 24));
  }

  static Future<dynamic> getCachedUser() async {
    return await getData(_userCacheKey);
  }

  // Méthodes spécialisées pour les paramètres
  static Future<void> cacheSettings(dynamic settings) async {
    await setData(_settingsCacheKey, settings, expiry: const Duration(days: 7));
  }

  static Future<dynamic> getCachedSettings() async {
    return await getData(_settingsCacheKey);
  }

  // Nettoyer le cache expiré
  static Future<void> cleanExpiredCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    for (final key in keys) {
      final cachedString = prefs.getString(key);
      if (cachedString != null) {
        try {
          final entry = _CacheEntry.fromJson(jsonDecode(cachedString));
          if (entry.isExpired) {
            await prefs.remove(key);
          }
        } catch (e) {
          await prefs.remove(key);
        }
      }
    }

    // Nettoyer aussi le cache mémoire
    _memoryCache.removeWhere((key, entry) => entry.isExpired);
  }
}

// Classe pour représenter une entrée de cache
class _CacheEntry {
  final dynamic data;
  final DateTime timestamp;
  final Duration expiry;

  _CacheEntry({
    required this.data,
    required this.timestamp,
    required this.expiry,
  });

  bool get isExpired {
    return DateTime.now().isAfter(timestamp.add(expiry));
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'expiry': expiry.inMilliseconds,
    };
  }

  factory _CacheEntry.fromJson(Map<String, dynamic> json) {
    return _CacheEntry(
      data: json['data'],
      timestamp: DateTime.parse(json['timestamp']),
      expiry: Duration(milliseconds: json['expiry']),
    );
  }
}
