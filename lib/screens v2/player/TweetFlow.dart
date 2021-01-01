import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yay/controllers/App.dart';
import 'package:yay/screens%20v2/feed/tweet.dart';

class TweetFlow extends StatefulWidget {
  final int tweetFlowContainerHeight;

  const TweetFlow({Key key, this.tweetFlowContainerHeight}) : super(key: key);

  @override
  _TweetFlowState createState() => _TweetFlowState();
}

class _TweetFlowState extends State<TweetFlow> {
  @override
  Widget build(BuildContext context) {
    return _buildTweetFlow();
  }

  Widget _buildTweetFlow() {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      width: double.infinity,
      color: Theme.of(context).colorScheme.primary,
      height: 350,
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 5),
            alignment: Alignment.center,
            height: widget.tweetFlowContainerHeight * 0.15,
            child: Text(
              "Tweet Flow",
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: tweetFlowItem(),
            ),
          )
        ],
      ),
    );
  }

  Widget tweetFlowItem() {
    return Container(
      child: LayoutBuilder(
        builder: (context, constraint) {
          return StreamBuilder(
              stream: App.getInstance().tweetFlowController.tweetFlowStream.getStream(),
              builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
                Widget w;
                if (snapshot.hasData) {
                  var tweetFlow = snapshot.data;
                  if (tweetFlow["status"] == 200) {
                    var tweetsDynamic = tweetFlow["tweetFlow"]["tweets"] as List<dynamic>;
                    var tweets = tweetsDynamic.cast<Map<String, dynamic>>();
                    print("tweets");
                    print(tweets);

                    return ListView.separated(
                      itemCount: tweets.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int index) {
                        return ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: constraint.maxWidth),
                          child: Container(
                            decoration: BoxDecoration(border: Border.all(width: 0.5)),
                            child: FeedTweet(
                              itemData: tweets[index],
                              itemIndex: index,
                              tweetType: "tweetFlow",
                              key: ValueKey(tweets[index]["id_str"]),
                            ),
                          ),
                        );
                      }, separatorBuilder: (BuildContext context, int index) {
                        return Container(
                          width: 0,
                        );
                    },
                    );
                  }
                }
                return emptyTweetFlow();
              });
        },
      ),
    );
  }
}
Widget emptyTweetFlow() {
  return Container(
    child: Text("No tweets to show"),
  );
}
