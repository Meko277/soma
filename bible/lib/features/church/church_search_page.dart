// ============================================================
// CHURCH SEARCH PAGE (بحث الكنائس)
//
// In-app church finder: an embedded OpenStreetMap (flutter_map)
// plus a results list. Search any church by text, or tap
// "nearest church" to sort real churches around the user by
// distance. No Google Maps involved.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../core/church/church_search_service.dart';
import '../../core/localization/app_strings.dart';
import '../../core/preferences/preferences_provider.dart';

// ============================================================
// CHURCH SEARCH PAGE
// ============================================================

class ChurchSearchPage extends ConsumerStatefulWidget {
  const ChurchSearchPage({super.key, this.autoNearby = false});

  /// When true (e.g. opened from "أقرب كنيسة أرثوذكسية"), the
  /// nearby search starts automatically on open.
  final bool autoNearby;

  @override
  ConsumerState<ChurchSearchPage> createState() => _ChurchSearchPageState();
}

class _ChurchSearchPageState extends ConsumerState<ChurchSearchPage> {
  final TextEditingController _queryController = TextEditingController();
  final ChurchSearchService _service = ChurchSearchService();
  final MapController _mapController = MapController();

  /// Default view: Cairo, until a search moves the map.
  static const LatLng _fallbackCenter = LatLng(30.0444, 31.2357);

  String _country = '';
  bool _searching = false;
  bool _searched = false;
  bool _failed = false;
  bool _locationDenied = false;
  LatLng _mapCenter = _fallbackCenter;
  LatLng? _userPoint;
  List<ChurchSearchResult> _results = const [];

