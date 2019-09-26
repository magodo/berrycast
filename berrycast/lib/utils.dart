import 'dart:io';

import 'package:flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:marquee/marquee.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'audio.dart';
import 'bloc/db_offline_episode.dart';
import 'bloc/db_podcast.dart';
import 'episode_info.dart';
import 'model/episode.dart';
import 'model/offline_episode.dart';
import 'model/podcast.dart';
import 'model/songs.dart';
import 'offline_episode_page.dart';
import 'play_page.dart';
import 'podcast_page.dart';
import 'resources/bookmark_provider.dart';
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

Future<String> ensureMusicFolder() async {
  final musicDirPath = await getMusicFolder();

  if (!await Directory(musicDirPath).exists())
    await Directory(musicDirPath).create();
  return musicDirPath;
}

Future<String> getMusicFolder() async {
  return p.join(await _findLocalPath(), 'Musics');
}

// Return two Widgets: [progressbar, control button]
List<Widget> buildDownloadControls(BuildContext context, OfflineEpisode p) {
  Widget progressWidget, controlWidget;
  if (p.taskInfo == null) {
    progressWidget = ProgressBar(
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
    progressWidget = ProgressBar(context: context, progress: progress);
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
    progressWidget = ProgressBar(context: context, progress: progress);
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
    progressWidget = ProgressBar(
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
      return await showDeleteConfirmDialog(context);
    },
    child: child,
  );
}

Future<bool> showDeleteConfirmDialog(BuildContext context) {
  return showDialog(
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
}

Widget buildMarqueeText(BuildContext context, Text text, double height) {
  final parentWidth = MediaQuery.of(context).size.width;
  return SizedBox(
    height: height,
    child: Marquee(
      text: text.data.trim(),
      style: text.style,
      scrollAxis: Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.center,
      blankSpace: parentWidth / 2,
      velocity: 100.0,
    ),
  );
}

openPodcastPage(BuildContext context, Podcast podcast) async {
  dbPodcastBloc.feedPodcast(podcast);
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return PodcastPage(podcast.image);
  }));
}

Future<void> buildEpisodeBottomSheet(BuildContext context, Episode episode,
    {double height = 500}) async {
  final bmp = BookmarkProvider(episode.audioUrl);
  await bmp.load();
  showModalBottomSheet(
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10))),
    elevation: 5,
    isScrollControlled: true,
    context: context,
    builder: (BuildContext context) {
      return MultiProvider(
        providers: [ChangeNotifierProvider<BookmarkProvider>.value(value: bmp)],
        child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: height),
            child: Scaffold(body: EpisodeInfoPage(episode, height))),
      );
    },
  );
}

void playSong(BuildContext context, Song song, {Duration from}) {
  final schedule = Provider.of<AudioSchedule>(context);
  schedule.pushSong(song);
  schedule.playNthSong(0, from: from);
}

void playSongs(BuildContext context, List<Song> songs) {
  final schedule = Provider.of<AudioSchedule>(context);
  schedule.playlist = List.from(songs);
  schedule.playNthSong(0);
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return PlayPage();
  }));
}

buildPlayallButton(BuildContext context, List<Song> songs) {
  return FlatButton(
    child: Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            Icons.play_circle_outline,
            color: accentColor,
          ),
        ),
        Text(
          "PLAY ALL (${songs.length})",
          style: TextStyle(color: accentColor),
        ),
      ],
    ),
    onPressed: () => playSongs(context, songs),
  );
}
