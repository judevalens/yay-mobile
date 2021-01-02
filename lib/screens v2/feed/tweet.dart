import 'package:flutter/material.dart';
import 'package:yay/controllers/TweetController.dart';

class FeedTweet extends StatefulWidget {
  final Map<String, dynamic> itemData;
  final int itemIndex;
  final String tweetType;

  const FeedTweet({Key key, this.itemData, this.itemIndex, this.tweetType}) : super(key: key);

  @override
  _FeedTweetState createState() => _FeedTweetState();
}

class _FeedTweetState extends State<FeedTweet> {
  String itemType;
  TweetItem tweet;

  _FeedTweetState();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (widget.tweetType == "normal") {
      tweet = TweetItem(widget.itemData);
    } else if (widget.tweetType == "tweetFlow") {
      tweet = TweetItem.tweetFlow(widget.itemData);
    } else {
      print("quoted tweet " + widget.itemData.toString());
      tweet = TweetItem.quoteTweet(widget.itemData);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget w;
    if (widget.tweetType == "normal") {
      w = buildTweet();
    }else if(widget.tweetType == "tweetFlow"){
      w = buildTweetFlow();
    }
    else if (widget.tweetType == "quote") {
      w = buildQuotedTweet();
    }
    return w;
  }

  Widget buildTweet() {
    Color c = widget.itemIndex.isEven ? Colors.white : Theme.of(context).colorScheme.primary;
    var paragraph = buildTweetText();
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
              child: tweetBody(paragraph),
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                margin: EdgeInsets.only(right: 5),
                height: 50,
                width: 50,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(25)),
                child: ClipOval(
                  child: Image.network(
                    tweet.profilePictureUrl,
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
                      tweet.userName,
                      softWrap: true,
                      overflow: TextOverflow.clip,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                  Text(
                    tweet.screenName,
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ],
              )),
            ],
          ),
        ),
        Container(
          width: 50,
          height: 50,
          alignment: Alignment.centerRight,
          child: Material(
            type: MaterialType.transparency,
            shape: CircleBorder(),
            child: InkWell(
              customBorder: CircleBorder(),
              onTap: () {},
              child: ImageIcon(
                AssetImage("assets/Twitter_Logo_Blue.png"),
                size: 50,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget quoteTweetHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                margin: EdgeInsets.only(right: 5),
                height: 40,
                width: 40,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
                child: ClipOval(
                  child: Image.network(
                    tweet.profilePictureUrl,
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
                      tweet.userName,
                      softWrap: true,
                      overflow: TextOverflow.clip,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    tweet.screenName,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w100),
                  ),
                ],
              )),
            ],
          ),
        ),
        Container(
          alignment: Alignment.centerRight,
          child: Text(tweet.tweetDate,
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 15, color: Colors.black54)),
        )
      ],
    );
  }

  List<TextSpan> buildTweetText() {
    List<TextSpan> paragraph = List.empty(growable: true);
    tweet.tweetElements.forEach((element) {
      TextSpan segment;
      if (element.type == "hashtag") {
        segment = TextSpan(
          text: element.text,
          style: TextStyle(
            fontSize: 20,
            color: Color(0xff1DA1F2),
            fontWeight: FontWeight.bold,
          ),
        );
      } else if (element.type == "mention") {
        segment = TextSpan(
          text: element.text,
          style: TextStyle(
            fontSize: 20,
            color: Color(0xff1DA1F2),
          ),
        );
      } else if ((element.type == "url")) {
        segment = TextSpan(
          text: element.text,
          style: TextStyle(
            decoration: TextDecoration.underline,
            fontSize: 20,
            color: Color(0xff1DA1F2),
            fontWeight: FontWeight.bold,
          ),
        );
      } else {
        segment = TextSpan(
          text: element.text,
          style: TextStyle(fontSize: 20, color: Colors.black),
        );
      }

      paragraph.add(segment);
    });

    if (tweet.isQuoted) {
      if (paragraph.length > 0) {
        paragraph.removeAt(paragraph.length - 1);
      }
    }

    return paragraph;
  }

  Widget tweetBody(List<InlineSpan> paragraph) {
    List<Widget> bodyWidget = List.empty(growable: true);

    var mainText = Container(
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(children: paragraph),
      ),
    );

    bodyWidget.add(mainText);

    if (tweet.isQuoted) {
      if (tweet.quotedTweetData != null) {
        Widget quotedTweet = Container(
          margin: EdgeInsets.only(top: 5),
          child: FeedTweet(
            itemData: tweet.quotedTweetData,
            itemIndex: widget.itemIndex,
            tweetType: "quote",
          ),
        );
        bodyWidget.add(quotedTweet);
      }
    }

    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.only(top: 20, bottom: 20),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: bodyWidget,
      ),
    );
  }

  Widget actionButton() {
    return Row(
      children: [
        Flexible(
          flex: 12,
          child: Container(
            child: ImageIcon(
              AssetImage("assets/tweet_icons/speech-bubble.png"),
              color: Colors.black54,
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
            color: Colors.black54,
          ),
        ),
        Spacer(
          flex: 1,
        ),
        Flexible(
          flex: 12,
          child: ImageIcon(
            AssetImage("assets/tweet_icons/heart.png"),
            color: Colors.black54,
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
          child: Text(
            tweet.tweetDate,
            style: Theme.of(context).textTheme.button,
          ),
        )
      ],
    );
  }

  Widget buildQuotedTweet() {
    var paragraph = buildTweetText();
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.black54),
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          quoteTweetHeader(),
          tweetBody(paragraph),
        ],
      ),
    );
  }

  Widget buildTweetFlow(){
    return     Container(
      padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(width: 0.1,),

        ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          quoteTweetHeader(),
          Container(

            alignment: Alignment.centerLeft,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: Text(tweet.tweetText,style: TextStyle(
                fontSize: 18,
              ),overflow: TextOverflow.fade,softWrap: true,),),
        ],
      ),
    );

  }
}
