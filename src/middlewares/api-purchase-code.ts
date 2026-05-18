import type { Context, Next } from 'koa';

export async function apiPurchaseCode(ctx: Context, next: Next): Promise<void> {
  // TODO: 对齐 Laravel apipurchasecode 逻辑
  await next();
}
