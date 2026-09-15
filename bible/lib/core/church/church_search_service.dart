// ================================================================
// CHURCH SEARCH SERVICE
//
// In-app Coptic church finder backed by the OpenStreetMap
// Nominatim public API (no API key required):
//
//   GET https://nominatim.openstreetmap.org/search
//     ?format=json&q=<query> church&limit=15[&countrycodes=xx]
//
// Returns lightweight typed results (name + coordinates + country)
// which the church search page renders in-app, exactly like the
// admin's Leaflet map search. No Google Maps is involved.
// ================================================================

import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// One church / place returned by Nominatim.
class ChurchSearchResult {
  final String id;
  final String displayName;
  final String name;
  final String address;
  final double lat;
  final double lon;
  final String? country;
  final String? city;
  final double? distanceKm;

  const ChurchSearchResult({
    required this.id,
    required this.displayName,
    required this.name,
    required this.address,
    required this.lat,
    required this.lon,
    this.country,
    this.city,
    this.distanceKm,
  });

  double get lng => lon;
  LatLng get point => LatLng(lat, lon);

  factory ChurchSearchResult.fromJson(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>? ?? {};
    final displayName = json['display_name']?.toString() ?? '';
    return ChurchSearchResult(
      id: json['place_id']?.toString() ?? displayName,
      displayName: displayName,
      name: json['name']?.toString() ?? _firstPart(displayName) ?? 'Church',
      address: _addressLabel(address, displayName),
      lat: _toDouble(json['lat']),
      lon: _toDouble(json['lon']),
      country: _pick(address, 'country_code') ?? _pick(address, 'country'),
      city:
          _pick(address, 'city') ??
          _pick(address, 'town') ??
          _pick(address, 'village'),
    );
  }

  static String? _pick(Map<String, dynamic> json, String key) {
    final v = json[key];
    if (v is String && (v).trim().isNotEmpty) {
      return v.toString().trim();
    }
    return null;
  }

  static double _toDouble(Object? value) =>
      value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

  static String? _firstPart(String value) {
    final first = value.split(',').first.trim();
    return first.isEmpty ? null : first;
  }

  static String _addressLabel(Map<String, dynamic> address, String fallback) {
    final parts = <String>[];
    for (final key in ['road', 'suburb', 'city', 'town', 'state', 'country']) {
      final value = _pick(address, key);
      if (value != null) parts.add(value);
    }
    return parts.isEmpty ? fallback : parts.join(', ');
  }
}

/// One church + nearest-user distance info.
class ChurchNearbyResult {
  final ChurchSearchResult place;
  final double userLat;
  final double userLng;
  final double? distanceMeters;

  const ChurchNearbyResult({
    required this.place,
    required this.userLat,
    required this.userLng,
    this.distanceMeters,
  });
}

