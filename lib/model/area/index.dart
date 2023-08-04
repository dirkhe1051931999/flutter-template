// To parse this JSON data, do
//
//     final iAreaCodes = iAreaCodesFromJson(jsonString);

import 'dart:convert';

IAreaCodes iAreaCodesFromJson(String str) =>
    IAreaCodes.fromJson(json.decode(str));

String iAreaCodesToJson(IAreaCodes data) => json.encode(data.toJson());

class IAreaCodes {
  int status;
  String msg;
  List<Datum> data;

  IAreaCodes({
    required this.status,
    required this.msg,
    required this.data,
  });

  factory IAreaCodes.fromJson(Map<String, dynamic> json) => IAreaCodes(
        status: json["status"],
        msg: json["msg"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "msg": msg,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  int code;
  String zip;
  String call;
  String name;
  String short;
  String merger;
  String pinyin;
  int level;
  int select;
  String lng;
  String lat;

  Datum({
    required this.code,
    required this.zip,
    required this.call,
    required this.name,
    required this.short,
    required this.merger,
    required this.pinyin,
    required this.level,
    required this.select,
    required this.lng,
    required this.lat,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        code: json["code"],
        zip: json["zip"],
        call: json["call"],
        name: json["name"],
        short: json["short"],
        merger: json["merger"],
        pinyin: json["pinyin"],
        level: json["level"],
        select: json["select"],
        lng: json["lng"],
        lat: json["lat"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "zip": zip,
        "call": call,
        "name": name,
        "short": short,
        "merger": merger,
        "pinyin": pinyin,
        "level": level,
        "select": select,
        "lng": lng,
        "lat": lat,
      };
}
