import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:yay/controllers/App.dart';
import 'package:yay/controllers/Authorization.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return LoginScreenState();
  }
}

class LoginScreenState extends State<LoginScreen> {
  int currentIndex = 1;
  int twitterCurrentIndex = 0;
  String statusMessage = "";
  bool displayLoader = true;
  PageController _pageController = PageController();
  WebViewController _webViewController;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [spotifyLogin(), twitterLogin()],
      ),
    );
  }

  Widget twitterLogin() {
    return IndexedStack(
      index: twitterCurrentIndex,
      children: [
        twitterLoginButton(),
        twitterLoginWebview(),
      ],
    );
  }

  Widget twitterLoginButton() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      color: Color(0xff1DA1F2),
      child: FractionallySizedBox(
        heightFactor: 0.1,
        widthFactor: 0.8,
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(90),
          ),
          alignment: Alignment.center,
          child: SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: RaisedButton(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(90),
              ),
              onPressed: () {
                App.getInstance().authorization.twitterGetRequestToken().then((response) {
                  if (response["action"] == "sendToTwitter") {
                    setState(() {
                      _webViewController.loadUrl(response["url"]);
                      twitterCurrentIndex = 1;
                    });
                  }
                });

                //Navigator.popAndPushNamed(context, "/home",);
              },
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                Image.asset(
                  "assets/Twitter_Logo_Blue.png",
                  width: 50,
                  height: 50,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "Sign In with Twitter",
                  style: TextStyle(color: Color(0xff1DA1F2)),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget twitterLoginWebview() {
    return Container(
      child: WebView(
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (webViewController) {
          _webViewController = webViewController;
        },
        onPageStarted: (url) {
          Uri uri = Uri.parse(url);
          var callBackUri= Uri.parse(Authorization.TwitterAuthenticationCallbackUrl);
          if (uri.path == callBackUri.path){
            setState(() {
              twitterCurrentIndex = 0;
            });
            print("Path " + uri.path + " : " + callBackUri.path);

            App.getInstance().authorization.twitterAccessToken(url).then((isTwitterAuthSuccessful) {

              if(isTwitterAuthSuccessful){
                App.getInstance().authorization.hardLogin().then((isLoginSuccessful)  {

                  if (isLoginSuccessful){
                    Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
                  }
                  print("login was successful");

                });
              }else{
                // TODO must handle unSuccessful twitter authentication
              }

            });



          }

        },
      ),
    );
  }

  Widget spotifyLogin() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      child: FractionallySizedBox(
        heightFactor: 0.1,
        widthFactor: 0.8,
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Color(0xff1DB954),
            borderRadius: BorderRadius.circular(90),
          ),
          alignment: Alignment.center,
          child: SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: RaisedButton(
              color: Color(0xff1DB954),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(90),
              ),
              onPressed: () {
                App.getInstance().authorization.spotifyHardLogin().then((isSuccessful) {

                  // if the spotify authentication process was successful we move to twitter
                  if (isSuccessful){
                    _pageController.animateToPage(1,
                        duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
                  }else{
                    //TODO must handle unsuccessful spotify authentication
                  }


                });
                //Navigator.popAndPushNamed(context, "/home",);
              },
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                Image.asset(
                  "assets/Spotify_Icon_RGB_White.png",
                  width: 50,
                  height: 50,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "Login with Spotify",
                  style: TextStyle(color: Colors.white),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
