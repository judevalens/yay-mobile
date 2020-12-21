import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuple/tuple.dart';
import 'package:yay/misc/SingleSubsStream.dart';

class FeedController {
  List<Map<String, dynamic>> data;
  int startIndex = 0;
  int endIndex = 0;
  Tuple2<int,int> indexRange ;
  int upperSize = 100;
  int lowerSize = 100;
  int bufferSize = 200;
  Query feedItemQuery;
  CollectionReference feedItemCol;
  FirebaseFirestore firebaseFirestore;
  SingleSCMultipleSubscriptions<List<Map<String, dynamic>>> feedStream = new SingleSCMultipleSubscriptions();
  String selectionField = "time_stamp";

  FeedController(this.firebaseFirestore) {
    data = List(bufferSize);
    feedItemCol = firebaseFirestore.collection("users_feed").doc("test").collection("items");

    /*for(int i = 0; i < 1500; i++){
      feedItemCol.add({
        "time_stamp": i,
      });
    }*/
  }

  classicFetch() async {
    var snapshot = await query(1);
    var snapShotData  = snapshot.docs;

    snapShotData.forEach((element) {
      data.add(element.data());
    });
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
    indexRange = range(bufferSize, startIndex, endIndex, direction, upperSize, lowerSize);

    if (direction < 0) {
      feedItemQuery = feedItemCol
          .orderBy(selectionField, descending: false)
          .endBefore([(data[0][selectionField] as int)]).limitToLast(upperSize);
    } else if (direction > 0) {
      feedItemQuery = feedItemCol
          .orderBy(selectionField, descending: false)
          .startAfter([(data[bufferSize - 1][selectionField] as int)]).limit(lowerSize);
    } else {
      feedItemQuery = feedItemCol.orderBy(selectionField, descending: false).limit(bufferSize);
    }
    return feedItemQuery.get();
  }

  Tuple2<int, int> range(
      int bufferSize, startIndex, endIndex, direction, upperBuffer, lowerBuffer) {
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

  int max(int a, b) {
    if (a > b) {
      return a;
    }
    return b;
  }
}
