import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:property_list/model/property.dart';

class ApiService {
  static const String _baseUrl = 'http://147.182.207.192:8003/properties';

  Future<List<Property>> fetchProperties({
    required int page,
    required int pageSize,
    int? minPrice,
    int? maxPrice,
    String? location,
    List<String>? tags,
    String? status,
  }) async {
    final query = <String, dynamic>{
      'page': page.toString(),
      'page_size': pageSize.toString(),
    };

    if (minPrice != null) query['min_price'] = minPrice.toString();
    if (maxPrice != null) query['max_price'] = maxPrice.toString();
    if (location != null && location.isNotEmpty) query['location'] = location;
    if (status != null && status.isNotEmpty) query['status'] = status;

    final uri = Uri.parse(_baseUrl).replace(queryParameters: query);
    final tagsQuery = tags == null || tags.isEmpty ? '' : tags.map((t) => '&tags=$t').join();
    final url = uri.toString() + tagsQuery;

    final response = await http.get(Uri.parse(url));

    print('[API] GET $url => ${response.statusCode}\n${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

    if (response.statusCode != 200) {
      throw Exception('API error: ${response.statusCode}');
    }

    return Property.listFromJson(response.body);
  }
}