// To parse this JSON data, do
//
//     final iBanner = iBannerFromJson(jsonString);

import 'dart:convert';

IBanner iBannerFromJson(String str) => IBanner.fromJson(json.decode(str));

String iBannerToJson(IBanner data) => json.encode(data.toJson());

class IBanner {
  GuestbookData? data;
  int? code;
  bool? success;
  String? message;

  IBanner({
    this.data,
    this.code,
    this.success,
    this.message,
  });

  factory IBanner.fromJson(Map<String, dynamic> json) => IBanner(
        data:
            json["data"] == null ? null : GuestbookData.fromJson(json["data"]),
        code: json["code"],
        success: json["success"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "data": data?.toJson(),
        "code": code,
        "success": success,
        "message": message,
      };
}

class GuestbookData {
  int? total;
  int? page;
  int? pageSize;
  List<GuestbookItem>? list;

  GuestbookData({
    this.total,
    this.page,
    this.pageSize,
    this.list,
  });

  factory GuestbookData.fromJson(Map<String, dynamic> json) => GuestbookData(
        total: json["total"],
        page: json["page"],
        pageSize: json["pageSize"],
        list: json["list"] == null
            ? []
            : List<GuestbookItem>.from(
                json["list"].map((x) => GuestbookItem.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "total": total,
        "page": page,
        "pageSize": pageSize,
        "list": list == null
            ? []
            : List<dynamic>.from(list!.map((x) => x.toJson())),
      };
}

class GuestbookItem {
  int? id;
  String? author;
  String? avatar;
  String? content;
  int? createdAt;
  int? likes;
  List<GuestbookReply>? replies;

  GuestbookItem({
    this.id,
    this.author,
    this.avatar,
    this.content,
    this.createdAt,
    this.likes,
    this.replies,
  });

  factory GuestbookItem.fromJson(Map<String, dynamic> json) => GuestbookItem(
        id: json["id"],
        author: json["author"],
        avatar: json["avatar"],
        content: json["content"],
        createdAt: json["createdAt"],
        likes: json["likes"],
        replies: json["replies"] == null
            ? []
            : List<GuestbookReply>.from(
                json["replies"].map((x) => GuestbookReply.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "author": author,
        "avatar": avatar,
        "content": content,
        "createdAt": createdAt,
        "likes": likes,
        "replies": replies == null
            ? []
            : List<dynamic>.from(replies!.map((x) => x.toJson())),
      };
}

class GuestbookReply {
  int? id;
  String? from;
  String? avatar;
  String? to;
  String? content;
  int? createdAt;
  int? likes;

  GuestbookReply({
    this.id,
    this.from,
    this.avatar,
    this.to,
    this.content,
    this.createdAt,
    this.likes,
  });

  factory GuestbookReply.fromJson(Map<String, dynamic> json) => GuestbookReply(
        id: json["id"],
        from: json["from"],
        avatar: json["avatar"],
        to: json["to"],
        content: json["content"],
        createdAt: json["createdAt"],
        likes: json["likes"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "from": from,
        "avatar": avatar,
        "to": to,
        "content": content,
        "createdAt": createdAt,
        "likes": likes,
      };
}
