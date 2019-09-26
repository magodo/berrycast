class Bookmark {
  final int id;
  final String episodeUrl;
  final Duration duration;
  final String description;

  Bookmark({this.id, this.episodeUrl, this.duration, this.description});

  factory Bookmark.fromMap(Map<String, dynamic> json) => Bookmark(
        id: json["id"],
        episodeUrl: json["song"],
        duration: Duration(seconds: json['duration']),
        description: json["description"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "song": episodeUrl,
        "duration": duration.inSeconds,
        "description": description,
      };
}
