import 'common.dart';

class TabsModel extends INewsCommon {
  TabsModel({
    super.respStatus,
    super.respInfo,
    super.errorCode,
    TabsRespData? respData,
  }) : super(respData: respData);

  factory TabsModel.fromJson(Map<String, dynamic> json) => TabsModel(
        respStatus: json["resp_status"],
        respInfo: json["resp_info"],
        errorCode: json["errorCode"],
        respData: json["resp_data"] == null ? null : TabsRespData.fromJson(json["resp_data"]),
      );

  @override
  Map<String, dynamic> toJson() => {
        "resp_status": respStatus,
        "resp_info": respInfo,
        "resp_data": respData?.toJson(),
        "errorCode": errorCode,
      };
}

class TabsRespData {
  List<TabsItem>? columnTypeList;

  TabsRespData({
    this.columnTypeList,
  });

  factory TabsRespData.fromJson(Map<String, dynamic> json) => TabsRespData(
        columnTypeList: json["columnTypeList"] == null
            ? []
            : List<TabsItem>.from(json["columnTypeList"].map((x) => TabsItem.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "columnTypeList": columnTypeList == null
            ? []
            : List<dynamic>.from(columnTypeList!.map((x) => x.toJson())),
      };
}

class TabsItem {
  int? id;
  String? name;
  int? type;
  int? clickType;
  dynamic clickUrl;

  TabsItem({
    this.id,
    this.name,
    this.type,
    this.clickType,
    this.clickUrl,
  });

  factory TabsItem.fromJson(Map<String, dynamic> json) => TabsItem(
        id: json["id"],
        name: json["name"],
        type: json["type"],
        clickType: json["clickType"],
        clickUrl: json["clickUrl"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "type": type,
        "clickType": clickType,
        "clickUrl": clickUrl,
      };
}
