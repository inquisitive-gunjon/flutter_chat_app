import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../api/apis.dart';
import '../../helper/my_date_util.dart';
import '../../main.dart';
import '../../models/chat_user.dart';
import '../../models/message.dart';
import '../screens/chat_screen.dart';
import 'dialogs/profile_dialog.dart';

//card to represent a single user in home screen
class AddToGroupUserCard extends StatefulWidget {
  final ChatRoom user;

  const AddToGroupUserCard({super.key, required this.user});

  @override
  State<AddToGroupUserCard> createState() => _AddToGroupUserCardState();
}

class _AddToGroupUserCardState extends State<AddToGroupUserCard> {
  //last message info (if null --> no message)
  Message? _message;
  bool isEnableAddButton=true;

  @override
  Widget build(BuildContext context) {
    return !APIs.userIdList.contains(widget.user.id)&&!widget.user.isGroup?Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: 4),
      // color: Colors.blue.shade100,
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
          onTap: () {
            //for navigating to chat screen
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //         builder: (_) => ChatScreen(user: widget.user)));
          },
          child: StreamBuilder(
            stream: APIs.getLastMessage(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
              if (list.isNotEmpty) _message = list[0];

              return ListTile(
                //user profile picture
                //user profile picture
                leading: InkWell(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (_) => ProfileDialog(user: widget.user));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .03),
                    child: CachedNetworkImage(
                      width: mq.height * .055,
                      height: mq.height * .055,
                      imageUrl: widget.user.image,
                      errorWidget: (context, url, error) => const CircleAvatar(
                          child: Icon(CupertinoIcons.person)),
                    ),
                  ),
                ),

                //user name
                title: Text(widget.user.name),

                //last message
                subtitle: Text(
                    _message != null
                        ? _message!.type == Type.image
                        ? 'image'
                        : _message!.msg
                        : widget.user.about,
                    maxLines: 1),

                //last message time
                trailing: isEnableAddButton?ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor
                  ),
                  onPressed: (){
                    APIs.addUserId(widget.user.id, widget.user);
                    setState(() {
                      isEnableAddButton=false;
                    });
                  },
                  child: Text("Add"),
                ):null,
              );
            },
          )),
    ):SizedBox.shrink();
  }
}
