import Koa from 'koa';
import bodyParser from 'koa-bodyparser';
import { rootRouter } from './routes/index.route';
import { errorHandler } from './core/middlewares/error-handler';
import { requestLogger } from './core/middlewares/request-logger';

export function createApp(): Koa {
  const app = new Koa();

  app.use(errorHandler);
  app.use(requestLogger);
  app.use(bodyParser());
  app.use(rootRouter.routes());
  app.use(rootRouter.allowedMethods());

  return app;
}
