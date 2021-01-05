import 'package:flutter/material.dart';

class Playlist extends StatefulWidget {
  @override
  _PlaylistState createState() => _PlaylistState();
}

class _PlaylistState extends State<Playlist> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          searchBar()
        ],
      ),
    );
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
                  hintText: "Search for a artist, friend... ",
                ),
                onChanged: (text) {
                 // App.getInstance().browserController.search(text);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

}
