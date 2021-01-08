import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tuple/tuple.dart';
import 'package:yay/misc/SingleSubsStream.dart';

import 'App.dart';
import 'dart:math' as math;
class FeedController {
  static const String USER_TYPE = "user";
  static const String ARTIST_TYPE = "artist";
  static const String TWEET_TYPE = "tweet";

  List<Map<String, dynamic>> data;
  int startIndex = 0;
  int endIndex = 0;
  Tuple2<int, int> indexRange;

  int upperSize = 10;
  int lowerSize = 10;
  int bufferSize = 10;
  Query feedItemQuery;
  CollectionReference feedItemCol;
  FirebaseFirestore firebaseFirestore;
  FirebaseAuth _firebaseAuth;
  SingleSCMultipleSubscriptions<List<Map<String, dynamic>>> feedStream = new SingleSCMultipleSubscriptions();
  String selectionField = "sorting_timestamp";

  FeedController(this.firebaseFirestore,this._firebaseAuth) {
    data = List();

    App.getInstance().authorization.getConnectionState().listen((isConnected) {
      if (isConnected) {
        feedItemCol = firebaseFirestore.collection("users_feed").doc(_firebaseAuth.currentUser.uid).collection("items");
      }
    });

    /*for(int i = 0; i < 1500; i++){
      feedItemCol.add({
        "time_stamp": i,
      });
    }*/
  }

  classicFetch(int dir) async {
    var snapshot = await query(dir);
    var snapShotData = snapshot.docs;

    print("fetching ....");

    for (QueryDocumentSnapshot itemInfoSnapShot in snapShotData) {
      print("querrying item");
      var itemInfoData = itemInfoSnapShot.data();
      var itemContent = await queryFeedItem(itemInfoData);
      print("info data : " + itemInfoData.toString());
      print("info content : " + itemContent.data().toString());
      var item = {
        "content": itemContent.data(),
        "info": itemInfoData,
      };
      data.add(item);
    }

    feedStream.controller.add(data);
  }


  Future<int> fetch (int direction) async{
    var snapshot = await query(direction);
    var snapShotData  = snapshot.docs;
    int i = 0;

    if (direction > 0){
      List.copyRange(data, 0, data,lowerSize,bufferSize);
      i = upperSize;
    }else if (direction < 0){
      List.copyRange(data, upperSize, data,0,lowerSize);
      i = 0;
    }
    snapShotData.forEach((element) {
      data[i] =element.data();
      i++;
    });

    feedStream.controller.add(data);


    print("timestamp BATCH START, size :"+ snapshot.size.toString() +"\n");
    var j = 0;
    data.forEach((element) {
      var t = element["time_stamp"];
      j++;
      print(j.toString() +" timestamp : " + (t as int).toString());
    });
    print("timestamp BATCH END , size " + data.length.toString()+ "\n");

    startIndex = indexRange.item1;
    endIndex = indexRange.item2;

    return snapshot.size;
  }

  Future<QuerySnapshot> query(int direction) async{

    if (direction < 0) {
      feedItemQuery = feedItemCol
          .orderBy(selectionField, descending: true)
          .endBefore([(data[0][selectionField] as int)]).limitToLast(upperSize);
    } else if (direction > 0) {
      //print("data length " + data.length.toString() + "last timestamp " + data[data.length - 1]["info"][selectionField].toString());

      if (data.length == 0){
        return feedItemQuery.get();
      }

      var lastIndex  = math.max(data.length-1, 0);
      var lowerBound =  data[lastIndex]["info"][selectionField];
      feedItemQuery = feedItemCol
          .orderBy(selectionField, descending: true)
          .startAfter([lowerBound]).limit(lowerSize);
    } else {
      feedItemQuery = feedItemCol.orderBy(selectionField, descending: true).limit(bufferSize);
    }
    return feedItemQuery.get();
  }

  Tuple2<int, int> range(int bufferSize, startIndex, endIndex, direction, upperBuffer, lowerBuffer) {
    if (direction == 0) {
      startIndex = 0;
      endIndex += bufferSize;
    } else if (direction < 0) {
      endIndex = startIndex + lowerBuffer;
      endIndex = max(0, endIndex);
      startIndex -= upperBuffer;
      startIndex = max(0, startIndex);
    } else {
      startIndex = endIndex - upperBuffer;
      endIndex += lowerBuffer;
    }
    return Tuple2<int, int>(startIndex, endIndex);
  }

  Future<DocumentSnapshot> queryFeedItem(Map<String, dynamic> itemInfo) {
    DocumentReference itemColRed;
    var itemID = itemInfo["item_id"] as String;
    var itemType = itemInfo["content_type"] as String;
    var creatorSpotifyID = itemInfo["created_by_spotify_id"] as String;
    var creatorTwitterID = itemInfo["created_by_twitter_id"] as String;
    var creatorType = ARTIST_TYPE;

    if (creatorType == ARTIST_TYPE) {
      if (itemType == TWEET_TYPE) {
        print("its a tweet,  twitterID  " +creatorTwitterID + ", item ID " +  itemID);
        itemColRed =
            firebaseFirestore.collection("artists_twitter_feeds").doc(creatorTwitterID).collection(
                "tweets").doc(itemID);
      }
    }

    return itemColRed.get();
  }

  int max(int a, b) {
    if (a > b) {
      return a;
    }
    return b;
  }
}
