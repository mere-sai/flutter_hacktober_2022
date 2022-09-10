import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ScrollController _controller = ScrollController();
  String? userReply;
  StreamController chatController = StreamController();
  List<String> replies=[];

  Future<String> getChatbotReply(String userReply) async {
    var response = await http.get(Uri.parse("http://api.brainshop.ai/get?bid=166897&key=c5R1lM3QRvsNJ4Ah&uid=Kunalpal215&msg=${userReply}"));
    var data = jsonDecode(response.body);
    return data["cnt"];
  }

  Widget messageTileMaker(String message,String sender,var screenWidth){
    return Row(
      mainAxisAlignment: sender=="user" ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.all(8),
          padding: EdgeInsets.symmetric(vertical: 6,horizontal: 5),
          color: Colors.white,
          child: Column(
            //mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Visibility(
                visible: sender=="user" ? false : true,
                child: Container(
                  margin: EdgeInsets.only(bottom: 3),
                  child: Text("Bot", maxLines: 1, overflow: TextOverflow.ellipsis,style: TextStyle(color: Colors.blue,fontSize: screenWidth*0.04,fontWeight: FontWeight.w900),),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 0.7*screenWidth),
                child: Text(message,style: TextStyle(fontWeight: FontWeight.w500,fontSize: screenWidth*0.037),),
              )
            ],
          ),
        ),
      ],);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xffECE5DD),
        appBar: AppBar(
          title: Text("Chat Bot"),
        ),
        body: StreamBuilder(
            stream: chatController.stream,
            builder: (context, AsyncSnapshot snapshot){
              if(snapshot.hasData){
                replies=snapshot.data!;
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ListView.builder(
                        itemCount: replies.length,
                        itemBuilder: (context, index){
                          return messageTileMaker(replies[index], index%2==0 ? "user" : "bot", screenWidth);
                        }
                    ),
                  ),
                  Container(
                    width: screenWidth,
                    margin: EdgeInsets.all(5),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            color: Colors.white,
                            margin: EdgeInsets.only(right: 6),
                            padding: EdgeInsets.only(left: 8),
                            child: TextField(
                              onChanged: (value){
                                userReply=value;
                              },
                              style: TextStyle(
                                fontSize: screenWidth*0.043,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Type a message",
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            if(userReply!=null && userReply!=""){
                              replies.add(userReply!);
                              chatController.sink.add(replies);
                              var generatedReply = await getChatbotReply(userReply!);
                              replies.add(generatedReply);
                              chatController.sink.add(replies);
                            }
                          },
                          child: Container(
                            width: screenWidth*0.14,
                            height: screenWidth*0.14,
                            margin: EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              color: Color(0xff128C7E),
                              borderRadius: BorderRadius.circular(screenWidth*0.07),
                            ),
                            alignment: Alignment.center,
                            child: Icon(Icons.send_rounded,color: Colors.white,size: screenWidth*0.07,),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              );
              return Stack(
                children: [
                  Center(child: Text("Start chatting with me :)"),),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Row(
                      children: [
                        Container(
                          width: 100,
                          margin: EdgeInsets.symmetric(horizontal: 16),
                          child: TextFormField(
                            onChanged: (value){
                              userReply=value;
                            },
                          ),
                        ),
                        ElevatedButton(
                            onPressed: () async {
                              if(userReply!=null && userReply!=""){
                                replies.add(userReply!);
                                var generatedReply = await getChatbotReply(userReply!);
                                replies.add(generatedReply);
                                chatController.sink.add(replies);
                              }
                            },
                            child: Text("Send")
                        )
                      ],
                    ),
                  )
                ],
              );
            },
          ),
        )
    );
  }
}
