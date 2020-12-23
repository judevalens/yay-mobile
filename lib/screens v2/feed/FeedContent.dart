
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:intl/intl.dart';
import 'package:yay/controllers/App.dart';
import 'package:yay/controllers/FeedController.dart';

class FeedContent extends StatefulWidget {
  final Map<String, dynamic> itemData;
  final int itemIndex;

  const FeedContent({Key key, this.itemData,this.itemIndex});

  @override
  _FeedContentState createState() => _FeedContentState();
}

class _FeedContentState extends State<FeedContent> {
  FeedController _feedController = App.getInstance().feedController;
  String itemType;
  Map<String, dynamic> itemInfo;
  Map<String, dynamic> itemContent;

  String userName;
  String screenName;
  String profilePictureUrl;
  String tweetDate;

  String tweetText;


  _FeedContentState();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    itemInfo = widget.itemData["info"] as Map<String, dynamic>;
    itemContent = widget.itemData["content"]["tweet"] as Map<String, dynamic>;
    itemType = itemInfo["content_type"] as String;

    tweetDate = itemContent["created_at"] as String;
    tweetDate = tweetDate.replaceFirst("+0000 ", "");

    var twitterDateFormat = DateFormat('EEE MMM dd HH:mm:ss yyyy');
    var tweetDateTime = twitterDateFormat.parse(tweetDate);
    var wantedDate = DateFormat("dd MMM yyyy");
    tweetDate = wantedDate.format(tweetDateTime);

     userName = itemContent["user"]["name"];
     screenName = "@" + itemContent["user"]["screen_name"];
     profilePictureUrl = getBigger(itemContent["user"]["profile_image_url_https"]);

    tweetText = itemContent["text"];

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
    Color c = widget.itemIndex.isEven ? Colors.white : Color(0xfff8f9fa);
    return Container(
      padding: EdgeInsets.all(10),
      alignment: Alignment.center,
      color: c,
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
    );
  }

  Widget tweetHeader() {
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
                userName,
                softWrap: true,
                overflow: TextOverflow.clip,
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Text(
              screenName,
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ],
        )),
      ],
    );
  }

  Widget tweetBody() {
    return Container(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.only(top: 20,bottom: 20),
        child: Text(tweetText, style: Theme.of(context).textTheme.bodyText1));
  }

  Widget actionButton() {
    return Row(
      children: [
        Flexible(
          flex: 12,
          child: Container(
            child: ImageIcon(
              AssetImage("assets/tweet_icons/speech-bubble.png"),
            ),
          ),
        ),
        Spacer(
          flex: 1,
        ),
        Flexible(
          flex: 12,
          child: ImageIcon(
            AssetImage("assets/tweet_icons/retweet.png"),
          ),
        ),
        Spacer(
          flex: 1,
        ),
        Flexible(
          flex: 12,
          child: ImageIcon(
            AssetImage("assets/tweet_icons/heart.png"),
          ),
        )
      ],
    );
  }

  Widget tweetFooter() {
    return Row(
      children: [
        Flexible(child: actionButton()),
        Container(
          child: Text(tweetDate),
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
