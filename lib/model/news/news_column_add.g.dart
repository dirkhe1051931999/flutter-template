// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_column_add.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

INewsColumnAdd _$INewsColumnAddFromJson(Map<String, dynamic> json) =>
    INewsColumnAdd(
      respStatus: json['resp_status'] as String?,
      respInfo: json['resp_info'] as String?,
      respData: json['resp_data'] == null
          ? null
          : RespData.fromJson(json['resp_data'] as Map<String, dynamic>),
      errorCode: json['errorCode'] as String?,
    );

Map<String, dynamic> _$INewsColumnAddToJson(INewsColumnAdd instance) =>
    <String, dynamic>{
      'resp_status': instance.respStatus,
      'resp_info': instance.respInfo,
      'resp_data': instance.respData,
      'errorCode': instance.errorCode,
    };

RespData _$RespDataFromJson(Map<String, dynamic> json) => RespData(
      columnTypeList: (json['columnTypeList'] as List<dynamic>?)
          ?.map((e) => ColumnTypeList.fromJson(e as Map<String, dynamic>))
          .toList(),
      newsmaterial: json['newsmaterial'] as int?,
    );

Map<String, dynamic> _$RespDataToJson(RespData instance) => <String, dynamic>{
      'columnTypeList': instance.columnTypeList,
      'newsmaterial': instance.newsmaterial,
    };

ColumnTypeList _$ColumnTypeListFromJson(Map<String, dynamic> json) =>
    ColumnTypeList(
      id: json['id'] as int?,
      name: json['name'] as String?,
      type: json['type'] as int?,
      clickType: json['clickType'] as int?,
      clickUrl: json['clickUrl'],
    );

Map<String, dynamic> _$ColumnTypeListToJson(ColumnTypeList instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'clickType': instance.clickType,
      'clickUrl': instance.clickUrl,
    };
