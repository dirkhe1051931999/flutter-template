import Router from '@koa/router';
import type { Context } from 'koa';

const docsRouter = new Router();

type DocField = {
  name: string;
  type: string;
  required: boolean;
  description: string;
};

type ApiDoc = {
  slug: string;
  method: 'POST' | 'GET';
  path: string;
  title: string;
  summary: string;
  fields: DocField[];
  successExample: string;
};

const dtliveApiPaths: string[] = [
  '/api/add_comment',
  '/api/add_continue_watching',
  '/api/add_remove_bookmark',
  '/api/add_remove_device_watching',
  '/api/add_remove_kids_mode',
  '/api/add_remove_like',
  '/api/add_rent_transaction',
  '/api/add_review',
  '/api/add_transaction',
  '/api/add_video_view',
  '/api/add_wallet_amount',
  '/api/apply_coupon',
  '/api/cast_detail',
  '/api/check_tv_login',
  '/api/content_by_cast',
  '/api/content_by_category',
  '/api/content_by_channel',
  '/api/content_by_language',
  '/api/content_detail',
  '/api/create_razorpay_order',
  '/api/delete_comment',
  '/api/edit_comment',
  '/api/general_setting',
  '/api/get_avatar',
  '/api/get_banner',
  '/api/get_bookmark_video',
  '/api/get_category',
  '/api/get_channel',
  '/api/get_comment',
  '/api/get_continue_watching',
  '/api/get_coupon_list',
  '/api/get_device_sync_list',
  '/api/get_language',
  '/api/get_notification',
  '/api/get_onboarding_screen',
  '/api/get_package',
  '/api/get_pages',
  '/api/get_payment_option',
  '/api/get_profile',
  '/api/get_refer_earn_history',
  '/api/get_releted_content',
  '/api/get_replay_comment',
  '/api/get_reviews',
  '/api/get_shorts_episode',
  '/api/get_shorts_list',
  '/api/get_social_link',
  '/api/get_transaction_list',
  '/api/get_tv_login_code',
  '/api/get_type',
  '/api/get_vdocipher_otp',
  '/api/get_video_by_season_id',
  '/api/get_wallet_transaction',
  '/api/getReferEarnHistory',
  '/api/login',
  '/api/logout_device_sync',
  '/api/parent_control_check_password',
  '/api/read_notification',
  '/api/register',
  '/api/remove_continue_watching',
  '/api/rent_content_list',
  '/api/search_content',
  '/api/section_detail',
  '/api/section_list',
  '/api/tv_login',
  '/api/update_profile',
  '/api/update_transaction_status',
  '/api/user_rent_content_list',
  '/api/validate_coupon',
];

const curatedDocs: Record<string, Partial<ApiDoc>> = {
  rent_content_list: {
    title: '租赁内容列表',
    summary: '获取可租赁内容列表，支持按电影/剧集/全部筛选并分页。',
    fields: [
      { name: 'type', type: 'number', required: false, description: '1=电影/视频, 2=剧集, 0或不传=全部' },
      { name: 'user_id', type: 'number', required: false, description: '用户 ID，默认 0' },
      { name: 'device_id', type: 'string', required: false, description: '设备 ID，用于家长控制判定' },
      { name: 'page_no', type: 'number', required: false, description: '页码，默认 1' },
    ],
    successExample: `{
  "status": 200,
  "message": "Data Retrieved Successfully.",
  "result": [
    {
      "id": 101,
      "name": "Sample Rent Content",
      "video_type": 1,
      "sub_video_type": 0
    }
  ],
  "total_rows": 120,
  "total_page": 12,
  "current_page": 1,
  "more_page": true
}`,
  },
};

function toTitle(slug: string): string {
  return `${slug} 接口`;
}

