import 'dart:async';

import '../model/itunes.dart';
import '../resources/itunes_api_provider.dart';

class ItunesBloc {
  final _itunesPodcastController = StreamController<List<ItunesPodcast>>.broadcast();

  void dispose() {
    _itunesPodcastController.close();
  }

  get podcasts => _itunesPodcastController.stream;

  searchPodcasts(String term) async {
    List<ItunesPodcast> itunesPodcasts =
        await ItunesApiProvider.api.searchPdocasts(term);
    _itunesPodcastController.add(itunesPodcasts);
  }
}

final itunesBloc = ItunesBloc();
