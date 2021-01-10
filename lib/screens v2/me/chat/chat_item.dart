import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:tuple/tuple.dart';
import 'package:yay/controllers/chat_controller.dart';

class ChatItem extends StatefulWidget {
  final Map<String, dynamic> chat;
  final ScrollController scrollController;

  const ChatItem({Key key, this.chat, this.scrollController}) : super(key: key);

  @override
  _ChatItemState createState() => _ChatItemState();
}

class _ChatItemState extends State<ChatItem> {
  Color bg;
  double gifPadding = 4;
  double maxHeight = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bg = Colors.black12;
    maxHeight = MediaQuery.of(context).size.height * 0.8;

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
                maxHeight: MediaQuery.of(context).size.height * 0.5,
                child: Container(
                  child: Text(
                    widget.chat["senderName"] +
                        " " +
                        time.hour.toString().padLeft(2, "0") +
                        ":" +
                        time.minute.toString().padLeft(2, "0"),
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: Theme.of(context).primaryTextTheme.bodyText2,
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
      maxHeight: maxHeight,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.all(20),
        child: Text(text, style: TextStyle(fontSize: 15, color: Colors.black87)),
      ),
    );
  }

  Widget gifContent(Map<dynamic, dynamic> media, double maxWidth) {
    var imageSize = mediaSize(
        (media["width"] as int).toDouble(), (media["height"] as int).toDouble(), maxWidth);

    return LimitedBox(
      maxWidth: maxWidth,
      maxHeight: maxHeight,
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
      maxHeight: maxHeight,
      child: Material(
        color: Theme.of(context).backgroundColor,
        child: InkWell(
          onTap: () {},
          child: Container(
            decoration:
                BoxDecoration(color: bg, borderRadius: BorderRadius.all(Radius.circular(5))),
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
      case MsgType.TEXT_CHAT:
        w = textContent(widget.chat["content"]);
        break;
      case MsgType.GIF:
        w = gifContent(widget.chat["content"], maxWidth);
        break;
      case MsgType.EMOJI:
        w = animatedEmojiContent(widget.chat["content"]);
        break;
      case MsgType.SUGGESTION:
        w = suggestionContent(widget.chat["content"], maxWidth);
        break;
    }

    return w;
  }
}
