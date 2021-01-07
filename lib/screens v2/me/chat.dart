import 'package:flutter/material.dart';
import 'package:yay/controllers/ChatController.dart';
import 'package:yay/model/chat_model.dart';

import 'chat_item.dart';

class Chat extends StatefulWidget {
  final ChatModel chatModel;
  final ChatController chatController;

  const Chat({Key key, this.chatModel, this.chatController}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  ScrollController scrollController = ScrollController();
  FocusNode _focusNode = FocusNode();
  TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.chatModel.loadChatContent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Container(
        padding: MediaQuery.of(context).padding,
        child: Column(
          children: [
            Expanded(
              child: chatList(),
            ),
            bar(context),
          ],
        ),
      ),
    );
  }

  Widget chatList() {
    return Container(
      child: StreamBuilder(
          stream: widget.chatModel.chatMessageStreamController.getStream(),
          builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> chatData) {
            if (chatData.hasData) {
              var msg = chatData.data;
              var msgIDs = chatData.data.keys.toList();
              print("chat data hashcode  " + context.owner.toString());
              if (msgIDs.length == 0) {
                return emptyList();
              } else {
                return ListView.builder(
                    //   controller: _scrollController,
                    padding: EdgeInsets.only(left: 5, right: 5),
                    physics: ClampingScrollPhysics(),
                    itemCount: msgIDs.length,
                    itemBuilder: (context, index) {
                      return ChatItem(
                        chat: msg[msgIDs[index]],
                        key: ValueKey(msg[msgIDs[index]]["chatID"]),
                        scrollController: scrollController,
                      );
                    });
              }
            } else {
              return emptyList();
            }

            /* if (App.getInstance().roomController.chatController.messageStreamController.brandNew){
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.decelerate,
                  );
                });
                App.getInstance().roomController.chatController.messageStreamController.brandNew = false;
              }*/
          }),
    );
  }

  Widget bar(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      padding: EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              cursorColor: Colors.black,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                filled: true,
                hintText: "Say something...",
                hintStyle: TextStyle(fontSize: 15),
              ),
              focusNode: _focusNode,
              maxLines: 2,
              style: TextStyle(fontSize: 15),
              minLines: 1,
              autofocus: false,
              textInputAction: TextInputAction.send,
              controller: _textEditingController,
              onSubmitted: (text) {
                print("sending chat " + text);
                _textEditingController.clear();
                widget.chatController.sendContent(
                    widget.chatModel.chatID, text, ChatItemType(ChatItemType.TEXT_CHAT));
                _focusNode.requestFocus();
              },
            ),
          ),
          Container(
            child: IconButton(
              color: Theme.of(context).accentColor,
              onPressed: () {},
              icon: Icon(Icons.gif),
            ),
          ),
          Container(
            child: IconButton(
              color: Theme.of(context).accentColor,
              onPressed: () {
                _focusNode.unfocus();
                widget.chatController.channel.invokeListMethod("showGiphyPad");
              },
              icon: Icon(Icons.emoji_emotions_sharp),
            ),
          ),
        ],
      ),
    );
  }

  Widget emptyList() {
    return Container(
      child: Text("Chat is empty!!"),
    );
  }

  Widget loadList() {
    return Container(
      alignment: Alignment.center,
      child: CircularProgressIndicator(),
    );
  }
}
