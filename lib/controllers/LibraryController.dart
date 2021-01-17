
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;
import 'package:yay/controllers/Authorization.dart';

import 'App.dart';

class BrowserController{
  Authorization _authorization;
  static const String SearchURL = "https://api.spotify.com/v1/search";
  int maxEntry = 25;

  // ignore: close_sinks
  StreamController<List<Map<String, dynamic>>> queryResponseStreamController =
      new StreamController.broadcast();

  // ignore: close_sinks
  StreamController<List<Map<String, dynamic>>> userPlayListStreamController =
      new StreamController.broadcast();

  StreamController<Map<String, dynamic>> userIndividualPlayListStreamController =
      new StreamController.broadcast();

  // ignore: close_sinks
  StreamController<List<Map<String, dynamic>>> artistQueryResponseStreamController =
      new StreamController.broadcast();

  // ignore: close_sinks
  StreamController<List<Map<String, dynamic>>> userQueryResponseStreamController =
      new StreamController.broadcast();

  // ignore: close_sinks
  StreamController<CompositeSearchResult> newSearchResult = new StreamController.broadcast();

  List<Map<String, dynamic>> songSearchResult = new List.empty();
  List<Map<String, dynamic>> artistSearchResult = new List.empty();
  List<Map<String, dynamic>> userSearchResult = new List.empty();

  List<Map<String, dynamic>> playList = new List();

  BrowserController(this._authorization) {
    App.getInstance().authorization.getConnectionState().listen((isConnected) {
      if (isConnected) {
        loadPlayLists();
      }
    });
  }

  void loadPlayLists() {
    var url = Uri.https("api.spotify.com", "/v1/me/playlists", {
      "limit": "50",
    });

    http.get(url, headers: {"Authorization": _authorization.getSpotifyToken()}).then((value) {
      print("playlist!");
      print(value.body);

      var responses = jsonDecode(value.body);

      playList = List.from(responses["items"]);

      print("next " + responses["next"].toString());

      userPlayListStreamController.add(playList);
    });
  }

  void individualPlayList(String playListID){
    var url = Uri.https("api.spotify.com",
        "/v1/playlists/" + playListID,{
        });

    http.get(url,headers: {
      "Authorization": _authorization.getSpotifyToken()
    }).then((value) {
      print("indivdual playList \n" + value.body);

      var response = jsonDecode(value.body);
      userIndividualPlayListStreamController.add(response);



    });
    }

  Future<bool> searchSongs(String query) async {
    print("query : " + query);
    var searchURL = Uri.https("api.spotify.com", "/v1/search", {
      "q": query,
      "type": "track",
      "limit": "45",
    });
    print("query2 : " + query);

    print("url " + searchURL.toString());

    var songRes =
        await http.get(searchURL, headers: {"Authorization": _authorization.getSpotifyToken()});

    print("value from search \n ");
    print(songRes.body);

    var responses = jsonDecode(songRes.body);

    if (responses["tracks"] != null) {
      songSearchResult = List.from(responses["tracks"]["items"]);
      print("n track returned " + responses["tracks"]["items"].toString());
    } else {
      songSearchResult.clear();
    }

    return true;
  }

  Future<bool> searchArtists(String query) async {
    print("query : " + query);
    var searchURL = Uri.https("api.spotify.com", "/v1/search", {
      "q": query,
      "type": "artist",
      "limit": "45",
    });
    print("query2 : " + query);

    print("url " + searchURL.toString());

    var artistRes =
        await http.get(searchURL, headers: {"Authorization": _authorization.getSpotifyToken()});
    print("value from search \n ");
    print(artistRes.body);

    var responses = jsonDecode(artistRes.body);

    if (responses["artists"] != null) {
      artistSearchResult = List.from(responses["artists"]["items"]);
    } else {
      artistSearchResult.clear();
    }


    return true;
  }

