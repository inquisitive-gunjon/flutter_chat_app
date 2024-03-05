import 'dart:developer';

import 'package:chat_app/view/widgets/add_to_group_user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../api/apis.dart';
import '../../helper/dialogs.dart';
import '../../main.dart';
import '../../models/chat_user.dart';
import '../widgets/chat_user_card.dart';
import 'profile_screen.dart';

//home screen -- where all available contacts are shown
class GroupCreateScreen extends StatefulWidget {
  const GroupCreateScreen({super.key});

  @override
  State<GroupCreateScreen> createState() => _GroupCreateScreenState();
}

class _GroupCreateScreenState extends State<GroupCreateScreen> {
  // for storing all users
  List<ChatRoom> _list = [];

  // for storing all users
  final List<ChatRoom> _groupList = [];

  // for storing searched items
  final List<ChatRoom> _searchList = [];
  // for storing search status
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();

    //for updating user active status according to lifecycle events
    //resume -- active or online
    //pause  -- inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message: $message');

      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }

      return Future.value(message);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    APIs.clearUserIdList();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //for hiding keyboard when a tap is detected on screen
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        //app bar
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          // leading: const Icon(CupertinoIcons.home),
          title: _isSearching
              ? TextField(
            decoration: const InputDecoration(
                border: InputBorder.none, hintText: 'Name, Email, ...'),
            autofocus: true,
            style: const TextStyle(fontSize: 17, letterSpacing: 0.5),
            //when search text changes then updated search list
            onChanged: (val) {
              //search logic
              _searchList.clear();

              for (var i in _list) {
                if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                    i.email.toLowerCase().contains(val.toLowerCase())) {
                  _searchList.add(i);
                  setState(() {
                    _searchList;
                  });
                }
              }
            },
          )
          :  Text('Create Group',style: TextStyle(fontSize: 20.sp,color: Colors.white),),
          //     : Image.asset("images/e_chat.png",color: Colors.white,height: 20.h,width: 100.w,fit: BoxFit.contain,),
          actions: [
            //search user button
            IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                  });
                },
                icon: Icon(_isSearching
                    ? CupertinoIcons.clear_circled_solid
                    : Icons.search)),

            // //more features button
            // IconButton(
            //     onPressed: () {
            //       Navigator.push(
            //           context,
            //           MaterialPageRoute(
            //               builder: (_) => ProfileScreen(user: APIs.me)));
            //     },
            //     icon: const Icon(Icons.more_vert))
          ],
        ),

        //floating button to add new user
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton(
            onPressed: () {
              _addChatUserDialog();
            },
            child: Image.asset("images/create_chat.png",height: 50.h,width: 50.w,fit: BoxFit.contain,),),
        ),

        //body
        body: StreamBuilder(
          stream: APIs.getMyUsersId(),

          //get id of only known users
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
            //if data is loading
              case ConnectionState.waiting:
              case ConnectionState.none:
                return const Center(child: CircularProgressIndicator());

            //if some or all data is loaded then show it
              case ConnectionState.active:
              case ConnectionState.done:
                return StreamBuilder(
                  stream: APIs.getAllUsers(
                      snapshot.data?.docs.map((e) => e.id).toList() ?? []),

                  //get only those user, who's ids are provided
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                    //if data is loading
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                      // return const Center(
                      //     child: CircularProgressIndicator());

                      //if some or all data is loaded then show it
                      case ConnectionState.active:
                      case ConnectionState.done:
                        final data = snapshot.data?.docs;
                        _list = data
                            ?.map((e) => ChatRoom.fromJson(e.data()))
                            .toList() ??
                            [];

                        if (_list.isNotEmpty) {
                          return ListView.builder(
                              itemCount: _isSearching
                                  ? _searchList.length
                                  : _list.length,
                              padding: EdgeInsets.only(top: mq.height * .01),
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return AddToGroupUserCard(
                                    user: _isSearching
                                        ? _searchList[index]
                                        : _list[index]);
                              });
                        } else {
                          return const Center(
                            child: Text('No Connections Found!',
                                style: TextStyle(fontSize: 20)),
                          );
                        }
                    }
                  },
                );
            }
          },
        ),
      ),
    );
  }

  // for adding new chat user
  void _addChatUserDialog() {
    // String email = APIs.groupName;
    TextEditingController textEditingController =TextEditingController();
    textEditingController.text=APIs.groupName;

    showDialog(
      barrierDismissible: false,
        context: context,
        builder: (_) => AlertDialog(

          contentPadding:  EdgeInsets.only(
              left: 24.w, right: 24.w, top: 20.h, bottom: 10.h),

          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),

          //title
          title: Row(
            children:  [
              Icon(
                Icons.person_add,
                color: Colors.blue,
                size: 15.sp,
              ),
              Text(' Group Name',style: TextStyle(fontSize: 15.sp),),

            ],
          ),

          //content
          content: TextFormField(
            controller: textEditingController,
            maxLines: null,
            // onChanged: (value) {
            //   email = value;
            // },
            decoration: InputDecoration(
                hintText: 'Group Name',
                // prefixIcon:  Icon(Icons.email, color: Theme.of(context).primaryColor),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15))),
          ),

          //actions
          actions: [
            //cancel button
            MaterialButton(
                onPressed: () {
                  //hide alert dialog
                  Navigator.pop(context);
                },
                child: Text('Cancel',
                    style: TextStyle( color: Theme.of(context).primaryColor, fontSize: 16))),

            //add button
            MaterialButton(
                onPressed: () async {
                  log("Group User List : ${APIs.userIdList}");
                  log("Group Name : ${APIs.groupName}");
                  APIs.groupName=textEditingController.text;
                  //hide alert dialog
                  Navigator.pop(context);
                  if (APIs.userIdList.isNotEmpty) {
                    await APIs.createGroup(APIs.userIdList).then((value) {
                      // if (!value) {
                      //   Dialogs.showSnackbar(
                      //       context, 'User does not Exists!');
                      // }
                    });
                  }
                },
                child:  Text(
                  'Create',
                  style: TextStyle( color: Theme.of(context).primaryColor, fontSize: 16),
                ))
          ],
        ));
  }
}
