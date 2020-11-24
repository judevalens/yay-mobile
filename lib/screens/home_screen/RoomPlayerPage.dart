import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:yay/controllers/App.dart';
import 'package:yay/misc/marquee/marquee.dart';
import 'package:yay/screens/room_screen/Room.dart';

import '../player/Player.dart';

typedef void PageSwitcher(int i);

class PlayerRoom extends StatefulWidget {
  @override
  _PlayerRoomState createState() => _PlayerRoomState();
}

class _PlayerRoomState extends State<PlayerRoom> {
  PageController _pageController = new PageController(keepPage: false);

  void goToPage(int i) {
    _pageController.animateToPage(i, duration: Duration(milliseconds: 500), curve: Curves.easeIn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        scrollDirection: Axis.vertical,
        children: [
          ChangeNotifierProvider.value(
            value: App.getInstance().playBackController.currentPlayBackState,
            child: PlayerPage(
              pageSwitcher: goToPage,
            ),
          ),
          Container(
            height: double.infinity,
            color: Theme.of(context).backgroundColor,
            child: MyRoom(
              key: ValueKey("room"),
              pageSwitcher: goToPage,
              roomController: App.getInstance().roomController,
            ),
          ),
        ],
      ),
    );
  }
}