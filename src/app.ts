import Koa from 'koa';
import bodyParser from 'koa-bodyparser';
import { rootRouter } from './routes/index.route';
import { errorHandler } from './core/middlewares/error-handler';
import { requestLogger } from './core/middlewares/request-logger';
import { applySessionMiddleware } from './core/middlewares/session';
import { renderGlobalNotFoundPage } from './modules/backoffice/backoffice.views';

function translateApiText(input: string): string {
  const dict: Array<[string, string]> = [
    ['Login Successfully.', '登录成功。'],
    ['Data Retrieved Successfully.', '数据获取成功。'],
    ['Data retrieved successfully', '数据获取成功。'],
    ['Profile Update Successfully.', '资料更新成功。'],
    ['Delete Successfully.', '删除成功。'],
    ['Success.', '成功。'],
    ['Bad request', '请求参数错误。'],
    ['Data Not Found.', '数据不存在。'],
    ['Data not found', '数据不存在。'],
    ['Data Not Saved.', '数据保存失败。'],
    ['Code is wrong.', '验证码错误。'],
    ['Password wrong.', '密码错误。'],
    ['Password is correct.', '密码正确。'],
    ['Order created successfully.', '订单创建成功。'],
    ['OTP Generated Successfully', 'OTP 生成成功。'],
    ['Wallet credited successfully.', '钱包入账成功。'],
    ['Coupon apply successfully.', '优惠券使用成功。'],
    ['Transaction status changed', '交易状态已更新。'],
    ['Failed to create order.', '创建订单失败。'],
    ['Failed to generate OTP', '生成 OTP 失败。'],
    ['Please get subscription.', '请先开通订阅。'],
    ['Streaming limit reached.', '已达到同时播放上限。'],
    ['Device add successfully.', '设备添加成功。'],
    ['Device delete successfully.', '设备移除成功。'],
    ['Type is wrong.', '类型参数错误。'],
    ['Type is Wrong.', '类型参数错误。'],
    ['Something is wrong.', '系统异常，请稍后重试。'],
    ['Your device sync limit is over.', '设备同步数量已超限。'],
    ['Pending moderation', '待审核'],
    ['Approved', '已通过'],
    ['Rejected', '已拒绝'],
    ['Not Found', '未找到'],
    ['Route not found', '接口不存在'],
    ['Status changed', '状态已更新。'],
    ['Transaction status changed', '交易状态已更新。'],
    ['Code is wrong', '验证码错误。'],
    ['Password wrong', '密码错误。'],
    ['Password is correct', '密码正确。'],
    ['required and must be numeric', '为必填且必须为数字'],
    [' is required', '为必填项'],
    ['must be 1 or 2', '只能为 1 或 2'],
    ['must be between 1 and 5', '必须在 1 到 5 之间'],
  ];

  let output = input;
  for (const [from, to] of dict) {
    output = output.split(from).join(to);
  }
  return output;
}

function localizeApiPayload(payload: unknown): unknown {
  if (typeof payload === 'string') {
    return translateApiText(payload);
  }
  if (Array.isArray(payload)) {
    return payload.map((item) => localizeApiPayload(item));
  }
  if (!payload || typeof payload !== 'object') {
    return payload;
  }

  const source = payload as Record<string, unknown>;
  const next: Record<string, unknown> = {};
  for (const [key, value] of Object.entries(source)) {
    next[key] = localizeApiPayload(value);
  }
  return next;
}

function translateBackofficeText(input: string): string {
  const dict: Array<[string, string]> = [
    ['Bad request', '请求参数错误。'],
    ['unauthorized', '未授权'],
    ['data not found', '数据不存在。'],
    ['Data not found', '数据不存在。'],
    ['Data Not Found.', '数据不存在。'],
    ['Operation failed, please try again later.', '操作失败，请稍后重试。'],
    ['Status changed.', '状态已更新。'],
    ['Setting saved.', '设置保存成功。'],
    ['Review approved.', '评论已通过。'],
    ['Review rejected.', '评论已拒绝。'],
    ['Coupon deleted.', '优惠券已删除。'],
    ['Rent price deleted.', '租赁价格已删除。'],
    ['Payment updated successfully.', '支付配置更新成功。'],
    ['Deleted.', '删除成功。'],
    ['Created.', '创建成功。'],
    ['Updated.', '更新成功。'],
    ['Video status changed.', '视频状态已更新。'],
    ['TV show status changed.', '剧集状态已更新。'],
    ['Shorts status changed.', '短剧状态已更新。'],
    ['Banner status changed.', '横幅状态已更新。'],
    ['Section status changed.', '版块状态已更新。'],
  ];
  let output = input;
  for (const [from, to] of dict) {
    output = output.split(from).join(to);
  }
  return output;
}

function localizeBackofficePayload(payload: unknown): unknown {
  if (typeof payload === 'string') {
    return translateBackofficeText(payload);
  }
  if (Array.isArray(payload)) {
    return payload.map((item) => localizeBackofficePayload(item));
  }
  if (!payload || typeof payload !== 'object') {
    return payload;
  }

  const source = payload as Record<string, unknown>;
  const next: Record<string, unknown> = {};
  for (const [key, value] of Object.entries(source)) {
    next[key] = localizeBackofficePayload(value);
  }
  return next;
}

export function createApp(): Koa {
  const app = new Koa();

  app.use(errorHandler);
  app.use(requestLogger);
  app.use(bodyParser());
  applySessionMiddleware(app);
  app.use(async (ctx, next) => {
    await next();
    if (!ctx.path.startsWith('/api/')) {
      if (ctx.path.startsWith('/admin/') || ctx.path.startsWith('/producer/')) {
        ctx.body = localizeBackofficePayload(ctx.body);
      }
      return;
    }
    ctx.body = localizeApiPayload(ctx.body);
  });
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
