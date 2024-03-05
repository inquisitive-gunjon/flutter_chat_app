import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as random;

import 'package:chat_app/view/screens/auth/otp_verification_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../models/chat_user.dart';
import '../models/message.dart';

class APIs {
  // for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // for accessing firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  // for storing self information
  static ChatRoom me = ChatRoom(
      id: user.uid,
      name: user.displayName.toString(),
      email: user.email.toString(),
      phone: user.phoneNumber.toString(),
      members: [],
      about: "Hey, I'm using E-Chat",
      image: user.photoURL.toString(),
      createdAt: '',
      isOnline: false,
      isGroup: false,
      lastActive: '',
      pushToken: ''
  );

  // for sending otp button
  static sendOtp(String phoneNo,BuildContext context)async{
    await auth.verifyPhoneNumber(
      phoneNumber: phoneNo,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) {
      },
      verificationFailed: (FirebaseAuthException e) {},
      codeSent: (String verificationId, int? resendToken) {
        Navigator.of(context).push(MaterialPageRoute(builder: (context)=>OtpVerificationPage(verificationId: verificationId,phoneNo: phoneNo,)));
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
    // Navigator.of(context).pop();
  }

  //for resend otp button
  static reSendOtp(String phoneNo,BuildContext context)async{
    await auth.verifyPhoneNumber(
      phoneNumber: phoneNo,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) {
      },
      verificationFailed: (FirebaseAuthException e) {},
      codeSent: (String verificationId, int? resendToken) {
        // Navigator.of(context).push(MaterialPageRoute(builder: (context)=>OtpVerificationPage(verificationId: verificationId,)));
      },
      codeAutoRetrievalTimeout: (String verificationId) {

      },
    );
  }

