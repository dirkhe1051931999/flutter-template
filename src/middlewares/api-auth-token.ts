import type { Middleware } from '@koa/router';
import { env } from '../config/env';

export const apiAuthToken: Middleware = async (ctx, next): Promise<void> => {
  const token = ctx.get('Api-Token');

  if (!token) {
    ctx.status = 401;
    ctx.body = {
      status: 401,
      errors: 'Api token missing',
    };
    return;
  }

  if (!env.apiToken || token !== env.apiToken) {
    ctx.status = 401;
    ctx.body = {
      status: 401,
      errors: 'Invalid api token',
    };
    return;
  }

  await next();
};
