import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:oolaf_flutted/pages/404/index.dart';
import 'package:oolaf_flutted/router/handler.dart';

class Routes {
  static const root = "/";
  static const transitionDetail = "/transition-detail";
  static const fixedTransitionDetail = "/fixed-transition-detail";
  static const dialogDemo = "/dialog-demo";
  static const todolist = "/todolist";
  static const fluro = "/fluro";
  static const request = "/request";
  static const oolafDynamicAudio = "/oolaf-dynamic-audio";
  static const shortVideo = "/short-video";
  static const auth = "/auth";
  static const authSplashGate = "/auth/splash-gate";
  static const authLogin = "/auth/login";
  static const authRegister = "/auth/register";
  static const authOtp = "/auth/otp";
  static const authForgotPassword = "/auth/forgot-password";
  static const authResetPassword = "/auth/reset-password";
  static const authChangePassword = "/auth/change-password";
  static const authBinding = "/auth/binding";
  static const authUnbinding = "/auth/unbinding";
  static const authCompleteProfile = "/auth/complete-profile";
  static const authPermissionIntro = "/auth/permission-intro";
  static const authVerificationStatus = "/auth/verification-status";
  static const authMfa = "/auth/mfa";
  static const authSessionExpired = "/auth/session-expired";
  static const authAccountSecurity = "/auth/account-security";
  static const authDevices = "/auth/devices";
  static const authDelete = "/auth/delete";
  static const authTerms = "/auth/terms";
  static const authPrivacy = "/auth/privacy";
  static const authThirdPartyCallback = "/auth/third-party-callback";
  static const authException = "/auth/exception";
  static const profile = "/profile";
  static const scrollableTabs = "/scrollable-tabs";
  static const networkImageDemo = "/network-image-demo";
  static const appAssetIconDemo = "/app-asset-icon-demo";
  static const appButtonDemo = "/app-button-demo";
  static const appActionSheetDemo = "/app-action-sheet-demo";
  static const appCalendarDemo = "/app-calendar-demo";
  static const appDatePickerDemo = "/app-date-picker-demo";
  static const appDialogDemo = "/app-dialog-demo";
  static const appDropdownMenuDemo = "/app-dropdown-menu-demo";
  static const appIndexBarDemo = "/app-index-bar-demo";
  static const appNoticeBarDemo = "/app-notice-bar-demo";
  static const appPickerDemo = "/app-picker-demo";
  static const appCheckboxDemo = "/app-checkbox-demo";
  static const appSwitchDemo = "/app-switch-demo";
  static const appStepperDemo = "/app-stepper-demo";
  static const appStepsDemo = "/app-steps-demo";
  static const appTabDemo = "/app-tab-demo";
  static const appFieldDemo = "/app-field-demo";
  static const appPasswordInputDemo = "/app-password-input-demo";
  static const appPopoverDemo = "/app-popover-demo";
  static const appRadioDemo = "/app-radio-demo";
  static const appRollingTextDemo = "/app-rolling-text-demo";
  static const appSearchDemo = "/app-search-demo";
  static const appSwipeDemo = "/app-swipe-demo";
  static const appSwipeCellDemo = "/app-swipe-cell-demo";
  static const appTagDemo = "/app-tag-demo";
  static const appTextEllipsisDemo = "/app-text-ellipsis-demo";
  static const appToastDemo = "/app-toast-demo";
  static const appSidebarDemo = "/app-sidebar-demo";
  static const areaPickDemo = "/area-pick-demo";
  static const appSheetDemo = "/app-sheet-demo";
  static const galleryPreviewDemo = "/gallery-preview-demo";
  static const routeBottomNavBarDemo = "/route-bottom-nav-bar-demo";
  static const routePageHeaderDemo = "/route-page-header-demo";
  static const weather = "/weather";
  static const hupu = "/hupu";
  static const hupuLogin = "/hupu/login";
  static const tetris = "/tetris";
  static const hupuPostDetail = "/hupu/post_detail";

