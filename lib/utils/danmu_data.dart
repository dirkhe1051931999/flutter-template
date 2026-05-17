import 'dart:math' as math;

import 'package:oolaf_flutted/model/short_video/danmaku_item.dart';

List<DanmakuItem> generateMockDanmakuItems(String videoId) {
  if (videoId.isEmpty) {
    return const <DanmakuItem>[];
  }

  const targetCount = 1200;
  final random = math.Random(videoId.hashCode);
  const reactions = <String>[
    '太上头了',
    '哈哈哈哈',
    '稳',
    '有点东西',
    'DNA动了',
    '高能预警',
    '这条必火',
    '再看一遍',
    '直接关注',
    '救命好好看',
    '这也太会了',
    '我先赞为敬',
  ];
  const scenes = <String>[
    '这转场绝了',
    '卡点好准',
    '节奏舒服',
    '太丝滑了',
    '这个运镜好强',
    '这段镜头语言绝了',
    '配乐和画面好搭',
    '手速太快了',
    '质感拉满',
    '氛围感拿捏了',
  ];
  const asks = <String>[
    '想学这个',
    '教程在哪里',
    '求BGM名',
    '这一段怎么拍的',
    '能不能出个慢放版',
    '这机位怎么架',
    '同款滤镜求分享',
  ];
  const suffixes = <String>[
    '！',
    '！！',
    '!!!',
    '~',
    '～',
    '（已收藏）',
    '（前排）',
    '（二刷打卡）',
    '（暂停细看）',
    '（这个细节绝）',
  ];
  const colors = <String>[
    '#FFFFFF',
    '#FFE7A7',
    '#B7F1FF',
    '#FFC7D8',
    '#D5FFBF',
  ];
  const types = <String>[
    'normal',
    'normal',
    'normal',
    'hot',
    'highlight',
  ];

  String buildText(int index) {
    final mode = random.nextInt(4);
    final content = switch (mode) {
      0 => reactions[random.nextInt(reactions.length)],
      1 => scenes[random.nextInt(scenes.length)],
      2 => asks[random.nextInt(asks.length)],
      _ =>
        '${reactions[random.nextInt(reactions.length)]} ${scenes[random.nextInt(scenes.length)]}',
    };
    final suffix = suffixes[random.nextInt(suffixes.length)];

    if (index % 37 == 0) {
      return '第${index + 1}条弹幕 $content$suffix';
    }
    return '$content$suffix';
  }

  var cursorMs = 200 + random.nextInt(300);
  final count = targetCount + random.nextInt(120);
  final items = <DanmakuItem>[];

  for (var i = 0; i < count; i += 1) {
    cursorMs += 70 + random.nextInt(180);
    final type = types[random.nextInt(types.length)];
    final priority = switch (type) {
      'highlight' => 3 + random.nextInt(2),
      'hot' => 2 + random.nextInt(2),
      _ => random.nextInt(2),
    };
    items.add(
      DanmakuItem(
        atMs: cursorMs,
        text: buildText(i),
        type: type,
        color: colors[random.nextInt(colors.length)],
        priority: priority,
      ),
    );
  }

  return items;
}
