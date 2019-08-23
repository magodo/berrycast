import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' show Client;

import '../model/itunes.dart';

class ItunesApiProvider {
  ItunesApiProvider._();
  static final api = ItunesApiProvider._();

  Client _client = Client();
  final _baseUrl = 'https://itunes.apple.com';

  Future<List<ItunesPodcast>> searchPdocasts(String term) async {
    final response = await _client.get("$_baseUrl/search?media=podcast&term=$term");
    if (response.statusCode != 200) {
      throw Exception('Failed to search for podcast');
    }
    return ItunesPodcastResult.fromJson(response.body).results;
  }
}
