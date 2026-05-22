import Router from '@koa/router';
import type { Context } from 'koa';
import { DtliveController } from './dtlive.controller';

const dtliveRouter = new Router({ prefix: '/api' });
const controller = new DtliveController();

dtliveRouter.get('/register', async (ctx: Context) => {
  await controller.register(ctx);
});

dtliveRouter.post('/register', async (ctx: Context) => {
  await controller.register(ctx);
});

dtliveRouter.get('/login', async (ctx: Context) => {
  await controller.login(ctx);
});

dtliveRouter.post('/login', async (ctx: Context) => {
  await controller.login(ctx);
});

dtliveRouter.get('/get_profile', async (ctx: Context) => {
  await controller.getProfile(ctx);
});

dtliveRouter.post('/get_profile', async (ctx: Context) => {
  await controller.getProfile(ctx);
});

dtliveRouter.get('/update_profile', async (ctx: Context) => {
  await controller.updateProfile(ctx);
});

dtliveRouter.post('/update_profile', async (ctx: Context) => {
  await controller.updateProfile(ctx);
});

dtliveRouter.get('/get_tv_login_code', async (ctx: Context) => {
  await controller.getTvLoginCode(ctx);
});

dtliveRouter.post('/get_tv_login_code', async (ctx: Context) => {
  await controller.getTvLoginCode(ctx);
});

dtliveRouter.get('/tv_login', async (ctx: Context) => {
  await controller.tvLogin(ctx);
});

dtliveRouter.post('/tv_login', async (ctx: Context) => {
  await controller.tvLogin(ctx);
});

dtliveRouter.get('/check_tv_login', async (ctx: Context) => {
  await controller.checkTvLogin(ctx);
});

dtliveRouter.post('/check_tv_login', async (ctx: Context) => {
  await controller.checkTvLogin(ctx);
});

dtliveRouter.get('/parent_control_check_password', async (ctx: Context) => {
  await controller.parentControlCheckPassword(ctx);
});

dtliveRouter.post('/parent_control_check_password', async (ctx: Context) => {
  await controller.parentControlCheckPassword(ctx);
});

dtliveRouter.get('/get_device_sync_list', async (ctx: Context) => {
  await controller.getDeviceSyncList(ctx);
});

dtliveRouter.post('/get_device_sync_list', async (ctx: Context) => {
  await controller.getDeviceSyncList(ctx);
});

dtliveRouter.get('/logout_device_sync', async (ctx: Context) => {
  await controller.logoutDeviceSync(ctx);
});

dtliveRouter.post('/logout_device_sync', async (ctx: Context) => {
  await controller.logoutDeviceSync(ctx);
});

dtliveRouter.get('/add_remove_device_watching', async (ctx: Context) => {
  await controller.addRemoveDeviceWatching(ctx);
});

dtliveRouter.post('/add_remove_device_watching', async (ctx: Context) => {
  await controller.addRemoveDeviceWatching(ctx);
});

dtliveRouter.get('/general_setting', async (ctx: Context) => {
  await controller.generalSetting(ctx);
});

dtliveRouter.post('/general_setting', async (ctx: Context) => {
  await controller.generalSetting(ctx);
});

dtliveRouter.get('/get_payment_option', async (ctx: Context) => {
  await controller.getPaymentOption(ctx);
});

dtliveRouter.post('/get_payment_option', async (ctx: Context) => {
  await controller.getPaymentOption(ctx);
});

dtliveRouter.get('/get_social_link', async (ctx: Context) => {
  await controller.getSocialLink(ctx);
});

dtliveRouter.post('/get_social_link', async (ctx: Context) => {
  await controller.getSocialLink(ctx);
});

dtliveRouter.get('/get_onboarding_screen', async (ctx: Context) => {
  await controller.getOnboardingScreen(ctx);
});

dtliveRouter.post('/get_onboarding_screen', async (ctx: Context) => {
  await controller.getOnboardingScreen(ctx);
});

dtliveRouter.get('/get_avatar', async (ctx: Context) => {
  await controller.getAvatar(ctx);
});

dtliveRouter.post('/get_avatar', async (ctx: Context) => {
  await controller.getAvatar(ctx);
});

dtliveRouter.get('/get_category', async (ctx: Context) => {
  await controller.getCategory(ctx);
});

