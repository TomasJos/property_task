import 'dart:convert';

class Property {
  final String id;
  final String title;
  final String? description;
  final String location;
  final double price;
  final int bedrooms;
  final int bathrooms;
  final double areaSqFt;
  final List<String> images;
  final String status;

  Property({
    required this.id,
    required this.title,
    required this.location,
    required this.price,
    required this.bedrooms,
    required this.bathrooms,
    required this.areaSqFt,
    required this.images,
    required this.status,
    this.description,
  });

  factory Property.fromMap(Map<String, dynamic> map) {
    return Property(
      id: map['id'].toString(),
      title: map['title']?.toString() ?? 'Property ${map['id']}',
      location: (map['location'] ?? map['address'] ?? 'Unknown').toString(),
      price: _toDouble(map['price'] ?? map['listingPrice']),
      bedrooms: _toInt(map['bedrooms']),
      bathrooms: _toInt(map['bathrooms']),
      areaSqFt: _toDouble(map['areaSqFt'] ?? map['area']),
      images: (map['images'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      status: map['status']?.toString() ?? 'Available',
      description: map['description']?.toString(),
    );
  }

  static int _toInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
  static double _toDouble(dynamic v) =>
      v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0.0;

  /// extract the proper list of properties from the varying JSON formats we saw
  static List<dynamic>? _extractList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map<String, dynamic>) {
      // 1st priority: explicit `properties` key
      if (decoded['properties'] is List) return decoded['properties'];
      // 2nd priority: explicit `data` key (some APIs)
      if (decoded['data'] is List) return decoded['data'];
    }
    return null;
  }

  static List<Property> listFromJson(String source) {
    final decoded = jsonDecode(source);
    final list = _extractList(decoded);
    if (list == null) {
      throw Exception('Unexpected JSON format — couldn\'t locate properties list');
    }
    return list
        .whereType<Map<String, dynamic>>()
        .map(Property.fromMap)
        .toList();
  }
}
