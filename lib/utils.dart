import 'dart:io';

import 'package:flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'bloc/db_offline_episode.dart';
import 'episodes_page.dart';
import 'model/offline_episode.dart';
import 'offline_episode_page.dart';
import 'resources/db.dart';
import 'theme.dart';

String prettyDuration(Duration dur) {
  String twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  final String h = twoDigits(dur.inHours.remainder(24));
  final String m = twoDigits(dur.inMinutes.remainder(60));
  final String s = twoDigits(dur.inSeconds.remainder(60));
  return "$h:$m:$s";
}

String prettySize(int byte) {
  if (byte < 1024) {
    return "$byte B";
  }
  if (byte < (1 << 20)) {
    return "${(byte / (1 << 10)).toStringAsFixed(2)} KB";
  }
  if (byte < (1 << 30)) {
    return "${(byte / (1 << 20)).toStringAsFixed(2)} MB";
  }
  return "${(byte / (1 << 30)).toStringAsFixed(2)} GB";
}

Future<bool> ensureStoragePermission() async {
  if (Platform.isAndroid) {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    if (permission != PermissionStatus.granted) {
      Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.storage]);
      return permissions[PermissionGroup.storage] == PermissionStatus.granted;
    }
    return true;
  }
  return true;
}

Future<String> _findLocalPath() async {
  final directory = Platform.isAndroid
      ? await getExternalStorageDirectory()
      : await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<String> ensurePodcastFolder() async {
  final podcastDirPath = await getPodcastFolder();

  if (!await Directory(podcastDirPath).exists())
    await Directory(podcastDirPath).create();
  return podcastDirPath;
}

Future<String> getPodcastFolder() async {
  return p.join(await _findLocalPath(), 'Podcasts');
}

// Return two Widgets: [progressbar, control button]
List<Widget> buildDownloadControls(BuildContext context, OfflineEpisode p) {
  Widget progressWidget, controlWidget;
  if (p.taskInfo == null) {
    progressWidget = progressBar(
      context: context,
      progress: 0,
      color: Colors.grey,
    );
    controlWidget = null;
    return [progressWidget, controlWidget];
  }

  final progress = (p.taskInfo.progress / 100);
  final status = p.taskInfo.status;
  if (status == DownloadTaskStatus.running) {
    progressWidget = progressBar(context: context, progress: progress);
    controlWidget = IconButton(
      icon: Icon(
        Icons.pause,
        color: accentColor,
      ),
      onPressed: () => FlutterDownloader.pause(taskId: p.taskID),
    );
    return [progressWidget, controlWidget];
  }
  if (status == DownloadTaskStatus.paused) {
    progressWidget = progressBar(context: context, progress: progress);
    controlWidget = IconButton(
        icon: Icon(
          Icons.file_download,
          color: accentColor,
        ),
        onPressed: () async {
          final newTaskId = await FlutterDownloader.resume(taskId: p.taskID);
          p.taskID = newTaskId;
          // upgrade new task id in repository (see: https://pub.dev/packages/flutter_downloader#resume-a-task)
          dbOfflineEpisodeBloc.upgrade(p);
        });
    return [progressWidget, controlWidget];
  }
  if (status == DownloadTaskStatus.failed) {
    progressWidget = progressBar(
      context: context,
      progress: progress,
      color: Colors.red,
    );
    controlWidget = IconButton(
        icon: Icon(
          Icons.refresh,
          color: accentColor,
        ),
        onPressed: () async {
          final newTaskId = await FlutterDownloader.retry(taskId: p.taskID);
          p.taskID = newTaskId;
          dbOfflineEpisodeBloc.upgrade(p);
        });
    return [progressWidget, controlWidget];
  }
  if (status == DownloadTaskStatus.complete) {
    progressWidget = Text("Download Complete");
    controlWidget = IconButton(
      icon: Icon(
        Icons.play_arrow,
        color: accentColor,
      ),
      onPressed: () async {
        final podcast = await DBProvider.db.getPodcast(p.podcastUrl);
        final idx = podcast.episodes.indexWhere((e) => e.audioUrl == p.songUrl);
        if (idx == -1) {
          FlushbarHelper.createError(message: "unknown episode: ${p.title}");
          return;
        }
        var episode = podcast.episodes[idx];
        await playNewEpisode(context, episode);
        return;
      },
    );
    return [progressWidget, controlWidget];
  }
  progressWidget = Text("{status}");
  controlWidget = null;
  return [progressWidget, controlWidget];
}

Dismissible buildCancelDownloadDismissable(
    BuildContext context, OfflineEpisode p, Widget child) {
  return Dismissible(
    key: Key(p.title),
    direction: DismissDirection.startToEnd,
    onDismissed: (direction) async {
      if (p.taskInfo.status == DownloadTaskStatus.running) {
        await FlutterDownloader.pause(taskId: p.taskID);
      }
      await FlutterDownloader.remove(
          taskId: p.taskID, shouldDeleteContent: true);
      dbOfflineEpisodeBloc.delete(p.songUrl);
    },
    background: Container(
      alignment: Alignment(-0.8, 0),
      color: accentColor,
      child: Icon(Icons.cancel),
    ),
    confirmDismiss: (DismissDirection direction) async {
      return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Confirm"),
              content: const Text("Are you sure you wish to delete this item?"),
              actions: <Widget>[
                FlatButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text("DELETE")),
                FlatButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("CANCEL"),
                )
              ],
            );
          });
    },
    child: child,
  );
}
