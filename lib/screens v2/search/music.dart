import 'package:flutter/material.dart';
import 'package:yay/screens%20v2/search/playlist.dart';
import 'package:yay/screens%20v2/search/search.dart';

class MusicPage extends StatefulWidget {
  @override
  _MusicPageState createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> with TickerProviderStateMixin {
  TabController _controller;
  PageController _pageController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = TabController(length: 2, vsync: this);
    _pageController = PageController(initialPage: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 16, right: 16),
            child: TabBar(
              onTap: (index) {
                print("TAPPED!! " + index.toString());
                _pageController.animateToPage(index,
                    duration: Duration(milliseconds: 700), curve: Curves.ease);
              },
              controller: _controller,
              tabs: [
                Tab(
                  text: "Search",
                ),
                Tab(
                  text: "Playlist",
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              child: PageView(
                physics: BouncingScrollPhysics(),
                controller: _pageController,
                onPageChanged: (index) {
                  _controller.animateTo(index);
                },
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 16, right: 16),
                    child: Search(),
                  ),
                  Playlist()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
