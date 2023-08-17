// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inews_detail_ad.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

INewsDetailAd _$INewsDetailAdFromJson(Map<String, dynamic> json) =>
    INewsDetailAd()
      ..respStatus = json['resp_status'] as String?
      ..respInfo = json['resp_info'] as String?
      ..respData = json['resp_data'] == null
          ? null
          : RespData.fromJson(json['resp_data'] as Map<String, dynamic>)
      ..errorCode = json['errorCode'] as String?;

Map<String, dynamic> _$INewsDetailAdToJson(INewsDetailAd instance) =>
    <String, dynamic>{
      'resp_status': instance.respStatus,
      'resp_info': instance.respInfo,
      'resp_data': instance.respData,
      'errorCode': instance.errorCode,
    };

RespData _$RespDataFromJson(Map<String, dynamic> json) => RespData()
  ..newsvo = json['newsvo'] == null
      ? null
      : NewsVO.fromJson(json['newsvo'] as Map<String, dynamic>);

Map<String, dynamic> _$RespDataToJson(RespData instance) => <String, dynamic>{
      'newsvo': instance.newsvo,
    };

NewsVO _$NewsVOFromJson(Map<String, dynamic> json) => NewsVO()
  ..id = json['id'] as int?
  ..columnID = json['columnId'] as int?
  ..title = json['title'] as String?
  ..subhead = json['subhead'] as String?
  ..source = json['source'] as String?
  ..sourceImage = json['sourceImg'] as String?
  ..date = json['date'] as String?
  ..smallImages = json['smallImgs'] as String?
  ..readCnt = json['readCnt'] as int?
  ..heatCnt = json['heatCnt'] as int?
  ..content = json['content'] as String?
  ..commentCnt = json['commentCnt'] as int?
  ..isPush = json['isPush'] as String?
  ..nextId = json['nextId'] as int?
  ..jumpAddr = json['jumpAddr'] as String?;

Map<String, dynamic> _$NewsVOToJson(NewsVO instance) => <String, dynamic>{
      'id': instance.id,
      'columnId': instance.columnID,
      'title': instance.title,
      'subhead': instance.subhead,
      'source': instance.source,
      'sourceImg': instance.sourceImage,
      'date': instance.date,
      'smallImgs': instance.smallImages,
      'readCnt': instance.readCnt,
      'heatCnt': instance.heatCnt,
      'content': instance.content,
      'commentCnt': instance.commentCnt,
      'isPush': instance.isPush,
      'nextId': instance.nextId,
      'jumpAddr': instance.jumpAddr,
    };
