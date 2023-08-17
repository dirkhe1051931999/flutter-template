// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_list_ad.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

INewsListAd _$INewsListAdFromJson(Map<String, dynamic> json) => INewsListAd(
      respStatus: json['resp_status'] as String?,
      respInfo: json['resp_info'] as String?,
      respData: (json['resp_data'] as List<dynamic>?)
          ?.map((e) => NewsItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      errorCode: json['errorCode'] as String?,
    );

Map<String, dynamic> _$INewsListAdToJson(INewsListAd instance) =>
    <String, dynamic>{
      'resp_status': instance.respStatus,
      'resp_info': instance.respInfo,
      'resp_data': instance.respData,
      'errorCode': instance.errorCode,
    };

NewsItem _$NewsItemFromJson(Map<String, dynamic> json) => NewsItem(
      id: json['id'] as int?,
      columnId: json['columnId'] as int?,
      title: json['title'] as String?,
      subhead: json['subhead'] as String?,
      source: json['source'] as String?,
      sourceImg: json['sourceImg'] as String?,
      date: json['date'] as String?,
      smallImgs: json['smallImgs'] as String?,
      readCnt: json['readCnt'] as int?,
      heatCnt: json['heatCnt'] as int?,
      content: json['content'] as String?,
      commentCnt: json['commentCnt'] as int?,
      isPush: json['isPush'] as bool?,
      nextId: json['nextId'] as int?,
      jumpAddr: json['jumpAddr'] as String?,
    );

Map<String, dynamic> _$NewsItemToJson(NewsItem instance) => <String, dynamic>{
      'id': instance.id,
      'columnId': instance.columnId,
      'title': instance.title,
      'subhead': instance.subhead,
      'source': instance.source,
      'sourceImg': instance.sourceImg,
      'date': instance.date,
      'smallImgs': instance.smallImgs,
      'readCnt': instance.readCnt,
      'heatCnt': instance.heatCnt,
      'content': instance.content,
      'commentCnt': instance.commentCnt,
      'isPush': instance.isPush,
      'nextId': instance.nextId,
      'jumpAddr': instance.jumpAddr,
    };
