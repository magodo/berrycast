import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ItunesPodcastResult {
  int resultCount;
  List<ItunesPodcast> results;

  ItunesPodcastResult({
    this.resultCount,
    this.results,
  });

  factory ItunesPodcastResult.fromJson(String str) =>
      ItunesPodcastResult.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ItunesPodcastResult.fromMap(Map<String, dynamic> json) =>
      new ItunesPodcastResult(
        resultCount: json["resultCount"],
        results: new List<ItunesPodcast>.from(
            json["results"].map((x) => ItunesPodcast.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "resultCount": resultCount,
        "results": new List<dynamic>.from(results.map((x) => x.toMap())),
      };
}

class ItunesPodcast {
  String wrapperType;
  String kind;
  int collectionId;
  int trackId;
  String artistName;
  String collectionName;
  String trackName;
  String collectionCensoredName;
  String trackCensoredName;
  String collectionViewUrl;
  String feedUrl;
  String trackViewUrl;
  String artworkUrl30;
  String artworkUrl60;
  String artworkUrl100;
  double collectionPrice;
  double trackPrice;
  int trackRentalPrice;
  int collectionHdPrice;
  int trackHdPrice;
  int trackHdRentalPrice;
  DateTime releaseDate;
  String collectionExplicitness;
  String trackExplicitness;
  int trackCount;
  String country;
  String currency;
  String primaryGenreName;
  String contentAdvisoryRating;
  String artworkUrl600;
  List<String> genreIds;
  List<String> genres;

  ItunesPodcast({
    this.wrapperType,
    this.kind,
    this.collectionId,
    this.trackId,
    this.artistName,
    this.collectionName,
    this.trackName,
    this.collectionCensoredName,
    this.trackCensoredName,
    this.collectionViewUrl,
    this.feedUrl,
    this.trackViewUrl,
    this.artworkUrl30,
    this.artworkUrl60,
    this.artworkUrl100,
    this.collectionPrice,
    this.trackPrice,
    this.trackRentalPrice,
    this.collectionHdPrice,
    this.trackHdPrice,
    this.trackHdRentalPrice,
    this.releaseDate,
    this.collectionExplicitness,
    this.trackExplicitness,
    this.trackCount,
    this.country,
    this.currency,
    this.primaryGenreName,
    this.contentAdvisoryRating,
    this.artworkUrl600,
    this.genreIds,
    this.genres,
  });

  factory ItunesPodcast.fromJson(String str) =>
      ItunesPodcast.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ItunesPodcast.fromMap(Map<String, dynamic> json) => new ItunesPodcast(
        wrapperType: json["wrapperType"],
        kind: json["kind"],
        collectionId: json["collectionId"],
        trackId: json["trackId"],
        artistName: json["artistName"],
        collectionName: json["collectionName"],
        trackName: json["trackName"],
        collectionCensoredName: json["collectionCensoredName"],
        trackCensoredName: json["trackCensoredName"],
        collectionViewUrl: json["collectionViewUrl"],
        feedUrl: json["feedUrl"],
        trackViewUrl: json["trackViewUrl"],
        artworkUrl30: json["artworkUrl30"],
        artworkUrl60: json["artworkUrl60"],
        artworkUrl100: json["artworkUrl100"],
        collectionPrice: json["collectionPrice"],
        trackPrice: json["trackPrice"],
        trackRentalPrice: json["trackRentalPrice"],
        collectionHdPrice: json["collectionHdPrice"],
        trackHdPrice: json["trackHdPrice"],
        trackHdRentalPrice: json["trackHdRentalPrice"],
        releaseDate: DateTime.parse(json["releaseDate"]),
        collectionExplicitness: json["collectionExplicitness"],
        trackExplicitness: json["trackExplicitness"],
        trackCount: json["trackCount"],
        country: json["country"],
        currency: json["currency"],
        primaryGenreName: json["primaryGenreName"],
        contentAdvisoryRating: json["contentAdvisoryRating"],
        artworkUrl600: json["artworkUrl600"],
        genreIds: new List<String>.from(json["genreIds"].map((x) => x)),
        genres: new List<String>.from(json["genres"].map((x) => x)),
      );

  Map<String, dynamic> toMap() => {
        "wrapperType": wrapperType,
        "kind": kind,
        "collectionId": collectionId,
        "trackId": trackId,
        "artistName": artistName,
        "collectionName": collectionName,
        "trackName": trackName,
        "collectionCensoredName": collectionCensoredName,
        "trackCensoredName": trackCensoredName,
        "collectionViewUrl": collectionViewUrl,
        "feedUrl": feedUrl,
        "trackViewUrl": trackViewUrl,
        "artworkUrl30": artworkUrl30,
        "artworkUrl60": artworkUrl60,
        "artworkUrl100": artworkUrl100,
        "collectionPrice": collectionPrice,
        "trackPrice": trackPrice,
        "trackRentalPrice": trackRentalPrice,
        "collectionHdPrice": collectionHdPrice,
        "trackHdPrice": trackHdPrice,
        "trackHdRentalPrice": trackHdRentalPrice,
        "releaseDate": releaseDate.toIso8601String(),
        "collectionExplicitness": collectionExplicitness,
        "trackExplicitness": trackExplicitness,
        "trackCount": trackCount,
        "country": country,
        "currency": currency,
        "primaryGenreName": primaryGenreName,
        "contentAdvisoryRating": contentAdvisoryRating,
        "artworkUrl600": artworkUrl600,
        "genreIds": new List<dynamic>.from(genreIds.map((x) => x)),
        "genres": new List<dynamic>.from(genres.map((x) => x)),
      };

  CachedNetworkImage get image => CachedNetworkImage(
        imageUrl: artworkUrl600,
        placeholder: (context, url) => CircularProgressIndicator(),
//    errorWidget: (context, url, err) => Image.memory(base64.decode(imageBase64), fit: BoxFit.cover),
        fit: BoxFit.cover,
      );
}
