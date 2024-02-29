import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialmedia/models/enum/message_type.dart';

class StatusModel {
  String? caption;
  String? url;
  String? status;
  String? statusId;
  MessageType? type;
  List<dynamic>? viewers;
  Timestamp? time;

  StatusModel(
      {this.caption,
      this.url,
      this.statusId,
      this.time,
      this.type,
      this.viewers});

  StatusModel.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    caption = json['caption'];
    statusId = json['statusId'];
    viewers = json['viewers'];
    if (json['type'] == 'text') {
      type = MessageType.text;
    } else {
      type = MessageType.image;
    }

    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['caption'] = caption;
    data['statusId'] = statusId;
    data['viewers'] = viewers;
    data['url'] = url;
    if (type == MessageType.text) {
      data['type'] = 'text';
    } else {
      data['type'] = 'image';
    }
    data['time'] = time;
    return data;
  }
}
