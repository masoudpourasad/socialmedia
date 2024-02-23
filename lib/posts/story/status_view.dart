import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialmedia/models/status.dart';
import 'package:socialmedia/models/user.dart';
import 'package:socialmedia/utils/firebase.dart';
import 'package:socialmedia/view_models/status/status_view_model.dart';
import 'package:socialmedia/widgets/indicators.dart';
import 'package:story/story.dart';
import 'package:timeago/timeago.dart' as timeago;

class StatusScreen extends StatefulWidget {
  final dynamic initPage;
  final dynamic statusId;
  final dynamic storyId;
  final dynamic userId;

  const StatusScreen({
    super.key,
    required this.initPage,
    required this.storyId,
    required this.statusId,
    required this.userId,
  });

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  @override
  Widget build(BuildContext context) {
    Provider.of<StatusViewModel>(context);
    return Scaffold(
      body: GestureDetector(
        onVerticalDragUpdate: (value) {
          Navigator.pop(context);
        },
        child: FutureBuilder<QuerySnapshot>(
          future: statusRef.doc(widget.statusId).collection('statuses').get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return circularProgress(context);
            } else if (snapshot.hasError) {
              // Handle error case
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
              // Handle case where data is null or empty
              return const Center(child: Text('No data available'));
            } else {
              List status = snapshot.data!.docs;
              // Rest of your code
              return StoryPageView(
                indicatorPadding: const EdgeInsets.symmetric(
                    vertical: 50.0, horizontal: 20.0),
                indicatorHeight: 15.0,
                initialPage: 0,
                onPageLimitReached: () {
                  Navigator.pop(context);
                },
                indicatorVisitedColor: Theme.of(context).colorScheme.secondary,
                indicatorDuration: const Duration(seconds: 30),
                itemBuilder: (context, pageIndex, storyIndex) {
                  StatusModel stats = StatusModel.fromJson(
                    status.toList()[storyIndex].data(),
                  );
                  //we will get the list of all viewers for each status
                  //then add our id to the list if it does not exist
                  List<dynamic>? allViewers = stats.viewers;
                  if (allViewers!.contains(firebaseAuth.currentUser!.uid)) {
                    if (kDebugMode) {
                      print('ID ALREADY EXIST');
                    }
                  } else {
                    allViewers.add(firebaseAuth.currentUser!.uid);
                    //update the viewCount for each status
                    statusRef
                        .doc(widget.statusId)
                        .collection('statuses')
                        .doc(stats.statusId)
                        .update({'viewers': allViewers});
                  }
                  return SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 50.0),
                          child: getImage(stats.url!),
                        ),
                        Positioned(
                          top: 65.0,
                          left: 10.0,
                          child: FutureBuilder(
                            future: usersRef.doc(widget.userId).get(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                DocumentSnapshot documentSnapshot =
                                    snapshot.data as DocumentSnapshot<Object?>;
                                UserModel user = UserModel.fromJson(
                                    documentSnapshot.data()
                                        as Map<String, dynamic>);
                                return Padding(
                                  padding: const EdgeInsets.only(right: 10.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.transparent,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.3),
                                              offset: const Offset(0.0, 0.0),
                                              blurRadius: 2.0,
                                              spreadRadius: 0.0,
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(1.0),
                                          child: CircleAvatar(
                                            radius: 15.0,
                                            backgroundColor: Colors.grey,
                                            backgroundImage:
                                                CachedNetworkImageProvider(
                                              user.photoUrl!,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10.0),
                                      Column(
                                        children: [
                                          Text(
                                            user.username!,
                                            style: const TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            timeago
                                                .format(stats.time!.toDate()),
                                            style: const TextStyle(
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                );
                              } else {
                                return const SizedBox();
                              }
                            },
                          ),
                        ),
                        Positioned(
                          bottom: widget.userId == firebaseAuth.currentUser!.uid
                              ? 10.0
                              : 30.0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                color: Colors.grey.withOpacity(0.2),
                                width: MediaQuery.of(context).size.width,
                                constraints:
                                    const BoxConstraints(maxHeight: 50.0),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0,
                                        ),
                                        child: Text(
                                          stats.caption ?? '',
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (widget.userId ==
                                  firebaseAuth.currentUser!.uid)
                                TextButton.icon(
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.remove_red_eye_outlined,
                                    size: 20.0,
                                    color: Theme.of(context).iconTheme.color,
                                  ),
                                  label: Text(
                                    stats.viewers!.length.toString(),
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: Theme.of(context).iconTheme.color,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
                storyLength: (int pageIndex) {
                  return status.length;
                },
                pageLength: 1,
              );
            }
          },
        ),
      ),
    );
  }

  getImage(String url) {
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: Image.network(url),
    );
  }
}
