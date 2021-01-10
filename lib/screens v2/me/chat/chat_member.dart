import 'package:flutter/material.dart';
import 'package:yay/controllers/App.dart';
import 'package:yay/model/chat_model.dart';
import 'package:yay/model/user_model.dart';
import 'package:yay/screens%20v2/profile/user_profile.dart';

typedef SelectMember(String memberId, bool add);

class ChatMember extends StatefulWidget {
  final ChatModel chatModel;

  const ChatMember({Key key, this.chatModel}) : super(key: key);

  @override
  ChatMemberState createState() => ChatMemberState();
}

class ChatMemberState extends State<ChatMember> {
  List<String> selectedMembers = List.empty(growable: true);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> selectedMember = Map();
    return Scaffold(
      appBar: AppBar(
        title: Text("Members"),
      ),
      body: Container(
        child: StreamBuilder(
            stream: widget.chatModel.chatMemberStreamController.getStream(),
            builder: (BuildContext context, AsyncSnapshot<Map<String, UserModel>> snapshot) {
              if (snapshot.hasData) {
                var memberIDs = snapshot.data.keys.toList();

                return ListView.builder(
                  itemCount: memberIDs.length,
                  itemBuilder: (context, index) {
                    return ChatMemberItem(
                      user: snapshot.data[memberIDs[index]],
                      isInChat: true,
                    );
                  },
                );
              } else {
                return loadingList();
              }
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showNonChatMember(context);
        },
        child: Icon(Icons.group_add_outlined),
      ),
    );
  }

  showNonChatMember(BuildContext context) {
    var nonChatMemberIDs = widget.chatModel.nonChatMember.keys.toList();

    showDialog(
        context: context,
        builder: (context) {
          return Container(
            child: FractionallySizedBox(
              heightFactor: 0.7,
              widthFactor: 0.9,
              child: Card(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Add Members",
                        style: TextStyle(fontSize: 25, fontWeight: FontWeight.w400),
                      ),
                      Divider(
                        thickness: 2,
                      ),
                      if (nonChatMemberIDs.length > 0)
                        Expanded(
                          child: ListView.separated(
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (BuildContext context, index) {
                              return ChatMemberItem(
                                user: widget.chatModel.nonChatMember[nonChatMemberIDs[index]],
                                selectMember: this.addMember,
                                isInChat: false,
                              );
                            },
                            itemCount: nonChatMemberIDs.length,
                            separatorBuilder: (BuildContext context, int index) {
                              return Divider();
                            },
                          ),
                        ),
                      if (nonChatMemberIDs.length <= 0)
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            child: Text("All your friends are already in this group chat :)"),
                          ),
                        ),
                      Container(
                        width: double.infinity,
                        child: RaisedButton(
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                          color: Theme.of(context).colorScheme.secondary,
                          onPressed: () {
                            widget.chatModel.addMembers(selectedMembers);
                            Navigator.of(context).pop();
                            selectedMembers.clear();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  Widget loadingList() {
    return Container(
      alignment: Alignment.center,
      child: CircularProgressIndicator(),
    );
  }

  addMember(String memberID, bool add) {
    if (add) {
      if (!selectedMembers.contains(memberID)) {
        selectedMembers.add(memberID);
      }
    } else {
      selectedMembers.remove(memberID);
    }
  }
}

class ChatMemberItem extends StatefulWidget {
  final UserModel user;
  final SelectMember selectMember;
  final bool isInChat;

  const ChatMemberItem({Key key, this.user, this.selectMember, this.isInChat}) : super(key: key);

  @override
  _ChatMemberItemState createState() => _ChatMemberItemState();
}

class _ChatMemberItemState extends State<ChatMemberItem> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    if (widget.isInChat) {
      return chatMember();
    } else {
      return nonChatMember();
    }
  }

  Widget chatMember() {
    var profilePictureUrl = widget.user.userProfile["basic"]["profile_picture"];
    profilePictureUrl = profilePictureUrl.length == 0 ? null : profilePictureUrl;
    return ListTile(
        selected: isChecked,
        selectedTileColor: Theme.of(context).colorScheme.secondary,
        title: GestureDetector(
          onTap: () {
            print("tapped artist");
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return UserProfile(
                userID: widget.user.userID,
              );
            }));
          },
          child: Container(
            child: Row(
              children: [
                Container(
                  margin: EdgeInsets.only(right: 5),
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
                  child: ClipOval(
                    child: profilePictureUrl != null
                        ? Image.network(
                            profilePictureUrl,
                            fit: BoxFit.fill,
                          )
                        : Container(
                            child: Icon(
                              Icons.account_circle,
                              size: 60,
                            ),
                          ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: 2),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        //TODO clean this up. this work should be done in the userModel!!!!
                        widget.user.userProfile["basic"]["spotify_user_name"],
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
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
        color: Theme.of(context).colorScheme.secondary,
        disabledColor: Theme.of(context).colorScheme.secondary,
        textColor: Theme.of(context).colorScheme.primary,
        onPressed: null,
        child: Text(
          "Following",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget followButton() {
    return Container(
      child: RaisedButton(
        color: Theme.of(context).colorScheme.secondary,
        disabledColor: Theme.of(context).colorScheme.secondary,
        textColor: Theme.of(context).colorScheme.primary,
        onPressed: () {
          App.getInstance()
              .userProfileController
              .followUser(widget.user.currentUSerID, widget.user.userID);
        },
        child: Text("Follow"),
      ),
    );
  }

  Widget followButtonLoader() {
    return Container(
      child: RaisedButton(
        color: Theme.of(context).colorScheme.secondary,
        disabledColor: Theme.of(context).colorScheme.secondary,
        textColor: Theme.of(context).colorScheme.primary,
        onPressed: null,
        child: LinearProgressIndicator(),
      ),
    );
  }

  Widget nonChatMember() {
    var profilePictureUrl = widget.user.userProfile["basic"]["profile_picture"];
    profilePictureUrl = profilePictureUrl.length == 0 ? null : profilePictureUrl;
    return ListTile(
      selected: isChecked,
      selectedTileColor: Theme.of(context).colorScheme.secondary,
      title: GestureDetector(
        onTap: () {
          print("tapped artist");
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return UserProfile(
              userID: widget.user.userID,
            );
          }));
        },
        child: Container(
          child: Row(
            children: [
              Container(
                margin: EdgeInsets.only(right: 5),
                height: 60,
                width: 60,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
                child: ClipOval(
                  child: profilePictureUrl != null
                      ? Image.network(
                          profilePictureUrl,
                          fit: BoxFit.fill,
                        )
                      : Container(
                          child: Icon(
                            Icons.account_circle,
                            size: 60,
                          ),
                        ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 2),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      //TODO clean this up. this work should be done in the userModel!!!!
                      widget.user.userProfile["basic"]["spotify_user_name"],
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      trailing: Checkbox(
        value: isChecked,
        onChanged: (bool value) {
          setState(() {
            widget.selectMember(widget.user.userID, value);
            isChecked = value;
          });
        },
      ),
    );
  }
}
