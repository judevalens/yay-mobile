
import 'dart:async';
import 'dart:convert';

import 'package:yay/controllers/Authorization.dart';
import 'package:http/http.dart' as http;

import 'App.dart';

class BrowserController{
  Authorization _authorization;
  static  const String SearchURL = "https://api.spotify.com/v1/search";
  // ignore: close_sinks
  StreamController<List<Map<String,dynamic>>> queryResponseStreamController = new StreamController.broadcast();
  // ignore: close_sinks
  StreamController<List<Map<String,dynamic>>> userPlayListStreamController = new StreamController.broadcast();

  StreamController<Map<String,dynamic>> userIndividualPlayListStreamController = new StreamController.broadcast();

  // ignore: close_sinks
  StreamController<List<Map<String,dynamic>>> artistQueryResponseStreamController = new StreamController.broadcast();
  // ignore: close_sinks
  StreamController<List<Map<String,dynamic>>> userQueryResponseStreamController = new StreamController.broadcast();


  List<Map<String,dynamic>> playList = new List();

  BrowserController(this._authorization){
      App.getInstance().authorization.getConnectionState().listen((isConnected) {
        if (isConnected) {
          loadPlayLists();
        }
      });
    }


  void loadPlayLists(){
    var url = Uri.https("api.spotify.com",
        "/v1/me/playlists",{
      "limit": "50",
        });

    http.get(url,headers: {
      "Authorization": _authorization.getSpotifyToken()
    }).then((value){


      print("playlist!");
      print(value.body);

      var responses  = jsonDecode(value.body);

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

  void search(String query){
    print("query : " + query);
    var searchURL = Uri.https("api.spotify.com",
        "/v1/search", {
          "q": query, "type": "track",
          "limit": "45",
        });
    print("query2 : " + query);

    print("url " + searchURL.toString());

      http.get(searchURL,headers: {
        "Authorization": _authorization.getSpotifyToken()
      }).then((value) {
        print("value from search \n ");
        print(value.body);

        var responses  = jsonDecode(value.body);

        if (responses["tracks"] != null){
          List<Map<String,dynamic>> responseList = List.from(responses["tracks"]["items"]);

          queryResponseStreamController.add(responseList);
          print("n track returned " + responses["tracks"]["items"].toString());
        }


      });

  }

  void searchArtists(String query){
    print("query : " + query);
    var searchURL = Uri.https("api.spotify.com",
        "/v1/search", {
          "q": query, "type": "artist",
          "limit": "45",
        });
    print("query2 : " + query);

    print("url " + searchURL.toString());

    http.get(searchURL,headers: {
      "Authorization": _authorization.getSpotifyToken()
    }).then((value) {
      print("value from search \n ");
      print(value.body);

      var responses  = jsonDecode(value.body);

      if (responses["artists"] != null){
        List<Map<String,dynamic>> responseList = List.from(responses["artists"]["items"]);

        artistQueryResponseStreamController.add(responseList);
        print("n artist returned " + responses["artists"]["items"].toString());
      }
    });

  }

  void searchUsers(String query){

    query = query.trim();

    if (query.length == 0){
      userQueryResponseStreamController.add(List.empty());
    }else{

      var searchUrl = Authorization.ApiBaseUrl + "/relation/searchUser?query="+query;

      var searchRes = http.get(searchUrl);

      searchRes.then((value){
        var searchResponse  = jsonDecode(value.body);

        print("user search");
        print(searchResponse);

        if( searchResponse["status"] == 200){
          var users = searchResponse["users"].cast<Map<String,dynamic>>();
          userQueryResponseStreamController.add(users);
        }else{
          // NOT A PRETTY SOLUTION
          userQueryResponseStreamController.add(List.empty());
        }
      });

    }



   // http.get(searchUrl,)
  }

}