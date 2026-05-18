import Router from '@koa/router';
import { healthRouter } from '../modules/health/health.route';
import { dtliveRouter } from '../modules/dtlive/dtlive.route';
import { apiAuthToken } from '../middlewares/api-auth-token';
import { apiPurchaseCode } from '../middlewares/api-purchase-code';

const rootRouter = new Router();

rootRouter.use(healthRouter.routes(), healthRouter.allowedMethods());
rootRouter.use(apiPurchaseCode);
rootRouter.use(apiAuthToken);
rootRouter.use(dtliveRouter.routes(), dtliveRouter.allowedMethods());

export { rootRouter };