const apiDocs: ApiDoc[] = dtliveApiPaths.map((path) => {
  const slug = path.replace('/api/', '');
  const curated = curatedDocs[slug] ?? {};
  return {
    slug,
    method: 'POST',
    path,
    title: curated.title ?? toTitle(slug),
    summary: curated.summary ?? `Flutter 客户端接口：${path}`,
    fields: curated.fields ?? [],
    successExample: curated.successExample ?? `{
  "status": 200,
  "message": "success",
  "result": {}
}`,
  };
});

function renderLayout(title: string, body: string): string {
  return `<!doctype html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>${title}</title>
  <style>
    body { font-family: Arial, sans-serif; background:#f5f6f8; margin:0; color:#111827; }
    .container { max-width: 1120px; margin: 40px auto; padding: 0 20px; }
    .hero, .card { background:#fff; border-radius:16px; box-shadow:0 8px 24px rgba(15,23,42,.08); }
    .hero { padding:32px; margin-bottom:24px; }
    .card { padding:24px; margin-bottom:20px; }
    h1, h2 { margin-top:0; }
    h1 { font-size:30px; margin-bottom:12px; }
    h2 { font-size:22px; margin-bottom:14px; }
    .muted { color:#6b7280; }
    .badge { display:inline-block; padding:4px 10px; border-radius:999px; font-size:12px; font-weight:700; }
    .badge-post { background:#dbeafe; color:#1d4ed8; }
    .grid { display:grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap:16px; }
    .endpoint { border:1px solid #e5e7eb; border-radius:12px; padding:16px; background:#f8fafc; }
    .path { display:block; font-family: Consolas, monospace; font-size:14px; margin:10px 0 8px; word-break: break-all; }
    pre { font-family: Consolas, monospace; background:#0f172a; color:#e2e8f0; padding:16px; border-radius:12px; overflow:auto; font-size:13px; }
    table { width:100%; border-collapse: collapse; }
    th, td { text-align:left; padding:10px 12px; border-top:1px solid #e5e7eb; vertical-align:top; }
    th { background:#f8fafc; }
    .link-btn { display:inline-flex; align-items:center; justify-content:center; min-width:110px; padding:10px 12px; border-radius:8px; background:#eef2ff; color:#1e3a8a; text-decoration:none; }
  </style>
</head>
<body>
  <div class="container">${body}</div>
</body>
</html>`;
}

function renderFieldRows(fields: DocField[]): string {
  if (fields.length === 0) {
    return '<tr><td colspan="4" class="muted">该接口当前未定义固定业务参数（按客户端实际请求传参）。</td></tr>';
  }

  return fields
    .map((field) => `<tr><td><code>${field.name}</code></td><td>${field.type}</td><td>${field.required ? '是' : '否'}</td><td>${field.description}</td></tr>`)
    .join('');
}

