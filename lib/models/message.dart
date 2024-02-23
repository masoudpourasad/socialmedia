import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialmedia/models/enum/message_type.dart';

class Message {
  String? content;
  String? senderUid;
  String? messageId;
  MessageType? type;
  Timestamp? time;

  Message({this.content, this.senderUid, this.messageId, this.type, this.time});

  Message.fromJson(Map<String, dynamic> json) {
    content = json['content'];
    senderUid = json['senderUid'];
    messageId = json['messageId'];
    type = json['type'] == 'text' ? MessageType.text : MessageType.image;
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['content'] = content;
    data['senderUid'] = senderUid;
    data['messageId'] = messageId;
    data['type'] = type == MessageType.text ? 'text' : 'image';
    data['time'] = time;
    return data;
  }
}
