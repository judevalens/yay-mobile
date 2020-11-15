
import 'dart:async';
import 'dart:convert';

import 'package:yay/controllers/Authorization.dart';
import 'package:http/http.dart' as http;

class BrowserController{
  Authorization _authorization;
  static  const String SearchURL = "https://api.spotify.com/v1/search";
  // ignore: close_sinks
  StreamController<List<Map<String,dynamic>>> queryResponseStreamController = new StreamController.broadcast();
  BrowserController(this._authorization);

  void search(String query){
    print("query : " + query);
    var searchURL = Uri.https("api.spotify.com",
        "/v1/search", {
          "q": query, "type": "track"
        });
    print("query2 : " + query);

    print("url " + searchURL.toString());

      http.get(searchURL,headers: {
        "Authorization": _authorization.getSpotifyToken()
      }).then((value) {
        print("value from search \n ");
        print(value.body);

        var responses  = jsonDecode(value.body);

         List<Map<String,dynamic>> responseList = List.from(responses["tracks"]["items"]);

        queryResponseStreamController.add(responseList);
        print("n track returned " + responses["tracks"]["items"].toString());
      });

  }
}