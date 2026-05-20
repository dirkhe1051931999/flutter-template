import Koa from 'koa';
import bodyParser from 'koa-bodyparser';
import { rootRouter } from './routes/index.route';
import { errorHandler } from './core/middlewares/error-handler';
import { requestLogger } from './core/middlewares/request-logger';
import { applySessionMiddleware } from './core/middlewares/session';
import { renderGlobalNotFoundPage } from './modules/backoffice/backoffice.views';

export function createApp(): Koa {
  const app = new Koa();

  app.use(errorHandler);
  app.use(requestLogger);
  app.use(bodyParser());
  applySessionMiddleware(app);
  app.use(rootRouter.routes());
  app.use(rootRouter.allowedMethods());
  app.use(async (ctx) => {
    if (ctx.status !== 404) {
      return;
    }

    if (ctx.path.startsWith('/api/')) {
      ctx.status = 404;
      ctx.body = {
        status: 404,
        message: 'Not Found',
        errors: 'Route not found',
      };
      return;
    }

    ctx.status = 404;
    ctx.type = 'html';
    ctx.body = renderGlobalNotFoundPage(ctx.path);
  });

  return app;
}