  Future<bool> searchUsers(String query) async {
    query = query.trim();

    if (query.length == 0) {
      userQueryResponseStreamController.add(List.empty());
    } else {
      var searchUrl = Authorization.ApiBaseUrl + "/relation/searchUser?query=" + query;

      var userRes = await http.get(searchUrl);

      var searchResponse = jsonDecode(userRes.body);

      print("user search");
      print(searchResponse);

      if (searchResponse["status"] == 200) {
        userSearchResult = searchResponse["users"].cast<Map<String, dynamic>>();
      } else {
        // NOT A PRETTY SOLUTION
        userSearchResult.clear();
      }
    }

    return true;

    // http.get(searchUrl,)
  }

  Future<void> search(String query) async {
    int counter = 3;
    searchSongs(query).then((value) {
      counter--;
      if (counter == 0) {
        updateSearchResultPartition();
      }
    });
    searchArtists(query).then((value) {
      counter--;
      if (counter == 0) {
        updateSearchResultPartition();
      }
    });
    searchUsers(query).then((value) {
      counter--;
      if (counter == 0) {
        updateSearchResultPartition();
      }
    });
  }

  updateSearchResultPartition() {
    var searchResultsInfo = [
      ResultCategory(songSearchResult.length, "song", 0),
      ResultCategory(artistSearchResult.length, "artist", 1),
      ResultCategory(userSearchResult.length, "user", 2),
    ];

    var searchResult = CompositeSearchResult(searchResultsInfo, 9);
    searchResult.buildCompositeResult();
    newSearchResult.add(searchResult);
  }

  List<Map<String, dynamic>> buildCompositeResult(
      List<Map<String, dynamic>> categories, int maxEnTry, List<Map<String, dynamic>> solved) {
    print("length :" + categories.length.toString());
    var nCat = categories.length;

    if (nCat == 0) {
      return solved;
    }

    var minItem = maxEnTry ~/ nCat;
    var leftOver = maxEnTry % nCat;
    print("minItem :" + minItem.toString());

    for (int i = nCat - 1; i >= 0; i--) {
      var cat = categories[i];
      var n = math.min(minItem, (cat["length"] as int).toInt());
      cat["nItem"] = n;
      print("     nItem :" + n.toString());

      if (i == 0) {
        cat["nItem"] += leftOver;
      }

      if (n < minItem) {
        maxEnTry -= n;
        print("     maxEnTry :" + maxEnTry.toString());
        solved.add(cat);
        categories.removeAt(i);
        return buildCompositeResult(categories, maxEnTry, solved);
      }
    }
    categories.forEach((element) {
      solved.add(element);
    });

    return solved;
  }
}

class CompositeSearchResult {
  List<ResultCategory> categories;
  List<ResultCategory> solvedCategories = List.empty(growable: true);
  Map<String, int> categoriesIndex = Map();
  int maxEntries;

  CompositeSearchResult(this.categories, this.maxEntries);

  buildCompositeResult() {
    print("length :" + categories.length.toString());
    var nCat = categories.length;

    if (nCat == 0) {
      return;
    }

    var minItem = maxEntries ~/ nCat;
    var leftOver = maxEntries % nCat;
    print("minItem :" + minItem.toString());

    for (int i = nCat - 1; i >= 0; i--) {
      var cat = categories[i];
      var n = math.min(minItem, cat.length);
      cat.wantedLength = n;
      print("     nItem :" + n.toString());

      if (i == 0) {
        cat.wantedLength += leftOver;
      }

      if (n < minItem) {
        maxEntries -= n;
        print("     maxEnTry :" + maxEntries.toString());
        solvedCategories.add(cat);
        categoriesIndex[cat.type] = solvedCategories.length - 1;
        categories.removeAt(i);
        return buildCompositeResult();
      }
    }
    categories.forEach((element) {
      solvedCategories.add(element);
      categoriesIndex[element.type] = solvedCategories.length - 1;
    });
    solvedCategories.sort((a, b) {
      if (a.sortingIndex > b.sortingIndex) {
        return 1;
      } else if (a.sortingIndex < b.sortingIndex) {
        return -1;
      } else {
        return 0;
      }
    });
  }
}

class ResultCategory {
  int startIndex;
  String type;
  int length;
  int wantedLength;
  int sortingIndex;

  ResultCategory(this.length, this.type, this.sortingIndex);
}