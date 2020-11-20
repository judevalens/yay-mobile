import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yay/controllers/App.dart';

class SearchBottomSheet extends StatefulWidget {
  final double statusBArHeight;

  SearchBottomSheet(this.statusBArHeight);

  @override
  _SearchBottomSheetState createState() => _SearchBottomSheetState();
}

class _SearchBottomSheetState extends State<SearchBottomSheet> {
  FocusNode searchFocus;
  ScrollController scrollController;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    searchFocus = new FocusNode(canRequestFocus: false);
    scrollController = new ScrollController();
    scrollController.addListener(() {
      print("scrolling");
     searchFocus.unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      height: MediaQuery.of(context).size.height -
          AppBar().preferredSize.height -
          widget.statusBArHeight,
      padding: EdgeInsets.only(left: 10,right: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(icon: Icon(Icons.keyboard_arrow_down_rounded), onPressed: null),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Search",
                  style: Theme.of(context).accentTextTheme.headline4,
                ),
              ),
            ],
          ),
          Divider(),
          searchBar(),
          Divider(),
          Expanded(
            child: resultContainer(),
          ),
        ],
      ),
    );
  }

  Widget searchBar() {
    return Container(
      child: Row(
        children: [
          Expanded(
            child: Container(
              child: TextField(
                focusNode: searchFocus,
                onEditingComplete: () {
                  print("editing is done");
                },
                autofocus: false,
                decoration: InputDecoration(hintText: "Search for a song "),
                onChanged: (text) {
                  App.getInstance().browserController.search(text);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget resultContainer() {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: searchResultList(context),
    );
  }

  Widget searchResultList(BuildContext context) {
    return StreamBuilder(
        stream: App.getInstance().browserController.queryResponseStreamController.stream,
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> responses) {
          Widget w;

          if (responses.hasData) {
            List<Widget> responseItems = new List();

            responses.data.forEach((track) {
              responseItems.add(SearchResponseItem(track, searchFocus));
            });

            w = ListView(
              padding:
                EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              controller: scrollController,
              children: responseItems,
            );
          } else {
            w = Text("No result yet");
          }

          return w;
        });
  }

}

class SearchResponseItem extends StatefulWidget {
  final Map<String, dynamic> track;
  final FocusNode searchBarFocusNode;

  SearchResponseItem(this.track, this.searchBarFocusNode):super(key: UniqueKey());

  @override
  _SearchResponseItemState createState() => _SearchResponseItemState();
}

class _SearchResponseItemState extends State<SearchResponseItem> {
  int imagesListLength;
  String artistList;

  @override
  void initState() {
    super.initState();
    imagesListLength = widget.track["album"]["images"].length;
    artistList = "";
    int counter = 0;
    for (var value in widget.track["artists"]) {
      artistList += value["name"];

      counter++;

      if (counter < widget.track["artists"].length) {
        artistList += ", ";
      }
    }
    // TODO: implement initState
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: (){
          widget.searchBarFocusNode.unfocus();
          App.getInstance().playBackController.start(widget.track["uri"]);
        },
        child: Container(
          margin: EdgeInsets.only(top: 5, bottom: 5),

            child: Row(
              children: [
                SizedBox(
                  height: 64,
                  width: 64,
                  child: Image.network(widget.track["album"]["images"][1]["url"]),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: 2),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        widget.track["name"],
                        style: Theme.of(context).accentTextTheme.button,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        artistList,
                        style: Theme.of(context).accentTextTheme.bodyText2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ]),
                  ),
                ),
                trackMoreButton(context),
              ],
            ),
          ),
        ),
    );
  }

  Widget trackMoreButton(BuildContext context) {
    return PopupMenuButton<int>(
      // padding: MediaQuery.of(context).viewInsets,
      onCanceled: () {
        widget.searchBarFocusNode.unfocus();
        //FocusScope.of(context).unfocus();
        ///// searchFocus.unfocus();
      },
      onSelected: (value) {
        widget.searchBarFocusNode.unfocus();
        //FocusScope.of(context).unfocus();searchFocus.unfocus();
      },
      itemBuilder: (context) {
        return <PopupMenuEntry<int>>[
          const PopupMenuItem<int>(
            child: Text("Play"),
            value: 0,
          ),
          const PopupMenuItem<int>(
            child: Text("add to queue"),
            value: 0,
          ),
          const PopupMenuItem<int>(
            child: Text("Suggest to room"),
            value: 0,
          ),
          const PopupMenuItem<int>(
            child: Text("Open in spotify"),
            value: 0,
          ),
        ];
      },
      icon: Icon(Icons.more_vert_sharp),
    );
  }
}
