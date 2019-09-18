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

  refreshPodcast(String feedUrl) async {
    var podcast = await DBProvider.db.getPodcast(feedUrl);
    print("start to refresh ${podcast.feedUrl}");
    var newPodcast = await Podcast.newPodcastByUrl(podcast.feedUrl);
    if (podcast.feedContent == newPodcast.feedContent) {
      print("${podcast.feedUrl} is same");
      return;
    }
    await upgrade(newPodcast);
    _podcastSubject.add(newPodcast);
  }

  refreshPodcasts() async {
    var podcasts = await DBProvider.db.getAllPodcasts();
    //TODO: parallelize the refresh process below
    var futures = <Future>[];
    for (var p in podcasts) {
      futures.add(() async {
        print("start to refresh ${p.feedUrl}");
        var podcast = await Podcast.newPodcastByUrl(p.feedUrl);
        if (podcast.feedContent == p.feedContent) {
          print("${p.feedUrl} is same");
          return;
        }
        print("${p.feedUrl} is different, update...");
        await upgrade(podcast);
      }());
    }
    await Future.wait(futures);
    await getPodcasts();
    return;
  }

  Future<Podcast> feedPodcastByUrl(String feedUrl, {String imageUrl}) async {
    // Since we are using BehaviorSubscribe, if the `add()` takes time, and the page
    // which subscribe it is built first. Then it will show the last emitted event.
    // This is not what we want, which causes confusion.
    // So we will pass in a null, which will notify the page a new event will come soon,
    // and page should be in an waiting state, showing indicator or something similar.
    _podcastSubject.add(null);
    Podcast podcast;
    try {
      podcast = await Podcast.newPodcastByUrl(feedUrl, imageUrl: imageUrl);
    } catch (e, traceback) {
      print("failed to new podcast by url: $e\n$traceback");
      _podcastSubject.add(nullPodcast);
      return null;
    }
    _podcastSubject.add(podcast);
    return podcast;
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

  add(Podcast podcast, {bool subscribed = false}) async {
    podcast.isSubscribed = subscribed;
    await DBProvider.db.addPodcast(podcast);
    getPodcasts();
  }

  upgrade(Podcast podcast) async {
    await DBProvider.db.updatePodcast(podcast);
    getPodcasts();
  }

  subscribe(String url) async {
    await DBProvider.db.subscribePodcast(url);
    getPodcasts();
  }

  unsubscribe(String url) async {
    await DBProvider.db.unsubscribePodcast(url);
    getPodcasts();
  }
}

final DBPodcastBloc dbPodcastBloc = DBPodcastBloc();
