import 'dart:async';

import '../model/podcast.dart';
import '../repository/db.dart';

class PodcastAlreadyExistException implements Exception{
  @override
  String toString() {
    return "Podcast already exists!";
  }
}

class PodcastBloc {
  final _podcastsController = StreamController<List<Podcast>>.broadcast();

  PodcastBloc() {
    getPodcasts();
  }

  dispose() {
    _podcastsController.close();
  }

  getPodcasts() async {
    _podcastsController.add(await DBProvider.db.getAllPodcasts());
  }

  get podcasts => _podcastsController.stream;

  add(Podcast podcast) async {
    final podcasts = await DBProvider.db.getAllPodcasts();
    for (var p in podcasts) {
      if (p.title == podcast.title) throw PodcastAlreadyExistException();
    }
    await DBProvider.db.newPodcast(podcast);
    getPodcasts();
  }

  delete(int id) async {
    await DBProvider.db.deletePodcast(id);
    getPodcasts();
  }

  upgrade(Podcast podcast) async {
    await DBProvider.db.updatePodcast(podcast);
    getPodcasts();
  }
}

final PodcastBloc podcastBloc =PodcastBloc();
