import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:socialmedia/utils/firebase.dart';

class IconBadge extends StatefulWidget {
  final IconData icon;
  final double? size;
  final Color? color;
  const IconBadge({super.key, required this.icon, this.size, this.color});

  @override
  State<IconBadge> createState() => _IconBadgeState();
}

class _IconBadgeState extends State<IconBadge> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Icon(
          widget.icon,
          size: widget.size,
          color: widget.color,
        ),
        Positioned(
          right: 0.0,
          child: Container(
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(6),
            ),
            constraints: const BoxConstraints(
              minWidth: 11,
              minHeight: 11,
            ),
            child: Padding(
                padding: const EdgeInsets.only(top: 1), child: buildCount()),
          ),
        ),
      ],
    );
  }

  buildCount() {
    StreamBuilder(
      stream: notificationRef
          .doc(firebaseAuth.currentUser!.uid)
          .collection('notifications')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          QuerySnapshot snap = snapshot.data!;
          List<DocumentSnapshot> docs = snap.docs;
          return buildTextWidget(docs.length.toString());
        } else {
          return buildTextWidget(0.toString());
        }
      },
    );
  }

  buildTextWidget(String counter) {
    return Text(
      counter,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 9,
      ),
      textAlign: TextAlign.center,
    );
  }
}
