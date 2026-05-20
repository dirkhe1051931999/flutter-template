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
  method: 'GET' | 'POST';
  path: string;
  title: string;
  summary: string;
  fields: DocField[];
  requestExample: string;
  successExample: string;
  errorCodes: Array<{ code: number; meaning: string }>;
  authFailureExample: string;
};

function escapeHtml(value: string): string {
  return value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');
}

function parseExampleObject(input: string): Record<string, unknown> {
  try {
    const parsed = JSON.parse(input) as unknown;
    if (parsed && typeof parsed === 'object' && !Array.isArray(parsed)) {
      return parsed as Record<string, unknown>;
    }
  } catch {
    return {};
  }

  return {};
}

const apiDocs: ApiDoc[] = [
  {
    slug: 'get_channel',
    method: 'POST',
    path: '/api/get_channel',
    title: '获取频道列表',
    summary: '返回当前可用频道列表，并补齐频道图片 URL。',
    fields: [],
    requestExample: `{}`,
    successExample: `{
  "status": 200,
  "message": "Data retrieved successfully",
  "result": [
    {
      "id": 1,
      "name": "News Channel",
      "portrait_img": "https://example.com/uploads/channel/portrait/xxx.png",
      "landscape_img": "https://example.com/uploads/channel/landscape/xxx.png",
      "status": 1
    }
  ]
}`,
    errorCodes: [
      { code: 200, meaning: '请求成功' },
      { code: 400, meaning: '数据为空或业务处理失败' },
      { code: 401, meaning: '缺少或错误的 Api-Token' },
    ],
    authFailureExample: `{
  "status": 401,
  "errors": "Api token missing"
}`,
  },
  {
    slug: 'section_list',
    method: 'POST',
    path: '/api/section_list',
    title: '获取首页 section 列表',
    summary: '按首页场景、内容类型与分页参数返回 section 列表和分页信息。',
    fields: [
      { name: 'is_home_screen', type: 'number', required: true, description: '首页场景标识，只允许 1 或 2。' },
      { name: 'type_id', type: 'number', required: true, description: '内容类型 ID。' },
      { name: 'page_no', type: 'number', required: false, description: '页码，默认 1。' },
      { name: 'user_id', type: 'number', required: false, description: '用户 ID，默认 0。' },
      { name: 'device_id', type: 'string', required: false, description: '设备 ID，用于配合家长控制状态判断。' },
    ],
    requestExample: `{
  "is_home_screen": 1,
  "type_id": 1,
  "page_no": 1,
  "user_id": 12,
  "device_id": "device-001"
}`,
    successExample: `{
  "status": 200,
  "message": "Data retrieved successfully",
  "result": [
    {
      "id": 3,
      "title": "Trending",
      "video_type": 1,
      "data": []
    }
  ],
  "total_rows": 8,
  "total_page": 1,
  "current_page": 1,
  "more_page": false
}`,
    errorCodes: [
      { code: 200, meaning: '请求成功' },
      { code: 400, meaning: '参数缺失、参数类型错误或数据为空' },
      { code: 401, meaning: '缺少或错误的 Api-Token' },
    ],
    authFailureExample: `{
  "status": 401,
  "errors": "Invalid api token"
}`,
  },
  {
    slug: 'content_detail',
    method: 'POST',
    path: '/api/content_detail',
    title: '获取内容详情',
    summary: '根据类型与内容 ID 返回单个内容详情、cast 和 season 等扩展信息。',
    fields: [
      { name: 'type_id', type: 'number', required: true, description: '内容类型 ID。' },
      { name: 'video_type', type: 'number', required: true, description: '内容视频类型。' },
      { name: 'video_id', type: 'number', required: true, description: '内容主键 ID。' },
      { name: 'sub_video_type', type: 'number', required: false, description: '子视频类型，默认 0。对于部分类型必须为 1 或 2。' },
      { name: 'user_id', type: 'number', required: false, description: '用户 ID，默认 0。' },
      { name: 'is_kids_profile', type: 'number', required: false, description: '是否儿童模式，默认 0。' },
    ],
    requestExample: `{
  "type_id": 1,
  "video_type": 1,
  "video_id": 25,
  "sub_video_type": 0,
  "user_id": 12,
  "is_kids_profile": 0
}`,
    successExample: `{
  "status": 200,
  "message": "Data retrieved successfully",
  "result": [
    {
      "id": 25,
      "name": "Example Content",
      "thumbnail": "https://example.com/uploads/content/portrait/xxx.png",
      "landscape": "https://example.com/uploads/content/landscape/xxx.png",
      "cast": [],
      "season": [],
      "is_bookmark": 0,
      "is_user_like": 0
    }
  ]
}`,
    errorCodes: [
      { code: 200, meaning: '请求成功' },
      { code: 400, meaning: '参数错误、内容不存在或子类型非法' },
      { code: 401, meaning: '缺少或错误的 Api-Token' },
    ],
    authFailureExample: `{
  "status": 401,
  "errors": "Api token missing"
}`,
  },
  {
    slug: 'content_by_channel',
    method: 'POST',
    path: '/api/content_by_channel',
    title: '按频道获取内容列表',
    summary: '根据频道 ID 返回内容列表，并附带分页信息。',
    fields: [
      { name: 'channel_id', type: 'number', required: true, description: '频道 ID。' },
      { name: 'user_id', type: 'number', required: false, description: '用户 ID，默认 0。' },
      { name: 'is_kids_profile', type: 'number', required: false, description: '是否儿童模式，默认 0。' },
      { name: 'page_no', type: 'number', required: false, description: '页码，默认 1。' },
    ],
    requestExample: `{
  "channel_id": 2,
  "user_id": 12,
  "is_kids_profile": 0,
  "page_no": 1
}`,
    successExample: `{
  "status": 200,
  "message": "Data retrieved successfully",
  "result": [
    {
      "id": 101,
      "name": "Channel Content",
      "sub_video_type": 1
    }
  ],
  "total_rows": 10,
  "total_page": 1,
  "current_page": 1,
  "more_page": false
}`,
    errorCodes: [
      { code: 200, meaning: '请求成功' },
      { code: 400, meaning: '参数错误或无数据' },
      { code: 401, meaning: '缺少或错误的 Api-Token' },
    ],
    authFailureExample: `{
  "status": 401,
  "errors": "Invalid api token"
}`,
  },
  {
    slug: 'add_continue_watching',
    method: 'POST',
    path: '/api/add_continue_watching',
    title: '新增或更新继续观看记录',
    summary: '写入当前用户的继续观看进度。',
    fields: [
      { name: 'user_id', type: 'number', required: true, description: '用户 ID。' },
      { name: 'is_kids_profile', type: 'number', required: true, description: '是否儿童模式。' },
      { name: 'video_type', type: 'number', required: true, description: '视频类型。' },
      { name: 'sub_video_type', type: 'number', required: false, description: '子视频类型，默认 0。' },
      { name: 'video_id', type: 'number', required: true, description: '内容 ID。' },
      { name: 'episode_id', type: 'number', required: false, description: '分集 ID，默认 0。' },
      { name: 'stop_time', type: 'number', required: true, description: '停止播放时间，通常为秒或毫秒数值。' },
    ],
    requestExample: `{
  "user_id": 12,
  "is_kids_profile": 0,
  "video_type": 2,
  "sub_video_type": 0,
  "video_id": 35,
  "episode_id": 6,
  "stop_time": 840
}`,
    successExample: `{
  "status": 200,
  "message": "Added continue watching"
}`,
    errorCodes: [
      { code: 200, meaning: '写入成功' },
      { code: 400, meaning: '参数缺失或类型错误' },
      { code: 401, meaning: '缺少或错误的 Api-Token' },
    ],
    authFailureExample: `{
  "status": 401,
  "errors": "Api token missing"
}`,
  },
  {
    slug: 'add_remove_like',
    method: 'POST',
    path: '/api/add_remove_like',
    title: '点赞 / 取消点赞',
    summary: '同一接口根据当前状态执行点赞或取消点赞。',
    fields: [
      { name: 'user_id', type: 'number', required: true, description: '用户 ID。' },
      { name: 'video_type', type: 'number', required: true, description: '视频类型。' },
      { name: 'sub_video_type', type: 'number', required: false, description: '子视频类型，默认 0。' },
      { name: 'video_id', type: 'number', required: true, description: '内容 ID。' },
    ],
    requestExample: `{
  "user_id": 12,
  "video_type": 1,
  "sub_video_type": 0,
  "video_id": 25
}`,
    successExample: `{
  "status": 200,
  "message": "Content liked"
}`,
    errorCodes: [
      { code: 200, meaning: '点赞或取消点赞成功' },
      { code: 400, meaning: '参数缺失或类型错误' },
      { code: 401, meaning: '缺少或错误的 Api-Token' },
    ],
    authFailureExample: `{
  "status": 401,
  "errors": "Invalid api token"
}`,
  },
  {
    slug: 'add_remove_bookmark',
    method: 'POST',
    path: '/api/add_remove_bookmark',
    title: '收藏 / 取消收藏',
    summary: '同一接口根据当前状态执行收藏或取消收藏。',
    fields: [
      { name: 'user_id', type: 'number', required: true, description: '用户 ID。' },
      { name: 'is_kids_profile', type: 'number', required: true, description: '是否儿童模式。' },
      { name: 'video_type', type: 'number', required: true, description: '视频类型。' },
      { name: 'sub_video_type', type: 'number', required: false, description: '子视频类型，默认 0。' },
      { name: 'video_id', type: 'number', required: true, description: '内容 ID。' },
    ],
    requestExample: `{
  "user_id": 12,
  "is_kids_profile": 0,
  "video_type": 1,
  "sub_video_type": 0,
  "video_id": 25
}`,
    successExample: `{
  "status": 200,
  "message": "Content bookmarked"
}`,
    errorCodes: [
      { code: 200, meaning: '收藏或取消收藏成功' },
      { code: 400, meaning: '参数缺失或类型错误' },
      { code: 401, meaning: '缺少或错误的 Api-Token' },
    ],
    authFailureExample: `{
  "status": 401,
  "errors": "Api token missing"
}`,
  },
];

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
    h1, h2, h3 { margin-top:0; }
    h1 { font-size:32px; margin-bottom:12px; }
    h2 { font-size:22px; margin-bottom:14px; }
    h3 { font-size:18px; margin-bottom:10px; }
    p { line-height:1.7; }
    .muted { color:#6b7280; }
    .badge { display:inline-block; padding:4px 10px; border-radius:999px; font-size:12px; font-weight:700; }
    .badge-post { background:#dbeafe; color:#1d4ed8; }
    .badge-get { background:#dcfce7; color:#166534; }
    .grid { display:grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap:16px; }
    .endpoint { border:1px solid #e5e7eb; border-radius:12px; padding:16px; background:#f8fafc; }
    .path { display:block; font-family: Consolas, monospace; font-size:14px; margin:10px 0 8px; word-break: break-all; }
    code, pre { font-family: Consolas, monospace; }
    pre { background:#0f172a; color:#e2e8f0; padding:16px; border-radius:12px; overflow:auto; font-size:13px; line-height:1.6; }
    ul { padding-left:20px; }
    table { width:100%; border-collapse: collapse; margin-top:10px; }
    th, td { text-align:left; padding:10px 12px; border-top:1px solid #e5e7eb; vertical-align:top; }
    th { background:#f8fafc; }
    a { color:#2563eb; text-decoration:none; }
    .topbar { display:flex; justify-content:space-between; align-items:flex-start; gap:16px; margin-bottom:14px; }
    .link-group { display:flex; gap:10px; flex-wrap:wrap; }
    .link-btn { display:inline-flex; align-items:center; justify-content:center; min-width:110px; padding:10px 12px; border-radius:8px; background:#eef2ff; color:#1e3a8a; }
    .debug-grid { display:grid; gap:14px; }
    .debug-field { display:grid; gap:8px; }
    .debug-label { font-weight:700; color:#111827; }
    .debug-grid input { width:100%; box-sizing:border-box; padding:10px 12px; border:1px solid #d1d5db; border-radius:10px; font:inherit; }
    .debug-action-row { display:flex; justify-content:flex-start; }
    .debug-submit { padding:10px 16px; border:none; border-radius:10px; background:#111827; color:#fff; cursor:pointer; font:inherit; }
    .debug-submit:disabled { opacity:.6; cursor:not-allowed; }
  </style>
</head>
<body>
  <div class="container">${body}</div>
</body>
</html>`;
}

function renderCommonIntro(): string {
  return `<div class="card">
    <h2>调用要求</h2>
    <ul>
      <li>公开业务接口走 <code>/api/*</code>，当前已开放接口以 <strong>POST</strong> 为主。</li>
      <li>请求头必须携带 <code>Api-Token</code>。</li>
      <li>当服务端启用了购买码校验但未验证通过时，会返回 <code>Purchase code is not verified</code>。</li>
      <li>请求体建议使用 <code>application/json</code>。</li>
    </ul>
    <h3>示例请求头</h3>
    <pre>Api-Token: YOUR_API_TOKEN
Content-Type: application/json</pre>
  </div>
  <div class="card">
    <h2>通用返回结构</h2>
    <table>
      <thead>
        <tr>
          <th>字段</th>
          <th>说明</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td><code>status</code></td>
          <td>状态码。成功一般为 200，鉴权失败通常为 401，业务失败多为 400。</td>
        </tr>
        <tr>
          <td><code>message</code></td>
          <td>响应说明。</td>
        </tr>
        <tr>
          <td><code>result</code></td>
          <td>成功时的主体数据。</td>
        </tr>
        <tr>
          <td><code>total_rows / total_page / current_page / more_page</code></td>
          <td>列表型接口的分页字段。</td>
        </tr>
        <tr>
          <td><code>errors</code></td>
          <td>失败时的错误信息。</td>
        </tr>
      </tbody>
    </table>
  </div>`;
}

function renderDocsIndexPage(): string {
  const endpointCards = apiDocs
    .map(
      (doc) => `<div class="endpoint">
        <span class="badge ${doc.method === 'GET' ? 'badge-get' : 'badge-post'}">${doc.method}</span>
        <span class="path">${doc.path}</span>
        <div style="font-weight:700; margin-bottom:8px;">${doc.title}</div>
        <div class="muted">${doc.summary}</div>
        <div style="margin-top:12px;"><a class="link-btn" href="/docs/api/${doc.slug}">查看详情</a></div>
      </div>`,
    )
    .join('');

  return renderLayout(
    'DTLive API Docs',
    `<div class="hero">
      <div class="badge badge-post" style="margin-bottom:12px;">Public API Docs</div>
      <h1>DTLive API 文档首页</h1>
      <p class="muted">这里是面向外部调用方的 API 文档入口。你可以先看总览，再进入每个接口的详情页查看参数表、请求示例、成功响应、错误码和鉴权失败示例。</p>
      <p class="muted">Base URL：<code>/api</code></p>
    </div>
    ${renderCommonIntro()}
    <div class="card">
      <h2>接口目录</h2>
      <div class="grid">${endpointCards}</div>
    </div>`,
  );
}

function renderFieldRows(fields: DocField[]): string {
  if (fields.length === 0) {
    return `<tr><td colspan="4" class="muted">该接口无需业务参数，请直接提交空 JSON 对象即可。</td></tr>`;
  }

  return fields
    .map(
      (field) => `<tr>
        <td><code>${field.name}</code></td>
        <td>${field.type}</td>
        <td>${field.required ? '是' : '否'}</td>
        <td>${field.description}</td>
      </tr>`,
    )
    .join('');
}

function renderErrorRows(items: Array<{ code: number; meaning: string }>): string {
  return items
    .map(
      (item) => `<tr>
        <td><code>${item.code}</code></td>
        <td>${item.meaning}</td>
      </tr>`,
    )
    .join('');
}

function renderRequestDebugger(doc: ApiDoc): string {
  const exampleObject = parseExampleObject(doc.requestExample);
  const fieldRows = doc.fields.length === 0
    ? `<div class="muted">该接口无需业务参数，将直接提交空 JSON 对象。</div>`
    : doc.fields
        .map((field) => {
          const exampleValue = exampleObject[field.name];
          const defaultValue = exampleValue === undefined || exampleValue === null ? '' : String(exampleValue);

          return `<label class="debug-field">
            <div class="debug-label"><code>${field.name}</code> <span class="muted">${field.type}${field.required ? ' · 必填' : ' · 可选'}</span></div>
            <input data-param-name="${escapeHtml(field.name)}" data-param-type="${escapeHtml(field.type)}" placeholder="${escapeHtml(field.description)}" value="${escapeHtml(defaultValue)}" />
          </label>`;
        })
        .join('');

  return `<div class="card">
    <h2>请求调试</h2>
    <div class="muted" style="margin-bottom:14px;">按参数一行一个填写，点击发送后会直接请求当前接口并展示返回结果。</div>
    <div class="debug-grid" data-doc-debugger data-endpoint="${escapeHtml(doc.path)}" data-method="${doc.method}">
      <label class="debug-field">
        <div class="debug-label"><code>Api-Token</code> <span class="muted">请求头</span></div>
        <input data-api-token placeholder="请输入 Api-Token" />
      </label>
      ${fieldRows}
      <div class="debug-action-row">
        <button type="button" class="debug-submit">发送请求</button>
      </div>
      <div>
        <div class="debug-label">请求体预览</div>
        <pre class="debug-request">{}</pre>
      </div>
      <div>
        <div class="debug-label">响应结果</div>
        <pre class="debug-response">点击“发送请求”后查看结果</pre>
      </div>
    </div>
  </div>`;
}

function renderDocsDetailPage(doc: ApiDoc): string {
  return renderLayout(
    `${doc.title} - DTLive API Docs`,
    `<div class="hero">
      <div class="topbar">
        <div>
          <div class="badge ${doc.method === 'GET' ? 'badge-get' : 'badge-post'}" style="margin-bottom:12px;">${doc.method}</div>
          <h1>${doc.title}</h1>
          <div class="path">${doc.path}</div>
          <p class="muted">${doc.summary}</p>
        </div>
        <div class="link-group">
          <a class="link-btn" href="/docs">返回文档首页</a>
        </div>
      </div>
    </div>
    ${renderCommonIntro()}
    <div class="card">
      <h2>参数表</h2>
      <table>
        <thead>
          <tr>
            <th>参数</th>
            <th>类型</th>
            <th>必填</th>
            <th>说明</th>
          </tr>
        </thead>
        <tbody>
          ${renderFieldRows(doc.fields)}
        </tbody>
      </table>
    </div>
    <div class="card">
      <h2>请求 JSON 示例</h2>
      <pre>${doc.requestExample}</pre>
    </div>
    ${renderRequestDebugger(doc)}
    <div class="card">
      <h2>成功响应 JSON 示例</h2>
      <pre>${doc.successExample}</pre>
    </div>
    <div class="card">
      <h2>错误码说明</h2>
      <table>
        <thead>
          <tr>
            <th>状态码</th>
            <th>含义</th>
          </tr>
        </thead>
        <tbody>
          ${renderErrorRows(doc.errorCodes)}
        </tbody>
      </table>
    </div>
    <div class="card">
      <h2>鉴权失败示例</h2>
      <pre>${doc.authFailureExample}</pre>
    </div>
    <script>
      (() => {
        const debuggers = document.querySelectorAll('[data-doc-debugger]');

        const parseValue = (rawValue, type) => {
          const value = rawValue.trim();
          if (value.length === 0) {
            return undefined;
          }
          if (type === 'number') {
            const parsed = Number(value);
            return Number.isNaN(parsed) ? value : parsed;
          }
          if (type === 'boolean') {
            return value === 'true' || value === '1';
          }
          return value;
        };

        debuggers.forEach((root) => {
          const endpoint = root.getAttribute('data-endpoint') || '';
          const method = root.getAttribute('data-method') || 'POST';
          const tokenInput = root.querySelector('[data-api-token]');
          const submitButton = root.querySelector('.debug-submit');
          const requestPreview = root.querySelector('.debug-request');
          const responsePreview = root.querySelector('.debug-response');
          const paramInputs = Array.from(root.querySelectorAll('[data-param-name]'));

          const buildPayload = () => {
            const payload = {};
            paramInputs.forEach((input) => {
              const name = input.getAttribute('data-param-name') || '';
              const type = input.getAttribute('data-param-type') || 'string';
              const value = parseValue(input.value || '', type);
              if (value !== undefined && name) {
                payload[name] = value;
              }
            });
            return payload;
          };

          const syncPreview = () => {
            requestPreview.textContent = JSON.stringify(buildPayload(), null, 2);
          };

          paramInputs.forEach((input) => input.addEventListener('input', syncPreview));
          syncPreview();

          submitButton?.addEventListener('click', async () => {
            const payload = buildPayload();
            responsePreview.textContent = '请求中...';
            submitButton.disabled = true;

            try {
              const response = await fetch(endpoint, {
                method,
                headers: {
                  'Content-Type': 'application/json',
                  ...(tokenInput?.value ? { 'Api-Token': tokenInput.value } : {}),
                },
                body: method === 'GET' ? undefined : JSON.stringify(payload),
              });

              const text = await response.text();
              try {
                const json = JSON.parse(text);
                responsePreview.textContent = JSON.stringify({
                  http_status: response.status,
                  body: json,
                }, null, 2);
              } catch {
                responsePreview.textContent = JSON.stringify({
                  http_status: response.status,
                  body: text,
                }, null, 2);
              }
            } catch (error) {
              responsePreview.textContent = JSON.stringify({
                error: error instanceof Error ? error.message : String(error),
              }, null, 2);
            } finally {
              submitButton.disabled = false;
            }
          });
        });
      })();
    </script>`,
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
    ctx.body = renderLayout(
      'Docs 404',
      `<div class="hero">
        <h1>文档不存在</h1>
        <p class="muted">未找到对应接口文档：<code>/docs/api/${slug}</code></p>
        <div style="margin-top:16px;"><a class="link-btn" href="/docs">返回文档首页</a></div>
      </div>`,
    );
    return;
  }

  ctx.type = 'html';
  ctx.body = renderDocsDetailPage(doc);
});

export { docsRouter };
