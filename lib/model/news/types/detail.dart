// i_news_detail_model.dart
import 'common.dart';

class DetailModel extends INewsCommon {
  DetailModel({
    super.respStatus,
    super.respInfo,
    super.errorCode,
    DetailRespData? respData,
  }) : super(respData: respData);

  factory DetailModel.fromJson(Map<String, dynamic> json) => DetailModel(
        respStatus: json["resp_status"],
        respInfo: json["resp_info"],
        errorCode: json["errorCode"],
        respData: json["resp_data"] == null ? null : DetailRespData.fromJson(json["resp_data"]),
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

  factory DetailRespData.fromJson(Map<String, dynamic> json) => DetailRespData(
        newsvo: json["newsvo"] == null ? null : NewsVo.fromJson(json["newsvo"]),
      );

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
  });

  factory NewsVo.fromJson(Map<String, dynamic> json) => NewsVo(
        id: json["id"],
        columnId: json["columnId"],
        title: json["title"],
        subhead: json["subhead"],
        source: json["source"],
        sourceImg: json["sourceImg"],
        date: json["date"],
        smallImgs: json["smallImgs"],
        readCnt: json["readCnt"],
        heatCnt: json["heatCnt"],
        content: json["content"],
        commentCnt: json["commentCnt"],
        isPush: json["isPush"],
        nextId: json["nextId"],
        jumpAddr: json["jumpAddr"],
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
      };
}