dtliveRouter.post('/get_category', async (ctx: Context) => {
  await controller.getCategory(ctx);
});

dtliveRouter.get('/get_language', async (ctx: Context) => {
  await controller.getLanguage(ctx);
});

dtliveRouter.post('/get_language', async (ctx: Context) => {
  await controller.getLanguage(ctx);
});

dtliveRouter.get('/get_type', async (ctx: Context) => {
  await controller.getType(ctx);
});

dtliveRouter.post('/get_type', async (ctx: Context) => {
  await controller.getType(ctx);
});

dtliveRouter.get('/get_package', async (ctx: Context) => {
  await controller.getPackage(ctx);
});

dtliveRouter.post('/get_package', async (ctx: Context) => {
  await controller.getPackage(ctx);
});

dtliveRouter.get('/add_transaction', async (ctx: Context) => {
  await controller.addTransaction(ctx);
});

dtliveRouter.post('/add_transaction', async (ctx: Context) => {
  await controller.addTransaction(ctx);
});

dtliveRouter.get('/add_rent_transaction', async (ctx: Context) => {
  await controller.addRentTransaction(ctx);
});

dtliveRouter.post('/add_rent_transaction', async (ctx: Context) => {
  await controller.addRentTransaction(ctx);
});

dtliveRouter.get('/update_transaction_status', async (ctx: Context) => {
  await controller.updateTransactionStatus(ctx);
});

dtliveRouter.post('/update_transaction_status', async (ctx: Context) => {
  await controller.updateTransactionStatus(ctx);
});

dtliveRouter.get('/get_transaction_list', async (ctx: Context) => {
  await controller.getTransactionList(ctx);
});

dtliveRouter.post('/get_transaction_list', async (ctx: Context) => {
  await controller.getTransactionList(ctx);
});

dtliveRouter.get('/apply_coupon', async (ctx: Context) => {
  await controller.applyCoupon(ctx);
});

dtliveRouter.post('/apply_coupon', async (ctx: Context) => {
  await controller.applyCoupon(ctx);
});

dtliveRouter.get('/get_coupon_list', async (ctx: Context) => {
  await controller.getCouponList(ctx);
});

dtliveRouter.post('/get_coupon_list', async (ctx: Context) => {
  await controller.getCouponList(ctx);
});

dtliveRouter.get('/user_rent_content_list', async (ctx: Context) => {
  await controller.userRentContentList(ctx);
});

dtliveRouter.post('/user_rent_content_list', async (ctx: Context) => {
  await controller.userRentContentList(ctx);
});

dtliveRouter.get('/rent_content_list', async (ctx: Context) => {
  await controller.rentContentList(ctx);
});

dtliveRouter.post('/rent_content_list', async (ctx: Context) => {
  await controller.rentContentList(ctx);
});

dtliveRouter.get('/create_razorpay_order', async (ctx: Context) => {
  await controller.createRazorpayOrder(ctx);
});

dtliveRouter.post('/create_razorpay_order', async (ctx: Context) => {
  await controller.createRazorpayOrder(ctx);
});

dtliveRouter.get('/getReferEarnHistory', async (ctx: Context) => {
  await controller.getReferEarnHistory(ctx);
});

dtliveRouter.post('/getReferEarnHistory', async (ctx: Context) => {
  await controller.getReferEarnHistory(ctx);
});

dtliveRouter.get('/get_refer_earn_history', async (ctx: Context) => {
  await controller.getReferEarnHistory(ctx);
});

dtliveRouter.post('/get_refer_earn_history', async (ctx: Context) => {
  await controller.getReferEarnHistory(ctx);
});

dtliveRouter.get('/validate_coupon', async (ctx: Context) => {
  await controller.validateCoupon(ctx);
});

dtliveRouter.post('/validate_coupon', async (ctx: Context) => {
  await controller.validateCoupon(ctx);
});

dtliveRouter.get('/add_wallet_amount', async (ctx: Context) => {
  await controller.addWalletAmount(ctx);
});

dtliveRouter.post('/add_wallet_amount', async (ctx: Context) => {
  await controller.addWalletAmount(ctx);
});

dtliveRouter.get('/get_wallet_transaction', async (ctx: Context) => {
  await controller.getWalletTransaction(ctx);
});

