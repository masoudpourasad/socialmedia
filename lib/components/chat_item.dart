import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:socialmedia/chats/conversation.dart';
import 'package:socialmedia/models/enum/message_type.dart';
import 'package:socialmedia/models/user.dart';
import 'package:socialmedia/utils/firebase.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatItem extends StatelessWidget {
  final String? userId;
  final Timestamp? time;
  final String? msg;
  final int? messageCount;
  final String? chatId;
  final MessageType? type;
  final String? currentUserId;

  const ChatItem({
    super.key,
    required this.userId,
    required this.time,
    required this.msg,
    required this.messageCount,
    required this.chatId,
    required this.type,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: usersRef.doc('$userId').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          DocumentSnapshot documentSnapshot =
              snapshot.data as DocumentSnapshot<Object?>;
          UserModel user = UserModel.fromJson(
            documentSnapshot.data() as Map<String, dynamic>,
          );
          return ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
            leading: Stack(
              children: <Widget>[
                user.photoUrl == null || user.photoUrl!.isEmpty
                    ? CircleAvatar(
                        radius: 25.0,
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        child: Center(
                          child: Text(
                            user.username![0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      )
                    : CircleAvatar(
                        radius: 25.0,
                        backgroundImage: CachedNetworkImageProvider(
                          '${user.photoUrl}',
                        ),
                      ),
                Positioned(
                  bottom: 0.0,
                  right: 0.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    height: 15,
                    width: 15,
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: user.isOnline ?? false
                              ? const Color(0xff00d72f)
                              : Colors.grey,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        height: 11,
                        width: 11,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            title: Text(
              '${user.username}',
              maxLines: 1,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              type == MessageType.image ? "IMAGE" : "$msg",
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                const SizedBox(height: 10),
                Text(
                  timeago.format(time!.toDate()),
                  style: const TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 5),
                buildCounter(context),
              ],
            ),
            onTap: () {
              Navigator.of(context, rootNavigator: true).push(
                CupertinoPageRoute(
                  builder: (BuildContext context) {
                    return Conversation(
                      userId: userId!,
                      chatId: chatId!,
                    );
                  },
                ),
              );
            },
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  buildCounter(BuildContext context) {
    return StreamBuilder(
      stream: messageBodyStream(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          DocumentSnapshot snap = snapshot.data;
          final bool hasScore = snapshot.data!.data()!.containsKey('reads');
          Map usersReads = hasScore ? snap.get('reads') ?? {} : {};
          int readCount = usersReads[currentUserId] ?? 0;
          int counter = messageCount! - readCount;
          if (counter == 0) {
            return const SizedBox();
          } else {
            return Container(
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(6),
              ),
              constraints: const BoxConstraints(
                minWidth: 11,
                minHeight: 11,
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 1, left: 5, right: 5),
                child: Text(
                  "$counter",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Stream<DocumentSnapshot> messageBodyStream() {
    return chatRef.doc(chatId).snapshots();
  }
}
