import Router from '@koa/router';
import type { Context } from 'koa';
import { DtliveController } from './dtlive.controller';

const dtliveRouter = new Router({ prefix: '/api' });
const controller = new DtliveController();

dtliveRouter.post('/get_channel', async (ctx: Context) => {
  await controller.getChannel(ctx);
});

dtliveRouter.post('/section_list', async (ctx: Context) => {
  await controller.sectionList(ctx);
});

dtliveRouter.post('/content_detail', async (ctx: Context) => {
  await controller.contentDetail(ctx);
});

dtliveRouter.post('/content_by_channel', async (ctx: Context) => {
  await controller.contentByChannel(ctx);
});

dtliveRouter.post('/add_continue_watching', async (ctx: Context) => {
  await controller.addContinueWatching(ctx);
});

dtliveRouter.post('/add_remove_like', async (ctx: Context) => {
  await controller.addRemoveLike(ctx);
});

dtliveRouter.post('/add_remove_bookmark', async (ctx: Context) => {
  await controller.addRemoveBookmark(ctx);
});

export { dtliveRouter };
