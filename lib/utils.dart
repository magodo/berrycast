import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
    return "${(byte/(1<<10)).toStringAsFixed(2)} KB";
  }
  if (byte < (1 << 30)) {
    return "${(byte/(1<<20)).toStringAsFixed(2)} MB";
  }
  return "${(byte/(1<<30)).toStringAsFixed(2)} GB";
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

  if (! await Directory(podcastDirPath).exists()) await Directory(podcastDirPath).create();
  return podcastDirPath;
}

Future<String> getPodcastFolder() async {
  return p.join(await _findLocalPath(), 'Podcasts');
}
