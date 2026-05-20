import type { Context } from 'koa';
import { ok, fail, failWithErrors } from '../../core/http/api-response';
import { DtliveService } from './dtlive.service';

type BodyPayload = Record<string, unknown>;

function getBodyPayload(ctx: Context): BodyPayload {
  const requestWithBody = ctx.request as typeof ctx.request & { body?: unknown };
  if (!requestWithBody.body || typeof requestWithBody.body !== 'object') {
    return {};
  }

  return requestWithBody.body as BodyPayload;
}

export class DtliveController {
  private readonly service = new DtliveService();

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
}
