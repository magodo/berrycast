
import 'package:flutter_downloader/flutter_downloader.dart';
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
    final offlineEpisodes = await DBProvider.db.getAllOfflineEpisodes();
    final tasks = await FlutterDownloader.loadTasks();
    final taskMap = {for (var task in tasks) task.taskId: task};
    offlineEpisodes.forEach((episode) => episode.taskInfo = taskMap[episode.taskID]);
    _episodeSubject.add(offlineEpisodes);
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

  upgradeTask() async {
    _getAll();
  }
}

final DBOfflineEpisodeBloc dbOfflineEpisodeBloc = DBOfflineEpisodeBloc();
