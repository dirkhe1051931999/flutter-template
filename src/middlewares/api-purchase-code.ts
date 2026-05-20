import type { Middleware } from '@koa/router';
import { env } from '../config/env';

export const apiPurchaseCode: Middleware = async (ctx, next): Promise<void> => {
  if (!env.purchaseCodeEnabled) {
    await next();
    return;
  }

  const purchaseCode = process.env.PURCHASE_CODE;
  const buyerUsername = process.env.BUYER_USERNAME;
  const purchaseStatus = process.env.PURCHASE_STATUS;
  const verified = Boolean(purchaseCode && buyerUsername && purchaseStatus === '1');

  if (!verified) {
    ctx.status = 400;
    ctx.body = {
      status: 400,
      errors: 'Purchase code is not verified',
    };
    return;
  }

  await next();
};