function renderDocsIndexPage(): string {
  const groupDefs: Array<{ key: string; title: string; match: (slug: string) => boolean }> = [
    { key: 'auth', title: '账号与登录', match: (slug) => ['register', 'login', 'get_profile', 'update_profile', 'get_tv_login_code', 'tv_login', 'check_tv_login', 'parent_control_check_password', 'get_device_sync_list', 'logout_device_sync', 'add_remove_device_watching'].includes(slug) },
    { key: 'home', title: '首页与基础配置', match: (slug) => ['general_setting', 'get_payment_option', 'get_social_link', 'get_onboarding_screen', 'get_avatar', 'get_category', 'get_language', 'get_channel', 'get_type', 'get_pages', 'get_banner', 'section_list', 'section_detail'].includes(slug) },
    { key: 'content', title: '内容浏览与详情', match: (slug) => ['content_detail', 'get_releted_content', 'cast_detail', 'content_by_category', 'content_by_language', 'content_by_cast', 'content_by_channel', 'get_video_by_season_id', 'search_content', 'get_shorts_list', 'get_shorts_episode'].includes(slug) },
    { key: 'user_action', title: '用户行为', match: (slug) => ['add_continue_watching', 'remove_continue_watching', 'get_continue_watching', 'add_remove_like', 'add_remove_bookmark', 'get_bookmark_video', 'add_video_view', 'add_comment', 'edit_comment', 'delete_comment', 'get_comment', 'get_replay_comment', 'add_remove_kids_mode', 'add_review', 'get_reviews'].includes(slug) },
    { key: 'payment', title: '交易支付与优惠', match: (slug) => ['add_transaction', 'update_transaction_status', 'get_transaction_list', 'add_rent_transaction', 'rent_content_list', 'user_rent_content_list', 'get_coupon_list', 'apply_coupon', 'validate_coupon', 'create_razorpay_order'].includes(slug) },
    { key: 'wallet', title: '钱包与推荐', match: (slug) => ['get_refer_earn_history', 'getReferEarnHistory', 'add_wallet_amount', 'get_wallet_transaction'].includes(slug) },
    { key: 'notification', title: '通知', match: (slug) => ['get_notification', 'read_notification'].includes(slug) },
    { key: 'media_security', title: '媒体与安全', match: (slug) => ['get_vdocipher_otp'].includes(slug) },
  ];

  const grouped = groupDefs.map((group) => {
    const docs = apiDocs.filter((doc) => group.match(doc.slug));
    return { ...group, docs };
  });
  const uncategorized = apiDocs.filter((doc) => !groupDefs.some((group) => group.match(doc.slug)));

  const renderCards = (docs: ApiDoc[]) => docs
    .map((doc) => `<div class="endpoint"><span class="badge badge-post">POST</span><span class="path">${doc.path}</span><div style="font-weight:700; margin-bottom:8px;">${doc.title}</div><div class="muted">${doc.summary}</div><div style="margin-top:12px;"><a class="link-btn" href="/docs/api/${doc.slug}">查看详情</a></div></div>`)
    .join('');

  const groupedHtml = grouped
    .filter((group) => group.docs.length > 0)
    .map((group) => `<div class="card"><h2>${group.title}（${group.docs.length}）</h2><div class="grid">${renderCards(group.docs)}</div></div>`)
    .join('');

  const uncategorizedHtml = uncategorized.length > 0
    ? `<div class="card"><h2>未分类（${uncategorized.length}）</h2><div class="grid">${renderCards(uncategorized)}</div></div>`
    : '';

  return renderLayout(
    'DTLive API Docs',
    `<div class="hero"><h1>DTLive API 文档</h1><p class="muted">共 ${apiDocs.length} 个接口（Flutter 客户端）。已按业务分类展示。</p></div>${groupedHtml}${uncategorizedHtml}`,
  );
}

function renderDocsDetailPage(doc: ApiDoc): string {
  return renderLayout(
    `${doc.title} - DTLive API Docs`,
    `<div class="hero"><h1>${doc.title}</h1><span class="path">${doc.path}</span><p class="muted">${doc.summary}</p><a class="link-btn" href="/docs">返回文档首页</a></div>
    <div class="card"><h2>请求类型</h2><p><span class="badge badge-post">${doc.method}</span></p></div>
    <div class="card"><h2>参数</h2><table><thead><tr><th>参数</th><th>类型</th><th>必填</th><th>说明</th></tr></thead><tbody>${renderFieldRows(doc.fields)}</tbody></table></div>
    <div class="card"><h2>正确返回示例</h2><pre>${doc.successExample}</pre></div>`,
  );
}

docsRouter.get('/docs', async (ctx: Context) => {
  ctx.type = 'html';
  ctx.body = renderDocsIndexPage();
});

docsRouter.get('/docs/api/:slug', async (ctx: Context) => {
  const slug = String(ctx.params.slug ?? '');
  const doc = apiDocs.find((item) => item.slug === slug);

  if (!doc) {
    ctx.status = 404;
    ctx.type = 'html';
    ctx.body = renderLayout('Docs 404', `<div class="hero"><h1>文档不存在</h1><p class="muted">未找到接口：/docs/api/${slug}</p><a class="link-btn" href="/docs">返回文档首页</a></div>`);
    return;
  }

  ctx.type = 'html';
  ctx.body = renderDocsDetailPage(doc);
});

export { docsRouter };
