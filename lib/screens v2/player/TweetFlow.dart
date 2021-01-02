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
      padding: EdgeInsets.all(5),
      width: double.infinity,
      color: Theme.of(context).colorScheme.primary,
      height: 400,
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            height: widget.tweetFlowContainerHeight * 0.1,
            child: Text(
              "Tweet Flow",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Divider(
            thickness: 2,
          ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: tweetFlowItem2(),
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            child: Text("1/50",style: TextStyle(
              fontSize: 20
            ),),
          ),
          Divider(
            thickness: 2,
          ),
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
                            decoration: BoxDecoration(
                                border: Border.all(width: 0.1),
                                borderRadius: BorderRadius.circular(10)),
                            child: FeedTweet(
                              itemData: tweets[index],
                              itemIndex: index,
                              tweetType: "tweetFlow",
                              key: ValueKey(tweets[index]["id_str"]),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Container(
                          width: 5,
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

  Widget tweetFlowItem2() {
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

                    return PageView.builder(
                      itemCount: tweets.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int index) {
                        return ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: constraint.maxWidth),
                          child: Container(
                            child: FeedTweet(
                              itemData: tweets[index],
                              itemIndex: index,
                              tweetType: "tweetFlow",
                              key: ValueKey(tweets[index]["id_str"]),
                            ),
                          ),
                        );
                      },
                    );
                  } else if (tweetFlow["status"] == 100) {
                    return loading();
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

Widget loading() {
  return Container(
    alignment: Alignment.center,
    child: CircularProgressIndicator(),
  );
}
