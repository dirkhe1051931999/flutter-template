import Router from '@koa/router';
import { healthRouter } from '../modules/health/health.route';
import { dtliveRouter } from '../modules/dtlive/dtlive.route';
import { docsRouter } from '../modules/docs/docs.route';
import { backofficeRouter } from '../modules/backoffice/backoffice.route';
import { apiAuthToken } from '../middlewares/api-auth-token';
import { apiPurchaseCode } from '../middlewares/api-purchase-code';

const rootRouter = new Router();

dtliveRouter.use(apiPurchaseCode);
dtliveRouter.use(apiAuthToken);

rootRouter.use(healthRouter.routes(), healthRouter.allowedMethods());
rootRouter.use(docsRouter.routes(), docsRouter.allowedMethods());
rootRouter.use(dtliveRouter.routes(), dtliveRouter.allowedMethods());
rootRouter.use(backofficeRouter.routes(), backofficeRouter.allowedMethods());

export { rootRouter };
