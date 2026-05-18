import type { Context, Next } from 'koa';

export async function apiAuthToken(ctx: Context, next: Next): Promise<void> {
  // TODO: 对齐 Laravel apiauthtoken 逻辑
  await next();
}