dtliveRouter.post('/get_wallet_transaction', async (ctx: Context) => {
  await controller.getWalletTransaction(ctx);
});

dtliveRouter.get('/get_vdocipher_otp', async (ctx: Context) => {
  await controller.getVdocipherOtp(ctx);
});

dtliveRouter.post('/get_vdocipher_otp', async (ctx: Context) => {
  await controller.getVdocipherOtp(ctx);
});

dtliveRouter.get('/get_pages', async (ctx: Context) => {
  await controller.getPages(ctx);
});

dtliveRouter.post('/get_pages', async (ctx: Context) => {
  await controller.getPages(ctx);
});

dtliveRouter.get('/get_banner', async (ctx: Context) => {
  await controller.getBanner(ctx);
});

dtliveRouter.post('/get_banner', async (ctx: Context) => {
  await controller.getBanner(ctx);
});

dtliveRouter.get('/section_detail', async (ctx: Context) => {
  await controller.sectionDetail(ctx);
});

dtliveRouter.post('/section_detail', async (ctx: Context) => {
  await controller.sectionDetail(ctx);
});

dtliveRouter.get('/content_by_category', async (ctx: Context) => {
  await controller.contentByCategory(ctx);
});

dtliveRouter.post('/content_by_category', async (ctx: Context) => {
  await controller.contentByCategory(ctx);
});

dtliveRouter.get('/content_by_language', async (ctx: Context) => {
  await controller.contentByLanguage(ctx);
});

dtliveRouter.post('/content_by_language', async (ctx: Context) => {
  await controller.contentByLanguage(ctx);
});

dtliveRouter.get('/content_by_cast', async (ctx: Context) => {
  await controller.contentByCast(ctx);
});

dtliveRouter.post('/content_by_cast', async (ctx: Context) => {
  await controller.contentByCast(ctx);
});

dtliveRouter.get('/search_content', async (ctx: Context) => {
  await controller.searchContent(ctx);
});

dtliveRouter.post('/search_content', async (ctx: Context) => {
  await controller.searchContent(ctx);
});

dtliveRouter.get('/get_channel', async (ctx: Context) => {
  await controller.getChannel(ctx);
});

dtliveRouter.post('/get_channel', async (ctx: Context) => {
  await controller.getChannel(ctx);
});

dtliveRouter.get('/section_list', async (ctx: Context) => {
  await controller.sectionList(ctx);
});

dtliveRouter.post('/section_list', async (ctx: Context) => {
  await controller.sectionList(ctx);
});

dtliveRouter.get('/content_detail', async (ctx: Context) => {
  await controller.contentDetail(ctx);
});

dtliveRouter.post('/content_detail', async (ctx: Context) => {
  await controller.contentDetail(ctx);
});

dtliveRouter.get('/cast_detail', async (ctx: Context) => {
  await controller.castDetail(ctx);
});

dtliveRouter.post('/cast_detail', async (ctx: Context) => {
  await controller.castDetail(ctx);
});

dtliveRouter.get('/get_releted_content', async (ctx: Context) => {
  await controller.getReletedContent(ctx);
});

dtliveRouter.post('/get_releted_content', async (ctx: Context) => {
  await controller.getReletedContent(ctx);
});

dtliveRouter.get('/content_by_channel', async (ctx: Context) => {
  await controller.contentByChannel(ctx);
});

dtliveRouter.post('/content_by_channel', async (ctx: Context) => {
  await controller.contentByChannel(ctx);
});

dtliveRouter.get('/add_continue_watching', async (ctx: Context) => {
  await controller.addContinueWatching(ctx);
});

dtliveRouter.post('/add_continue_watching', async (ctx: Context) => {
  await controller.addContinueWatching(ctx);
});

dtliveRouter.get('/get_video_by_season_id', async (ctx: Context) => {
  await controller.getVideoBySeasonId(ctx);
});

dtliveRouter.post('/get_video_by_season_id', async (ctx: Context) => {
  await controller.getVideoBySeasonId(ctx);
});

dtliveRouter.get('/add_video_view', async (ctx: Context) => {
  await controller.addVideoView(ctx);
});

dtliveRouter.post('/add_video_view', async (ctx: Context) => {
  await controller.addVideoView(ctx);
});

