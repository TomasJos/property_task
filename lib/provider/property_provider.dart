

import 'package:flutter/material.dart';
import 'package:property_list/model/property.dart';

import '../services/api_service.dart';

class PropertyProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final List<Property> _properties = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;
  static const int _pageSize = 20;

  // filters
  int? _minPrice;
  int? _maxPrice;
  String? _location;
  List<String>? _tags;
  String? _status;

  List<Property> get properties => List.unmodifiable(_properties);
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  int get currentPage => _page;

  /// Public API
  Future<void> refresh() async {
    _page = 1;
    _hasMore = true;
    _properties.clear();
    await _fetchPage();
  }

  Future<void> nextPage() async {
    if (_isLoading || !_hasMore) return;
    _page += 1;
    await _fetchPage();
  }

  Future<void> previousPage() async {
    if (_isLoading || _page == 1) return;
    _page -= 1;
    _hasMore = true; // allow forward navigation again
    _properties.clear();
    await _fetchPage();
  }

  Future<void> applyFilters({
    int? minPrice,
    int? maxPrice,
    String? location,
    List<String>? tags,
    String? status,
  }) async {
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    _location = location;
    _tags = tags;
    _status = status;
    await refresh();
  }

  Future<void> clearFilters() async {
    _minPrice = null;
    _maxPrice = null;
    _location = null;
    _tags = null;
    _status = null;
    await refresh();
  }

  /// Internal
  Future<void> _fetchPage() async {
    _isLoading = true;
    notifyListeners();

    try {
      final fetched = await _api.fetchProperties(
        page: _page,
        pageSize: _pageSize,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        location: _location,
        tags: _tags,
        status: _status,
      );

      _properties
        ..clear()
        ..addAll(fetched);
      _hasMore = fetched.length == _pageSize;
    } catch (e) {
      // ignore: avoid_print
      print('Provider fetch error: $e');
      _hasMore = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}


