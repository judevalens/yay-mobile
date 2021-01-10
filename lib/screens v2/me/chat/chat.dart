import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:yay/controllers/App.dart';
import 'package:yay/controllers/chat_controller.dart';
import 'package:yay/model/chat_model.dart';
import 'package:yay/screens%20v2/me/chat/chat_member.dart';

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
        title: Text(widget.chatModel.chatData["chat_name"]),
        actions: [
          IconButton(
              icon: Icon(
                Icons.add,
              ),
              onPressed: () {
                print("member button pressed");
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return ChatMember(
                        chatModel: widget.chatModel,
                      );
                    },
                  ),
                );
              })
        ],
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
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

                  SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                    var oldPos = scrollController.position.maxScrollExtent;
                    scrollToBottom(scrollController);

                  });



                return ListView.builder(
                      reverse: true,
                      controller: scrollController,
                    physics: ClampingScrollPhysics(),
                    padding: EdgeInsets.only(left: 5, right: 5),
                    itemCount: msgIDs.length,
                    itemBuilder: (context, index) {
                      return ChatItem(
                        chat: msg[msgIDs[(msgIDs.length-1)-index]],
                        key: ValueKey(msg[msgIDs[(msgIDs.length-1)-index]]["chatID"]),
                        scrollController: scrollController,
                      );
                    });
              }
            } else {
              return emptyList();
            }


          }),
    );
  }


  void scrollToBottom(ScrollController _scrollController){
      var oldPos = scrollController.position.maxScrollExtent;
      var scroll  =  scrollController.animateTo(
        scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutSine,
      );

      scroll.then((value) {
        if (oldPos < scrollController.position.minScrollExtent){
          scrollToBottom(_scrollController);
        }
      }
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
                widget.chatModel.sendText(
                    widget.chatModel.chatID, text, MsgType(MsgType.TEXT_CHAT));
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
              widget.chatModel.showGifPad();
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

  Widget loadingList() {
    return Container(
      alignment: Alignment.center,
      child: CircularProgressIndicator(),
    );
  }
}
/*
class  extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
*/
