import 'package:json_annotation/json_annotation.dart';

part 'inews_detail_ad.g.dart';

@JsonSerializable()
class INewsDetailAd {
  @JsonKey(name: 'resp_status')
  String? respStatus;
  @JsonKey(name: 'resp_info')
  String? respInfo;
  @JsonKey(name: 'resp_data')
  RespData? respData;
  String? errorCode;

  INewsDetailAd();

  factory INewsDetailAd.fromJson(Map<String, dynamic> json) =>
      _$INewsDetailAdFromJson(json);

  Map<String, dynamic> toJson() => _$INewsDetailAdToJson(this);
}

@JsonSerializable()
class RespData {
  NewsVO? newsvo;

  RespData();

  factory RespData.fromJson(Map<String, dynamic> json) =>
      _$RespDataFromJson(json);

  Map<String, dynamic> toJson() => _$RespDataToJson(this);
}

@JsonSerializable()
class NewsVO {
  int? id;
  @JsonKey(name: 'columnId')
  int? columnID;
  String? title;
  String? subhead;
  String? source;
  @JsonKey(name: 'sourceImg')
  String? sourceImage;
  String? date;
  @JsonKey(name: 'smallImgs')
  String? smallImages; // 注意，由于JSON字段是字符串类型，我将其更改为String
  int? readCnt;
  int? heatCnt;
  String? content;
  int? commentCnt;
  @JsonKey(name: 'isPush')
  String? isPush;
  int? nextId;
  String? jumpAddr;

  NewsVO();

  factory NewsVO.fromJson(Map<String, dynamic> json) => _$NewsVOFromJson(json);

  Map<String, dynamic> toJson() => _$NewsVOToJson(this);
}
