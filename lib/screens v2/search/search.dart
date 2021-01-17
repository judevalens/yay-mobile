import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yay/controllers/App.dart';
import 'package:yay/controllers/LibraryController.dart';
import 'package:yay/screens%20v2/profile/user_profile.dart';

import 'find.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
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
        stream: App
            .getInstance()
            .browserController
            .newSearchResult
            .stream,
        builder: (context, AsyncSnapshot<CompositeSearchResult> searchResult) {
          Widget w;

          if (searchResult.hasData) {
            var compositeResult = searchResult.data;

            List<Widget> items = List.empty(growable: true);

            compositeResult.solvedCategories.forEach((category) {
              switch (category.type) {
                case "song":
                  items.add(Text(
                    "Songs",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                  ));

                  var songResult = App
                      .getInstance()
                      .browserController
                      .songSearchResult;

                  items.add(Divider());

                  for (int i = 0; i < category.wantedLength; i++) {
                    items.add(SearchResponseItem(songResult[i], searchFocus, category.type));
                  }

                  if (category.length > category.wantedLength) {
                    items.add(FlatButton(onPressed: null, child: Text("See all result")));
                  }
                  break;
                case "artist":
                  items.add(Text(
                    "Artists",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                  ));

                  var artistResult = App
                      .getInstance()
                      .browserController
                      .artistSearchResult;

                  items.add(Divider());

                  for (int i = 0; i < category.wantedLength; i++) {
                    items.add(SearchResponseItem(artistResult[i], searchFocus, category.type));
                  }

                  if (category.length > category.wantedLength) {
                    items.add(FlatButton(onPressed: null, child: Text("See all result")));
                  }
                  break;
                case "user":
                  items.add(Text(
                    "Users",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                  ));

                  var userResult = App
                      .getInstance()
                      .browserController
                      .userSearchResult;

                  items.add(Divider());

                  for (int i = 0; i < category.wantedLength; i++) {
                    items.add(SearchResponseItem(userResult[i], searchFocus, category.type));
                  }

                  if (category.length > category.wantedLength) {
                    items.add(FlatButton(onPressed: null, child: Text("See all result")));
                  }
                  break;
              }
            });

            return ListView(
              key: UniqueKey(),
              addAutomaticKeepAlives: false,
              physics: BouncingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.only(bottom: MediaQuery
                  .of(context)
                  .viewInsets
                  .bottom + 5),
              children: items,
            );
          }
          return Text("No result");
        });
  }


}

