
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
  final _podcastsSubject = BehaviorSubject<List<Podcast>>();
  final _podcastSubject = BehaviorSubject<Podcast>();

  DBPodcastBloc() {
    getPodcasts();
  }

  dispose() {
    _podcastsSubject.close();
    _podcastSubject.close();
  }

  getPodcasts() async {
    _podcastsSubject.add(await DBProvider.db.getAllPodcasts());
  }

  refreshPodcasts() async {
    var podcasts = await DBProvider.db.getAllPodcasts();
    //TODO: parallelize the refresh process below
    var futures = <Future>[];
    for (var p in podcasts) {
      futures.add(() async {
        print("start to refresh ${p.feedUrl}");
        var podcast =  await Podcast.newPodcastByUrl(p.feedUrl, imageUrl: p.imageUrl);
        if (podcast.feedContent == p.feedContent)  {
          print("${p.feedUrl} is same");
          return;
        }
        print("${p.feedUrl} is different, update...");
        await upgrade(podcast);
      }());
    }
    await Future.wait(futures);
    return;
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

  get podcasts => _podcastsSubject.stream;
  get podcast => _podcastSubject.stream;

//  addByUrl(String url) async {
//    var podcast = await Podcast.newPodcastByUrl(url);
//    add(podcast);
//  }

  add(Podcast podcast) async {
    podcast.isSubscribed = true;
    try {
      await DBProvider.db.addPodcast(podcast);
    } on Exception {
      await DBProvider.db.updatePodcast(podcast);
    }
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

