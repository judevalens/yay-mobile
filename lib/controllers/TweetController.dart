import 'dart:convert';
import 'dart:math' as math;

import 'package:intl/intl.dart';
import 'package:tuple/tuple.dart';

class TweetController {
  getTweetFlow() {}
}

class TweetEntity implements Comparable {
  Map<String, dynamic> data;
  String elementType;
  Tuple2<int, int> indices;

  TweetEntity(this.data) {
    print("data indices" + data["indices"][0].toString());

    var startIndex = data["indices"][0] is int
        ? data["indices"][0] as int
        : (data["indices"][0] as double).toInt();
    var endIndex = data["indices"][1] is int
        ? data["indices"][1] as int
        : (data["indices"][1] as double).toInt();
    indices = Tuple2<int, int>(startIndex, endIndex);
    elementType = data["element_type"];
  }

  @override
  int compareTo(other) {
    int i = 0;
    if (indices.item1 < other.indices.item1) {
      i = -1;
    } else if (indices.item1 > other.indices.item1) {
      i = 1;
    }
    return i;
  }
}

class TweetElement {
  String text;
  String type;
}

class TweetItem {
  String itemType;
  Map<String, dynamic> itemInfo;
  Map<String, dynamic> itemContent;
  Map<String, dynamic> quotedTweetData;

  String userName;
  String screenName;
  String profilePictureUrl;
  String tweetDate;
  bool isQuoted;
  bool isRetweeted;

  String tweetText;
  List<TweetElement> tweetElements;

  TweetItem(Map<String, dynamic> tweetData) {
    itemInfo = tweetData["info"] as Map<String, dynamic>;
    itemContent = tweetData["content"]["tweet"] as Map<String, dynamic>;
    itemType = itemInfo["content_type"] as String;
    initTweet();
  }

  TweetItem.quoteTweet(Map<String, dynamic> tweetContent) {
    itemContent = tweetContent;
    initTweet();
  }

  TweetItem.tweetFlow(Map<String, dynamic> tweetContent) {
    itemContent = tweetContent;
    initTweet();
  }

  initTweet() {
    tweetDate = itemContent["created_at"] as String;
    tweetDate = tweetDate.replaceFirst("+0000 ", "");
    isQuoted = itemContent["is_quote_status"] as bool;
    isRetweeted = itemContent["retweeted"] as bool;
    if (isQuoted) {
      quotedTweetData = itemContent["quoted_status"];

      if (quotedTweetData == null) {
        print("quotedTweetData " + itemContent["retweeted_status"].toString());
        jsonEncode(itemContent.toString());
      }
    }

    var twitterDateFormat = DateFormat('EEE MMM dd HH:mm:ss yyyy');
    var tweetDateTime = twitterDateFormat.parse(tweetDate);
    var wantedDate = DateFormat("dd MMM yyyy");
    tweetDate = wantedDate.format(tweetDateTime);

    userName = itemContent["user"]["name"];
    screenName = "@" + itemContent["user"]["screen_name"];
    profilePictureUrl = getBiggerUrl(itemContent["user"]["profile_image_url_https"]);

    tweetText = itemContent["text"];

    var tweetEntities = parseTweetEntities(itemContent["entities"]);

    tweetElements = parseTweet(tweetText, tweetEntities);
    print("NEW ENTITY LIST");

    tweetEntities.forEach((element) {
      print(element.data);
    });
    print("NEW ELEMENT LIST");

    tweetElements.forEach((element) {
      print("element :" + element.text + "\n");
    });
  }

  List<TweetEntity> parseTweetEntities(Map<String, dynamic> entities) {
    var hashtags = (entities["hashtags"] as List<dynamic>).cast<Map<String, dynamic>>();

    hashtags.forEach((element) {
      element["element_type"] = "hashtag";
    });
    var mentions = (entities["user_mentions"] as List<dynamic>).cast<Map<String, dynamic>>();
    mentions.forEach((element) {
      element["element_type"] = "mention";
    });
    var urls = (entities["urls"] as List<dynamic>).cast<Map<String, dynamic>>();
    urls.forEach((element) {
      element["element_type"] = "url";
    });

    List<Map<String, dynamic>> entitiesJSOn = List.empty(growable: true);
    entitiesJSOn.addAll(hashtags);
    entitiesJSOn.addAll(mentions);
    entitiesJSOn.addAll(urls);

    List<TweetEntity> entitiesList = List.empty(growable: true);

    for (int i = 0; i < entitiesJSOn.length; i++) {
      var entity = TweetEntity(entitiesJSOn[i]);

      if (entitiesList.length == 0) {
        entitiesList.add(entity);
      } else {
        if (entity.compareTo(entitiesList.last) >= 0) {
          entitiesList.add(entity);
        } else {
          entitiesList.insert(i, entity);
        }
      }
    }

    return entitiesList;
  }

  List<TweetElement> parseTweet(String tweetRawText, List<TweetEntity> entities) {
    List<TweetElement> tweetElements = List.empty(growable: true);

    if (entities.length > 0) {
      for (int i = 0; i < entities.length; i++) {
        var entity = entities[i];
        var prevEntity = entities[math.max(0, i - 1)];

        if (i == 0 && entity.indices.item1 != 0) {
          var startTingElement = TweetElement();

          startTingElement.text =
              String.fromCharCodes(tweetRawText.runes.toList(), 0, entity.indices.item1);
          startTingElement.type = "normal";
          tweetElements.add(startTingElement);
        }

        if (entity.indices.item1 > prevEntity.indices.item2) {
          var middleElement = TweetElement();

          middleElement.text = String.fromCharCodes(
              tweetRawText.runes.toList(), prevEntity.indices.item2, entity.indices.item1);

          middleElement.type = "normal";
          tweetElements.add(middleElement);
        }

        var currentElement = TweetElement();

        currentElement.text = String.fromCharCodes(
            tweetRawText.runes.toList(), entity.indices.item1, entity.indices.item2);

        currentElement.type = entity.elementType;
        tweetElements.add(currentElement);

        if (i == entities.length - 1 && entity.indices.item2 < entities.length) {
          var lastElement = TweetElement();

          lastElement.text = String.fromCharCodes(
              tweetRawText.runes.toList(), entity.indices.item2, tweetRawText.length);
          lastElement.type = "normal";
          tweetElements.add(lastElement);
        }
      }
    } else {
      var tweetElement = TweetElement();

      tweetElement.text = tweetRawText;
      tweetElement.type = "normal";
      tweetElements.add(tweetElement);
    }

    return tweetElements;
  }

  getNormalUrl(String url) {
    var lastIndex = url.lastIndexOf("_normal");

    var newUrl = url.substring(0, lastIndex) +
        url.substring(url.substring(0, lastIndex).length + "_normal".length);
    print("new url " + newUrl);
  }

  String getBiggerUrl(String url) {
    var lastIndex = url.lastIndexOf("_normal");
    var newUrl = url.substring(0, lastIndex) +
        "_bigger" +
        url.substring(url.substring(0, lastIndex).length + "_normal".length);
    print("new url " + newUrl);
    return newUrl;
  }
}
