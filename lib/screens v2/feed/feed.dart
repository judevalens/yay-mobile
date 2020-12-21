import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yay/controllers/App.dart';

class Feed extends StatefulWidget {
  @override
  _FeedState createState() => _FeedState();
}

ScrollController _controller = new ScrollController();
List<Map<String, dynamic>> data;

class _FeedState extends State<Feed> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: feedBody(),
    );
  }

  Widget sliverAppBar() {
    return SliverAppBar(
      title: Text("YAY"),
      leading: null,
      pinned: true,
      automaticallyImplyLeading: false,
      floating: true,
      flexibleSpace: Placeholder(),
      expandedHeight: 200,
    );
  }

  Widget feedSliverList() {
    return StreamBuilder(
      stream: App.getInstance().feedController.feedStream.getStream(),
      initialData: App.getInstance().feedController.data,
      builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        data = snapshot.data;
        return SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
          print("index before is " +
              index.toString() +
              ", start at " +
              App.getInstance().feedController.startIndex.toString() +
              " , end at " +
              App.getInstance().feedController.endIndex.toString());

          print("cyclic index is : " + (index%90).toString());

          if (index == App.getInstance().feedController.endIndex) {
            App.getInstance().feedController.fetch(1);
          } else if (index == App.getInstance().feedController.startIndex && index != 0) {
            App.getInstance().feedController.fetch(-1);
          }

          print("index " + ((App.getInstance().feedController.startIndex+index) % App.getInstance().feedController.bufferSize).toString()+ " | "+ App.getInstance().feedController.data.toString());

          return ListTile(
            title: Text("item " + data[(App.getInstance().feedController.startIndex+index) % App.getInstance().feedController.bufferSize]["time_stamp"].toString()),
          );
        },childCount:  App.getInstance().feedController.endIndex+1)
        );},
    );
  }

  Widget feedBody() {
    _controller.addListener(() {
      print("viewport " + _controller.position.viewportDimension.toString());
      print("scrolling, position :" +
          _controller.position.pixels.toString() +
          " atEdge : " +
          _controller.position.atEdge.toString());
    });
    return CustomScrollView(
      controller: _controller,
      slivers: [sliverAppBar(), feedSliverList()],
    );
  }
}
