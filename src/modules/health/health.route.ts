import Router from '@koa/router';
import type { Context } from 'koa';
import { checkDatabaseConnection } from '../../config/database';
import { ok, fail } from '../../core/http/api-response';

const healthRouter = new Router();

healthRouter.get('/health', async (ctx: Context) => {
  try {
    const dbOk = await checkDatabaseConnection();
    ctx.body = ok('Service healthy', {
      service: 'flutter-template-server',
      database: dbOk ? 'up' : 'down',
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Database unavailable';
    ctx.status = 500;
    ctx.body = fail(message, 500);
  }
});

export { healthRouter };