  static void configureRoutes(FluroRouter router) {
    router.notFoundHandler = Handler(handlerFunc: (
      BuildContext? context,
      Map<String, List<String>> params,
    ) {
      return const NotFoundPage();
    });
    router.define(root, handler: rootHandler);
    router.define(transitionDetail, handler: transitionDetailRouteHandler);
    router.define(
      fixedTransitionDetail,
      handler: transitionDetailRouteHandler,
      transitionType: TransitionType.inFromLeft,
    );
    router.define(dialogDemo, handler: dialogDemoRouteHandler);
    router.define(todolist, handler: todolistRouteHandler);
    router.define(fluro, handler: fluroRouteHandler);
    router.define(request, handler: requestRouteHandler);
    router.define(oolafDynamicAudio, handler: oolafDynamicAudioRouteHandler);
    router.define(shortVideo, handler: shortVideoRouteHandler);
    router.define(auth, handler: authRouteHandler);
    router.define(authSplashGate, handler: authSplashGateRouteHandler);
    router.define(authLogin, handler: authLoginRouteHandler);
    router.define(authRegister, handler: authRegisterRouteHandler);
    router.define(authOtp, handler: authOtpRouteHandler);
    router.define(authForgotPassword, handler: authForgotPasswordRouteHandler);
    router.define(authResetPassword, handler: authResetPasswordRouteHandler);
    router.define(authChangePassword, handler: authChangePasswordRouteHandler);
    router.define(authBinding, handler: authBindingRouteHandler);
    router.define(authUnbinding, handler: authUnbindingRouteHandler);
    router.define(authCompleteProfile,
        handler: authCompleteProfileRouteHandler);
    router.define(authPermissionIntro,
        handler: authPermissionIntroRouteHandler);
    router.define(
      authVerificationStatus,
      handler: authVerificationStatusRouteHandler,
    );
    router.define(authMfa, handler: authMfaRouteHandler);
    router.define(authSessionExpired, handler: authSessionExpiredRouteHandler);
    router.define(authAccountSecurity,
        handler: authAccountSecurityRouteHandler);
    router.define(authDevices, handler: authDevicesRouteHandler);
    router.define(authDelete, handler: authDeleteRouteHandler);
    router.define(authTerms, handler: authTermsRouteHandler);
    router.define(authPrivacy, handler: authPrivacyRouteHandler);
    router.define(
      authThirdPartyCallback,
      handler: authThirdPartyCallbackRouteHandler,
    );
    router.define(authException, handler: authExceptionRouteHandler);
    router.define(
      profile,
      handler: profileRouteHandler,
    );
    router.define(
      scrollableTabs,
      handler: scrollableTabsRouteHandler,
    );
    router.define(
      networkImageDemo,
      handler: networkImageDemoRouteHandler,
    );
    router.define(
      appAssetIconDemo,
      handler: appAssetIconDemoRouteHandler,
    );
    router.define(
      appButtonDemo,
      handler: appButtonDemoRouteHandler,
    );
    router.define(
      appActionSheetDemo,
      handler: appActionSheetDemoRouteHandler,
    );
    router.define(
      appCalendarDemo,
      handler: appCalendarDemoRouteHandler,
    );
    router.define(
      appDialogDemo,
      handler: appDialogDemoRouteHandler,
    );
    router.define(
      appDropdownMenuDemo,
      handler: appDropdownMenuDemoRouteHandler,
    );
    router.define(
      appIndexBarDemo,
      handler: appIndexBarDemoRouteHandler,
    );
    router.define(
      appNoticeBarDemo,
      handler: appNoticeBarDemoRouteHandler,
    );
    router.define(
      appDatePickerDemo,
      handler: appDatePickerDemoRouteHandler,
    );
    router.define(
      appPickerDemo,
      handler: appPickerDemoRouteHandler,
    );
    router.define(
      appCheckboxDemo,
      handler: appCheckboxDemoRouteHandler,
    );
    router.define(
      appSwitchDemo,
      handler: appSwitchDemoRouteHandler,
    );
    router.define(
      appStepperDemo,
      handler: appStepperDemoRouteHandler,
    );
    router.define(
      appStepsDemo,
      handler: appStepsDemoRouteHandler,
    );
    router.define(
      appTabDemo,
      handler: appTabDemoRouteHandler,
    );
    router.define(
      appFieldDemo,
      handler: appFieldDemoRouteHandler,
    );
    router.define(
      appPasswordInputDemo,
      handler: appPasswordInputDemoRouteHandler,
    );
    router.define(
      appPopoverDemo,
      handler: appPopoverDemoRouteHandler,
    );
    router.define(
      appRadioDemo,
      handler: appRadioDemoRouteHandler,
    );
    router.define(
      appRollingTextDemo,
      handler: appRollingTextDemoRouteHandler,
    );
    router.define(
      appSearchDemo,
      handler: appSearchDemoRouteHandler,
    );
    router.define(
      appSwipeDemo,
      handler: appSwipeDemoRouteHandler,
    );
    router.define(
      appSwipeCellDemo,
      handler: appSwipeCellDemoRouteHandler,
    );
    router.define(
      appTagDemo,
      handler: appTagDemoRouteHandler,
    );
    router.define(
      appTextEllipsisDemo,
      handler: appTextEllipsisDemoRouteHandler,
    );
    router.define(
      appToastDemo,
      handler: appToastDemoRouteHandler,
    );
    router.define(
      appSidebarDemo,
      handler: appSidebarDemoRouteHandler,
    );
    router.define(
      areaPickDemo,
      handler: areaPickDemoRouteHandler,
    );
    router.define(
      appSheetDemo,
      handler: appSheetDemoRouteHandler,
    );
    router.define(
      galleryPreviewDemo,
      handler: galleryPreviewDemoRouteHandler,
    );
    router.define(
      routeBottomNavBarDemo,
      handler: routeBottomNavBarDemoRouteHandler,
    );
    router.define(
      routePageHeaderDemo,
      handler: routePageHeaderDemoRouteHandler,
    );
    router.define(
      weather,
      handler: weatherRouteHandler,
    );
    router.define(
      hupu,
      handler: hupuRouteHandler,
    );
    router.define(
      hupuLogin,
      handler: hupuLoginRouteHandler,
    );
    router.define(
      tetris,
      handler: tetrisRouteHandler,
    );
    router.define(
      hupuPostDetail,
      handler: hupuPostDetailRouteHandler,
    );
  }
}
