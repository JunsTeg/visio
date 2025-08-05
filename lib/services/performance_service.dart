import 'dart:async';
import 'package:flutter/foundation.dart';

class PerformanceService {
  static final Map<String, DateTime> _operationStartTimes = {};
  static final Map<String, List<Duration>> _operationDurations = {};
  static final List<String> _performanceLog = [];

  // Mesurer le temps d'exécution d'une opération
  static Future<T> measureOperation<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    final startTime = DateTime.now();
    _operationStartTimes[operationName] = startTime;

    try {
      final result = await operation();
      _recordOperationDuration(operationName, startTime);
      return result;
    } catch (e) {
      _recordOperationDuration(operationName, startTime);
      rethrow;
    }
  }

  // Mesurer le temps d'exécution d'une opération synchrone
  static T measureSyncOperation<T>(
    String operationName,
    T Function() operation,
  ) {
    final startTime = DateTime.now();
    _operationStartTimes[operationName] = startTime;

    try {
      final result = operation();
      _recordOperationDuration(operationName, startTime);
      return result;
    } catch (e) {
      _recordOperationDuration(operationName, startTime);
      rethrow;
    }
  }

  // Enregistrer la durée d'une opération
  static void _recordOperationDuration(
    String operationName,
    DateTime startTime,
  ) {
    final duration = DateTime.now().difference(startTime);

    if (!_operationDurations.containsKey(operationName)) {
      _operationDurations[operationName] = [];
    }

    _operationDurations[operationName]!.add(duration);

    // Garder seulement les 100 dernières mesures
    if (_operationDurations[operationName]!.length > 100) {
      _operationDurations[operationName]!.removeAt(0);
    }

    // Logger les opérations lentes
    if (duration.inMilliseconds > 1000) {
      _logSlowOperation(operationName, duration);
    }
  }

  // Logger les opérations lentes
  static void _logSlowOperation(String operationName, Duration duration) {
    final message =
        'Opération lente détectée: $operationName (${duration.inMilliseconds}ms)';
    _performanceLog.add('${DateTime.now()}: $message');

    if (kDebugMode) {
      print('⚠️ $message');
    }
  }

  // Obtenir les statistiques de performance
  static Map<String, dynamic> getPerformanceStats() {
    final stats = <String, dynamic>{};

    for (final entry in _operationDurations.entries) {
      final durations = entry.value;
      if (durations.isEmpty) continue;

      final totalDuration = durations.fold<Duration>(
        Duration.zero,
        (total, duration) => total + duration,
      );

      final avgDuration = totalDuration.inMilliseconds / durations.length;

      stats[entry.key] = {
        'count': durations.length,
        'average_ms': avgDuration.round(),
        'total_ms': totalDuration.inMilliseconds,
        'min_ms': durations
            .map((d) => d.inMilliseconds)
            .reduce((a, b) => a < b ? a : b),
        'max_ms': durations
            .map((d) => d.inMilliseconds)
            .reduce((a, b) => a > b ? a : b),
      };
    }

    return stats;
  }

  // Obtenir le log de performance
  static List<String> getPerformanceLog() {
    return List.from(_performanceLog);
  }

  // Nettoyer les données de performance
  static void clearPerformanceData() {
    _operationStartTimes.clear();
    _operationDurations.clear();
    _performanceLog.clear();
  }

  // Optimiser les images (placeholder pour future implémentation)
  static String optimizeImageUrl(String url, {int? width, int? height}) {
    // TODO: Implémenter l'optimisation d'images
    return url;
  }

  // Debouncer les appels de fonction
  static Timer? _debounceTimer;
  static void debounce(
    VoidCallback callback, {
    Duration delay = const Duration(milliseconds: 300),
  }) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, callback);
  }

  // Throttler pour limiter la fréquence des appels
  static DateTime? _lastThrottleCall;
  static bool throttle(
    VoidCallback callback, {
    Duration delay = const Duration(milliseconds: 100),
  }) {
    final now = DateTime.now();
    if (_lastThrottleCall == null ||
        now.difference(_lastThrottleCall!) >= delay) {
      _lastThrottleCall = now;
      callback();
      return true;
    }
    return false;
  }

  // Optimiser les listes avec pagination
  static List<T> paginateList<T>(List<T> fullList, int page, int pageSize) {
    final startIndex = page * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, fullList.length);

    if (startIndex >= fullList.length) {
      return [];
    }

    return fullList.sublist(startIndex, endIndex);
  }

  // Optimiser les requêtes avec cache
  static final Map<String, _CacheEntry> _queryCache = {};

  static Future<T?> getCachedQuery<T>(
    String key,
    Future<T> Function() query, {
    Duration? expiry,
  }) async {
    final now = DateTime.now();
    final entry = _queryCache[key];

    if (entry != null && !entry.isExpired(now)) {
      return entry.data as T;
    }

    try {
      final result = await query();
      _queryCache[key] = _CacheEntry(
        data: result,
        timestamp: now,
        expiry: expiry ?? const Duration(minutes: 5),
      );
      return result;
    } catch (e) {
      return null;
    }
  }

  // Nettoyer le cache des requêtes
  static void clearQueryCache() {
    _queryCache.clear();
  }

  // Vérifier la mémoire disponible (placeholder)
  static Future<int> getAvailableMemory() async {
    // TODO: Implémenter la vérification de mémoire
    return 1000000000; // 1GB par défaut
  }

  // Optimiser les animations
  static bool shouldUseAnimation() {
    // Désactiver les animations en mode debug ou sur des appareils lents
    return !kDebugMode;
  }
}

// Classe pour les entrées de cache
class _CacheEntry {
  final dynamic data;
  final DateTime timestamp;
  final Duration expiry;

  _CacheEntry({
    required this.data,
    required this.timestamp,
    required this.expiry,
  });

  bool isExpired(DateTime now) {
    return now.isAfter(timestamp.add(expiry));
  }
}
