import 'common.dart';

class ListModel extends INewsCommon {
  ListModel({
    super.respStatus,
    super.respInfo,
    super.errorCode,
    List<ListItem>? respData,
  }) : super(respData: respData);

  factory ListModel.fromJson(Map<String, dynamic> json) => ListModel(
        respStatus: json["success"] == true ? "success" : "fail",
        respInfo: json["message"],
        errorCode: json["code"]?.toString(),
        respData: json["data"]?["list"] == null
            ? []
            : List<ListItem>.from(
                json["data"]["list"].map((x) => ListItem.fromJson(x))),
      );

  @override
  Map<String, dynamic> toJson() => {
        "resp_status": respStatus,
        "resp_info": respInfo,
        "resp_data": respData == null
            ? []
            : List<dynamic>.from(respData.map((x) => x.toJson())),
        "errorCode": errorCode,
      };
}

class ListItem {
  int? id;
  int? columnId;
  String? title;
  String? subhead;
  String? source;
  String? sourceImg;
  String? date;
  String? smallImgs;
  int? readCnt;
  int? heatCnt;
  String? content;
  int? commentCnt;
  bool? isPush;
  int? nextId;
  String? jumpAddr;
  String? author;
  String? avatar;
  int? createdAt;
  int? likes;

  ListItem({
    this.id,
    this.columnId,
    this.title,
    this.subhead,
    this.source,
    this.sourceImg,
    this.date,
    this.smallImgs,
    this.readCnt,
    this.heatCnt,
    this.content,
    this.commentCnt,
    this.isPush,
    this.nextId,
    this.jumpAddr,
    this.author,
    this.avatar,
    this.createdAt,
    this.likes,
  });

  factory ListItem.fromJson(Map<String, dynamic> json) => ListItem(
        id: json["id"],
        columnId: json["columnId"],
        title: json["author"],
        subhead: json["subhead"],
        source: json["author"],
        sourceImg: json["avatar"],
        date: json["createdAt"]?.toString(),
        smallImgs: json["avatar"],
        readCnt: json["readCnt"],
        heatCnt: json["likes"],
        content: json["content"],
        commentCnt: json["commentCnt"],
        isPush: json["isPush"],
        nextId: json["nextId"],
        jumpAddr: json["jumpAddr"],
        author: json["author"],
        avatar: json["avatar"],
        createdAt: json["createdAt"],
        likes: json["likes"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "columnId": columnId,
        "title": title,
        "subhead": subhead,
        "source": source,
        "sourceImg": sourceImg,
        "date": date,
        "smallImgs": smallImgs,
        "readCnt": readCnt,
        "heatCnt": heatCnt,
        "content": content,
        "commentCnt": commentCnt,
        "isPush": isPush,
        "nextId": nextId,
        "jumpAddr": jumpAddr,
        "author": author,
        "avatar": avatar,
        "createdAt": createdAt,
        "likes": likes,
      };
}
