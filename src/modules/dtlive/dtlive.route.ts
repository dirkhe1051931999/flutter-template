import Router from '@koa/router';
import type { Context } from 'koa';
import { ok } from '../../core/http/api-response';

const dtliveRouter = new Router({ prefix: '/api' });

const TODO_MESSAGE = 'TODO: implement with DTLive-compatible behavior';

dtliveRouter.post('/get_channel', async (ctx: Context) => {
  ctx.body = ok(TODO_MESSAGE, []);
});

dtliveRouter.post('/section_list', async (ctx: Context) => {
  ctx.body = ok(TODO_MESSAGE, []);
});

dtliveRouter.post('/content_detail', async (ctx: Context) => {
  ctx.body = ok(TODO_MESSAGE, []);
});

dtliveRouter.post('/content_by_channel', async (ctx: Context) => {
  ctx.body = ok(TODO_MESSAGE, []);
});

dtliveRouter.post('/add_continue_watching', async (ctx: Context) => {
  ctx.body = ok(TODO_MESSAGE);
});

dtliveRouter.post('/add_remove_like', async (ctx: Context) => {
  ctx.body = ok(TODO_MESSAGE);
});

dtliveRouter.post('/add_remove_bookmark', async (ctx: Context) => {
  ctx.body = ok(TODO_MESSAGE);
});

export { dtliveRouter };
