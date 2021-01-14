import 'package:flutter/material.dart';
import 'package:yay/controllers/App.dart';
import 'package:yay/controllers/chat_controller.dart';
import 'package:yay/model/chat_model.dart';

import 'chat.dart';

class ChatList extends StatefulWidget {
  final ChatController chatController;

  const ChatList({Key key, this.chatController}) : super(key: key);
  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  @override
  Widget build(BuildContext context) {
    return chatList();
  }

  Map<String, Chat> chats = Map();

  Widget chatList() {
    return Scaffold(
      body: Container(
          child: StreamBuilder(
            stream: App.getInstance().roomController.chatsStreamController.getStream(),
        builder: (context, AsyncSnapshot<Map<String, ChatModel>> snapshot) {
          if (snapshot.hasData) {
            var chatValue = snapshot.data;
            var chatID = App.getInstance().roomController.sortedChats;

            return ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: chatID.length,
              itemBuilder: (context, itemIndex) {
                print("chat data 2");
                print(chatValue[chatID[(chatID.length-1)-itemIndex]]);
                    return chatItem(chatValue[chatID[itemIndex]]);
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider();
                  },
                );
              }
              return emptyList();
            },
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addRoomModalSheet(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget chatItem(ChatModel chatModel) {
    var profileUrl;

    return StreamBuilder(
        stream: chatModel.chatDataStreamController.getStream(),
        builder: (context, AsyncSnapshot<Map<String, dynamic>> chatDataSnapShot) {
          if (chatDataSnapShot.hasData){
            var chatData  = chatDataSnapShot.data;
            return InkWell(
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context){
                  return getChat(
                    chatModel,
                    widget.chatController,
                  );
                }));
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: 5),
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Theme.of(context).colorScheme.secondary)),
                      child: ClipOval(
                        child: profileUrl != null
                            ? Image.network(
                          profileUrl,
                          fit: BoxFit.fill,
                        )
                            : Placeholder(),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chatData["chat_name"],
                          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w400),
                        ),
                        Text("created Jude Valens"),
                      ],
                    ),
                    if (chatModel.hasUnreadMessages())
                      Expanded(
                          child: Container(
                        child: Icon(
                          Icons.mark_chat_unread_rounded,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        alignment: Alignment.centerRight,
                      ))
                  ],
                ),
              ),
            );
          }else{
            return Container(
              child: Text("loading"),
            );
          }
        });
  }

  Widget emptyList() {
    return Container(
      child: Text("EMPTY!!"),
    );
  }

  Widget getChat(ChatModel chatModel, ChatController chatController) {
    if (chats.containsKey(chatModel.chatID)) {
      return chats[chatModel.chatID];
    }
    chats[chatModel.chatID] = Chat(
      chatModel: chatModel,
      chatController: chatController,
      key: ValueKey(chatModel.chatID),
    );
    return chats[chatModel.chatID];
  }

  Future<void> addRoomModalSheet(BuildContext context) {
    String joinCode = "";
    String roomName = "";
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          widthFactor: 0.5,
          child: Container(
            alignment: Alignment.center,
            height: double.infinity,
            width: double.infinity,
            padding: MediaQuery.of(context).viewInsets,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Add/Join a room",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondaryVariant, fontSize: 20)),
                Divider(
                  thickness: 2,
                ),
                TextField(
                  style: TextStyle(fontSize: 15, color: Colors.black),
                  decoration: InputDecoration(
                    labelText: "Enter Join Code",
                    labelStyle: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                  onChanged: (code) {
                    joinCode = code;
                  },
                ),
                Container(
                    width: double.infinity,
                    child: RaisedButton(
                      onPressed: () {
                        //    App.getInstance().roomController.joinGroupChat(joinCode);
                      },
                      child: Text("Join room"),
                    )),
                Divider(
                  thickness: 2,
                ),
                TextField(
                  style: TextStyle(fontSize: 15, color: Colors.black),
                  decoration: InputDecoration(
                      labelText: "Enter a name",
                      labelStyle: TextStyle(fontSize: 15, color: Colors.grey)),
                  onChanged: (name) {
                    roomName = name;
                  },
                ),
                Container(
                  width: double.infinity,
                  child: RaisedButton(
                    onPressed: () {
                      App.getInstance().roomController.createGroupChat(roomName);
                    },
                    child: Text("Create room"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
