
import 'package:rxdart/rxdart.dart';

import '../model/offline_episode.dart';
import '../resources/db.dart';

class DBOfflineEpisodeBloc {
  final _episodeSubject = BehaviorSubject<List<OfflineEpisode>>();

  DBOfflineEpisodeBloc() {
    _getAll();
  }

  dispose() {
  }

  _getAll() async {
    _episodeSubject.add(await DBProvider.db.getAllOfflineEpisodes());
  }

  get offlineEpisodes => _episodeSubject.stream;

  add(OfflineEpisode episode) async {
    await DBProvider.db.addOfflineEpisode(episode);
    _getAll();
  }

  delete(String song) async {
    await DBProvider.db.deleteOfflineEpisode(song);
    _getAll();
  }

  upgrade(OfflineEpisode episode) async {
    await DBProvider.db.updateOfflineEpisode(episode);
    _getAll();
  }
}

final DBOfflineEpisodeBloc dbOfflineEpisodeBloc = DBOfflineEpisodeBloc();
