import 'dart:async';

import 'package:http/http.dart' as http;

import '../model/itunes.dart';

class ItunesApiProvider {
  ItunesApiProvider._();
  static final api = ItunesApiProvider._();

  http.Client _client = http.Client();
  final _baseUrl = 'https://itunes.apple.com';

  Future<List<ItunesPodcast>> searchPdocasts(String term) async {
    final response = await _client.get("$_baseUrl/search?media=podcast&term=$term").timeout(Duration(seconds: 10), onTimeout: () => http.Response( "timeout",  400));
    if (response.statusCode != 200) {
      throw Exception('Failed to search for podcast: ${response.body}');
    }
    return ItunesPodcastResult.fromJson(response.body).results;
  }
}
