import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:rxdart/rxdart.dart';

import '../model/offline_episode.dart';
import '../resources/db.dart';

class DBOfflineEpisodeBloc {
  final _episodeSubject = BehaviorSubject<List<OfflineEpisode>>();
  Map<String, DownloadTask> _taskPool;

  init() async {
    final tasks = await FlutterDownloader.loadTasks();
    _taskPool = {for (var task in tasks) task.taskId: task};
    _getAll();
  }

  _getAll() async {
    final offlineEpisodes = await DBProvider.db.getAllOfflineEpisodes();
    offlineEpisodes
        .forEach((episode) => episode.taskInfo = _taskPool[episode.taskID]);
    _episodeSubject.add(offlineEpisodes);
  }

  get offlineEpisodes => _episodeSubject.stream;

  add(OfflineEpisode episode) async {
    // When a new task is added, add this certain taskInfo into pool
    // (NOTE: we add it manually, rather than calling [FlutterDownloader.loadTasks], in which case
    // it will make all outstanding task's progress to 0.
    // see:
    // https://github.com/fluttercommunity/flutter_downloader/blob/7ff646f89160bfd8ab426b95b8a1547c7386e36e/android/src/main/java/vn/hunghd/flutterdownloader/DownloadWorker.java#L271
    //)
    final tasks = await FlutterDownloader.loadTasks();
    var taskMap = {for (var task in tasks) task.taskId: task};
    _taskPool[episode.taskID] = taskMap[episode.taskID];
    await DBProvider.db.addOfflineEpisode(episode);
    await _getAll();
  }

  delete(String song) async {
    var episode = await DBProvider.db.getOfflineEpisode(song);
    _taskPool.remove(episode.taskID);
    await DBProvider.db.deleteOfflineEpisode(song);
    await _getAll();
  }

  upgrade(OfflineEpisode episode) async {
    _taskPool[episode.taskID] = episode.taskInfo;
    await DBProvider.db.updateOfflineEpisode(episode);
    await _getAll();
  }

  upgradeTaskStatus(String id, DownloadTaskStatus status, int progress) async {
    var oinfo = _taskPool[id];
    // Only update task belongs in pool. (should avoid task leak from the pool)
    if (oinfo != null) {
      _taskPool[id] = DownloadTask(
        taskId: oinfo.taskId,
        status: status,
        progress: progress,
        url: oinfo.url,
        filename: oinfo.filename,
        savedDir: oinfo.savedDir,
      );
    }
    await _getAll();
  }
}

final DBOfflineEpisodeBloc dbOfflineEpisodeBloc = DBOfflineEpisodeBloc();
