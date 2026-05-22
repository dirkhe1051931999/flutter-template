import type { Context } from 'koa';
import { ok, fail, failWithErrors } from '../../core/http/api-response';
import { DtliveService } from './dtlive.service';

type BodyPayload = Record<string, unknown>;

function getBodyPayload(ctx: Context): BodyPayload {
  const payload: BodyPayload = {};
  const queryParams = ctx.query as Record<string, string | string[] | undefined>;
  for (const [key, value] of Object.entries(queryParams)) {
    payload[key] = Array.isArray(value) ? (value[0] ?? '') : (value ?? '');
  }

  const requestWithBody = ctx.request as typeof ctx.request & { body?: unknown };
  if (!requestWithBody.body || typeof requestWithBody.body !== 'object') {
    return payload;
  }

  return {
    ...payload,
    ...(requestWithBody.body as BodyPayload),
  };
}

export class DtliveController {
  private readonly service = new DtliveService();

  async register(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const result = await this.service.registerUser(payload);
      ctx.body = ok('Login Successfully.', [result]);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async login(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const result = await this.service.loginUser(payload);
      ctx.body = ok('Login Successfully.', [result]);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async getProfile(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const result = await this.service.getProfile(payload);
      if (!result) {
        ctx.body = fail('Data Not Found.');
        return;
      }

      ctx.body = ok('Data Retrieved Successfully.', [result]);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async updateProfile(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const result = await this.service.updateProfile(payload);
      if (!result) {
        ctx.body = fail('Data Not Found.');
        return;
      }

      ctx.body = ok('Profile Update Successfully.', [result]);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async getTvLoginCode(ctx: Context): Promise<void> {
    try {
      const result = await this.service.getTvLoginCode();
      ctx.body = ok('Data Retrieved Successfully.', [result]);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async tvLogin(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const result = await this.service.tvLogin(payload);
      if (!result) {
        ctx.body = failWithErrors('Code is wrong.');
        return;
      }

      ctx.body = ok('Data Retrieved Successfully.', [result]);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async checkTvLogin(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const result = await this.service.checkTvLogin(payload);
      if (!result) {
        ctx.body = failWithErrors('Code is wrong.');
        return;
      }

      ctx.body = ok('Data Retrieved Successfully.', [result]);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async parentControlCheckPassword(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const passed = await this.service.parentControlCheckPassword(payload);
      if (!passed) {
        ctx.body = failWithErrors('Password wrong.');
        return;
      }

      ctx.body = ok('Password is correct.');
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async getDeviceSyncList(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const result = await this.service.getDeviceSyncList(payload);
      if (result.length === 0) {
        ctx.body = fail('Data Not Found.');
        return;
      }

      ctx.body = ok('Data Retrieved Successfully.', result);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async logoutDeviceSync(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      await this.service.logoutDeviceSync(payload);
      ctx.body = ok('Delete Successfully.');
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async addRemoveDeviceWatching(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const result = await this.service.addRemoveDeviceWatching(payload);
      if (result.status === 400) {
        ctx.body = {
          status: 400,
          message: String(result.message ?? 'Bad request'),
          result: Array.isArray(result.result) ? result.result : [],
        };
        return;
      }

      ctx.body = ok(String(result.message ?? 'Success.'));
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async generalSetting(ctx: Context): Promise<void> {
    try {
      const result = await this.service.getGeneralSetting();
      ctx.body = ok('Data Retrieved Successfully.', result);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async getPaymentOption(ctx: Context): Promise<void> {
    try {
      const result = await this.service.getPaymentOption();
      ctx.body = ok('Data Retrieved Successfully.', result);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async getPages(ctx: Context): Promise<void> {
    try {
      const result = await this.service.getPages();
      ctx.body = ok('Data Retrieved Successfully.', result);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async getSocialLink(ctx: Context): Promise<void> {
    try {
      const result = await this.service.getSocialLinks();
      if (result.length === 0) {
        ctx.body = fail('Data Not Found.');
        return;
      }

      ctx.body = ok('Data Retrieved Successfully.', result);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async getOnboardingScreen(ctx: Context): Promise<void> {
    try {
      const result = await this.service.getOnboardingScreen();
      if (result.length === 0) {
        ctx.body = fail('Data Not Found.');
        return;
      }

      ctx.body = ok('Data Retrieved Successfully.', result);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async getAvatar(ctx: Context): Promise<void> {
    try {
      const result = await this.service.getAvatar();
      if (result.length === 0) {
        ctx.body = fail('Data Not Found.');
        return;
      }

      ctx.body = ok('Data Retrieved Successfully.', result);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async getCategory(ctx: Context): Promise<void> {
    try {
      const result = await this.service.getCategory();
      if (result.length === 0) {
        ctx.body = fail('Data Not Found.');
        return;
      }

      ctx.body = ok('Data Retrieved Successfully.', result);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async getLanguage(ctx: Context): Promise<void> {
    try {
      const result = await this.service.getLanguage();
      if (result.length === 0) {
        ctx.body = fail('Data Not Found.');
        return;
      }

      ctx.body = ok('Data Retrieved Successfully.', result);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async getType(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const result = await this.service.getType(payload);
      if (result.length === 0) {
        ctx.body = fail('Data Not Found.');
        return;
      }

      ctx.body = ok('Data Retrieved Successfully.', result);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async getPackage(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const result = await this.service.getPackage(payload);
      ctx.body = ok('Data Retrieved Successfully.', result);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async addTransaction(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const result = await this.service.addTransaction(payload);
      ctx.body = ok('Transaction Successful.', [result]);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async addRentTransaction(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const result = await this.service.addRentTransaction(payload);
      ctx.body = ok('Transaction Successful.', [result]);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async updateTransactionStatus(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const changed = await this.service.updateTransactionStatus(payload);
      if (!changed) {
        ctx.body = fail('Data Not Saved.');
        return;
      }

      ctx.body = ok('Transaction status changed');
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async getTransactionList(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const response = await this.service.getTransactionList(payload);
      if (response.result.length === 0) {
        ctx.body = fail('Data Not Found.');
        return;
      }

      ctx.body = ok('Data Retrieved Successfully.', response.result, response.pagination);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async applyCoupon(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const result = await this.service.applyCoupon(payload);
      ctx.body = ok('Coupon apply successfully.', result);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async getCouponList(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const response = await this.service.getCouponList(payload);
      if (response.result.length === 0) {
        ctx.body = fail('Data Not Found.');
        return;
      }

      ctx.body = ok('Data Retrieved Successfully.', response.result, response.pagination);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async userRentContentList(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const response = await this.service.userRentContentList(payload);
      if (response.result.length === 0) {
        ctx.body = fail('Data Not Found.');
        return;
      }

      ctx.body = ok('Data Retrieved Successfully.', response.result, response.pagination);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async rentContentList(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const response = await this.service.rentContentList(payload);
      if (response.result.length === 0) {
        ctx.body = fail('Data Not Found.');
        return;
      }

      ctx.body = ok('Data Retrieved Successfully.', response.result, response.pagination);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async createRazorpayOrder(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const result = await this.service.createRazorpayOrder(payload);
      ctx.body = ok('Order created successfully.', result);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async getReferEarnHistory(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const response = await this.service.getReferEarnHistory(payload);
      if (response.result.length === 0) {
        ctx.body = fail('Data Not Found.');
        return;
      }

      ctx.body = ok('Data Retrieved Successfully.', response.result, response.pagination);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async addWalletAmount(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const result = await this.service.addWalletAmount(payload);
      ctx.body = ok('Wallet credited successfully.', result);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async getWalletTransaction(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const response = await this.service.getWalletTransaction(payload);
      if (response.result.length === 0) {
        ctx.body = fail('Data Not Found.');
        return;
      }

      ctx.body = ok('Data Retrieved Successfully.', response.result, response.pagination);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async getVdocipherOtp(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const result = await this.service.getVdocipherOtp(payload);
      ctx.body = ok('OTP Generated Successfully', result);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async getBanner(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const result = await this.service.getBanner(payload);
      if (result.length === 0) {
        ctx.body = fail('Data Not Found.');
        return;
      }

      ctx.body = ok('Data Retrieved Successfully.', result);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async sectionDetail(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const response = await this.service.sectionDetail(payload);
      if (!response || response.result.length === 0) {
        ctx.body = fail('Data Not Found.');
        return;
      }

      ctx.body = ok('Data Retrieved Successfully.', response.result, response.pagination);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async contentByCategory(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const response = await this.service.contentByCategory(payload);
      if (response.result.length === 0) {
        ctx.body = fail('Data Not Found.');
        return;
      }

      ctx.body = ok('Data Retrieved Successfully.', response.result, response.pagination);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async contentByLanguage(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const response = await this.service.contentByLanguage(payload);
      if (response.result.length === 0) {
        ctx.body = fail('Data Not Found.');
        return;
      }

      ctx.body = ok('Data Retrieved Successfully.', response.result, response.pagination);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async searchContent(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const response = await this.service.searchContent(payload);
      if (response.result.length === 0) {
        ctx.body = fail('Data Not Found.');
        return;
      }

      ctx.body = ok('Data Retrieved Successfully.', response.result, response.pagination);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async getChannel(ctx: Context): Promise<void> {
    try {
      const result = await this.service.getChannelList();
      if (result.length === 0) {
        ctx.body = fail('Data not found');
        return;
      }

      ctx.body = ok('Data retrieved successfully', result);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async sectionList(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const response = await this.service.getSectionList(payload);
      if (response.result.length === 0) {
        ctx.body = fail('Data not found');
        return;
      }

      ctx.body = ok('Data retrieved successfully', response.result, response.pagination);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async contentDetail(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const result = await this.service.getContentDetail(payload);
      if (result.length === 0) {
        ctx.body = fail('Data not found');
        return;
      }

      ctx.body = ok('Data retrieved successfully', result);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async contentByChannel(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const response = await this.service.getContentByChannel(payload);
      if (response.result.length === 0) {
        ctx.body = fail('Data not found');
        return;
      }

      ctx.body = ok('Data retrieved successfully', response.result, response.pagination);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async addContinueWatching(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      await this.service.addContinueWatching(payload);
      ctx.body = ok('Added continue watching');
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async getVideoBySeasonId(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const response = await this.service.getVideoBySeasonId(payload);
      if (response.result.length === 0) {
        ctx.body = fail('Data Not Found.');
        return;
      }

      ctx.body = ok('Data Retrieved Successfully.', response.result, response.pagination);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async addVideoView(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const added = await this.service.addVideoView(payload);
      ctx.body = ok(added ? 'View added' : 'Content already viewed');
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async getContinueWatching(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const response = await this.service.getContinueWatching(payload);
      if (response.result.length === 0) {
        ctx.body = fail('Data Not Found.');
        return;
      }

      ctx.body = ok('Data Retrieved Successfully.', response.result, response.pagination);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async removeContinueWatching(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      await this.service.removeContinueWatching(payload);
      ctx.body = ok('Remove continue watching');
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async getBookmarkVideo(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const response = await this.service.getBookmarkVideo(payload);
      if (response.result.length === 0) {
        ctx.body = fail('Data Not Found.');
        return;
      }

      ctx.body = ok('Data Retrieved Successfully.', response.result, response.pagination);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async addRemoveLike(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const liked = await this.service.addRemoveLike(payload);
      ctx.body = ok(liked ? 'Content liked' : 'Content unliked');
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async addRemoveBookmark(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const bookmarked = await this.service.addRemoveBookmark(payload);
      ctx.body = ok(bookmarked ? 'Content bookmarked' : 'Bookmark removed');
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async addComment(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      await this.service.addComment(payload);
      ctx.body = ok('Comment added');
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async editComment(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const updated = await this.service.editComment(payload);
      if (!updated) {
        ctx.body = fail('Data Not Found.');
        return;
      }

      ctx.body = ok('Comment edited');
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async deleteComment(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const deleted = await this.service.deleteComment(payload);
      if (!deleted) {
        ctx.body = fail('Data Not Found.');
        return;
      }

      ctx.body = ok('Comment deleted');
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async getComment(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const response = await this.service.getComment(payload);
      if (response.result.length === 0) {
        ctx.body = fail('Data Not Found.');
        return;
      }

      ctx.body = ok('Data Retrieved Successfully.', response.result, response.pagination);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async getReplayComment(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const response = await this.service.getReplayComment(payload);
      if (response.result.length === 0) {
        ctx.body = fail('Data Not Found.');
        return;
      }

      ctx.body = ok('Data Retrieved Successfully.', response.result, response.pagination);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async getNotification(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const response = await this.service.getNotification(payload);
      if (response.result.length === 0) {
        ctx.body = fail('Data Not Found.');
        return;
      }

      ctx.body = ok('Data Retrieved Successfully.', response.result, response.pagination);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async readNotification(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      await this.service.readNotification(payload);
      ctx.body = ok('Notification read');
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async addRemoveKidsMode(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const updated = await this.service.addRemoveKidsMode(payload);
      if (!updated) {
        ctx.body = fail('Data Not Found.');
        return;
      }

      ctx.body = ok('Status changed');
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async getShortsList(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const response = await this.service.getShortsList(payload);
      if (response.result.length === 0) {
        ctx.body = fail('Data Not Found.');
        return;
      }

      ctx.body = ok('Data Retrieved Successfully.', response.result, response.pagination);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async getShortsEpisode(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const result = await this.service.getShortsEpisode(payload);
      if (result.length === 0) {
        ctx.body = fail('Data Not Found.');
        return;
      }

      ctx.body = ok('Data Retrieved Successfully.', result);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async castDetail(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const result = await this.service.castDetail(payload);
      if (!result) {
        ctx.body = fail('Data Not Found.');
        return;
      }

      ctx.body = ok('Data Retrieved Successfully.', [result]);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async contentByCast(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const response = await this.service.contentByCast(payload);
      if (response.result.length === 0) {
        ctx.body = fail('Data Not Found.');
        return;
      }

      ctx.body = ok('Data Retrieved Successfully.', response.result, response.pagination);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async getReletedContent(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const response = await this.service.getRelatedContent(payload);
      if (!response || response.result.length === 0) {
        ctx.body = fail('Data Not Found.');
        return;
      }

      ctx.body = ok('Data Retrieved Successfully.', response.result, response.pagination);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async addReview(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const action = await this.service.addReview(payload);
      ctx.body = ok(action === 'updated' ? 'Review updated' : 'Review submitted');
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async getReviews(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const response = await this.service.getReviews(payload);
      if (!response) {
        ctx.body = fail('Data Not Found.');
        return;
      }

      ctx.body = ok('Data Retrieved Successfully.', response.result, response.pagination);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }

  async validateCoupon(ctx: Context): Promise<void> {
    try {
      const payload = getBodyPayload(ctx);
      const result = await this.service.validateCoupon(payload);
      ctx.body = ok('Data Retrieved Successfully.', [result]);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Bad request';
      ctx.body = failWithErrors(message);
    }
  }
}
