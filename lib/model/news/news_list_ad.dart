import 'package:json_annotation/json_annotation.dart';

part 'news_list_ad.g.dart';

@JsonSerializable()
class INewsListAd {
  @JsonKey(name: 'resp_status')
  String? respStatus;
  @JsonKey(name: 'resp_info')
  String? respInfo;
  @JsonKey(name: 'resp_data')
  List<NewsItem>? respData;
  @JsonKey(name: 'errorCode')
  String? errorCode;

  INewsListAd({this.respStatus, this.respInfo, this.respData, this.errorCode});

  factory INewsListAd.fromJson(Map<String, dynamic> json) =>
      _$INewsListAdFromJson(json);

  Map<String, dynamic> toJson() => _$INewsListAdToJson(this);
}

@JsonSerializable()
class NewsItem {
  int? id;
  @JsonKey(name: 'columnId')
  int? columnId;
  String? title;
  String? subhead;
  String? source;
  @JsonKey(name: 'sourceImg')
  String? sourceImg;
  String? date;
  @JsonKey(name: 'smallImgs')
  String? smallImgs;
  @JsonKey(name: 'readCnt')
  int? readCnt;
  @JsonKey(name: 'heatCnt')
  int? heatCnt;
  String? content;
  @JsonKey(name: 'commentCnt')
  int? commentCnt;
  @JsonKey(name: 'isPush')
  bool? isPush;
  @JsonKey(name: 'nextId')
  int? nextId;
  @JsonKey(name: 'jumpAddr')
  String? jumpAddr;

  NewsItem(
      {this.id,
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
      this.jumpAddr});

  factory NewsItem.fromJson(Map<String, dynamic> json) =>
      _$NewsItemFromJson(json);

  Map<String, dynamic> toJson() => _$NewsItemToJson(this);
}
