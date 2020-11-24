import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:tuple/tuple.dart';
import 'package:yay/controllers/ChatController.dart';
import 'dart:math' as math;

class ChatItem extends StatefulWidget {
  final Map<String, dynamic> chat;
  final ScrollController scrollController;

  const ChatItem({Key key, this.chat, this.scrollController}) : super(key: key);

  @override
  _ChatItemState createState() => _ChatItemState();
}

class _ChatItemState extends State<ChatItem> {
  Color bg = Color(0xFF2E2829);
  double gifPadding = 4;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var time = DateTime.fromMillisecondsSinceEpoch(widget.chat["time"]);
    return LayoutBuilder(builder: (context, constraintBox) {
      return Container(
        width: double.infinity,
        alignment: Alignment.centerRight,
        margin: EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            UnconstrainedBox(
              child: LimitedBox(
                maxWidth: constraintBox.maxWidth * 0.8,
                child: Container(
                  child: Text(
                    widget.chat["senderName"] +
                        " " +
                        time.hour.toString().padLeft(2, "0") +
                        ":" +
                        time.minute.toString().padLeft(2, "0"),
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: Theme.of(context).primaryTextTheme.caption,
                  ),
                ),
              ),
            ),
            UnconstrainedBox(
              child: getContent(constraintBox.maxWidth),
            ),
          ],
        ),
      );
    });
  }

  Widget textContent(String text) {
    return LimitedBox(
      maxWidth: 250,
      child: Container(
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.all(Radius.circular(5))),
        padding: EdgeInsets.all(10),
        child: Text(text, style: Theme.of(context).primaryTextTheme.bodyText1),
      ),
    );
  }

  Widget gifContent(Map<dynamic, dynamic> media, double maxWidth) {
    var imageSize = mediaSize(
        (media["width"] as int).toDouble(), (media["height"] as int).toDouble(), maxWidth);

    return LimitedBox(
      maxWidth: maxWidth,
      child: Container(
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.all(Radius.circular(2))),
        padding: EdgeInsets.all(gifPadding),
        child: Image.network(
          media["url"],
          width: imageSize.item1,
          height: imageSize.item2,
        ),
      ),
    );
  }

  Tuple2<double, double> mediaSize(double _width, double _height, double maxWidth) {
    double ratio = _width / _height;

    double width = math.min(maxWidth * 0.8, _width);

    double height = (width) / ratio;

    if (width != _width) {
      // height = (width - (gifPadding * 2)) / ratio;
    }

    return Tuple2<double, double>(width, height);
  }

  Widget animatedEmojiContent(Map<dynamic, dynamic> media) {
    return LimitedBox(
      maxWidth: 100,
      maxHeight: 100,
      child: Container(
          decoration: BoxDecoration(
              color: bg,
              // borderRadius: BorderRadius.all(Radius.circular(10)),
              shape: BoxShape.circle),
          padding: EdgeInsets.all(10),
          child: Image.network(
            media["url"],
            width: (media["width"] as int).toDouble(),
            height: (media["height"] as int).toDouble(),
          )),
    );
  }

  Widget suggestionContent(Map<dynamic, dynamic> media, double maxWidth) {
    return LimitedBox(
      maxWidth: maxWidth * 0.8,
      child: Material(
        color: Theme.of(context).backgroundColor,
        child: InkWell (
          onTap: (){

          },
          child:  Container(
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.all(Radius.circular(5))),
            padding: EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Image.network(media["album"]["images"][1]["url"]),
                ),
                Expanded(
                  child: Container(
                    height: 100,
                    margin: EdgeInsets.only(left: 2,right: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          media["name"] + " by " + media["artists"][0]["name"],
                          style: Theme.of(context).primaryTextTheme.bodyText1,
                        ),
                        Text("Suggested by " + widget.chat["senderName"],
                            style: Theme.of(context).primaryTextTheme.caption)
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),

    ),);
  }

  Widget getContent(double maxWidth) {
    Widget w;

    switch (widget.chat["contentType"]) {
      case ChatItemType.TEXT_CHAT:
        w = textContent(widget.chat["content"]);
        break;
      case ChatItemType.GIF:
        w = gifContent(widget.chat["content"], maxWidth);
        break;
      case ChatItemType.EMOJI:
        w = animatedEmojiContent(widget.chat["content"]);
        break;
      case ChatItemType.SUGGESTION:
        w = suggestionContent(widget.chat["content"], maxWidth);
        break;
    }

    return w;
  }
}
