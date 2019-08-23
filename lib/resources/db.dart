import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../model/podcast.dart';

class DBProvider {
  static final  sqliteRowSize = 1024*1024;
  static Database _database;
  DBProvider._();
  static final DBProvider db = DBProvider._();

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await initDB();
    return _database;
  }

  _migrateDB(Database db, int oldVersion, int newVersion) async {
    print("migrating db... ($oldVersion -> $newVersion)");
    await db.execute("DROP TABLE Podcasts");
    await db.execute("""
    CREATE TABLE Podcasts(
      feed_url TEXT NOT NULL PRIMARY KEY,
      image_url TEXT NOT NULL,
      feed_content TEXT NOT NULL
    );
    """);
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "Podcast.db");
    return await openDatabase(
      path,
      version: 3,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute("""
    CREATE TABLE Podcasts(
      feed_url TEXT NOT NULL PRIMARY KEY,
      image_url TEXT NOT NULL,
      feed_content TEXT NOT NULL
    );
    """);
      },
      onUpgrade: _migrateDB,
      onDowngrade: _migrateDB,
    );
  }

  newPodcast(Podcast podcast) async {
    final db = await database;
    var pm = podcast.toMap();
    if (pm["feed_content"].length >= sqliteRowSize) {
      throw Exception("podcast feed_content exceeds sql row size limit");
    }
    var res = await db.insert("Podcasts", pm);
    return res;
  }

  getPodcast(String url) async {
    final db = await database;
    var res = await db.query("Podcasts", where: "feed_url = ?", whereArgs: [url]);
    return res.isNotEmpty ? Podcast.fromMap(res.first) : null;
  }

  Future<List<Podcast>> getAllPodcasts() async {
    final db = await database;
    var res = await db.query("Podcasts");
    return res.isNotEmpty ? res.map((p) => Podcast.fromMap(p)).toList() : [];
  }

  updatePodcast(Podcast podcast) async {
    final db = await database;
    var res = await db.update(
      "Podcasts",
      podcast.toMap(),
      where: "feed_url = ?",
      whereArgs: [podcast.feedUrl],
    );
    return res;
  }

  deletePodcast(String url) async {
    final db = await database;
    var res = await db.delete("Podcasts", where: "feed_url = ?", whereArgs: [url]);
    return res;
  }
}
