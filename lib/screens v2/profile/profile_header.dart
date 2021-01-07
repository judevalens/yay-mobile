import 'package:flutter/material.dart';

class ProfileHeader extends StatefulWidget {
  final String profilePictureUrl;
  final String userName;
  final String description;

  const ProfileHeader({Key key, this.profilePictureUrl, this.userName, this.description})
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
      ),
    );
  }
}