  @override
  void initState() {
    super.initState();
    if (widget.autoNearby) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _searchNearby();
      });
    }
  }

  @override
  void dispose() {
    _queryController.dispose();
    _service.dispose();
    super.dispose();
  }

  AppStrings _strings() {
    return AppStrings(ref.read(preferencesProvider).interfaceLanguage);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final AppStrings strings = _strings();
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.churchSearchTitle),
        actions: <Widget>[
          IconButton(
            tooltip: strings.moreChurchTitle,
            icon: const Icon(Icons.my_location),
            onPressed: _searching ? null : _searchNearby,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          _buildSearchBar(strings),
          const SizedBox(height: 8),
          Expanded(flex: 5, child: _buildMapPanel(theme)),
          const SizedBox(height: 8),
          Expanded(flex: 4, child: _buildResultsPanel(theme, strings)),
        ],
      ),
    );
  }

  // ============================================================
  // SEARCH BAR
  // ============================================================

  Widget _buildSearchBar(AppStrings strings) {
    final bool isAr = strings.isArabic;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _queryController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _runSearch(),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: strings.churchSearchHint,
                isDense: true,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: _country,
            underline: const SizedBox.shrink(),
            items: <DropdownMenuItem<String>>[
              DropdownMenuItem<String>(
                value: '',
                child: Text(isAr ? 'كل الدول' : 'All'),
              ),
              DropdownMenuItem<String>(
                value: 'eg',
                child: Text(isAr ? 'مصر' : 'Egypt'),
              ),
              DropdownMenuItem<String>(
                value: 'us',
                child: Text(isAr ? 'أمريكا' : 'USA'),
              ),
              DropdownMenuItem<String>(
                value: 'ca',
                child: Text(isAr ? 'كندا' : 'Canada'),
              ),
              DropdownMenuItem<String>(
                value: 'au',
                child: Text(isAr ? 'أستراليا' : 'Australia'),
              ),
            ],
            onChanged: (String? v) {
              setState(() => _country = v ?? '');
            },
          ),
          IconButton(
            tooltip: strings.churchSearch,
            icon: const Icon(Icons.travel_explore),
            onPressed: _searching ? null : _runSearch,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  Future<void> _runSearch() async {
    final String q = _queryController.text.trim();
    if (q.isEmpty || _searching) return;

    setState(() {
      _searching = true;
      _failed = false;
      _locationDenied = false;
    });

    try {
      final List<ChurchSearchResult> results = await _service.search(
        q,
        countryCode: _country.isEmpty ? null : _country,
      );
      if (!mounted) return;
      setState(() {
        _results = results;
        _searched = true;
        _searching = false;
        if (results.isNotEmpty) {
          _mapCenter = results.first.point;
          _mapController.move(results.first.point, 13);
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _searching = false;
        _failed = true;
        _searched = true;
      });
    }
  }

  Future<void> _searchNearby() async {
    if (_searching) return;

    setState(() {
      _searching = true;
      _failed = false;
      _locationDenied = false;
    });

    try {
      final Position? pos = await _service.getCurrentPosition();
      if (!mounted) return;
      if (pos == null) {
        setState(() {
          _searching = false;
          _locationDenied = true;
          _searched = true;
        });
        return;
      }

      final List<ChurchSearchResult> results = await _service.searchNearby(
        position: pos,
      );
      if (!mounted) return;

      final LatLng userPoint = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _results = results;
        _userPoint = userPoint;
        _searched = true;
        _searching = false;
        _mapCenter = userPoint;
        _mapController.move(userPoint, 13);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _searching = false;
        _failed = true;
        _searched = true;
      });
    }
  }

  // __PART3__
  // __PART3__

  // ============================================================
  // MAP
  // ============================================================

  Widget _buildMapPanel(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: <Widget>[
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(initialCenter: _mapCenter, initialZoom: 11),
              children: <Widget>[
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'app.soma.coptic',
                ),
                MarkerLayer(markers: _buildMarkers(theme)),
              ],
            ),
            if (_searching)
              const Positioned.fill(
                child: ColoredBox(
                  color: Colors.black26,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Marker> _buildMarkers(ThemeData theme) {
    final List<Marker> markers = <Marker>[];

    if (_userPoint != null) {
      markers.add(
        Marker(
          point: _userPoint!,
          width: 44,
          height: 44,
          child: const Icon(
            Icons.my_location,
            color: Colors.blueAccent,
            size: 30,
          ),
        ),
      );
    }

    for (final ChurchSearchResult r in _results) {
      markers.add(
        Marker(
          point: r.point,
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () => _mapController.move(r.point, 15),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primary,
              child: Icon(
                Icons.church,
                size: 18,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      );
    }

    return markers;
  }

  // ============================================================
  // RESULTS LIST
  // ============================================================

  Widget _buildResultsPanel(ThemeData theme, AppStrings strings) {
    Widget child;

    if (_failed) {
      child = _message(theme, Icons.error_outline, strings.churchSearchAgain);
    } else if (_locationDenied) {
      child = _message(
        theme,
        Icons.location_off,
        strings.isArabic
            ? 'تعذّر تحديد موقعك — اسمح بالوصول إلى الموقع وحاول مرة أخرى'
            : 'Could not get your location — allow access and try again',
      );
    } else if (!_searched) {
      child = _message(theme, Icons.travel_explore, strings.moreChurchSubtitle);
    } else if (_results.isEmpty) {
      child = _message(theme, Icons.search_off, strings.churchNotFound);
    } else {
      child = ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: _results.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (BuildContext context, int index) =>
            _resultCard(theme, _results[index]),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: child,
    );
  }

  Widget _resultCard(ThemeData theme, ChurchSearchResult r) {
    final String subtitle = r.distanceKm != null
        ? '${r.distanceKm!.toStringAsFixed(1)} km • ${r.address}'
        : r.address;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundColor: theme.colorScheme.onPrimaryContainer,
          child: const Icon(Icons.church, size: 20),
        ),
        title: Text(r.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        onTap: () {
          _mapController.move(r.point, 15);
        },
      ),
    );
  }

  Widget _message(ThemeData theme, IconData icon, String text) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 32, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
