import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:socialmedia/models/status.dart';
import 'package:socialmedia/models/user.dart';
import 'package:socialmedia/posts/story/status_view.dart';
import 'package:socialmedia/utils/firebase.dart';
import 'package:socialmedia/widgets/indicators.dart';

class StoryWidget extends StatelessWidget {
  const StoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100.0,
      child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: StreamBuilder<QuerySnapshot>(
          stream: userChatsStream(firebaseAuth.currentUser!.uid),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List chatList = snapshot.data!.docs;
              if (chatList.isNotEmpty) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  itemCount: chatList.length,
                  scrollDirection: Axis.horizontal,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    DocumentSnapshot statusListSnapshot = chatList[index];
                    return StreamBuilder<QuerySnapshot>(
                      stream: messageListStream(statusListSnapshot.id),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List statuses = snapshot.data!.docs;
                          StatusModel status = StatusModel.fromJson(
                            statuses.first.data(),
                          );
                          List users = statusListSnapshot.get('whoCanSee');

                          users.remove(firebaseAuth.currentUser!.uid);
                          return _buildStatusAvatar(
                              statusListSnapshot.get('userId') as String,
                              statusListSnapshot.id,
                              status.statusId!,
                              index);
                        } else {
                          return const SizedBox();
                        }
                      },
                    );
                  },
                );
              } else {
                return const Center(
                  child: Text(
                    'No Status',
                  ),
                );
              }
            } else {
              return circularProgress(context);
            }
          },
        ),
      ),
    );
  }

  _buildStatusAvatar(
    String userId,
    String chatId,
    String messageId,
    int index,
  ) {
    return StreamBuilder(
      stream: usersRef.doc(userId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          DocumentSnapshot documentSnapshot =
              snapshot.data as DocumentSnapshot<Object?>;
          UserModel user = UserModel.fromJson(
            documentSnapshot.data() as Map<String, dynamic>,
          );
          return Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => StatusScreen(
                          statusId: chatId,
                          storyId: messageId,
                          initPage: index,
                          userId: userId,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.transparent,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          offset: const Offset(0.0, 0.0),
                          blurRadius: 2.0,
                          spreadRadius: 0.0,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: CircleAvatar(
                        radius: 35.0,
                        backgroundColor: Colors.grey,
                        backgroundImage: CachedNetworkImageProvider(
                          user.photoUrl!,
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  user.username!,
                  style: const TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Stream<QuerySnapshot> userChatsStream(String uid) {
    return statusRef.where('whoCanSee', arrayContains: uid).snapshots();
  }

  Stream<QuerySnapshot> messageListStream(String documentId) {
    return statusRef.doc(documentId).collection('statuses').snapshots();
  }
}
