import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:socialmedia/models/post.dart';
import 'package:socialmedia/utils/firebase.dart';
import 'package:socialmedia/widgets/indicators.dart';
import 'package:socialmedia/widgets/userpost.dart';

class ListPosts extends StatefulWidget {
  final dynamic userId;
  final dynamic username;

  const ListPosts({super.key, required this.userId, required this.username});

  @override
  State<ListPosts> createState() => _ListPostsState();
}

class _ListPostsState extends State<ListPosts> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Ionicons.chevron_back),
        ),
        title: Column(
          children: [
            Text(
              widget.username.toUpperCase(),
              style: const TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const Text(
              'Posts',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: FutureBuilder(
          future: postRef
              .where('ownerId', isEqualTo: widget.userId)
              .orderBy('timestamp', descending: true)
              .get(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              var snap = snapshot.data;
              List docs = snap!.docs;
              return ListView.builder(
                itemCount: docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  Map<String, dynamic> data = docs[index].data();
                  PostModel posts = PostModel.fromJson(data);
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: UserPost(post: posts),
                  );
                },
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return circularProgress(context);
            }
            return const Center(
              child: Text(
                'No Feeds',
                style: TextStyle(
                  fontSize: 26.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
