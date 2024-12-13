// To parse this JSON data, do
//
//     final iBanner = iBannerFromJson(jsonString);

import 'dart:convert';

IBanner iBannerFromJson(String str) => IBanner.fromJson(json.decode(str));

String iBannerToJson(IBanner data) => json.encode(data.toJson());

class IBanner {
  List<Banner>? banners;
  int? code;

  IBanner({
    this.banners,
    this.code,
  });

  factory IBanner.fromJson(Map<String, dynamic> json) => IBanner(
        banners: json["banners"] == null
            ? []
            : List<Banner>.from(
                json["banners"]!.map((x) => Banner.fromJson(x))),
        code: json["code"],
      );

  Map<String, dynamic> toJson() => {
        "banners": banners == null
            ? []
            : List<dynamic>.from(banners!.map((x) => x.toJson())),
        "code": code,
      };
}

class Banner {
  String? imageUrl;
  int? targetId;
  dynamic adid;
  int? targetType;
  String? titleColor;
  String? typeTitle;
  String? url;
  bool? exclusive;
  dynamic monitorImpress;
  dynamic monitorClick;
  dynamic monitorType;
  dynamic monitorImpressList;
  dynamic monitorClickList;
  dynamic monitorBlackList;
  dynamic extMonitor;
  dynamic extMonitorInfo;
  dynamic adSource;
  dynamic adLocation;
  dynamic adDispatchJson;
  String? encodeId;
  dynamic program;
  dynamic event;
  dynamic video;
  dynamic song;
  String? scm;
  String? bannerBizType;

  Banner({
    this.imageUrl,
    this.targetId,
    this.adid,
    this.targetType,
    this.titleColor,
    this.typeTitle,
    this.url,
    this.exclusive,
    this.monitorImpress,
    this.monitorClick,
    this.monitorType,
    this.monitorImpressList,
    this.monitorClickList,
    this.monitorBlackList,
    this.extMonitor,
    this.extMonitorInfo,
    this.adSource,
    this.adLocation,
    this.adDispatchJson,
    this.encodeId,
    this.program,
    this.event,
    this.video,
    this.song,
    this.scm,
    this.bannerBizType,
  });

  factory Banner.fromJson(Map<String, dynamic> json) => Banner(
        imageUrl: json["imageUrl"],
        targetId: json["targetId"],
        adid: json["adid"],
        targetType: json["targetType"],
        titleColor: json["titleColor"],
        typeTitle: json["typeTitle"],
        url: json["url"],
        exclusive: json["exclusive"],
        monitorImpress: json["monitorImpress"],
        monitorClick: json["monitorClick"],
        monitorType: json["monitorType"],
        monitorImpressList: json["monitorImpressList"],
        monitorClickList: json["monitorClickList"],
        monitorBlackList: json["monitorBlackList"],
        extMonitor: json["extMonitor"],
        extMonitorInfo: json["extMonitorInfo"],
        adSource: json["adSource"],
        adLocation: json["adLocation"],
        adDispatchJson: json["adDispatchJson"],
        encodeId: json["encodeId"],
        program: json["program"],
        event: json["event"],
        video: json["video"],
        song: json["song"],
        scm: json["scm"],
        bannerBizType: json["bannerBizType"],
      );

  Map<String, dynamic> toJson() => {
        "imageUrl": imageUrl,
        "targetId": targetId,
        "adid": adid,
        "targetType": targetType,
        "titleColor": titleColor,
        "typeTitle": typeTitle,
        "url": url,
        "exclusive": exclusive,
        "monitorImpress": monitorImpress,
        "monitorClick": monitorClick,
        "monitorType": monitorType,
        "monitorImpressList": monitorImpressList,
        "monitorClickList": monitorClickList,
        "monitorBlackList": monitorBlackList,
        "extMonitor": extMonitor,
        "extMonitorInfo": extMonitorInfo,
        "adSource": adSource,
        "adLocation": adLocation,
        "adDispatchJson": adDispatchJson,
        "encodeId": encodeId,
        "program": program,
        "event": event,
        "video": video,
        "song": song,
        "scm": scm,
        "bannerBizType": bannerBizType,
      };
}