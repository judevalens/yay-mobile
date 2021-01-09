import 'package:flutter/material.dart';
import 'package:yay/controllers/App.dart';
import 'package:yay/model/user_model.dart';

class ProfileHeader extends StatefulWidget {
  final String profilePictureUrl;
  final String userName;
  final String description;
  final UserModel user;

  const ProfileHeader({Key key, this.profilePictureUrl, this.userName, this.description, this.user})
      : super(key: key);

  @override
  _ProfileHeaderState createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: Theme.of(context).colorScheme.secondary),
            ),
            child: ClipOval(
              child: widget.profilePictureUrl != null
                  ? Image.network(
                      widget.profilePictureUrl,
                      fit: BoxFit.fill,
                    )
                  : Placeholder(),
            ),
          ),
          Container(
            child: Text(
              widget.userName,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            child: Text(
              widget.description,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
            ),
          ),
          Container(
            width: double.infinity,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ImageIcon(
                  AssetImage("assets/spotify_logo_green.png"),
                  size: 35,
                ),
                ImageIcon(
                  AssetImage("assets/Twitter_Logo_Blue.png"),
                  size: 50,
                ),
                if (widget.user.userID != widget.user.currentUSerID)
                  isFollowing(),
              ],
            ),
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.music_note_sharp),
                Text("Listening to : I Just know by Bugus"),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget userHeader() {
    List<Widget> wList = List.empty(growable: true);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: Theme.of(context).colorScheme.secondary),
          ),
          child: ClipOval(
            child: widget.profilePictureUrl != null
                ? Image.network(
                    widget.profilePictureUrl,
                    fit: BoxFit.fill,
                  )
                : Placeholder(),
          ),
        ),
        Container(
          child: Text(
            widget.userName,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          child: Text(
            widget.description,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
          ),
        ),
        Container(
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ImageIcon(
                AssetImage("assets/spotify_logo_green.png"),
                size: 35,
              ),
              ImageIcon(
                AssetImage("assets/Twitter_Logo_Blue.png"),
                size: 50,
              ),
              Container(
                child: RaisedButton(
                  color: Theme.of(context).colorScheme.secondaryVariant,
                  disabledColor: Theme.of(context).colorScheme.secondaryVariant,
                  textColor: Theme.of(context).colorScheme.primary,
                  onPressed: () {},
                  child: Text("Following"),
                ),
              ),
            ],
          ),
        ),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.music_note_sharp),
              Text("Listening to : I Just know by Bugus"),
            ],
          ),
        )
      ],
    );
  }

  Widget isFollowing() {
    return StreamBuilder(
        stream: widget.user.isFollowingCurrentUserStream.getStream(),
        builder: (context, AsyncSnapshot<bool> snapShot) {
          if (snapShot.hasData) {
            var isFollowing = snapShot.data;
            if (isFollowing) {
              return followedButton();
            } else {
              return followButton();
            }
          }
          return followButtonLoader();
        });
  }

  Widget followedButton() {
    return Container(
      child: RaisedButton(
        color: Theme.of(context).colorScheme.secondaryVariant,
        disabledColor: Theme.of(context).colorScheme.secondaryVariant,
        textColor: Theme.of(context).colorScheme.primary,
        onPressed: null,
        child: Text("Following",style: TextStyle(color: Colors.white),),
      ),
    );
  }

  Widget followButton() {
    return Container(
      child: RaisedButton(
        color: Theme.of(context).colorScheme.secondaryVariant,
        disabledColor: Theme.of(context).colorScheme.secondaryVariant,
        textColor: Theme.of(context).colorScheme.primary,
        onPressed: () {
          App.getInstance().userProfileController.followUser(widget.user.currentUSerID, widget.user.userID);
        },
        child: Text("Follow"),
      ),
    );
  }

  Widget followButtonLoader() {
    return Container(
      child: RaisedButton(
        color: Theme.of(context).colorScheme.secondaryVariant,
        disabledColor: Theme.of(context).colorScheme.secondaryVariant,
        textColor: Theme.of(context).colorScheme.primary,
        onPressed: null,
        child: CircularProgressIndicator(),
      ),
    );
  }
}