/// Thin wrapper around Nominatim's /search endpoint.
class ChurchSearchService {
  ChurchSearchService({
    http.Client? client,
    this.timeout = const Duration(seconds: 12),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final Duration timeout;

  static const String _endpoint = 'https://nominatim.openstreetmap.org/search';

  /// ISO-3166 alpha-2 country code(s), e.g. 'eg' or 'us,ca'.
  static const Map<String, String> countryCodes = {
    '': '',
    'egypt': 'eg',
    'usa': 'us',
    'canada': 'ca',
    'australia': 'au',
    'uk': 'gb',
    'germany': 'de',
    'france': 'fr',
    'italy': 'it',
    'uae': 'ae',
    'jordan': 'jo',
    'lebanon': 'lb',
    'netherlands': 'nl',
    'australia2': 'au',
  };

  static bool _isChristianChurch(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>? ?? {};
    final text = [
      json['name'],
      json['display_name'],
      json['type'],
      json['class'],
      address['amenity'],
      address['religion'],
      address['denomination'],
    ].whereType<Object>().join(' ').toLowerCase();

    const excluded = [
      'mosque',
      'masjid',
      'islam',
      'islamic',
      'muslim',
      'synagogue',
      'hindu',
      'buddhist',
      'temple',
      'gurdwara',
      'مسجد',
      'جامع',
      'إسلامي',
      'اسلامي',
      'يهودي',
      'هندوسي',
    ];
    if (excluded.any(text.contains)) return false;

    const accepted = [
      'church',
      'coptic',
      'christian',
      'orthodox',
      'catholic',
      'chapel',
      'cathedral',
      'monastery',
      'كنيسة',
      'قبطي',
      'مسيحي',
      'أرثوذكس',
    ];
    return accepted.any(text.contains);
  }

  /// Searches for churches matching [query] (+ optional 2-letter
  /// [countryCode]). Never throws - returns an empty list on any
  /// failure so the UI always stays usable.
  Future<List<ChurchSearchResult>> search(
    String query, {
    String? countryCode,
  }) async {
    final q = query.trim();
    if (q.isEmpty && (countryCode == null || countryCode.isEmpty)) {
      return [];
    }

    final queryParameters = <String, String>{
      'format': 'json',
      'limit': '15',
      'accept-language': 'en',
    };

    if (q.isNotEmpty) {
      queryParameters['q'] = '$q church';
    }

    if (countryCode != null && countryCode.isNotEmpty) {
      queryParameters['countrycodes'] = countryCode.toLowerCase();
    }

    try {
      final uri = Uri.parse(
        _endpoint,
      ).replace(queryParameters: queryParameters);

      final response = await _client
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
              'User-Agent': 'Soma-CopticCompanion/1.0',
            },
          )
          .timeout(timeout);

      if (response.statusCode != 200) {
        return [];
      }

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! List<dynamic>) {
        return [];
      }

      return (decoded)
          .whereType<Map<String, dynamic>>()
          .where(_isChristianChurch)
          .map(ChurchSearchResult.fromJson)
          .where((r) => r.lat != 0 || r.lng != 0)
          .toList();
    } catch (_) {
      // Network / timeout / parse errors never crash the app.
      return [];
    }
  }

  /// Device location, or null when location services or permission are off.
  Future<Position?> getCurrentPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      return Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 12),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  /// Finds nearby churches and returns them closest first.
  Future<List<ChurchSearchResult>> searchNearby({
    Position? position,
    int limit = 30,
  }) async {
    final location = position ?? await getCurrentPosition();
    if (location == null) return const [];
    try {
      final uri = Uri.parse(_endpoint).replace(
        queryParameters: {
          'q': 'christian church',
          'format': 'jsonv2',
          'addressdetails': '1',
          'limit': '$limit',
          'viewbox':
              '${location.longitude - .5},${location.latitude + .5},'
              '${location.longitude + .5},${location.latitude - .5}',
          'bounded': '1',
        },
      );
      final response = await _client
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
              'User-Agent': 'Soma-CopticCompanion/1.0',
            },
          )
          .timeout(timeout);
      final decoded = response.statusCode == 200
          ? jsonDecode(response.body)
          : null;
      if (decoded is! List) return const [];
      final distance = const Distance();
      final results =
          decoded
              .whereType<Map<String, dynamic>>()
              .where(_isChristianChurch)
              .map(ChurchSearchResult.fromJson)
              .where((result) => result.lat != 0 || result.lon != 0)
              .map(
                (result) => ChurchSearchResult(
                  id: result.id,
                  displayName: result.displayName,
                  name: result.name,
                  address: result.address,
                  lat: result.lat,
                  lon: result.lon,
                  country: result.country,
                  city: result.city,
                  distanceKm: distance.as(
                    LengthUnit.Kilometer,
                    LatLng(location.latitude, location.longitude),
                    result.point,
                  ),
                ),
              )
              .toList()
            ..sort(
              (a, b) => (a.distanceKm ?? double.infinity).compareTo(
                b.distanceKm ?? double.infinity,
              ),
            );
      return results;
    } catch (_) {
      return const [];
    }
  }

  /// Releases the HTTP client.
  void dispose() {
    _client.close();
  }
}

// Lightweight haversine math without extra math-package deps.
double _haversine(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371000.0;
  final dLat = _degToRad(lat2 - lat1);
  final dLon = _degToRad(lon2 - lon1);
  final a =
      _sinHalf(dLat) * _sinHalf(dLat) +
      _cosHalf(_degToRad(lat1)) *
          _cosHalf(_degToRad(lat2)) *
          _sinHalf(dLon) *
          _sinHalf(dLon);
  final c = 2 * _atan2(_sqrt(a), _sqrt((1 - a) < 0 ? 0 : 1 - a));
  return r * c;
}

double _degToRad(double deg) => deg * 3.141592653589793 / 180.0;
double _sinHalf(double x) => _sin(x / 2.0);
double _cosHalf(double x) => _cos(x / 2.0);
double _atan2(double y, double x) {
  if (x == 0.0 && y == 0.0) return 0.0;
  if (y > 0) return 1.5707963267948966 - _atan(x / y);
  if (y < 0) return -1.5707963267948966 - _atan(x / y);
  return x >= 0 ? 1.5707963267948966 : -1.5707963267948966;
}

double _atan(double x) {
  const c = 0.9999999956787343;
  final a = x.abs();
  final y = a <= 1
      ? c * a - c * (c * a - a) * a * a / 3.0
      : 1.5707963267948966 - _atan(1.0 / a);
  return x < 0 ? -y : y;
}

const _pi2 = 3.141592653589793;
double _sin(double x) {
  // Crude but stable enough for small geoposition math.
  final reduced = _pi2 - ((x.abs() * 2.0) % (2.0 * _pi2)).abs();
  return (reduced - x.abs()) +
      ((reduced * reduced * reduced) / 6.0 +
          (reduced * reduced * reduced * reduced * reduced) / 120.0);
}

double _cos(double x) => _sin(x + _pi2 / 2.0);
double _sqrt(double x) {
  if (x <= 0.0) return 0.0;
  double y = x;
  for (int i = 0; i < 10; i++) {
    y = (y + x / y) / 2.0;
  }
  return y;
}
