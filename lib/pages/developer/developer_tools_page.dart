import 'package:flutter/cupertino.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:oolaf_flutted/store/index.dart';
import 'package:oolaf_flutted/store/user/type.dart';
import 'package:oolaf_flutted/tools/developer_tools_center.dart';

class DeveloperToolsPage extends StatefulWidget {
  const DeveloperToolsPage({super.key});

  @override
  State<DeveloperToolsPage> createState() => _DeveloperToolsPageState();
}

class _DeveloperToolsPageState extends State<DeveloperToolsPage> {
  static const List<String> _tabs = <String>[
    '概览',
    '请求',
    '错误',
    '路由',
    '用户',
    '视频',
  ];

  PackageInfo? _packageInfo;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) {
      return;
    }
    setState(() {
      _packageInfo = info;
    });
  }

  Future<void> _copyToClipboard(String text) async {
    if (text.trim().isEmpty) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) {
      return;
    }
    await showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: const Text('已复制'),
          content: const Text('内容已复制到剪贴板。'),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('知道了'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final packageInfo = _packageInfo;
    final mediaQuery = MediaQuery.of(context);

    return StoreConnector<AppState, UserInfo>(
      converter: (store) => store.state.userInfo,
      builder: (context, userInfo) {
        return AnimatedBuilder(
          animation: DeveloperToolsCenter.instance,
          builder: (context, _) {
            return CupertinoPageScaffold(
              backgroundColor: const Color(0xFFF4F5F7),
              navigationBar: CupertinoNavigationBar(
                middle: const Text('Flutter 开发者工具'),
                trailing: CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('关闭'),
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                      child: CupertinoSlidingSegmentedControl<int>(
                        groupValue: _selectedTabIndex,
                        children: {
                          for (var i = 0; i < _tabs.length; i += 1)
                            i: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 6,
                              ),
                              child: Text(
                                _tabs[i],
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                        },
                        onValueChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _selectedTabIndex = value;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                        children: _buildTabChildren(
                          mediaQuery: mediaQuery,
                          packageInfo: packageInfo,
                          userInfo: userInfo,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildTabChildren({
    required MediaQueryData mediaQuery,
    required PackageInfo? packageInfo,
    required UserInfo userInfo,
  }) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildOverviewSection(mediaQuery: mediaQuery, packageInfo: packageInfo);
      case 1:
        return _buildRequestSection();
      case 2:
        return _buildErrorSection();
      case 3:
        return _buildRouteSection();
      case 4:
        return _buildUserSection(userInfo);
      case 5:
        return _buildVideoSection();
    }
    return const <Widget>[];
  }

  List<Widget> _buildOverviewSection({
    required MediaQueryData mediaQuery,
    required PackageInfo? packageInfo,
  }) {
    final center = DeveloperToolsCenter.instance;
    return [
      const _SectionCard(
        title: '工具说明',
        children: [
          _InfoRow(label: '入口暗号', value: 'OLAF'),
          _InfoRow(label: '定位', value: '独立于业务页面的线上诊断入口'),
          _InfoRow(label: '当前能力', value: '请求日志、错误日志、路由日志、用户信息、视频状态'),
        ],
      ),
      _SectionCard(
        title: '应用信息',
        children: [
          _InfoRow(label: '应用名', value: packageInfo?.appName ?? '加载中...'),
          _InfoRow(label: '包名', value: packageInfo?.packageName ?? '加载中...'),
          _InfoRow(
            label: '版本号',
            value: packageInfo == null
                ? '加载中...'
                : '${packageInfo.version} (${packageInfo.buildNumber})',
          ),
          _InfoRow(label: '平台亮度', value: mediaQuery.platformBrightness.name),
          _InfoRow(
            label: '屏幕尺寸',
            value: '${mediaQuery.size.width.toStringAsFixed(0)} x ${mediaQuery.size.height.toStringAsFixed(0)}',
          ),
          _InfoRow(
            label: '缩放倍率',
            value: mediaQuery.devicePixelRatio.toStringAsFixed(2),
          ),
        ],
      ),
      _SectionCard(
        title: '诊断摘要',
        children: [
          _InfoRow(label: '请求日志', value: '${center.requestLogs.length} 条'),
          _InfoRow(label: '错误日志', value: '${center.errorLogs.length} 条'),
          _InfoRow(label: '路由日志', value: '${center.routeLogs.length} 条'),
          _InfoRow(
            label: '视频状态',
            value: center.latestVideoStatus == null ? '暂无' : center.latestVideoStatus!.outputStatus.name,
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildRequestSection() {
    final logs = DeveloperToolsCenter.instance.requestLogs;
    return [
      _SectionCard(
        title: '最近请求日志',
        trailing: _HeaderActions(
          onCopy: logs.isEmpty
              ? null
              : () {
                  _copyToClipboard(_buildRequestLogsText(logs));
                },
          onClear: DeveloperToolsCenter.instance.clearRequestLogs,
        ),
        children: logs.isEmpty
            ? const [_EmptyRow(text: '暂无请求日志')]
            : logs.map((log) => _LogTile(
                  title: '[${log.method}] ${log.url}',
                  subtitle:
                      '${_formatDateTime(log.time)}  ${log.statusCode ?? '-'}  ${log.durationMs ?? '-'}ms\n请求: ${log.requestSummary.isEmpty ? '-' : log.requestSummary}\n响应: ${log.responseSummary.isEmpty ? '-' : log.responseSummary}${log.errorMessage.isEmpty ? '' : '\n错误: ${log.errorMessage}'}',
                )).toList(growable: false),
      ),
    ];
  }

  List<Widget> _buildErrorSection() {
    final logs = DeveloperToolsCenter.instance.errorLogs;
    return [
      _SectionCard(
        title: '最近错误日志',
        trailing: _HeaderActions(
          onCopy: logs.isEmpty
              ? null
              : () {
                  _copyToClipboard(_buildErrorLogsText(logs));
                },
          onClear: DeveloperToolsCenter.instance.clearErrorLogs,
        ),
        children: logs.isEmpty
            ? const [_EmptyRow(text: '暂无错误日志')]
            : logs.map((log) => _LogTile(
                  title: '[${log.source}] ${log.message}',
                  subtitle: '${_formatDateTime(log.time)}\n${log.stackTrace.isEmpty ? '无堆栈' : log.stackTrace}',
                )).toList(growable: false),
      ),
    ];
  }

  List<Widget> _buildRouteSection() {
    final logs = DeveloperToolsCenter.instance.routeLogs;
    return [
      _SectionCard(
        title: '最近路由日志',
        trailing: _HeaderActions(
          onCopy: logs.isEmpty
              ? null
              : () {
                  _copyToClipboard(_buildRouteLogsText(logs));
                },
          onClear: DeveloperToolsCenter.instance.clearRouteLogs,
        ),
        children: logs.isEmpty
            ? const [_EmptyRow(text: '暂无路由日志')]
            : logs.map((log) => _LogTile(
                  title: '[${log.event}] ${log.routeName}',
                  subtitle: '${_formatDateTime(log.time)}\n上一页: ${log.previousRouteName}',
                )).toList(growable: false),
      ),
    ];
  }

  List<Widget> _buildUserSection(UserInfo userInfo) {
    return [
      _SectionCard(
        title: '当前用户信息',
        trailing: _HeaderActions(
          onCopy: () {
            _copyToClipboard(_buildUserInfoText(userInfo));
          },
        ),
        children: [
          _InfoRow(label: 'name', value: userInfo.name.isEmpty ? '-' : userInfo.name),
          _InfoRow(label: 'age', value: userInfo.age < 0 ? '-' : '${userInfo.age}'),
          _InfoRow(label: 'username', value: userInfo.username.isEmpty ? '-' : userInfo.username),
          _InfoRow(label: 'email', value: userInfo.email.isEmpty ? '-' : userInfo.email),
          _InfoRow(label: 'phone', value: userInfo.phone.isEmpty ? '-' : userInfo.phone),
          _InfoRow(label: 'token', value: _maskToken(userInfo.token)),
        ],
      ),
    ];
  }

  List<Widget> _buildVideoSection() {
    final status = DeveloperToolsCenter.instance.latestVideoStatus;
    return [
      _SectionCard(
        title: '当前视频状态',
        trailing: _HeaderActions(
          onCopy: status == null
              ? null
              : () {
                  _copyToClipboard(_buildVideoStatusText(status));
                },
        ),
        children: status == null
            ? const [_EmptyRow(text: '暂无视频状态')]
            : [
                _InfoRow(label: '来源', value: status.source),
                _InfoRow(label: 'controller', value: status.controllerHash),
                _InfoRow(label: 'initialized', value: status.isInitialized ? 'true' : 'false'),
                _InfoRow(label: 'playing', value: status.isPlaying ? 'true' : 'false'),
                _InfoRow(label: 'buffering', value: status.isBuffering ? 'true' : 'false'),
                _InfoRow(label: 'position', value: _formatDuration(status.position)),
                _InfoRow(label: 'duration', value: _formatDuration(status.duration)),
                _InfoRow(label: 'outputStatus', value: status.outputStatus.name),
                _InfoRow(
                  label: 'videoSize',
                  value: status.videoSize == null
                      ? '-'
                      : '${status.videoSize!.width.toStringAsFixed(0)} x ${status.videoSize!.height.toStringAsFixed(0)}',
                ),
                _InfoRow(label: '采样时间', value: _formatDateTime(status.time)),
              ],
      ),
    ];
  }

  String _formatDateTime(DateTime time) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${twoDigits(time.hour)}:${twoDigits(time.minute)}:${twoDigits(time.second)}';
  }

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final hours = minutes ~/ 60;
    final normalizedMinutes = minutes % 60;
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(normalizedMinutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  String _maskToken(String token) {
    if (token.isEmpty) {
      return '-';
    }
    if (token.length <= 8) {
      return token;
    }
    return '${token.substring(0, 4)}***${token.substring(token.length - 4)}';
  }

  String _buildRequestLogsText(List<DeveloperRequestLog> logs) {
    return logs
        .map(
          (log) => '[${log.method}] ${log.url}\n'
              '时间: ${_formatDateTime(log.time)}\n'
              '状态: ${log.statusCode ?? '-'}\n'
              '耗时: ${log.durationMs ?? '-'}ms\n'
              '请求: ${log.requestSummary.isEmpty ? '-' : log.requestSummary}\n'
              '响应: ${log.responseSummary.isEmpty ? '-' : log.responseSummary}\n'
              '错误: ${log.errorMessage.isEmpty ? '-' : log.errorMessage}',
        )
        .join('\n\n');
  }

  String _buildErrorLogsText(List<DeveloperErrorLog> logs) {
    return logs
        .map(
          (log) => '[${log.source}] ${log.message}\n'
              '时间: ${_formatDateTime(log.time)}\n'
              '堆栈: ${log.stackTrace.isEmpty ? '无堆栈' : log.stackTrace}',
        )
        .join('\n\n');
  }

  String _buildRouteLogsText(List<DeveloperRouteLog> logs) {
    return logs
        .map(
          (log) => '[${log.event}] ${log.routeName}\n'
              '时间: ${_formatDateTime(log.time)}\n'
              '上一页: ${log.previousRouteName}',
        )
        .join('\n\n');
  }

  String _buildUserInfoText(UserInfo userInfo) {
    return 'name: ${userInfo.name.isEmpty ? '-' : userInfo.name}\n'
        'age: ${userInfo.age < 0 ? '-' : userInfo.age}\n'
        'username: ${userInfo.username.isEmpty ? '-' : userInfo.username}\n'
        'email: ${userInfo.email.isEmpty ? '-' : userInfo.email}\n'
        'phone: ${userInfo.phone.isEmpty ? '-' : userInfo.phone}\n'
        'token: ${_maskToken(userInfo.token)}';
  }

  String _buildVideoStatusText(DeveloperVideoStatus status) {
    final videoSize = status.videoSize == null
        ? '-'
        : '${status.videoSize!.width.toStringAsFixed(0)} x ${status.videoSize!.height.toStringAsFixed(0)}';
    return '来源: ${status.source}\n'
        'controller: ${status.controllerHash}\n'
        'initialized: ${status.isInitialized}\n'
        'playing: ${status.isPlaying}\n'
        'buffering: ${status.isBuffering}\n'
        'position: ${_formatDuration(status.position)}\n'
        'duration: ${_formatDuration(status.duration)}\n'
        'outputStatus: ${status.outputStatus.name}\n'
        'videoSize: $videoSize\n'
        '采样时间: ${_formatDateTime(status.time)}';
  }
}

class _HeaderActions extends StatelessWidget {
  const _HeaderActions({
    this.onCopy,
    this.onClear,
  });

  final VoidCallback? onCopy;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onCopy != null)
          CupertinoButton(
            padding: const EdgeInsets.only(left: 8),
            minimumSize: Size.zero,
            onPressed: onCopy,
            child: const Icon(
              CupertinoIcons.doc_on_doc,
              size: 18,
            ),
          ),
        if (onClear != null)
          CupertinoButton(
            padding: const EdgeInsets.only(left: 6),
            minimumSize: Size.zero,
            onPressed: onClear,
            child: const Text('清空'),
          ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.children,
    this.trailing,
  });

  final String title;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _EmptyRow extends StatelessWidget {
  const _EmptyRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF8E8E93),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  const _LogTile({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF1C1C1E),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF636366),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF8E8E93),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF1C1C1E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
