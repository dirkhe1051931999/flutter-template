// i_news_common.dart
import 'dart:convert';

INewsCommon iNewsCommonFromJson(String str) =>
    INewsCommon.fromJson(json.decode(str));

String iNewsCommonToJson(INewsCommon data) => json.encode(data.toJson());

class INewsCommon {
  String? respStatus;
  String? respInfo;
  dynamic respData; // Changed to dynamic to handle different response types
  String? errorCode;

  INewsCommon({
    this.respStatus,
    this.respInfo,
    this.respData,
    this.errorCode,
  });

  factory INewsCommon.fromJson(Map<String, dynamic> json) => INewsCommon(
        respStatus: json["resp_status"],
        respInfo: json["resp_info"],
        respData: json["resp_data"],
        errorCode: json["errorCode"],
      );

  Map<String, dynamic> toJson() => {
        "resp_status": respStatus,
        "resp_info": respInfo,
        "resp_data": respData,
        "errorCode": errorCode,
      };
}
