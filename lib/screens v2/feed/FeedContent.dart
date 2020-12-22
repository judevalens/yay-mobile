import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:yay/controllers/App.dart';
import 'package:yay/controllers/FeedController.dart';

class FeedContent extends StatefulWidget {
  final Map<String, dynamic> itemData;

  const FeedContent({Key key, this.itemData});

  @override
  _FeedContentState createState() => _FeedContentState();
}

class _FeedContentState extends State<FeedContent> {
  FeedController _feedController = App.getInstance().feedController;
  String itemType;
  Map<String, dynamic> itemInfo;
  Map<String, dynamic> itemContent;

  _FeedContentState();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    itemInfo = widget.itemData["info"] as Map<String, dynamic>;
    itemContent = widget.itemData["content"]["tweet"] as Map<String, dynamic>;
    itemType = itemInfo["content_type"] as String;

    print("contentssfd  " + itemContent["id_str"]);
  }

  @override
  Widget build(BuildContext context) {
    Widget w;

    if (itemType == FeedController.TWEET_TYPE) {
      w = buildTweet();
    }

    return w;
  }

  Widget buildTweet() {
    return Container(
      child: Card(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(
                fit: FlexFit.loose,
                child: Container(
                  child: tweetHeader(),
                ),
              ),
              Flexible(
                fit: FlexFit.loose,
                child: Container(
                  child: tweetBody(),
                ),
              ),
              Flexible(
                  child: Container(
                child: tweetFooter(),
              ))
            ],
          ),
        ),
      ),
    );
  }

  Widget tweetHeader() {


    var name = itemContent["user"]["name"];
    var screenName = "@" + itemContent["user"]["screen_name"];
    var profilePictureUrl = getBigger(itemContent["user"]["profile_image_url_https"]);

    return Row(
      children: [
        Container(
          margin: EdgeInsets.only(right: 5),
          height: 50,
          width: 50,
          decoration:
              BoxDecoration(border: Border.all(width: 1), borderRadius: BorderRadius.circular(25)),
          child: ClipOval(
            child: Image.network(
              profilePictureUrl,
              fit: BoxFit.fill,
            ),
          ),
        ),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Text(
                name,
                softWrap: true,
                overflow: TextOverflow.clip,
                style: Theme.of(context).accentTextTheme.headline6,
              ),
            ),
            Text(
              screenName,
              style: Theme.of(context).accentTextTheme.subtitle1,
            ),
          ],
        )),
      ],
    );
  }

  Widget tweetBody() {
    var text = itemContent["text"];
    return Container(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.only(top: 20,bottom: 20),
        child: Text(text, style: Theme.of(context).accentTextTheme.bodyText2));
  }

  Widget tweetFooter() {
    return Row(
      children: [
        Flexible(
          flex: 12,
          child: ImageIcon(
            AssetImage("assets/tweet_icons/speech-bubble.png"),
          ),
        ),
        Spacer(flex: 1,),
        Flexible(
          flex: 12,
          child: ImageIcon(
            AssetImage("assets/tweet_icons/retweet.png"),
          ),
        ),
        Spacer(flex: 1,),
        Flexible(
          flex: 12,
          child: ImageIcon(
            AssetImage("assets/tweet_icons/heart.png"),
          ),
        )
      ],
    );
  }

  getNormalUrl(String url) {
    var lastIndex = url.lastIndexOf("_normal");

    var newUrl = url.substring(0, lastIndex) +
        url.substring(url.substring(0, lastIndex).length + "_normal".length);
    print("new url " + newUrl);
  }

  String getBigger(String url) {
    var lastIndex = url.lastIndexOf("_normal");
    var newUrl = url.substring(0, lastIndex) +
        "_bigger" +
        url.substring(url.substring(0, lastIndex).length + "_normal".length);
    print("new url " + newUrl);
    return newUrl;
  }
}