dtliveRouter.get('/get_continue_watching', async (ctx: Context) => {
  await controller.getContinueWatching(ctx);
});

dtliveRouter.post('/get_continue_watching', async (ctx: Context) => {
  await controller.getContinueWatching(ctx);
});

dtliveRouter.get('/remove_continue_watching', async (ctx: Context) => {
  await controller.removeContinueWatching(ctx);
});

dtliveRouter.post('/remove_continue_watching', async (ctx: Context) => {
  await controller.removeContinueWatching(ctx);
});

dtliveRouter.get('/get_bookmark_video', async (ctx: Context) => {
  await controller.getBookmarkVideo(ctx);
});

dtliveRouter.post('/get_bookmark_video', async (ctx: Context) => {
  await controller.getBookmarkVideo(ctx);
});

dtliveRouter.get('/add_remove_like', async (ctx: Context) => {
  await controller.addRemoveLike(ctx);
});

dtliveRouter.post('/add_remove_like', async (ctx: Context) => {
  await controller.addRemoveLike(ctx);
});

dtliveRouter.get('/add_remove_bookmark', async (ctx: Context) => {
  await controller.addRemoveBookmark(ctx);
});

dtliveRouter.post('/add_remove_bookmark', async (ctx: Context) => {
  await controller.addRemoveBookmark(ctx);
});

dtliveRouter.get('/add_comment', async (ctx: Context) => {
  await controller.addComment(ctx);
});

dtliveRouter.post('/add_comment', async (ctx: Context) => {
  await controller.addComment(ctx);
});

dtliveRouter.get('/edit_comment', async (ctx: Context) => {
  await controller.editComment(ctx);
});

dtliveRouter.post('/edit_comment', async (ctx: Context) => {
  await controller.editComment(ctx);
});

dtliveRouter.get('/delete_comment', async (ctx: Context) => {
  await controller.deleteComment(ctx);
});

dtliveRouter.post('/delete_comment', async (ctx: Context) => {
  await controller.deleteComment(ctx);
});

dtliveRouter.get('/get_comment', async (ctx: Context) => {
  await controller.getComment(ctx);
});

dtliveRouter.post('/get_comment', async (ctx: Context) => {
  await controller.getComment(ctx);
});

dtliveRouter.get('/get_replay_comment', async (ctx: Context) => {
  await controller.getReplayComment(ctx);
});

dtliveRouter.post('/get_replay_comment', async (ctx: Context) => {
  await controller.getReplayComment(ctx);
});

dtliveRouter.get('/get_notification', async (ctx: Context) => {
  await controller.getNotification(ctx);
});

dtliveRouter.post('/get_notification', async (ctx: Context) => {
  await controller.getNotification(ctx);
});

dtliveRouter.get('/read_notification', async (ctx: Context) => {
  await controller.readNotification(ctx);
});

dtliveRouter.post('/read_notification', async (ctx: Context) => {
  await controller.readNotification(ctx);
});

dtliveRouter.get('/add_remove_kids_mode', async (ctx: Context) => {
  await controller.addRemoveKidsMode(ctx);
});

dtliveRouter.post('/add_remove_kids_mode', async (ctx: Context) => {
  await controller.addRemoveKidsMode(ctx);
});

dtliveRouter.get('/get_shorts_list', async (ctx: Context) => {
  await controller.getShortsList(ctx);
});

dtliveRouter.post('/get_shorts_list', async (ctx: Context) => {
  await controller.getShortsList(ctx);
});

dtliveRouter.get('/get_shorts_episode', async (ctx: Context) => {
  await controller.getShortsEpisode(ctx);
});

dtliveRouter.post('/get_shorts_episode', async (ctx: Context) => {
  await controller.getShortsEpisode(ctx);
});

dtliveRouter.get('/add_review', async (ctx: Context) => {
  await controller.addReview(ctx);
});

dtliveRouter.post('/add_review', async (ctx: Context) => {
  await controller.addReview(ctx);
});

dtliveRouter.get('/get_reviews', async (ctx: Context) => {
  await controller.getReviews(ctx);
});

dtliveRouter.post('/get_reviews', async (ctx: Context) => {
  await controller.getReviews(ctx);
});

export { dtliveRouter };