  //  otp authentication and return usercredential
  static Future<UserCredential?> otpAuthentication(String verificationId,String smsCode)async{

    try{
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: smsCode
      );

      // Sign the user in (or link) with the credential
      return await APIs.auth.signInWithCredential(credential);
    }catch(ex){
      log(ex.toString());
    }
  }




  //group name
  static String groupName=user.displayName!;
  //for user id list for group chat
  static List<String> userIdList =["${user.uid}"];
  // add user in group list
  static void addUserId(String chatRoomId, ChatRoom chatRoom){
    if(userIdList.contains(chatRoomId)){
      return;
    }
    else{
      groupName=groupName+","+chatRoom.name;
      userIdList.add(chatRoomId);
    }
  }
  // remove user in group list
  static void removeUserId(String chatRoomId){
    userIdList.remove(chatRoomId);
  }
  //clear userIdList
  static void clearUserIdList(){
    groupName=user.displayName!;
    userIdList.clear();
    userIdList =["${user.uid}"];
  }





  // to return current user
  static User get user => auth.currentUser!;

  // for accessing firebase messaging (Push Notification)
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  // for getting firebase messaging token
  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();

    await fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        log('Push Token: $t');
      }
    });

    // for handling foreground messages
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   log('Got a message whilst in the foreground!');
    //   log('Message data: ${message.data}');

    //   if (message.notification != null) {
    //     log('Message also contained a notification: ${message.notification}');
    //   }
    // });
  }

  // for sending push notification
  static Future<void> sendPushNotification(
      ChatRoom chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": me.name, //our name should be send
          "body": msg,
          "android_channel_id": "chats"
        },
        // "data": {
        //   "some_data": "User ID: ${me.id}",
        // },
      };

      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'key=AAAAXCxdR3Q:APA91bHAD9RczzWChvlD4mfK1GJyUikULvWiTCKoPcJgJtvjFu17JWGeqR6aZ9zO2QknI4fa3qW4EOm07-bUJhraGqWga1HbL6ibwduFd7kv-e2N9v38b5oPW-Bbo7yB_7ug4Ji85t6Z'
          },
          body: jsonEncode(body));
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('\nsendPushNotificationE: $e');
    }
  }

  // for checking if user exists or not?
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  // for adding an chat user for our conversation
  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    log('data: ${data.docs}');

    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      //user exists

      log('user exists: ${data.docs.first.data()}');

      firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});

      return true;
    } else {
      //user doesn't exists

      return false;
    }
  }


  // for getting current user info
  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatRoom.fromJson(user.data()!);
        await getFirebaseMessagingToken();

        //for setting user status to active
        APIs.updateActiveStatus(true);
        log('My Data: ${user.data()}');
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  // for creating a new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatRoom(
        id: user.uid,
        name: user.displayName??user.phoneNumber.toString(),
        email: user.email.toString(),
        phone: user.phoneNumber.toString(),
        members: [],
        about: "Hey, I'm using E-Chat",
        image: user.photoURL.toString(),
        createdAt: time,
        isOnline: false,
        isGroup: false,
        lastActive: time,
        pushToken: '',);

    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  // for creating a new group
  static Future<void> createGroup(List<dynamic> userList) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final id=generateRandomString(28);
    final chatUser = ChatRoom(
      id: id,
      name: groupName,
      email: "",
      phone: "",
      members: userList,
      about: "Hey, we are using E-Chat",
      image: "https://firebasestorage.googleapis.com/v0/b/chat-app-e9f41.appspot.com/o/images%2Fgroupchat.png?alt=media&token=1db814bb-fd38-4225-a9b8-027afc5fabcd",
      createdAt: time,
      isOnline: false,
      isGroup: true,
      lastActive: time,
      pushToken: '',);

    await firestore
        .collection('users')
        .doc(id)
        .set(chatUser.toJson()).then((value) async{
            for (var uId in userList) {

              final data = await firestore
                  .collection('users')
                  .where('members', arrayContains: uId)
                  .get();

              log('data: ${data.docs.first.id}');

              if (data.docs.isNotEmpty && data.docs.first.id != uId) {
                //user exists

                log('user exists: ${data.docs.first.data()}');
                log('user exists: ${data.docs.first.data()}');
                log('user exists: ${data.docs.first.data()}');
                log('user exists: ${data.docs.first.data()}');

                firestore
                    .collection('users')
                    .doc(uId)
                    .collection('my_users')
                    .doc(data.docs.first.id)
                    .set({});

                // return true;
              } else {
                //user doesn't exists

                // return false;
              }
            }
        });


  }

  static String generateRandomString(int length) {
    const String chars = "abcdefghijklmnopqrstuvwxyz0123456789"; // You can customize the characters in the string

    random.Random r= random.Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
            (_) => chars.codeUnitAt(r.nextInt(chars.length)),
      ),
    );
  }

  // for getting id's of known users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

  // for getting all users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(List<String> userIds) {
    log('\nUserIds: $userIds');

    return firestore
        .collection('users')
        .where('id', whereIn: userIds.isEmpty ? [''] : userIds) //because empty list throws an error
        // .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  // for adding an user to my user when first message is send
  static Future<void> sendFirstMessage(ChatRoom chatUser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }

  // for updating user information
  static Future<void> updateUserInfo() async {
    await firestore.collection('users').doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }

  // update profile picture of user
  static Future<void> updateProfilePicture(File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;
    log('Extension: $ext');

    //storage file ref with path
    final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    me.image = await ref.getDownloadURL();
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'image': me.image});
  }

  // for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatRoom chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  // update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }

  ///************** Chat Screen Related APIs **************

  // chats (collection) --> conversation_id (doc) --> messages (collection) --> message (doc)

  // useful for getting conversation id
  static String getConversationID(String id, bool isGroup) {
    if(isGroup){
      return id;
    }else{
      return user.uid.hashCode <= id.hashCode ? '${user.uid}_$id' : '${id}_${user.uid}';

    }

  }

  // for getting all messages of a specific conversation from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(ChatRoom room) {
    if(room.isGroup){
      return firestore
          .collection('chats/${getConversationID(room.id,true)}/messages/')
          .orderBy('sent', descending: true)
          .snapshots();
    }else{
      return firestore
          .collection('chats/${getConversationID(room.id,false)}/messages/')
          .orderBy('sent', descending: true)
          .snapshots();
    }
  }

  // for sending message
  static Future<void> sendMessage(ChatRoom chatRoom, String msg, Type type) async {
    //message sending time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //message to send
    final Message message = Message(
        toId: chatRoom.id,
        msg: msg,
        read: '',
        type: type,
        fromId: user.uid,
        sent: time);

    final ref = firestore.collection('chats/${getConversationID(chatRoom.id,chatRoom.isGroup?true:false)}/messages/');
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(chatRoom, type == Type.text ? msg : 'image'));
  }

  //update read status of message
  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.fromId,false)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  //get only last message of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(ChatRoom chatRoom) {
    return firestore
        .collection('chats/${getConversationID(chatRoom.id,chatRoom.isGroup?true:false)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  //send chat image
  static Future<void> sendChatImage(ChatRoom chatRoom, File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = storage.ref().child(
        'images/${getConversationID(chatRoom.id,chatRoom.isGroup?true:false)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatRoom, imageUrl, Type.image);
  }

  //delete message
  static Future<void> deleteMessage(Message message) async {
    await firestore
        .collection('chats/${getConversationID(message.toId,false)}/messages/')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  //update message
  static Future<void> updateMessage(Message message, String updatedMsg) async {
    await firestore
        .collection('chats/${getConversationID(message.toId,false)}/messages/')
        .doc(message.sent)
        .update({'msg': updatedMsg});
  }
}
