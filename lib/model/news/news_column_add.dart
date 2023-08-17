import 'package:json_annotation/json_annotation.dart';

part 'news_column_add.g.dart';

@JsonSerializable()
class INewsColumnAdd {
  @JsonKey(name: 'resp_status')
  final String? respStatus;

  @JsonKey(name: 'resp_info')
  final String? respInfo;

  @JsonKey(name: 'resp_data')
  final RespData? respData;

  @JsonKey(name: 'errorCode')
  final String? errorCode;

  INewsColumnAdd(
      {this.respStatus, this.respInfo, this.respData, this.errorCode});

  factory INewsColumnAdd.fromJson(Map<String, dynamic> json) =>
      _$INewsColumnAddFromJson(json);

  Map<String, dynamic> toJson() => _$INewsColumnAddToJson(this);
}

@JsonSerializable()
class RespData {
  final List<ColumnTypeList>? columnTypeList;
  final int? newsmaterial;

  RespData({this.columnTypeList, this.newsmaterial});

  factory RespData.fromJson(Map<String, dynamic> json) =>
      _$RespDataFromJson(json);

  Map<String, dynamic> toJson() => _$RespDataToJson(this);
}

@JsonSerializable()
class ColumnTypeList {
  final int? id;
  final String? name;
  final int? type;
  final int? clickType;
  final dynamic clickUrl;

  ColumnTypeList(
      {this.id, this.name, this.type, this.clickType, this.clickUrl});

  factory ColumnTypeList.fromJson(Map<String, dynamic> json) =>
      _$ColumnTypeListFromJson(json);

  Map<String, dynamic> toJson() => _$ColumnTypeListToJson(this);
}
