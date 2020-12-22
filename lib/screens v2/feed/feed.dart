import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yay/controllers/App.dart';
import 'package:yay/screens%20v2/feed/FeedContent.dart';

class Feed extends StatefulWidget {
  @override
  _FeedState createState() => _FeedState();
}

ScrollController _controller = new ScrollController();
List<Map<String, dynamic>> data;

class _FeedState extends State<Feed> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    App.getInstance().feedController.classicFetch(0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: feedBody(context),
    );
  }



  Widget sliverAppBar(BuildContext context) {
    return SliverAppBar(
      title: Text("YAY"),
      leading: null,
      pinned: true,
      automaticallyImplyLeading: false,
      floating: true,
      flexibleSpace: Container(
        child: Text("Feed",style: Theme.of(context).accentTextTheme.headline2,),
      ),
      expandedHeight: 200,
    );
  }

  Widget feedSliverList() {
    return StreamBuilder(
        stream: App
            .getInstance()
            .feedController
            .feedStream
            .getStream(),
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          data = snapshot.data;
          print("sliver list");
          if (snapshot.hasData) {
            return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  Widget w;

                  print("index is " + index.toString() + "length " + data.length.toString());

                  if (index == data.length) {
                    w = Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(bottom: 5),
                      child: SizedBox(
                          height: 50,
                          width: 50,
                          child: CircularProgressIndicator(backgroundColor: Theme
                              .of(context)
                              .primaryColor,)
                      ),
                    );
                    App
                        .getInstance()
                        .feedController
                        .classicFetch(1);
                  }else{
                    print("myssksk " + data[index].toString());
                    w = FeedContent(key: ValueKey(data[index]["id_str"]),itemData: data[index],);
                  }
                  return w;
                }, childCount: data.length + 1)
            );
          } else {
            return emptyListLoader();
          }
        });
  }

  Widget emptyListLoader() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Container(
        height: double.infinity,
        alignment: Alignment.center,
        child: SizedBox(
            height: 50,
            width: 50,
            child: CircularProgressIndicator(backgroundColor: Theme
                .of(context)
                .primaryColor,)
        ),
      ),
    );
  }

  Widget feedBody(BuildContext context) {
    _controller.addListener(() {
      print("viewport " + _controller.position.viewportDimension.toString());
      print("scrolling, position :" +
          _controller.position.pixels.toString() +
          " atEdge : " +
          _controller.position.atEdge.toString());
    });
    return CustomScrollView(
      controller: _controller,
      slivers: [sliverAppBar(context), feedSliverList()],
    );
  }



}
