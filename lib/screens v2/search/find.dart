import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yay/screens%20v2/search/music.dart';
import 'package:yay/screens%20v2/search/people.dart';

class Find extends StatefulWidget {
  @override
  _FindState createState() => _FindState();
}

class _FindState extends State<Find> with TickerProviderStateMixin {
  TabController _tabController;
  PageController _pageController;
  double statusBarHeight;
  MusicPage _musicPage = MusicPage();
  PeoplePage _peoplePage = PeoplePage();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    _pageController = PageController(initialPage: 0);
  }

  @override
  Widget build(BuildContext context) {
    statusBarHeight = MediaQuery.of(context).padding.top + AppBar().preferredSize.height;
    return LayoutBuilder(builder: (context, constraint) {
      return Container(
        color: Colors.white,
        child: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            sliverAppBar(context),
            SliverFillRemaining(
                fillOverscroll: false,
                hasScrollBody: false,
                child: Container(
                  height: constraint.maxHeight - (100 + AppBar().preferredSize.height),
                  child: body(),
                )),
          ],
        ),
      );
    });
  }

  Widget sliverAppBar(BuildContext context) {
    return SliverAppBar(
      title: Text(
        "YaY",
        style: TextStyle(
            fontSize: 20,
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.bold),
      ),
      leading: null,
      pinned: true,
      snap: true,
      automaticallyImplyLeading: false,
      floating: true,
      flexibleSpace: Container(
        height: double.infinity,
        alignment: Alignment.topLeft,
        color: Colors.white,
        padding: EdgeInsets.only(top: statusBarHeight, left: 16, right: 16),
        child: Container(
          child: TabBar(
            onTap: (index) {
              _pageController.animateToPage(index,
                  duration: Duration(milliseconds: 10), curve: Curves.ease);
            },
            controller: _tabController,
            tabs: [
              Tab(
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "MUSIC",
                    style: TextStyle(
                      fontSize: 30,
                    ),
                  ),
                ),
              ),
              Tab(
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "PEOPLE",
                    style: TextStyle(
                      fontSize: 30,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      expandedHeight: 100,
    );
  }

  Widget body() {
    return PageView(
      physics: NeverScrollableScrollPhysics(),
      controller: _pageController,
      onPageChanged: (index) {
        _tabController.animateTo(index);
      },
      children: [_musicPage, _peoplePage],
    );
  }
}
