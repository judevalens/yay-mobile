import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yay/controllers/App.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search>  {
  FocusNode searchFocus;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.centerLeft,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            searchBar(),
            Expanded(child: resultContainer()),
          ],
        ));
  }

  Widget searchBar() {
    return Container(
      margin: EdgeInsets.only(bottom: 5, top: 5),
      child: Row(
        children: [
          Expanded(
            child: Container(
              child: TextField(
                onEditingComplete: () {
                  print("editing is done");
                },
                autofocus: false,
                cursorColor: Colors.black54,
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Search for a song ",
                ),
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
      color: Colors.white,
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
            return ListView.separated(
              key: UniqueKey(),
              addAutomaticKeepAlives: false,
              physics: BouncingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              itemBuilder: (context, index) {
                return SearchResponseItem(responses.data[index], searchFocus);
              },
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 5),
              itemCount: responses.data.length,
              separatorBuilder: (BuildContext context, int index) {
                return Divider();
              },
              // controller: scrollController,
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

  SearchResponseItem(this.track, this.searchBarFocusNode) : super(key: ValueKey(track["id"]));

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
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () {
          print("TAPPPEDD!");
          App.getInstance().playBackController.start(widget.track["uri"]);
        },
        child: Container(
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      artistList,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
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
        if (value == 2) {
          /*App.getInstance()
              .roomController
              .chatController
              .sendMedia("",widget.track, MsgType(MsgType.SUGGESTION));*/
        }
      },
      itemBuilder: (context) {
        return <PopupMenuEntry<int>>[
          const PopupMenuItem<int>(
            child: Text("Play"),
            value: 0,
          ),
          const PopupMenuItem<int>(
            child: Text("add to queue"),
            value: 1,
          ),
          const PopupMenuItem<int>(
            child: Text("Suggest to room"),
            value: 2,
          ),
          const PopupMenuItem<int>(
            child: Text("Open in spotify"),
            value: 3,
          ),
        ];
      },
      icon: Icon(Icons.more_vert_sharp),
    );
  }
}
