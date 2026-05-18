import type { Context, Next } from 'koa';
import { fail } from '../http/api-response';

export async function errorHandler(ctx: Context, next: Next): Promise<void> {
  try {
    await next();
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Internal server error';
    ctx.status = 500;
    ctx.body = fail(message, 500);
  }
}
