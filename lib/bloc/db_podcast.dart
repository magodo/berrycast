
import 'package:rxdart/rxdart.dart';

import '../model/podcast.dart';
import '../resources/db.dart';

class PodcastAlreadyExistException implements Exception {
  @override
  String toString() {
    return "Podcast already exists!";
  }
}

class DBPodcastBloc {
  final _podcastsSubscribe = BehaviorSubject<List<Podcast>>();
  final _podcastSubject = BehaviorSubject<Podcast>();

  DBPodcastBloc() {
    getPodcasts();
  }

  dispose() {
    _podcastsSubscribe.close();
    _podcastSubject.close();
  }

  getPodcasts() async {
    _podcastsSubscribe.add(await DBProvider.db.getAllPodcasts());
  }

  feedPodcastByUrl(String feedUrl, {String imageUrl}) async {
    // Since we are using BehaviorSubscribe, if the `add()` takes time, and the page
    // which subscribe it is built first. Then it will show the last emitted event.
    // This is not what we want, which causes confusion.
    // So we will pass in a null, which will notify the page a new event will come soon,
    // and page should be in an waiting state, showing indicator or something similar.
    _podcastSubject.add(null);
    var podcast = await Podcast.newPodcastByUrl(feedUrl, imageUrl: imageUrl);
    _podcastSubject.add(podcast);
  }

  feedPodcast(Podcast podcast) async {
      _podcastSubject.add(podcast);
  }

  get podcasts => _podcastsSubscribe.stream;
  get podcast => _podcastSubject.stream;

//  addByUrl(String url) async {
//    var podcast = await Podcast.newPodcastByUrl(url);
//    add(podcast);
//  }

  add(Podcast podcast) async {
    final podcasts = await DBProvider.db.getAllPodcasts();
    for (var p in podcasts) {
      if (p.title == podcast.title) throw PodcastAlreadyExistException();
    }
    await DBProvider.db.newPodcast(podcast);
    getPodcasts();
  }

  delete(String url) async {
    await DBProvider.db.deletePodcast(url);
    getPodcasts();
  }

  upgrade(Podcast podcast) async {
    await DBProvider.db.updatePodcast(podcast);
    getPodcasts();
  }
}

final DBPodcastBloc dbPodcastBloc = DBPodcastBloc();

