import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:yay/controllers/App.dart';
import 'package:yay/controllers/Authorization.dart';
import 'package:yay/misc/SingleSubsStream.dart';

class TweetFlowController {
  var logger = Logger();

  static const String tweetFlowUrl = Authorization.ApiBaseUrl+"/content/tweetFlow";
  SingleSCMultipleSubscriptions<Map<String, dynamic>> tweetFlowStream =
      new SingleSCMultipleSubscriptions();

  String userID;

  TweetFlowController(this.userID) {
    App.getInstance().authorization.getConnectionState().listen((isConnected) {
      if (isConnected) {
        this.userID = App.getInstance().authorization.firebaseAuth.currentUser.uid;
        updateTweetFlow();
      }
    });
  }

  Future<Map<String, dynamic>> getFlow(Map<String, dynamic> trackInfo, String userID) async {
    print("my user id " + userID);
    var tweetFlowRes = await http.post(tweetFlowUrl,
        body: jsonEncode({"user_id": userID, "track_info": trackInfo}));
    //TODO must check that decoding was successful
    return Future.value(jsonDecode(tweetFlowRes.body));
  }

  updateTweetFlow() {
    App.getInstance()
        .playBackController
        .newTrackStreamController
        .getStream()
        .listen((trackHasChanged) async {
      var currentPlayBackState = App.getInstance().playBackController.currentPlayBackState;
      print("artistsss " + currentPlayBackState.track.toString());

      var artists = List.empty(growable: true);

      for (var artist in currentPlayBackState.track.artists) {
        artists.add(artist.name);
      }

      Map<String, dynamic> trackInfo = {
        "track_id": currentPlayBackState.track.trackUri,
        "track_title": currentPlayBackState.track.name,
        "track_artists": artists
      };

      var tweetFlow =  getFlow(trackInfo, userID);

      tweetFlow.then((tweetFlowRes){
        tweetFlowStream.controller.add(tweetFlowRes);
      });


      tweetFlowStream.controller.add({
        "status": 100,
      });


      print(tweetFlow);

    });
  }
}
