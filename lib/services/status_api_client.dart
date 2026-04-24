import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/service.dart';
import '../models/service_snapshot.dart';
import 'statuspage_parser.dart';

class StatusApiClient {
  final http.Client _http;

  StatusApiClient({http.Client? client}) : _http = client ?? http.Client();

  Future<ServiceSnapshot> fetch(MonitoredService service) async {
    try {
      final results = await Future.wait([
        _getJson(service.summaryUrl),
        _getJson(service.incidentsUrl),
      ]);
      return StatuspageParser.parse(
        service: service,
        summaryJson: results[0],
        incidentsJson: results[1],
      );
    } catch (e) {
      return ServiceSnapshot.error(service, e.toString());
    }
  }

  Future<Map<String, dynamic>> _getJson(String url) async {
    final resp = await _http
        .get(Uri.parse(url), headers: {'Accept': 'application/json'})
        .timeout(httpTimeout);
    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode} for $url');
    }
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  void dispose() => _http.close();
}
