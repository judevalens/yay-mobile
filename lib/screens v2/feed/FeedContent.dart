import 'package:flutter/material.dart';

class FeedContent extends StatefulWidget {
  final Map<String,dynamic> itemData;

  const FeedContent({Key key, this.itemData}) : super(key: key);
  @override
  _FeedContentState createState() => _FeedContentState();
}

class _FeedContentState extends State<FeedContent> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
