import 'dart:async';

import 'package:rxdart/rxdart.dart';

import '../model/itunes.dart';
import '../resources/itunes_api_provider.dart';

class ItunesBloc {
  final _itunesPodcastSubscribe = BehaviorSubject<List<ItunesPodcast>>();

  void dispose() {
    _itunesPodcastSubscribe.close();
  }

  get podcasts => _itunesPodcastSubscribe.stream;

  searchPodcasts(String term) async {
    List<ItunesPodcast> itunesPodcasts =
        await ItunesApiProvider.api.searchPdocasts(term);
    _itunesPodcastSubscribe.add(itunesPodcasts);
  }
}

final itunesBloc = ItunesBloc();
