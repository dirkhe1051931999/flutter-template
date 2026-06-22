import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/router/config.dart';
import 'package:oolaf_flutted/router/routes.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  static const List<_AuthEntry> _entries = <_AuthEntry>[
    _AuthEntry('启动鉴权页', '判断 token、过期、onboarding 和升级策略', Routes.authSplashGate,
        CupertinoIcons.lock_shield),
    _AuthEntry('登录页', '账号密码登录示例；虎扑业务仍走虎扑登录页', Routes.authLogin,
        CupertinoIcons.person_crop_circle),
    _AuthEntry('注册页', '账号创建、密码规则和协议勾选', Routes.authRegister,
        CupertinoIcons.person_badge_plus),
    _AuthEntry('验证码页 / OTP 页', '验证码、倒计时、重发、错误次数限制', Routes.authOtp,
        CupertinoIcons.number),
    _AuthEntry('忘记密码页', '输入邮箱/手机号，发送重置链接或验证码', Routes.authForgotPassword,
        CupertinoIcons.question_circle),
    _AuthEntry('重置密码页', '设置新密码、确认密码和失效状态提示', Routes.authResetPassword,
        CupertinoIcons.lock_rotation),
    _AuthEntry('修改密码页', '旧密码、新密码和确认新密码', Routes.authChangePassword,
        CupertinoIcons.lock),
    _AuthEntry(
        '账号绑定页', '绑定手机号、邮箱和第三方账号', Routes.authBinding, CupertinoIcons.link),
    _AuthEntry('账号解绑页 / 安全验证页', '解绑前二次验证，防误操作或盗号', Routes.authUnbinding,
        CupertinoIcons.shield),
    _AuthEntry('补全资料页', '昵称、头像、生日、性别和地区', Routes.authCompleteProfile,
        CupertinoIcons.person_crop_circle_badge_plus),
    _AuthEntry('权限申请说明页', '先解释用途，再触发系统权限', Routes.authPermissionIntro,
        CupertinoIcons.hand_raised),
    _AuthEntry('邮箱/手机号验证状态页', '验证链接已发送和重新发送', Routes.authVerificationStatus,
        CupertinoIcons.mail),
    _AuthEntry('二次验证页 / MFA 页', '高风险操作和异地登录验证', Routes.authMfa,
        CupertinoIcons.shield_lefthalf_fill),
    _AuthEntry('会话过期页 / 重新登录页', 'token 过期或账号在别处登录', Routes.authSessionExpired,
        CupertinoIcons.clock),
    _AuthEntry('账号安全页', '绑定方式、设备、改密、MFA 和注销入口', Routes.authAccountSecurity,
        CupertinoIcons.checkmark_shield),
    _AuthEntry('登录设备管理页', '查看当前设备，退出其他设备', Routes.authDevices,
        CupertinoIcons.device_laptop),
    _AuthEntry(
        '注销账号页', '注销后果、冷静期和最终确认', Routes.authDelete, CupertinoIcons.delete),
    _AuthEntry('条款和隐私政策页', '注册、登录、注销和权限说明可复用', Routes.authTerms,
        CupertinoIcons.doc_text),
    _AuthEntry('第三方登录回调/中转页', '处理登录返回、loading、错误和取消',
        Routes.authThirdPartyCallback, CupertinoIcons.arrow_2_circlepath),
    _AuthEntry('异常状态页', '冻结、封禁、审核、客服、网络和维护状态', Routes.authException,
        CupertinoIcons.exclamationmark_octagon),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF6F7FA),
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Auth'),
        border: null,
        backgroundColor: Color(0xCCF6F7FA),
      ),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
              children: _entries
                  .map(
                    (entry) => _AuthEntryTile(
                      title: entry.title,
                      subtitle: entry.subtitle,
                      icon: entry.icon,
                      onTap: () => Application.router.navigateTo(
                        context,
                        entry.route,
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthEntry {
  const _AuthEntry(this.title, this.subtitle, this.route, this.icon);

  final String title;
  final String subtitle;
  final String route;
  final IconData icon;
}

class _AuthEntryTile extends StatelessWidget {
  const _AuthEntryTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        onPressed: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8EAF0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF667085),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFF202127),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF8A92A0),
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  CupertinoIcons.chevron_right,
                  color: Color(0xFFADB4C0),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
