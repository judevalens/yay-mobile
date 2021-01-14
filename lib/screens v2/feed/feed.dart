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
double statusBarHeight;

class _FeedState extends State<Feed> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    App.getInstance().feedController.classicFetch(0);
  }

  @override
  Widget build(BuildContext context) {
    statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      color: Colors.white,
      child: feedBody(context),
    );
  }

  Widget sliverAppBar(BuildContext context) {
    return SliverAppBar(
      title: Container(
        child: Text("Feed"),
        ),
      leading: null,
      pinned: true,
      automaticallyImplyLeading: true,
      floating: true,
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
          if (snapshot.hasData) {
            if (data.length == 0) {
              return emptyListMessage();
            }

            return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
              Widget w;

              var itemIndex = index ~/ 2;

              if (index == data.length) {
                w = Container(
                  alignment: Alignment.center,
                      margin: EdgeInsets.only(bottom: 5,top: 5),
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
                  }else if (index.isEven){
                    w = FeedContent(key: ValueKey(data[itemIndex]["id_str"]),itemData: data[itemIndex],itemIndex: itemIndex,);
                  }else{
                    w = Divider(height: 0,);
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
            child: CircularProgressIndicator(
              backgroundColor: Theme.of(context).primaryColor,
            )),
      ),
    );
  }

  Widget emptyListMessage() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Container(
          height: double.infinity, alignment: Alignment.center, child: Text("No Content to show")),
    );
  }

  Widget feedBody(BuildContext context) {
    _controller.addListener(() {});
    return CustomScrollView(
      controller: _controller,
      slivers: [sliverAppBar(context), feedSliverList()],
    );
  }
}
