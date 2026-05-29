// i_news_detail_model.dart
import 'common.dart';

class DetailModel extends INewsCommon {
  DetailModel({
    super.respStatus,
    super.respInfo,
    super.errorCode,
    DetailRespData? super.respData,
  });

  factory DetailModel.fromJson(Map<String, dynamic> json, [int? id]) =>
      DetailModel(
        respStatus: json["success"] == true ? "success" : "fail",
        respInfo: json["message"],
        errorCode: json["code"]?.toString(),
        respData: json["data"] == null
            ? null
            : DetailRespData.fromJson(json["data"], id),
      );

  @override
  Map<String, dynamic> toJson() => {
        "resp_status": respStatus,
        "resp_info": respInfo,
        "resp_data": respData?.toJson(),
        "errorCode": errorCode,
      };
}

class DetailRespData {
  NewsVo? newsvo;

  DetailRespData({
    this.newsvo,
  });

  factory DetailRespData.fromJson(Map<String, dynamic> json, [int? id]) {
    final List<dynamic> list = json["list"] ?? [];
    final matched = list.cast<Map<String, dynamic>?>().firstWhere(
          (item) => item?["id"] == id,
          orElse: () => list.isEmpty ? null : list.first,
        );
    return DetailRespData(
      newsvo: matched == null ? null : NewsVo.fromJson(matched),
    );
  }

  Map<String, dynamic> toJson() => {
        "newsvo": newsvo?.toJson(),
      };
}

class NewsVo {
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
  String? isPush;
  int? nextId;
  String? jumpAddr;
  String? author;
  String? avatar;
  int? createdAt;
  int? likes;

  NewsVo({
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

  factory NewsVo.fromJson(Map<String, dynamic> json) => NewsVo(
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
