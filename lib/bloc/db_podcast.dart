import 'dart:async';

import '../model/podcast.dart';
import '../resources/db.dart';

class PodcastAlreadyExistException implements Exception{
  @override
  String toString() {
    return "Podcast already exists!";
  }
}

class DBPodcastBloc {
  final _podcastsController = StreamController<List<Podcast>>.broadcast();
  final _podcastController = StreamController<Podcast>.broadcast();

  DBPodcastBloc() {
    getPodcasts();
  }

  dispose() {
    _podcastsController.close();
    _podcastController.close();
  }

  getPodcasts() async {
    _podcastsController.add(await DBProvider.db.getAllPodcasts());
  }

  loadPodcast(String feedUrl) async {
    var podcast = await Podcast.newPodcastByUrl(feedUrl);
    _podcastController.add(podcast);
  }

  get podcasts => _podcastsController.stream;
  get podcast => _podcastController.stream;

  addByUrl(String url) async {
    var podcast = await Podcast.newPodcastByUrl(url);
    add(podcast);
  }

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

final DBPodcastBloc dbPodcastBloc =DBPodcastBloc();
