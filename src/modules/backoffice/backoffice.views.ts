import fs from 'node:fs';
import path from 'node:path';
import ejs from 'ejs';

const layoutTemplatePath = path.resolve(process.cwd(), 'src/modules/backoffice/templates/layout.ejs');
const layoutTemplate = fs.readFileSync(layoutTemplatePath, 'utf8');
const producerVideoTemplatePath = path.resolve(process.cwd(), 'src/modules/backoffice/templates/producer-video.ejs');
const producerVideoTemplate = fs.readFileSync(producerVideoTemplatePath, 'utf8');
const producerTvShowTemplatePath = path.resolve(process.cwd(), 'src/modules/backoffice/templates/producer-tvshow.ejs');
const producerTvShowTemplate = fs.readFileSync(producerTvShowTemplatePath, 'utf8');
const producerShortsTemplatePath = path.resolve(process.cwd(), 'src/modules/backoffice/templates/producer-shorts.ejs');
const producerShortsTemplate = fs.readFileSync(producerShortsTemplatePath, 'utf8');

function localizeBackofficeText(input: string): string {
  const dict: Array<[string, string]> = [
    ['404 Not Found', '404 页面不存在'],
    ['Admin 404', '管理后台 404'],
    ['Producer 404', '制作人后台 404'],
    ['Admin Login', '管理后台登录'],
    ['Producer Login', '制作人登录'],
    ['Email', '邮箱'],
    ['Password', '密码'],
    ['Sign In', '登录'],
    ['Back Dashboard', '返回仪表盘'],
    ['Back', '返回'],
    ['Logout', '退出登录'],
    ['Profile', '个人资料'],
    ['Channel', '频道'],
    ['Dashboard', '仪表盘'],
    ['Create', '新增'],
    ['Edit', '编辑'],
    ['Update', '更新'],
    ['Delete', '删除'],
    ['Save', '保存'],
    ['Status', '状态'],
    ['Toggle Status', '切换状态'],
    ['Actions', '操作'],
    ['Search', '搜索'],
    ['Reset', '重置'],
    ['Submit', '提交'],
    ['Cancel', '取消'],
    ['Name', '名称'],
    ['Title', '标题'],
    ['Image', '图片'],
    ['Image filename', '图片文件名'],
    ['Portrait image', '竖图'],
    ['Landscape image', '横图'],
    ['Is title (0/1)', '是否标题(0/1)'],
    ['Icon', '图标'],
    ['Portrait', '竖图'],
    ['Landscape', '横图'],
    ['Category', '分类'],
    ['Language', '语言'],
    ['Season', '季'],
    ['Avatar', '头像'],
    ['Banner', '横幅'],
    ['Section', '版块'],
    ['Video', '视频'],
    ['TV Show', '剧集'],
    ['Shorts', '短剧'],
    ['Episode', '剧集分集'],
    ['User', '用户'],
    ['Producer', '制作人'],
    ['Producers', '制作人'],
    ['Cast', '演员'],
    ['Casts', '演员'],
    ['Coupon', '优惠券'],
    ['Coupons', '优惠券'],
    ['Package', '套餐'],
    ['Packages', '套餐'],
    ['Transaction', '交易'],
    ['Transactions', '交易'],
    ['Rent Transaction', '租赁交易'],
    ['Rent Transactions', '租赁交易'],
    ['Rent Price', '租赁价格'],
    ['Rent Price List', '租赁价格'],
    ['Withdrawal', '提现'],
    ['Withdrawals', '提现'],
    ['Wallet Transaction', '钱包流水'],
    ['Wallet Transactions', '钱包流水'],
    ['Notification', '通知'],
    ['Notifications', '通知'],
    ['Notification Config', '通知配置'],
    ['Notification Setting', '通知设置'],
    ['Notification Configuration', '通知配置'],
    ['App Setting', '应用设置'],
    ['Panel Setting', '面板设置'],
    ['System Setting', '系统设置'],
    ['Payment', '支付'],
    ['Payment Option', '支付方式'],
    ['Page', '页面'],
    ['Reviews', '评论'],
    ['Review', '评论'],
    ['Type', '类型'],
    ['Section List', '版块列表'],
    ['Dashboard Stats', '仪表盘统计'],
    ['Admin Dashboard', '管理后台仪表盘'],
    ['Producer Dashboard', '制作人仪表盘'],
    ['Producer Profile', '制作人资料'],
    ['Producer Change Password', '制作人修改密码'],
    ['Producer Video', '制作人视频'],
    ['Producer TV Show', '制作人剧集'],
    ['Producer Shorts', '制作人短剧'],
    ['Producer Video Detail', '制作人视频详情'],
    ['Producer Video Edit', '制作人视频编辑'],
    ['Producer TV Show Edit', '制作人剧集编辑'],
    ['Producer Shorts Edit', '制作人短剧编辑'],
    ['Producer TV Show Episode Edit', '制作人剧集分集编辑'],
    ['Producer Shorts Episode Edit', '制作人短剧分集编辑'],
    ['Back Video', '返回视频'],
    ['Back TV Show', '返回剧集'],
    ['Back Shorts', '返回短剧'],
    ['Back User', '返回用户'],
    ['Back Producer', '返回制作人'],
    ['Back Cast', '返回演员'],
    ['Create Successfully.', '创建成功。'],
    ['Updated successfully.', '更新成功。'],
    ['Sort order saved.', '排序已保存。'],
    ['No rows found', '暂无数据'],
    ['No record found', '暂无记录'],
    ['No data found', '暂无数据'],
    ['No category data', '暂无分类数据'],
    ['No channel data', '暂无频道数据'],
    ['No avatar data', '暂无头像数据'],
    ['No banner data', '暂无横幅数据'],
    ['No language data', '暂无语言数据'],
    ['No season data', '暂无季度数据'],
    ['No type data', '暂无类型数据'],
    ['No section data', '暂无版块数据'],
    ['Create a category first to manage it here.', '请先创建分类后再进行管理。'],
    ['Create a channel first to manage it here.', '请先创建频道后再进行管理。'],
    ['Create an avatar first to manage it here.', '请先创建头像后再进行管理。'],
    ['Create a banner first to manage it here.', '请先创建横幅后再进行管理。'],
    ['Create a language first to manage it here.', '请先创建语言后再进行管理。'],
    ['Create a season first to manage it here.', '请先创建季度后再进行管理。'],
    ['Create a type first to manage it here.', '请先创建类型后再进行管理。'],
    ['Create a section first to manage it here.', '请先创建版块后再进行管理。'],
    ['Profile updated successfully.', '资料更新成功。'],
    ['Banner created successfully.', '横幅创建成功。'],
    ['Banner updated successfully.', '横幅更新成功。'],
    ['Section created successfully.', '版块创建成功。'],
    ['Section updated successfully.', '版块更新成功。'],
    ['Type created successfully.', '类型创建成功。'],
    ['Type updated successfully.', '类型更新成功。'],
    ['Avatar created successfully.', '头像创建成功。'],
    ['Avatar updated successfully.', '头像更新成功。'],
    ['Channel created successfully.', '频道创建成功。'],
    ['Channel updated successfully.', '频道更新成功。'],
    ['Category created successfully.', '分类创建成功。'],
    ['Category updated successfully.', '分类更新成功。'],
    ['Language created successfully.', '语言创建成功。'],
    ['Language updated successfully.', '语言更新成功。'],
    ['Season created successfully.', '季度创建成功。'],
    ['Season updated successfully.', '季度更新成功。'],
    ['TV Show updated successfully.', '剧集更新成功。'],
    ['Shorts updated successfully.', '短剧更新成功。'],
    ['Video updated successfully.', '视频更新成功。'],
    ['Episode updated successfully.', '分集更新成功。'],
    ['Withdrawal request created successfully.', '提现申请提交成功。'],
    ['Operation failed, please try again later.', '操作失败，请稍后重试。'],
    ['Operation failed, please try again.', '操作失败，请稍后重试。'],
    ['Operation failed.', '操作失败。'],
    ['Access denied: can not add/edit/delete in demo mode.', '演示模式下禁止新增、编辑和删除。'],
    ['Password changed successfully.', '密码修改成功。'],
    ['Status changed.', '状态已更新。'],
    ['Content deleted.', '内容已删除。'],
    ['Created.', '创建成功。'],
    ['Updated.', '更新成功。'],
    ['Deleted.', '删除成功。'],
    ['Access denied', '访问受限'],
    ['Withdrawal Request', '提现申请'],
    ['Rent Transaction', '租赁交易'],
    ['Rent Transactions', '租赁交易'],
    ['TV Show Episodes', '剧集分集'],
    ['Shorts Episodes', '短剧分集'],
    ['Episode actions are grouped to keep the table readable while preserving quick edits.', '分集操作已聚合展示，方便快速编辑。'],
    ['Episode editing is folded into row actions so the table stays readable.', '分集编辑已折叠到行操作中，列表更清晰。'],
    ['No data available in table', '表格暂无数据'],
    ['Sort order saved.', '排序保存成功。'],
    ['TV show episode created.', '剧集分集创建成功。'],
    ['TV show episode updated.', '剧集分集更新成功。'],
    ['TV show episode status changed.', '剧集分集状态已更新。'],
    ['Shorts episode created.', '短剧分集创建成功。'],
    ['Shorts episode updated.', '短剧分集更新成功。'],
    ['Shorts episode status changed.', '短剧分集状态已更新。'],
    ['Completed', '已完成'],
    ['Pending', '待处理'],
    ['Success', '成功'],
    ['Processing', '处理中'],
    ['Failed', '失败'],
    ['Active', '有效'],
    ['Expiry', '已过期'],
    ['No data', '暂无数据'],
    ['No ', '暂无'],
    [' list', '列表'],
    [' Detail', '详情'],
  ];

  let output = input;
  for (const [from, to] of dict) {
    output = output.split(from).join(to);
  }
  return output;
}

function pageTemplate(title: string, body: string): string {
  return ejs.render(layoutTemplate, {
    title: localizeBackofficeText(title),
    body: localizeBackofficeText(body),
  });
}

function renderTopbarActions(primaryHref: string, primaryLabel: string): string {
  return `<div class="topbar-actions"><a href="/docs">/docs</a><a href="${primaryHref}">${primaryLabel}</a></div>`;
}

function renderPageHeader(title: string, backHref: string, backLabel: string, links: string[] = [], description = ''): string {
  const nav = links.length > 0 ? `<div class="navlinks">${links.join('<span>/</span>')}</div>` : '';
  const desc = description ? `<div class="muted" style="margin-bottom:16px;">${description}</div>` : '';
  return `<div class="topbar"><div><h1>${title}</h1>${nav}</div>${renderTopbarActions(backHref, backLabel)}</div>${desc}`;
}

function renderSelectOptions(options: number[], labels?: Record<number, string>): string {
  return options
    .map((value) => `<option value="${value}">${labels?.[value] ?? value}</option>`)
    .join('');
}

function renderEmptyRow(colspan: number, title: string, description: string): string {
  return `<tr><td colspan="${colspan}"><div class="empty"><strong>${title}</strong><div style="margin-top:6px;">${description}</div></div></td></tr>`;
}

function formatAmount(currencyCode: string, amount: number): string {
  return `${currencyCode}${Number(amount || 0).toFixed(2)}`;
}

function formatDateDMY(value: string): string {
  if (!value) {
    return '-';
  }

  const raw = value.slice(0, 10);
  const [year, month, day] = raw.split('-');
  const monthIndex = Number(month) - 1;
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  if (!year || !day || Number.isNaN(monthIndex) || monthIndex < 0 || monthIndex > 11) {
    return '-';
  }

  return `${day} ${months[monthIndex]} ${year}`;
}

function renderWithdrawalStatusBadge(status: number): string {
  return status === 1
    ? '<span class="badge badge-success">Completed</span>'
    : '<span class="badge badge-primary">Pending</span>';
}

function renderTransactionStatusBadge(status: number): string {
  if (status === 2) {
    return '<span class="badge badge-success">Success</span>';
  }
  if (status === 1) {
    return '<span class="badge badge-primary">Processing</span>';
  }
  if (status === 3) {
    return '<span class="badge badge-danger">Failed</span>';
  }
  return '<span class="badge">-</span>';
}

function renderRentExpiryBadge(status: number): string {
  return status === 1 ? '<span class="badge badge-success">Active</span>' : '<span class="badge badge-danger">Expiry</span>';
}

export function renderGlobalNotFoundPage(path: string): string {
  const safePath = path || '/';

  return pageTemplate(
    '404 Not Found',
    `<div class="card" style="max-width:720px;margin:60px auto;">
      <div class="topbar" style="align-items:flex-start; gap:16px;">
        <div>
          <h1 style="margin-bottom:8px;">404</h1>
          <div class="muted">你访问的页面不存在，或当前地址已失效。</div>
        </div>
        <a href="/docs">查看 API 文档</a>
      </div>
      <div class="msg">未找到地址：<strong>${safePath}</strong></div>
      <div class="action-group">
        <a class="action-link" href="/docs">进入文档首页</a>
        <a class="action-link" href="/admin/login">后台登录</a>
        <a class="action-link" href="/producer/login">制作人登录</a>
      </div>
    </div>`,
  );
}

export function renderBackofficeNotFoundPage(panel: 'admin' | 'producer', path: string): string {
  const title = panel === 'admin' ? 'Admin 404' : 'Producer 404';
  const homeHref = panel === 'admin' ? '/admin/dashboard' : '/producer/dashboard';
  const loginHref = panel === 'admin' ? '/admin/login' : '/producer/login';
  const safePath = path || `/${panel}`;

  return pageTemplate(
    title,
    `<div class="card" style="max-width:720px;margin:60px auto;">
      <div class="topbar" style="align-items:flex-start; gap:16px;">
        <div>
          <h1 style="margin-bottom:8px;">404</h1>
          <div class="muted">你访问的后台页面不存在，或当前地址已失效。</div>
        </div>
        <a href="${homeHref}">返回控制台</a>
      </div>
      <div class="msg">未找到地址：<strong>${safePath}</strong></div>
      <div class="action-group">
        <a class="action-link" href="${homeHref}">进入首页</a>
        <a class="action-link" href="${loginHref}">返回登录</a>
      </div>
    </div>`,
  );
}

export function renderLoginPage(panel: 'admin' | 'producer', message = ''): string {
  const action = `/${panel}/login`;
  const title = panel === 'admin' ? 'Admin Login' : 'Producer Login';
  const msgHtml = message ? `<div class="msg">${message}</div>` : '';

  return pageTemplate(
    title,
    `<div class="card" style="max-width:420px;margin:60px auto;">
      <h1>${title}</h1>
      ${msgHtml}
      <form method="post" action="${action}">
        <input name="email" type="email" placeholder="Email" required />
        <input name="password" type="password" placeholder="Password" required />
        <button type="submit">Sign In</button>
      </form>
    </div>`,
  );
}

export function renderAdminCategoryPage(
  categories: Array<{ id: number; name: string; image: string; status: number }>,
  message = '',
): string {
  const msgHtml = message ? `<div class="msg">${message}</div>` : '';
  const rows = categories
    .map(
      (item) => `<tr>
        <td>${item.id}</td>
        <td class="admin-config-name-cell"><div class="admin-config-name" title="${escapeHtmlAttr(item.name || '-')}" data-tooltip="${escapeHtmlAttr(item.name || '-')}">${item.name || '-'}</div></td>
        <td>${item.image || '-'}</td>
        <td>${renderAdminConfigStatusTag(item.status, 'Show', 'Hide')}</td>
        <td class="admin-config-action-cell">
          <div class="admin-config-action-stack">
            <form class="admin-config-inline-form" method="post" action="/admin/category/update">
              <input type="hidden" name="id" value="${item.id}" />
              <input name="name" value="${escapeHtmlAttr(item.name || '')}" placeholder="Name" required />
              <input name="image" value="${escapeHtmlAttr(item.image || '')}" placeholder="Image filename" />
              <button class="admin-config-btn admin-config-btn-primary" type="submit">Update</button>
            </form>
            <form method="post" action="/admin/category/toggle">
              <input type="hidden" name="id" value="${item.id}" />
              <button class="admin-config-btn admin-config-btn-ghost" type="submit">Toggle Status</button>
            </form>
          </div>
        </td>
      </tr>`,
    )
    .join('');

  return renderAdminConfigPage({
    title: 'Admin Category',
    message: msgHtml,
    introCards: [
      renderAdminConfigCreateCard('Create Category', '/admin/category', [
        { name: 'name', placeholder: 'Name', required: true },
        { name: 'image', placeholder: 'Image filename' },
      ]),
      renderAdminConfigSortCard('/admin/category/sortable/save'),
    ],
    listTitle: 'Category List',
    summary: `${categories.length} categories`,
    headerHtml: '<tr><th align="left">ID</th><th align="left">Name</th><th align="left">Image</th><th align="left">Status</th><th align="left">Actions</th></tr>',
    bodyHtml: rows || renderAdminConfigEmptyRow(5, 'No category data', 'Create a category first to manage it here.'),
  });
}

export function renderAdminChannelPage(
  channels: Array<{ id: number; name: string; portrait_img: string; landscape_img: string; is_title: number; status: number }>,
  message = '',
): string {
  const msgHtml = message ? `<div class="msg">${message}</div>` : '';
  const rows = channels
    .map(
      (item) => `<tr>
        <td>${item.id}</td>
        <td class="admin-config-name-cell"><div class="admin-config-name" title="${escapeHtmlAttr(item.name || '-')}" data-tooltip="${escapeHtmlAttr(item.name || '-')}">${item.name || '-'}</div></td>
        <td>${item.portrait_img || '-'}</td>
        <td>${item.landscape_img || '-'}</td>
        <td>${item.is_title === 1 ? '<span class="admin-config-tag admin-config-tag-blue">Yes</span>' : '<span class="admin-config-tag admin-config-tag-gray">No</span>'}</td>
        <td>${renderAdminConfigStatusTag(item.status, 'Show', 'Hide')}</td>
        <td class="admin-config-action-cell">
          <div class="admin-config-action-stack">
            <form class="admin-config-inline-form" method="post" action="/admin/channel/update">
              <input type="hidden" name="id" value="${item.id}" />
              <input name="name" value="${escapeHtmlAttr(item.name || '')}" placeholder="Name" required />
              <input name="portrait_img" value="${escapeHtmlAttr(item.portrait_img || '')}" placeholder="Portrait image" />
              <input name="landscape_img" value="${escapeHtmlAttr(item.landscape_img || '')}" placeholder="Landscape image" />
              <input name="is_title" value="${item.is_title}" placeholder="Is title (0/1)" required />
              <button class="admin-config-btn admin-config-btn-primary" type="submit">Update</button>
            </form>
            <form method="post" action="/admin/channel/toggle">
              <input type="hidden" name="id" value="${item.id}" />
              <button class="admin-config-btn admin-config-btn-ghost" type="submit">Toggle Status</button>
            </form>
          </div>
        </td>
      </tr>`,
    )
    .join('');

  return renderAdminConfigPage({
    title: 'Admin Channel',
    message: msgHtml,
    introCards: [
      renderAdminConfigCreateCard('Create Channel', '/admin/channel', [
        { name: 'name', placeholder: 'Name', required: true },
        { name: 'portrait_img', placeholder: 'Portrait image' },
        { name: 'landscape_img', placeholder: 'Landscape image' },
        { name: 'is_title', placeholder: 'Is title (0/1)', required: true },
      ]),
    ],
    listTitle: 'Channel List',
    summary: `${channels.length} channels`,
    headerHtml:
      '<tr><th align="left">ID</th><th align="left">Name</th><th align="left">Portrait</th><th align="left">Landscape</th><th align="left">Is Title</th><th align="left">Status</th><th align="left">Actions</th></tr>',
    bodyHtml: rows || renderAdminConfigEmptyRow(7, 'No channel data', 'Create a channel first to manage it here.'),
  });
}

export function renderAdminAvatarPage(
  avatars: Array<{ id: number; name: string; image: string; status: number }>,
  message = '',
): string {
  const msgHtml = message ? `<div class="msg">${message}</div>` : '';
  const rows = avatars
    .map(
      (item) => `<tr>
        <td>${item.id}</td>
        <td class="admin-config-name-cell"><div class="admin-config-name" title="${escapeHtmlAttr(item.name || '-')}" data-tooltip="${escapeHtmlAttr(item.name || '-')}">${item.name || '-'}</div></td>
        <td>${item.image || '-'}</td>
        <td>${renderAdminConfigStatusTag(item.status, 'Show', 'Hide')}</td>
        <td class="admin-config-action-cell">
          <div class="admin-config-action-stack">
            <form class="admin-config-inline-form" method="post" action="/admin/avatar/update">
              <input type="hidden" name="id" value="${item.id}" />
              <input name="name" value="${escapeHtmlAttr(item.name || '')}" placeholder="Name" required />
              <input name="image" value="${escapeHtmlAttr(item.image || '')}" placeholder="Image filename" />
              <button class="admin-config-btn admin-config-btn-primary" type="submit">Update</button>
            </form>
            <form method="post" action="/admin/avatar/toggle">
              <input type="hidden" name="id" value="${item.id}" />
              <button class="admin-config-btn admin-config-btn-ghost" type="submit">Toggle Status</button>
            </form>
          </div>
        </td>
      </tr>`,
    )
    .join('');

  return renderAdminConfigPage({
    title: 'Admin Avatar',
    message: msgHtml,
    introCards: [
      renderAdminConfigCreateCard('Create Avatar', '/admin/avatar', [
        { name: 'name', placeholder: 'Name', required: true },
        { name: 'image', placeholder: 'Image filename' },
      ]),
      renderAdminConfigSortCard('/admin/avatar/sortable/save'),
    ],
    listTitle: 'Avatar List',
    summary: `${avatars.length} avatars`,
    headerHtml: '<tr><th align="left">ID</th><th align="left">Name</th><th align="left">Image</th><th align="left">Status</th><th align="left">Actions</th></tr>',
    bodyHtml: rows || renderAdminConfigEmptyRow(5, 'No avatar data', 'Create an avatar first to manage it here.'),
  });
}

export function renderAdminTypePage(
  types: Array<{ id: number; name: string; type: number; icon: string; status: number }>,
  message = '',
): string {
  const msgHtml = message ? `<div class="msg">${message}</div>` : '';
  const rows = types
    .map(
      (item) => `<tr>
        <td>${item.id}</td>
        <td class="admin-config-name-cell"><div class="admin-config-name" title="${escapeHtmlAttr(item.name || '-')}" data-tooltip="${escapeHtmlAttr(item.name || '-')}">${item.name || '-'}</div></td>
        <td>${item.type}</td>
        <td>${item.icon || '-'}</td>
        <td>${renderAdminConfigStatusTag(item.status, 'Show', 'Hide')}</td>
        <td class="admin-config-action-cell">
          <div class="admin-config-action-stack">
            <form class="admin-config-inline-form" method="post" action="/admin/type/update">
              <input type="hidden" name="id" value="${item.id}" />
              <input name="name" value="${escapeHtmlAttr(item.name || '')}" placeholder="Name" required />
              <input name="type" value="${item.type}" placeholder="Type number" required />
              <input name="icon" value="${escapeHtmlAttr(item.icon || '')}" placeholder="Icon filename" />
              <button class="admin-config-btn admin-config-btn-primary" type="submit">Update</button>
            </form>
            <form method="post" action="/admin/type/toggle">
              <input type="hidden" name="id" value="${item.id}" />
              <button class="admin-config-btn admin-config-btn-ghost" type="submit">Toggle Status</button>
            </form>
          </div>
        </td>
      </tr>`,
    )
    .join('');

  return renderAdminConfigPage({
    title: 'Admin Type',
    message: msgHtml,
    introCards: [
      renderAdminConfigCreateCard('Create Type', '/admin/type', [
        { name: 'name', placeholder: 'Name', required: true },
        { name: 'type', placeholder: 'Type number', required: true },
        { name: 'icon', placeholder: 'Icon filename' },
      ]),
      renderAdminConfigSortCard('/admin/type/sortable/save'),
    ],
    listTitle: 'Type List',
    summary: `${types.length} types`,
    headerHtml: '<tr><th align="left">ID</th><th align="left">Name</th><th align="left">Type</th><th align="left">Icon</th><th align="left">Status</th><th align="left">Actions</th></tr>',
    bodyHtml: rows || renderAdminConfigEmptyRow(6, 'No type data', 'Create a type first to manage it here.'),
  });
}

export function renderAdminSeasonPage(
  seasons: Array<{ id: number; name: string; sort_order: number; status: number }>,
  message = '',
): string {
  const msgHtml = message ? `<div class="msg">${message}</div>` : '';
  const rows = seasons
    .map(
      (item) => `<tr>
        <td>${item.id}</td>
        <td class="admin-config-name-cell"><div class="admin-config-name" title="${escapeHtmlAttr(item.name || '-')}" data-tooltip="${escapeHtmlAttr(item.name || '-')}">${item.name || '-'}</div></td>
        <td>${item.sort_order}</td>
        <td>${renderAdminConfigStatusTag(item.status, 'Active', 'Inactive')}</td>
        <td class="admin-config-action-cell">
          <div class="admin-config-action-stack">
            <form class="admin-config-inline-form" method="post" action="/admin/season/update">
              <input type="hidden" name="id" value="${item.id}" />
              <input name="name" value="${escapeHtmlAttr(item.name || '')}" placeholder="Name" required />
              <button class="admin-config-btn admin-config-btn-primary" type="submit">Update</button>
            </form>
          </div>
        </td>
      </tr>`,
    )
    .join('');

  return renderAdminConfigPage({
    title: 'Admin Season',
    message: msgHtml,
    introCards: [
      renderAdminConfigCreateCard('Create Season', '/admin/season', [{ name: 'name', placeholder: 'Name', required: true }]),
      renderAdminConfigSortCard('/admin/season/sortable/save'),
    ],
    listTitle: 'Season List',
    summary: `${seasons.length} seasons`,
    headerHtml: '<tr><th align="left">ID</th><th align="left">Name</th><th align="left">Sort Order</th><th align="left">Status</th><th align="left">Actions</th></tr>',
    bodyHtml: rows || renderAdminConfigEmptyRow(5, 'No season data', 'Create a season first to manage it here.'),
  });
}

export function renderAdminLanguagePage(
  languages: Array<{ id: number; name: string; image: string; status: number }>,
  message = '',
): string {
  const msgHtml = message ? `<div class="msg">${message}</div>` : '';
  const rows = languages
    .map(
      (item) => `<tr>
        <td>${item.id}</td>
        <td class="admin-config-name-cell"><div class="admin-config-name" title="${escapeHtmlAttr(item.name || '-')}" data-tooltip="${escapeHtmlAttr(item.name || '-')}">${item.name || '-'}</div></td>
        <td>${item.image || '-'}</td>
        <td>${renderAdminConfigStatusTag(item.status, 'Show', 'Hide')}</td>
        <td class="admin-config-action-cell">
          <div class="admin-config-action-stack">
            <form class="admin-config-inline-form" method="post" action="/admin/language/update">
              <input type="hidden" name="id" value="${item.id}" />
              <input name="name" value="${escapeHtmlAttr(item.name || '')}" placeholder="Name" required />
              <input name="image" value="${escapeHtmlAttr(item.image || '')}" placeholder="Image filename" />
              <button class="admin-config-btn admin-config-btn-primary" type="submit">Update</button>
            </form>
            <form method="post" action="/admin/language/toggle">
              <input type="hidden" name="id" value="${item.id}" />
              <button class="admin-config-btn admin-config-btn-ghost" type="submit">Toggle Status</button>
            </form>
          </div>
        </td>
      </tr>`,
    )
    .join('');

  return renderAdminConfigPage({
    title: 'Admin Language',
    message: msgHtml,
    introCards: [
      renderAdminConfigCreateCard('Create Language', '/admin/language', [
        { name: 'name', placeholder: 'Name', required: true },
        { name: 'image', placeholder: 'Image filename' },
      ]),
      renderAdminConfigSortCard('/admin/language/sortable/save'),
    ],
    listTitle: 'Language List',
    summary: `${languages.length} languages`,
    headerHtml: '<tr><th align="left">ID</th><th align="left">Name</th><th align="left">Image</th><th align="left">Status</th><th align="left">Actions</th></tr>',
    bodyHtml: rows || renderAdminConfigEmptyRow(5, 'No language data', 'Create a language first to manage it here.'),
  });
}

export function renderAdminBannerPage(
  banners: Array<{ id: number; is_home_screen: number; type_id: number; video_type: number; subvideo_type: number; video_id: number; sort_order: number; status: number }>,
  message = '',
): string {
  const msgHtml = message ? `<div class="msg">${message}</div>` : '';
  const rows = banners
    .map(
      (item) => `<tr>
        <td>${item.id}</td>
        <td>${item.is_home_screen}</td>
        <td>${item.type_id}</td>
        <td>${item.video_type}</td>
        <td>${item.subvideo_type}</td>
        <td>${item.video_id}</td>
        <td>${item.sort_order}</td>
        <td>${renderAdminConfigStatusTag(item.status, 'Show', 'Hide')}</td>
        <td class="admin-config-action-cell">
          <div class="admin-config-action-stack">
            <form class="admin-config-inline-form" method="post" action="/admin/banner/update">
              <input type="hidden" name="id" value="${item.id}" />
              <input name="is_home_screen" value="${item.is_home_screen}" placeholder="home screen" required />
              <input name="type_id" value="${item.type_id}" placeholder="type id" required />
              <input name="video_type" value="${item.video_type}" placeholder="video type" required />
              <input name="subvideo_type" value="${item.subvideo_type}" placeholder="sub type" required />
              <input name="video_id" value="${item.video_id}" placeholder="video id" required />
              <input name="sort_order" value="${item.sort_order}" placeholder="sort" required />
              <input name="status" value="${item.status}" placeholder="status" required />
              <button class="admin-config-btn admin-config-btn-primary" type="submit">Update</button>
            </form>
            <form method="post" action="/admin/banner/toggle">
              <input type="hidden" name="id" value="${item.id}" />
              <button class="admin-config-btn admin-config-btn-ghost" type="submit">Toggle Status</button>
            </form>
          </div>
        </td>
      </tr>`,
    )
    .join('');

  return renderAdminConfigPage({
    title: 'Admin Banner',
    message: msgHtml,
    introCards: [
      renderAdminConfigCreateCard('Create Banner', '/admin/banner', [
        { name: 'is_home_screen', placeholder: 'home screen (1/2)', required: true },
        { name: 'type_id', placeholder: 'type id', required: true },
        { name: 'video_type', placeholder: 'video type', required: true },
        { name: 'subvideo_type', placeholder: 'sub video type', required: true },
        { name: 'video_id', placeholder: 'video id', required: true },
        { name: 'sort_order', placeholder: 'sort order', required: true },
        { name: 'status', placeholder: 'status (0/1)', required: true },
      ]),
      renderAdminConfigSortCard('/admin/banner/sortable/save'),
    ],
    listTitle: 'Banner List',
    summary: `${banners.length} banners`,
    headerHtml:
      '<tr><th align="left">ID</th><th align="left">Home Screen</th><th align="left">Type ID</th><th align="left">Video Type</th><th align="left">Sub Type</th><th align="left">Video ID</th><th align="left">Sort</th><th align="left">Status</th><th align="left">Actions</th></tr>',
    bodyHtml: rows || renderAdminConfigEmptyRow(9, 'No banner data', 'Create banners from this page to manage status and sort here.'),
  });
}

export function renderAdminSectionPage(
  sections: Array<{ id: number; title: string; short_title: string; section_type: number; is_home_screen: number; type_id: number; video_type: number; sub_video_type: number; screen_layout: string; content_ids: string; category_id: number; language_id: number; channel_id: number; order_by_upload: number; order_by_view: number; premium_video: number; no_of_content: number; view_all: number; is_title: number; sort_order: number; status: number }>,
  message = '',
): string {
  const msgHtml = message ? `<div class="msg">${message}</div>` : '';
  const rows = sections
    .map(
      (item) => `<tr>
        <td>${item.id}</td>
        <td class="admin-config-name-cell"><div class="admin-config-name" title="${escapeHtmlAttr(item.title || '-')}" data-tooltip="${escapeHtmlAttr(item.title || '-')}">${item.title || '-'}</div></td>
        <td>${item.is_home_screen}</td>
        <td>${item.type_id}</td>
        <td>${item.video_type}</td>
        <td>${item.sub_video_type}</td>
        <td>${item.sort_order}</td>
        <td>${renderAdminConfigStatusTag(item.status, 'Show', 'Hide')}</td>
        <td class="admin-config-action-cell">
          <div class="admin-config-action-stack">
            <form class="admin-config-inline-form" method="post" action="/admin/section/update">
              <input type="hidden" name="id" value="${item.id}" />
              <input name="title" value="${escapeHtmlAttr(item.title || '')}" placeholder="title" required />
              <input name="short_title" value="${escapeHtmlAttr(item.short_title || '')}" placeholder="short title" required />
              <input name="section_type" value="${item.section_type}" placeholder="section type" required />
              <input name="is_home_screen" value="${item.is_home_screen}" placeholder="home screen" required />
              <input name="type_id" value="${item.type_id}" placeholder="type id" required />
              <input name="video_type" value="${item.video_type}" placeholder="video type" required />
              <input name="sub_video_type" value="${item.sub_video_type}" placeholder="sub type" required />
              <input name="screen_layout" value="${escapeHtmlAttr(item.screen_layout || '')}" placeholder="layout" required />
              <input name="content_ids" value="${escapeHtmlAttr(item.content_ids || '')}" placeholder="content ids" />
              <input name="category_id" value="${item.category_id}" placeholder="category id" required />
              <input name="language_id" value="${item.language_id}" placeholder="language id" required />
              <input name="channel_id" value="${item.channel_id}" placeholder="channel id" required />
              <input name="order_by_upload" value="${item.order_by_upload}" placeholder="order upload" required />
              <input name="order_by_view" value="${item.order_by_view}" placeholder="order view" required />
              <input name="premium_video" value="${item.premium_video}" placeholder="premium" required />
              <input name="no_of_content" value="${item.no_of_content}" placeholder="count" required />
              <input name="view_all" value="${item.view_all}" placeholder="view all" required />
              <input name="is_title" value="${item.is_title}" placeholder="is title" required />
              <input name="sort_order" value="${item.sort_order}" placeholder="sort" required />
              <input name="status" value="${item.status}" placeholder="status" required />
              <button class="admin-config-btn admin-config-btn-primary" type="submit">Update</button>
            </form>
            <form method="post" action="/admin/section/toggle">
              <input type="hidden" name="id" value="${item.id}" />
              <button class="admin-config-btn admin-config-btn-ghost" type="submit">Toggle Status</button>
            </form>
          </div>
        </td>
      </tr>`,
    )
    .join('');

  return renderAdminConfigPage({
    title: 'Admin Section',
    message: msgHtml,
    introCards: [
      renderAdminConfigCreateCard('Create Section', '/admin/section', [
        { name: 'title', placeholder: 'title', required: true },
        { name: 'short_title', placeholder: 'short title', required: true },
        { name: 'section_type', placeholder: 'section type', required: true },
        { name: 'is_home_screen', placeholder: 'home screen', required: true },
        { name: 'type_id', placeholder: 'type id', required: true },
        { name: 'video_type', placeholder: 'video type', required: true },
        { name: 'sub_video_type', placeholder: 'sub type', required: true },
        { name: 'screen_layout', placeholder: 'screen layout', required: true },
        { name: 'content_ids', placeholder: 'content ids csv' },
        { name: 'category_id', placeholder: 'category id', required: true },
        { name: 'language_id', placeholder: 'language id', required: true },
        { name: 'channel_id', placeholder: 'channel id', required: true },
        { name: 'order_by_upload', placeholder: 'order by upload', required: true },
        { name: 'order_by_view', placeholder: 'order by view', required: true },
        { name: 'premium_video', placeholder: 'premium video', required: true },
        { name: 'no_of_content', placeholder: 'content count', required: true },
        { name: 'view_all', placeholder: 'view all', required: true },
        { name: 'is_title', placeholder: 'is title', required: true },
        { name: 'sort_order', placeholder: 'sort order', required: true },
        { name: 'status', placeholder: 'status', required: true },
      ]),
      renderAdminConfigSortCard('/admin/section/sortable/save'),
    ],
    listTitle: 'Section List',
    summary: `${sections.length} sections`,
    headerHtml:
      '<tr><th align="left">ID</th><th align="left">Title</th><th align="left">Home Screen</th><th align="left">Type ID</th><th align="left">Video Type</th><th align="left">Sub Type</th><th align="left">Sort</th><th align="left">Status</th><th align="left">Actions</th></tr>',
    bodyHtml: rows || renderAdminConfigEmptyRow(9, 'No section data', 'Create sections from legacy admin or database first, then manage status and sort here.'),
  });
}

type AdminConfigInputField = {
  name: string;
  placeholder: string;
  value?: string | number;
  required?: boolean;
};

type AdminConfigPageParams = {
  title: string;
  message: string;
  introCards: string[];
  listTitle: string;
  summary: string;
  headerHtml: string;
  bodyHtml: string;
};

function renderAdminConfigStyles(): string {
  return `<style>
    .admin-config-grid {
      display:grid;
      grid-template-columns:repeat(auto-fit,minmax(300px,1fr));
      gap:16px;
      margin-bottom:16px;
    }
    .admin-config-card {
      background:#fff;
      border:1px solid #e5e6eb;
      border-radius:12px;
      padding:16px;
      box-shadow:0 6px 20px rgba(15,35,95,.05);
    }
    .admin-config-card h3 {
      margin:0 0 6px;
      font-size:16px;
      color:#1d2129;
    }
    .admin-config-card .admin-config-muted {
      color:#86909c;
      font-size:13px;
      margin-bottom:12px;
    }
    .admin-config-form-grid {
      display:grid;
      gap:10px;
      grid-template-columns:repeat(auto-fit,minmax(160px,1fr));
      align-items:end;
    }
    .admin-config-form-grid input,
    .admin-config-inline-form input {
      height:34px;
      border:1px solid #d9dadd;
      border-radius:8px;
      padding:0 10px;
      font-size:13px;
      color:#1d2129;
      background:#fff;
      width:100%;
      min-width:0;
      box-sizing:border-box;
    }
    .admin-config-form-grid input:focus,
    .admin-config-inline-form input:focus {
      border-color:#165dff;
      outline:none;
      box-shadow:0 0 0 2px rgba(22,93,255,.13);
    }
    .admin-config-btn {
      height:34px;
      border-radius:8px;
      border:1px solid transparent;
      font-size:13px;
      font-weight:600;
      cursor:pointer;
      padding:0 14px;
      white-space:nowrap;
    }
    .admin-config-btn-primary {
      background:#165dff;
      border-color:#165dff;
      color:#fff;
    }
    .admin-config-btn-primary:hover { background:#0e42d2; border-color:#0e42d2; }
    .admin-config-btn-ghost {
      background:#fff;
      border-color:#c9cdd4;
      color:#4e5969;
    }
    .admin-config-btn-ghost:hover { border-color:#94a0b8; color:#1d2129; }
    .admin-config-shell {
      background:#fff;
      border:1px solid #e5e6eb;
      border-radius:12px;
      overflow:hidden;
    }
    .admin-config-toolbar {
      display:flex;
      justify-content:space-between;
      align-items:center;
      gap:10px;
      padding:14px 16px;
      border-bottom:1px solid #f2f3f5;
      background:#fafbfc;
    }
    .admin-config-title {
      margin:0;
      font-size:15px;
      color:#1d2129;
      font-weight:600;
    }
    .admin-config-summary {
      color:#86909c;
      font-size:13px;
    }
    .admin-config-table-wrap {
      width:100%;
      overflow-x:auto;
      overflow-y:visible;
    }
    .admin-config-table {
      width:100%;
      min-width:1080px;
      border-collapse:separate;
      border-spacing:0;
      table-layout:fixed;
    }
    .admin-config-table th {
      background:#fafbfc;
      color:#1d2129;
      font-weight:600;
      font-size:13px;
      padding:12px 14px;
      border-bottom:1px solid #e5e6eb;
      text-align:left;
    }
    .admin-config-table td {
      padding:14px;
      border-bottom:1px solid #f2f3f5;
      color:#1d2129;
      font-size:14px;
      vertical-align:top;
    }
    .admin-config-table tr:hover td { background:#f7f8fa; }
    .admin-config-table th:last-child,
    .admin-config-table td:last-child {
      position: sticky;
      right: 0;
      z-index: 2;
      background: #fff;
      box-shadow: -8px 0 10px -10px rgba(0, 0, 0, .35);
    }
    .admin-config-table thead th:last-child {
      z-index: 4;
      background: #fafbfc;
    }
    .admin-config-name-cell { position:relative; }
    .admin-config-name {
      max-width:260px;
      white-space:nowrap;
      overflow:hidden;
      text-overflow:ellipsis;
      font-weight:500;
      color:#1d2129;
      position:relative;
      cursor:default;
    }
    .admin-config-name[data-tooltip]:hover::after {
      content:attr(data-tooltip);
      position:absolute;
      left:0;
      top:calc(100% + 8px);
      z-index:30;
      max-width:420px;
      padding:8px 10px;
      border-radius:6px;
      background:#1d2129;
      color:#fff;
      font-size:12px;
      line-height:1.5;
      white-space:normal;
      word-break:break-word;
      box-shadow:0 8px 24px rgba(0,0,0,.2);
      pointer-events:none;
    }
    .admin-config-tag {
      display:inline-flex;
      align-items:center;
      padding:3px 10px;
      border-radius:999px;
      font-size:12px;
      line-height:1.2;
      font-weight:600;
    }
    .admin-config-tag-success { background:#e8ffea; color:#00b42a; }
    .admin-config-tag-danger { background:#ffece8; color:#f53f3f; }
    .admin-config-tag-blue { background:#e8f3ff; color:#165dff; }
    .admin-config-tag-gray { background:#f2f3f5; color:#4e5969; }
    .admin-config-action-cell { width:420px; }
    .admin-config-action-stack {
      display:flex;
      flex-direction:column;
      gap:8px;
    }
    .admin-config-inline-form {
      display:grid;
      grid-template-columns:repeat(auto-fit,minmax(120px,1fr)) auto;
      gap:8px;
      align-items:center;
    }
    .admin-config-empty {
      text-align:center;
      color:#86909c;
      padding:24px;
    }
    .admin-config-empty strong {
      color:#4e5969;
      display:block;
      margin-bottom:6px;
    }
    @media (max-width:900px) {
      .admin-config-inline-form {
        grid-template-columns:1fr;
      }
      .admin-config-action-cell { width:320px; }
    }
  </style>`;
}

function renderAdminConfigStatusTag(status: number, activeLabel: string, inactiveLabel: string): string {
  return status === 1
    ? `<span class="admin-config-tag admin-config-tag-success">${activeLabel}</span>`
    : `<span class="admin-config-tag admin-config-tag-danger">${inactiveLabel}</span>`;
}

function renderAdminConfigInputs(fields: AdminConfigInputField[]): string {
  return fields
    .map((field) => {
      const valueAttr =
        field.value === undefined ? '' : ` value="${escapeHtmlAttr(String(field.value))}"`;
      return `<input name="${field.name}"${valueAttr} placeholder="${field.placeholder}"${field.required ? ' required' : ''} />`;
    })
    .join('');
}

function renderAdminConfigCreateCard(title: string, action: string, fields: AdminConfigInputField[]): string {
  return `<div class="admin-config-card">
    <h3>${title}</h3>
    <div class="admin-config-muted">Use the same compact input pattern for all admin config records.</div>
    <form class="admin-config-form-grid" method="post" action="${action}">
      ${renderAdminConfigInputs(fields)}
      <button class="admin-config-btn admin-config-btn-primary" type="submit">Create</button>
    </form>
  </div>`;
}

function renderAdminConfigSortCard(action: string): string {
  return `<div class="admin-config-card">
    <h3>Save Sort Order</h3>
    <div class="admin-config-muted">Input IDs in order, separated by commas. Example: 5,2,7,1</div>
    <form class="admin-config-form-grid" method="post" action="${action}">
      <input name="ids" placeholder="Example: 5,2,7,1" required />
      <button class="admin-config-btn admin-config-btn-primary" type="submit">Save Sort</button>
    </form>
  </div>`;
}

function renderAdminConfigEmptyRow(colspan: number, title: string, description: string): string {
  return `<tr><td colspan="${colspan}" class="admin-config-empty"><strong>${title}</strong><div>${description}</div></td></tr>`;
}

function renderAdminConfigPage(params: AdminConfigPageParams): string {
  return pageTemplate(
    params.title,
    `${renderAdminConfigStyles()}
     <div class="topbar"><h1>${params.title}</h1>${renderTopbarActions('/admin/dashboard', 'Back Dashboard')}</div>
     ${params.message}
     <div class="admin-config-grid">${params.introCards.join('')}</div>
     <div class="admin-config-shell">
       <div class="admin-config-toolbar">
         <h3 class="admin-config-title">${params.listTitle}</h3>
         <div class="admin-config-summary">${params.summary}</div>
       </div>
       <div class="admin-config-table-wrap">
         <table class="admin-config-table">
           <thead>${params.headerHtml}</thead>
           <tbody>${params.bodyHtml}</tbody>
         </table>
       </div>
     </div>`,
  );
}

function escapeHtml(value: string): string {
  return value
    .replaceAll('&', '&amp;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;');
}

type AdminListColumn<T> = {
  header: string;
  render: (item: T) => string;
  align?: 'left' | 'center' | 'right';
  className?: string;
};

type AdminListPageParams<T> = {
  title: string;
  rows: T[];
  columns: AdminListColumn<T>[];
  summary?: string;
  message?: string;
  introHtml?: string;
  backHref?: string;
  backLabel?: string;
  emptyTitle?: string;
  emptyDescription?: string;
};

export function renderAdminListPage<T extends Record<string, unknown>>(params: AdminListPageParams<T>): string {
  const messageHtml = params.message ? `<div class="msg">${params.message}</div>` : '';
  const introHtml = params.introHtml ? `<div style="margin-bottom:16px;">${params.introHtml}</div>` : '';
  const headerHtml = params.columns
    .map(
      (column) =>
        `<th${column.align ? ` align="${column.align}"` : ''}${column.className ? ` class="${column.className}"` : ''}>${column.header}</th>`,
    )
    .join('');
  const bodyHtml =
    params.rows.length > 0
      ? params.rows
          .map(
            (row) =>
              `<tr>${params.columns
                .map((column) => `<td${column.className ? ` class="${column.className}"` : ''}>${column.render(row)}</td>`)
                .join('')}</tr>`,
          )
          .join('')
      : renderAdminConfigEmptyRow(
          params.columns.length,
          params.emptyTitle ?? 'No data',
          params.emptyDescription ?? 'There are no records to display yet.',
        );

  return pageTemplate(
    params.title,
    `${renderAdminConfigStyles()}
     <div class="topbar"><h1>${params.title}</h1>${renderTopbarActions(params.backHref ?? '/admin/dashboard', params.backLabel ?? 'Back Dashboard')}</div>
     ${messageHtml}
     ${introHtml}
     <div class="admin-config-shell">
       <div class="admin-config-toolbar">
         <h3 class="admin-config-title">${params.title}</h3>
         <div class="admin-config-summary">${params.summary ?? `${params.rows.length} records`}</div>
       </div>
       <div class="admin-config-table-wrap">
         <table class="admin-config-table">
           <thead><tr>${headerHtml}</tr></thead>
           <tbody>${bodyHtml}</tbody>
         </table>
       </div>
     </div>`,
  );
}

type AdminSettingsPageParams = {
  title: string;
  action?: string;
  settings: Record<string, string>;
  message?: string;
  backHref?: string;
  backLabel?: string;
  summary?: string;
};

export function renderAdminSettingsPage(params: AdminSettingsPageParams): string {
  const entries = Object.entries(params.settings).sort(([left], [right]) => left.localeCompare(right));
  const fieldsHtml = entries
    .map(
      ([key, value]) => `<label style="display:grid; gap:6px;">
        <span style="font-size:13px; color:#4e5969; font-weight:600;">${escapeHtml(key)}</span>
        <input name="${escapeHtmlAttr(key)}" value="${escapeHtmlAttr(value)}" />
      </label>`,
    )
    .join('');
  const rowsHtml = entries
    .map(
      ([key, value]) => `<tr>
        <td>${escapeHtml(key)}</td>
        <td>${escapeHtml(value || '-')}</td>
      </tr>`,
    )
    .join('');
  const messageHtml = params.message ? `<div class="msg">${params.message}</div>` : '';

  return pageTemplate(
    params.title,
    `${renderAdminConfigStyles()}
     <div class="topbar"><h1>${params.title}</h1>${renderTopbarActions(params.backHref ?? '/admin/dashboard', params.backLabel ?? 'Back Dashboard')}</div>
     ${messageHtml}
      <div class="admin-config-grid">
       <div class="admin-config-card">
         <h3>Edit Settings</h3>
         <div class="admin-config-muted">Review the current values and update them where saving is supported.</div>
         ${params.action ? `<form class="admin-config-form-grid" method="post" action="${params.action}">${fieldsHtml}<button class="admin-config-btn admin-config-btn-primary" type="submit">Save</button></form>` : fieldsHtml}
       </div>
     </div>
     <div class="admin-config-shell">
       <div class="admin-config-toolbar">
         <h3 class="admin-config-title">${params.title}</h3>
         <div class="admin-config-summary">${params.summary ?? `${entries.length} settings`}</div>
       </div>
       <div class="admin-config-table-wrap">
         <table class="admin-config-table">
           <thead><tr><th align="left">Key</th><th align="left">Value</th></tr></thead>
           <tbody>${rowsHtml || renderAdminConfigEmptyRow(2, 'No settings', 'No settings were returned from the database.')}</tbody>
         </table>
       </div>
     </div>`,
  );
}

export function renderAdminPaymentEditPage(
  payment: Record<string, unknown>,
  message = '',
): string {
  const title = `Payment #${Number(payment.id ?? 0) || ''}`.trim();
  const fields: Array<[string, unknown]> = [
    ['id', payment.id ?? ''],
    ['key_1', payment.key_1 ?? ''],
    ['key_2', payment.key_2 ?? ''],
    ['key_3', payment.key_3 ?? ''],
    ['key_4', payment.key_4 ?? ''],
    ['visibility', payment.visibility ?? ''],
    ['is_live', payment.is_live ?? ''],
  ];
  const messageHtml = message ? `<div class="msg">${message}</div>` : '';

  return pageTemplate(
    title,
    `${renderAdminConfigStyles()}
     <div class="topbar"><h1>${title}</h1>${renderTopbarActions('/admin/payment', 'Back Payment')}</div>
     ${messageHtml}
     <div class="admin-config-grid">
       <div class="admin-config-card">
         <h3>Edit Payment Option</h3>
         <div class="admin-config-muted">Update the existing payment option record.</div>
         <form class="admin-config-form-grid" method="post" action="/admin/payment/update">
           ${fields
             .map(
               ([key, value]) => `<label style="display:grid; gap:6px;">
                 <span style="font-size:13px; color:#4e5969; font-weight:600;">${escapeHtml(String(key))}</span>
                 <input name="${escapeHtmlAttr(String(key))}" value="${escapeHtmlAttr(String(value ?? ''))}" />
               </label>`,
             )
             .join('')}
           <button class="admin-config-btn admin-config-btn-primary" type="submit">Save</button>
         </form>
       </div>
     </div>`,
  );
}

export function renderAdminDashboard(userName: string, stats: Record<string, number>): string {
  const entries = [
    ['Users', stats.users],
    ['Videos', stats.videos],
    ['TV Shows', stats.tvShows],
    ['Channels', stats.channels],
    ['Casts', stats.casts],
    ['Producers', stats.producers],
    ['Packages', stats.packages],
    ['Shorts', stats.shorts],
    ['Total Withdrawal', stats.totalWithdrawal],
  ];

  const metrics = entries
    .map(([label, value]) => `<div class="metric"><div class="label">${label}</div><div class="value">${value}</div></div>`)
    .join('');

  return pageTemplate(
    'Admin Dashboard',
    `<div class="topbar"><h1>Admin Dashboard</h1>${renderTopbarActions('/admin/logout', 'Logout')}</div>
     <div style="margin-bottom:12px; line-height:1.9;">
       <a href="/admin/profile">Profile</a> |
       <a href="/admin/type">Type</a> |
       <a href="/admin/category">Category</a> |
       <a href="/admin/language">Language</a> |
       <a href="/admin/season">Season</a> |
       <a href="/admin/avatar">Avatar</a> |
       <a href="/admin/channel">Channel</a> |
       <a href="/admin/banner">Banner</a> |
       <a href="/admin/section">Section</a> |
       <a href="/admin/video">Video</a> |
       <a href="/admin/tvshow">TV Show</a> |
       <a href="/admin/shorts">Shorts</a> |
       <a href="/admin/episode">Episodes</a> |
       <a href="/admin/reviews">Reviews</a> |
       <a href="/admin/coupon">Coupon</a> |
       <a href="/admin/rent-price-list">Rent Price</a> |
       <a href="/admin/rent-transaction">Rent Transaction</a> |
       <a href="/admin/package">Package</a> |
       <a href="/admin/transaction">Transaction</a> |
       <a href="/admin/payment">Payment</a> |
       <a href="/admin/wallet-transaction">Wallet Transaction</a> |
       <a href="/admin/withdrawal">Withdrawal</a> |
       <a href="/admin/refer-earn">Refer Earn</a> |
       <a href="/admin/notification">Notification</a> |
       <a href="/admin/notifications/setting">Notification Setting</a> |
       <a href="/admin/notificationconfiguration">Notification Config</a> |
       <a href="/admin/admob">Admob</a> |
       <a href="/admin/app-setting">App Setting</a> |
       <a href="/admin/panel-setting">Panel Setting</a> |
       <a href="/admin/system-setting">System Setting</a> |
       <a href="/admin/page">Page</a> |
       <a href="/admin/user">User</a> |
       <a href="/admin/producer">Producer</a> |
       <a href="/admin/cast">Cast</a>
     </div>
     <div class="card"><p>Welcome, ${userName}</p><div class="grid">${metrics}</div></div>`,
  );
}

export function renderAdminContentPlaceholderPage(title: string, message: string): string {
  return pageTemplate(
    title,
    `<div class="topbar"><h1>${title}</h1>${renderTopbarActions('/admin/dashboard', 'Back Dashboard')}</div>
     <div class="card"><p>${message}</p></div>`,
  );
}

export function renderProducerContentPlaceholderPage(title: string, message: string): string {
  return pageTemplate(
    title,
    `<div class="topbar"><h1>${title}</h1>${renderTopbarActions('/producer/dashboard', 'Back Dashboard')}</div>
     <div class="card"><p>${message}</p></div>`,
  );
}

type AdminListPagination = {
  currentPage: number;
  totalPages: number;
  totalRows: number;
  pageSize: number;
  startRow: number;
  endRow: number;
};

function renderAdminArcoTableStyles(): string {
  return `<style>
    .admin-arco-shell { background:#fff; border:1px solid #e5e6eb; border-radius:12px; overflow:visible; }
    .admin-arco-toolbar {
      display:flex; justify-content:space-between; align-items:center; gap:12px;
      padding:14px 18px; border-bottom:1px solid #f2f3f5; background:#fafbfc;
    }
    .admin-arco-summary { color:#4e5969; font-size:13px; }
    .admin-arco-table-wrap {
      width:100%;
      overflow-x:auto;
      overflow-y:visible;
    }
    .admin-arco-table {
      width:100%;
      min-width:1120px;
      border-collapse:separate;
      border-spacing:0;
      table-layout:fixed;
    }
    .admin-arco-table th {
      background:#fafbfc; color:#1d2129; font-weight:600; font-size:13px;
      padding:12px 14px; border-bottom:1px solid #e5e6eb; text-align:left;
    }
    .admin-arco-table td {
      padding:14px; border-bottom:1px solid #f2f3f5; color:#1d2129; font-size:14px; vertical-align:top;
    }
    .admin-arco-table tr:hover td { background:#f7f8fa; }
    .admin-arco-table th:last-child,
    .admin-arco-table td:last-child {
      position: sticky;
      right: 0;
      z-index: 2;
      background: #fff;
      box-shadow: -8px 0 10px -10px rgba(0, 0, 0, .35);
    }
    .admin-arco-table thead th:last-child {
      z-index: 4;
      background: #fafbfc;
    }
    .admin-arco-name-cell { position:relative; }
    .admin-arco-name {
      max-width:340px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; font-weight:500;
      cursor:default;
    }
    .admin-arco-name[data-tooltip]:hover::after,
    .admin-arco-name[data-tooltip]:focus-visible::after {
      content:attr(data-tooltip);
      position:absolute;
      left:0;
      top:calc(100% + 8px);
      z-index:30;
      max-width:420px;
      padding:8px 10px;
      border-radius:6px;
      background:#1d2129;
      color:#fff;
      font-size:12px;
      line-height:1.5;
      white-space:normal;
      word-break:break-word;
      box-shadow:0 8px 24px rgba(0,0,0,.2);
      pointer-events:none;
    }
    .admin-arco-tag {
      display:inline-flex; align-items:center; padding:3px 10px; border-radius:999px;
      font-size:12px; line-height:1.2; font-weight:600;
    }
    .admin-arco-tag-success { background:#e8ffea; color:#00b42a; }
    .admin-arco-tag-danger { background:#ffece8; color:#f53f3f; }
    .admin-arco-tag-blue { background:#e8f3ff; color:#165dff; }
    .admin-arco-tag-gray { background:#f2f3f5; color:#4e5969; }
    .admin-arco-action button {
      min-width:120px; height:32px; border-radius:6px; border:1px solid #165dff;
      background:#165dff; color:#fff; font-weight:500; cursor:pointer;
    }
    .admin-arco-action button:hover { background:#0e42d2; border-color:#0e42d2; }
    .admin-arco-pagination {
      display:flex; justify-content:space-between; align-items:center; gap:12px;
      padding:14px 18px; background:#fff;
    }
    .admin-arco-pages { display:flex; align-items:center; gap:8px; }
    .admin-arco-page-btn, .admin-arco-page-num {
      min-width:32px; height:32px; border-radius:6px; border:1px solid #e5e6eb;
      background:#fff; color:#4e5969; text-decoration:none; display:inline-flex; align-items:center; justify-content:center;
      font-size:13px; padding:0 8px;
    }
    .admin-arco-page-num.active { border-color:#165dff; color:#165dff; background:#f2f7ff; font-weight:600; }
    .admin-arco-page-btn.disabled { pointer-events:none; opacity:.45; }
  </style>`;
}

function renderAdminArcoPagination(basePath: string, pagination: AdminListPagination): string {
  const currentPage = Math.max(1, pagination.currentPage);
  const totalPages = Math.max(1, pagination.totalPages);
  const totalRows = Math.max(0, pagination.totalRows);
  const windowSize = 5;
  let startPage = Math.max(1, currentPage - Math.floor(windowSize / 2));
  let endPage = Math.min(totalPages, startPage + windowSize - 1);
  if (endPage - startPage + 1 < windowSize) {
    startPage = Math.max(1, endPage - windowSize + 1);
  }

  const numbers: string[] = [];
  for (let page = startPage; page <= endPage; page += 1) {
    numbers.push(
      `<a class="admin-arco-page-num ${page === currentPage ? 'active' : ''}" href="${basePath}?page=${page}">${page}</a>`,
    );
  }

  return `<div class="admin-arco-pagination">
    <div class="admin-arco-summary">Showing <b>${pagination.startRow}</b>-<b>${pagination.endRow}</b> of <b>${totalRows}</b></div>
    <div class="admin-arco-pages">
      <a class="admin-arco-page-btn ${currentPage <= 1 ? 'disabled' : ''}" href="${currentPage <= 1 ? '#' : `${basePath}?page=${currentPage - 1}`}">Prev</a>
      ${numbers.join('')}
      <a class="admin-arco-page-btn ${currentPage >= totalPages ? 'disabled' : ''}" href="${currentPage >= totalPages ? '#' : `${basePath}?page=${currentPage + 1}`}">Next</a>
    </div>
  </div>`;
}

function escapeHtmlAttr(value: string): string {
  return value
    .replaceAll('&', '&amp;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;');
}

export function renderAdminVideoPage(
  items: Array<{
    id: number;
    type_id: number;
    video_type: number;
    producer_id: number;
    name: string;
    thumbnail: string;
    is_premium: number;
    is_rent: number;
    price: number;
    total_view: number;
    status: number;
    created_at: string;
  }>,
  pagination: AdminListPagination,
  message = '',
): string {
  const msgHtml = message ? `<div class="msg">${message}</div>` : '';
  const rowsHtml = items
    .map(
      (item) => `<tr>
        <td>${item.id}</td>
        <td class="admin-arco-name-cell"><div class="admin-arco-name" title="${escapeHtmlAttr(item.name || '-')}" data-tooltip="${escapeHtmlAttr(item.name || '-')}" tabindex="0">${item.name || '-'}</div></td>
        <td>${item.type_id}</td>
        <td>${item.video_type}</td>
        <td>${item.producer_id}</td>
        <td>${item.is_premium === 1 ? '<span class="admin-arco-tag admin-arco-tag-blue">Premium</span>' : '<span class="admin-arco-tag admin-arco-tag-gray">Free</span>'}</td>
        <td>${item.is_rent === 1 ? `<span class="admin-arco-tag admin-arco-tag-blue">Rent ${item.price}</span>` : '<span class="admin-arco-tag admin-arco-tag-gray">No</span>'}</td>
        <td>${item.total_view}</td>
        <td>${formatDateDMY(item.created_at)}</td>
        <td>${item.status === 1 ? '<span class="admin-arco-tag admin-arco-tag-success">Show</span>' : '<span class="admin-arco-tag admin-arco-tag-danger">Hide</span>'}</td>
        <td class="admin-arco-action">
          <form method="post" action="/admin/video/toggle">
            <input type="hidden" name="id" value="${item.id}" />
            <input type="hidden" name="page" value="${pagination.currentPage}" />
            <button type="submit">Toggle Status</button>
          </form>
        </td>
      </tr>`,
    )
    .join('');
  const rows = rowsHtml || '<tr><td colspan="11" style="text-align:center;color:#86909c;padding:24px;">No data available in table</td></tr>';

  return pageTemplate(
    'Admin Video',
    `${renderAdminArcoTableStyles()}
     <div class="topbar"><h1>Admin Video</h1>${renderTopbarActions('/admin/dashboard', 'Back Dashboard')}</div>
     ${msgHtml}
     <div class="admin-arco-shell">
       <div class="admin-arco-toolbar"><div class="admin-arco-summary">Arco-style table with pagination</div></div>
       <div class="admin-arco-table-wrap">
         <table class="admin-arco-table">
           <thead><tr><th align="left">#</th><th align="left">Name</th><th align="left">Type ID</th><th align="left">Video Type</th><th align="left">Producer</th><th align="left">Premium</th><th align="left">Rent</th><th align="left">Views</th><th align="left">Created</th><th align="left">Status</th><th align="left">Actions</th></tr></thead>
           <tbody>${rows}</tbody>
         </table>
       </div>
       ${renderAdminArcoPagination('/admin/video', pagination)}
     </div>`,
  );
}

export function renderAdminTvShowPage(
  items: Array<{
    id: number;
    type_id: number;
    video_type: number;
    producer_id: number;
    name: string;
    thumbnail: string;
    is_rent: number;
    price: number;
    total_view: number;
    status: number;
    created_at: string;
  }>,
  pagination: AdminListPagination,
  message = '',
): string {
  const msgHtml = message ? `<div class="msg">${message}</div>` : '';
  const rowsHtml = items
    .map(
      (item) => `<tr>
        <td>${item.id}</td>
        <td class="admin-arco-name-cell"><div class="admin-arco-name" title="${escapeHtmlAttr(item.name || '-')}" data-tooltip="${escapeHtmlAttr(item.name || '-')}" tabindex="0">${item.name || '-'}</div></td>
        <td>${item.type_id}</td>
        <td>${item.video_type}</td>
        <td>${item.producer_id}</td>
        <td>${item.is_rent === 1 ? `<span class="admin-arco-tag admin-arco-tag-blue">Rent ${item.price}</span>` : '<span class="admin-arco-tag admin-arco-tag-gray">No</span>'}</td>
        <td>${item.total_view}</td>
        <td>${formatDateDMY(item.created_at)}</td>
        <td>${item.status === 1 ? '<span class="admin-arco-tag admin-arco-tag-success">Show</span>' : '<span class="admin-arco-tag admin-arco-tag-danger">Hide</span>'}</td>
        <td class="admin-arco-action">
          <form method="post" action="/admin/tvshow/toggle">
            <input type="hidden" name="id" value="${item.id}" />
            <input type="hidden" name="page" value="${pagination.currentPage}" />
            <button type="submit">Toggle Status</button>
          </form>
        </td>
      </tr>`,
    )
    .join('');
  const rows = rowsHtml || '<tr><td colspan="10" style="text-align:center;color:#86909c;padding:24px;">No data available in table</td></tr>';

  return pageTemplate(
    'Admin TV Show',
    `${renderAdminArcoTableStyles()}
     <div class="topbar"><h1>Admin TV Show</h1>${renderTopbarActions('/admin/dashboard', 'Back Dashboard')}</div>
     ${msgHtml}
     <div class="admin-arco-shell">
       <div class="admin-arco-toolbar"><div class="admin-arco-summary">Arco-style table with pagination</div></div>
       <div class="admin-arco-table-wrap">
         <table class="admin-arco-table">
           <thead><tr><th align="left">#</th><th align="left">Name</th><th align="left">Type ID</th><th align="left">Video Type</th><th align="left">Producer</th><th align="left">Rent</th><th align="left">Views</th><th align="left">Created</th><th align="left">Status</th><th align="left">Actions</th></tr></thead>
           <tbody>${rows}</tbody>
         </table>
       </div>
       ${renderAdminArcoPagination('/admin/tvshow', pagination)}
     </div>`,
  );
}

export function renderAdminShortsPage(
  items: Array<{
    id: number;
    type_id: number;
    video_type: number;
    producer_id: number;
    name: string;
    thumbnail: string;
    total_view: number;
    status: number;
    created_at: string;
  }>,
  pagination: AdminListPagination,
  message = '',
): string {
  const msgHtml = message ? `<div class="msg">${message}</div>` : '';
  const rowsHtml = items
    .map(
      (item) => `<tr>
        <td>${item.id}</td>
        <td class="admin-arco-name-cell"><div class="admin-arco-name" title="${escapeHtmlAttr(item.name || '-')}" data-tooltip="${escapeHtmlAttr(item.name || '-')}" tabindex="0">${item.name || '-'}</div></td>
        <td>${item.type_id}</td>
        <td>${item.video_type}</td>
        <td>${item.producer_id}</td>
        <td>${item.total_view}</td>
        <td>${formatDateDMY(item.created_at)}</td>
        <td>${item.status === 1 ? '<span class="admin-arco-tag admin-arco-tag-success">Show</span>' : '<span class="admin-arco-tag admin-arco-tag-danger">Hide</span>'}</td>
        <td class="admin-arco-action">
          <form method="post" action="/admin/shorts/toggle">
            <input type="hidden" name="id" value="${item.id}" />
            <input type="hidden" name="page" value="${pagination.currentPage}" />
            <button type="submit">Toggle Status</button>
          </form>
        </td>
      </tr>`,
    )
    .join('');
  const rows = rowsHtml || '<tr><td colspan="9" style="text-align:center;color:#86909c;padding:24px;">No data available in table</td></tr>';

  return pageTemplate(
    'Admin Shorts',
    `${renderAdminArcoTableStyles()}
     <div class="topbar"><h1>Admin Shorts</h1>${renderTopbarActions('/admin/dashboard', 'Back Dashboard')}</div>
     ${msgHtml}
     <div class="admin-arco-shell">
       <div class="admin-arco-toolbar"><div class="admin-arco-summary">Arco-style table with pagination</div></div>
       <div class="admin-arco-table-wrap">
         <table class="admin-arco-table">
           <thead><tr><th align="left">#</th><th align="left">Name</th><th align="left">Type ID</th><th align="left">Video Type</th><th align="left">Producer</th><th align="left">Views</th><th align="left">Created</th><th align="left">Status</th><th align="left">Actions</th></tr></thead>
           <tbody>${rows}</tbody>
         </table>
       </div>
       ${renderAdminArcoPagination('/admin/shorts', pagination)}
     </div>`,
  );
}

export function renderAdminEpisodeHubPage(): string {
  return pageTemplate(
    'Admin Episodes',
    `<div class="topbar"><h1>Admin Episodes</h1>${renderTopbarActions('/admin/dashboard', 'Back Dashboard')}</div>
     <div class="card" style="margin-bottom:16px;">
       <h3>Episode Management</h3>
       <p>Select the content line you want to manage. The detailed admin episode modules are the next migration step.</p>
     </div>
     <div class="grid">
       <div class="card">
         <h3>TV Show Episodes</h3>
         <p>Manage episode lists, publish flow, status and ordering for TV shows.</p>
         <a href="/admin/episode/tvshow">Open TV Show Episodes</a>
       </div>
       <div class="card">
         <h3>Shorts Episodes</h3>
         <p>Manage episode lists, publish flow, status and ordering for shorts.</p>
         <a href="/admin/episode/shorts">Open Shorts Episodes</a>
       </div>
     </div>`,
  );
}

export function renderProducerDashboard(
  userName: string,
  stats: {
    videos: number;
    tvShows: number;
    shorts: number;
    totalWithdrawal: number;
    wallet: number;
    videoTypeId?: number | null;
    tvShowTypeId?: number | null;
    shortsTypeId?: number | null;
  },
): string {
  const entries = [
    ['Videos', stats.videos],
    ['TV Shows', stats.tvShows],
    ['Shorts', stats.shorts],
    ['Total Withdrawal', stats.totalWithdrawal],
    ['Wallet', stats.wallet],
  ];

  const metrics = entries
    .map(([label, value]) => `<div class="metric"><div class="label">${label}</div><div class="value">${value}</div></div>`)
    .join('');

  const videoLink = stats.videoTypeId ? `<a href="/producer/video/${stats.videoTypeId}">Video</a> | ` : '';
  const tvShowLink = stats.tvShowTypeId ? `<a href="/producer/tvshow/${stats.tvShowTypeId}">TV Show</a> | ` : '';
  const shortsLink = stats.shortsTypeId ? `<a href="/producer/shorts/${stats.shortsTypeId}">Shorts</a> | ` : '';

  return pageTemplate(
    'Producer Dashboard',
    `<div class="topbar"><h1>Producer Dashboard</h1>${renderTopbarActions('/producer/logout', 'Logout')}</div>
     <div style="margin-bottom:12px;"><a href="/producer/profile">Profile</a> | <a href="/producer/channel">Channel</a> | ${videoLink}${tvShowLink}${shortsLink}<a href="/producer/rent-transaction">Rent Transactions</a> | <a href="/producer/withdrawal">Withdrawal</a> | <a href="/producer/change-password">Change Password</a></div>
     <div class="card"><p>Welcome, ${userName}</p><div class="grid">${metrics}</div></div>`,
  );
}

export function renderProducerChannelPage(
  payload: {
    inputSearch: string;
    items: Array<{ id: number; name: string; portrait_img: string; landscape_img: string; is_title: number }>;
  },
): string {
  const rowsHtml = payload.items
    .map(
      (item) => `<tr>
        <td>${item.id}</td>
        <td>${item.name || '-'}</td>
        <td>${item.portrait_img || '-'}</td>
        <td>${item.landscape_img || '-'}</td>
        <td>${item.is_title}</td>
      </tr>`,
    )
    .join('');
  const rows = rowsHtml || '<tr><td colspan="5" style="text-align:center;color:#6b7280;">No data available in table</td></tr>';

  return pageTemplate(
    'Channel',
    `<div class="topbar"><h1>Channel</h1>${renderTopbarActions('/producer/dashboard', 'Back Dashboard')}</div>
     <div class="card" style="margin-bottom:16px;">
       <form method="get" action="/producer/channel" style="display:grid; grid-template-columns:1fr auto; gap:10px;">
         <input name="input_search" value="${payload.inputSearch}" placeholder="Search" />
         <button type="submit">Search</button>
       </form>
     </div>
     <div class="card">
       <table style="width:100%; border-collapse:collapse;">
         <thead><tr><th align="left">#</th><th align="left">Name</th><th align="left">Portrait</th><th align="left">Landscape</th><th align="left">Is Title</th></tr></thead>
         <tbody>${rows}</tbody>
       </table>
     </div>`,
  );
}

export function renderProducerVideoPage(
  payload: {
    typeId: number;
    inputSearch: string;
    inputRent: string;
    inputPremium: string;
    inputStatus: string;
    channels: Array<{ id: number; name: string }>;
    releasesTypes: Array<{ id: number; name: string; type: number }>;
    items: Array<{
      id: number;
      name: string;
      video_type: number;
      channel_id: number;
      category_id: string;
      language_id: string;
      cast_id: string;
      thumbnail: string;
      landscape: string;
      description: string;
      is_premium: number;
      is_title: number;
      is_download: number;
      is_comment: number;
      is_like: number;
      is_rent: number;
      price: number;
      rent_day: number;
      status: number;
      release_date: string;
      video_upload_type: string;
      video_320: string;
      video_480: string;
      video_720: string;
      video_1080: string;
      trailer_type: string;
      trailer_url: string;
      subtitle_type: string;
      subtitle_1: string;
      subtitle_2: string;
      subtitle_3: string;
      subtitle_lang_1: string;
      subtitle_lang_2: string;
      subtitle_lang_3: string;
    }>;
  },
  message = '',
): string {
  const liveProducerVideoTemplate = fs.readFileSync(producerVideoTemplatePath, 'utf8');

  return pageTemplate(
    'Video',
    ejs.render(
      liveProducerVideoTemplate,
      {
        payload,
        message,
        formatDateDMY,
      },
      {
        filename: producerVideoTemplatePath,
      },
    ),
  );
}

export function renderProducerTvShowPage(
  payload: {
    typeId: number;
    inputSearch: string;
    inputRent: string;
    inputStatus: string;
    channels: Array<{ id: number; name: string }>;
    releasesTypes: Array<{ id: number; name: string; type: number }>;
    items: Array<{
      id: number;
      name: string;
      video_type: number;
      channel_id: number;
      category_id: string;
      language_id: string;
      cast_id: string;
      thumbnail: string;
      landscape: string;
      trailer_type: string;
      trailer_url: string;
      description: string;
      is_title: number;
      is_comment: number;
      is_like: number;
      is_rent: number;
      price: number;
      rent_day: number;
      status: number;
      release_date: string;
    }>;
  },
  message = '',
): string {
  const liveProducerTvShowTemplate = fs.readFileSync(producerTvShowTemplatePath, 'utf8');

  return pageTemplate(
    'TV Show',
    ejs.render(
      liveProducerTvShowTemplate,
      {
        payload,
        message,
        formatDateDMY,
      },
      {
        filename: producerTvShowTemplatePath,
      },
    ),
  );
}

export function renderProducerTvShowEpisodePage(
  payload: {
    showId: number;
    typeId: number;
    inputSearch: string;
    inputSeason: string;
    seasons: Array<{ id: number; name: string }>;
    items: Array<{
      id: number;
      season_id: number;
      season_name: string;
      name: string;
      thumbnail: string;
      landscape: string;
      description: string;
      is_premium: number;
      is_title: number;
      is_download: number;
      total_view: number;
      status: number;
      sort_order: number;
      video_upload_type: string;
      video_320: string;
      video_480: string;
      video_720: string;
      video_1080: string;
      subtitle_type: string;
      subtitle_1: string;
      subtitle_2: string;
      subtitle_3: string;
      subtitle_lang_1: string;
      subtitle_lang_2: string;
      subtitle_lang_3: string;
    }>;
  },
  message = '',
): string {
  const msgHtml = message ? `<div class="msg">${message}</div>` : '';
  const seasonOptions = payload.seasons
    .map((item) => `<option value="${item.id}" ${String(item.id) === payload.inputSeason ? 'selected' : ''}>${item.name}</option>`)
    .join('');

  const rowsHtml = payload.items
    .map(
      (item) => `<tr>
        <td>${item.id}</td>
        <td>${item.name || '-'}</td>
        <td>${item.season_name || '-'}</td>
        <td>${item.is_premium === 1 ? 'Premium' : 'Free'}</td>
        <td>${item.total_view}</td>
        <td>${item.status === 1 ? '<span class="badge badge-success">Show</span>' : '<span class="badge badge-danger">Hide</span>'}</td>
        <td>${item.sort_order}</td>
        <td>
          <div class="action-group">
            <details class="inline-editor">
              <summary>Edit</summary>
              <form method="post" action="/producer/tvshow-episode/update/${item.id}">
                <input type="hidden" name="show_id" value="${payload.showId}" />
                <input type="hidden" name="type_id" value="${payload.typeId}" />
                <input name="season_id" value="${item.season_id}" placeholder="season_id" required />
                <input name="name" value="${item.name}" placeholder="Name" required />
                <input name="thumbnail" value="${item.thumbnail || ''}" placeholder="thumbnail" />
                <input name="description" value="${item.description || ''}" placeholder="description" />
                <input name="video_upload_type" value="${item.video_upload_type || 'external'}" placeholder="video_upload_type" />
                <input name="video_320" value="${item.video_320 || ''}" placeholder="video_320" />
                <input name="subtitle_type" value="${item.subtitle_type || 'external'}" placeholder="subtitle_type" />
                <input name="is_premium" value="${item.is_premium}" placeholder="is_premium" />
                <input name="is_title" value="${item.is_title}" placeholder="is_title" />
                <input name="is_download" value="${item.is_download}" placeholder="is_download" />
                <button type="submit">Save Changes</button>
              </form>
            </details>
            <form method="post" action="/producer/tvshow-episode/status" style="width:120px;">
              <input type="hidden" name="id" value="${item.id}" />
              <input type="hidden" name="show_id" value="${payload.showId}" />
              <input type="hidden" name="type_id" value="${payload.typeId}" />
              <button type="submit">Toggle</button>
            </form>
            <form method="post" action="/producer/tvshow-episode/delete/${payload.showId}/${item.id}/${payload.typeId}" style="width:120px;">
              <button type="submit">Delete</button>
            </form>
          </div>
        </td>
      </tr>`,
    )
    .join('');
  const rows = rowsHtml || renderEmptyRow(8, 'No episodes yet', 'Add the first episode after confirming the season and source settings.');

  return pageTemplate(
    'TV Show Episodes',
    `${renderPageHeader('TV Show Episodes', `/producer/tvshow/${payload.typeId}`, 'Back TV Show', ['Producer', 'TV Show', `Show #${payload.showId}`, 'Episodes'], 'Episode actions are grouped to keep the table readable while preserving quick edits.')}
     ${msgHtml}
     <div class="card" style="margin-bottom:16px;">
       <h3>Add Episode</h3>
       <form method="post" action="/producer/tvshow-episode/save">
         <input type="hidden" name="show_id" value="${payload.showId}" />
         <input type="hidden" name="type_id" value="${payload.typeId}" />
         <input name="season_id" placeholder="season_id" required />
         <input name="name" placeholder="Name" required />
         <input name="thumbnail" placeholder="thumbnail" />
         <input name="landscape" placeholder="landscape" />
         <input name="description" placeholder="description" />
         <input name="video_upload_type" value="external" placeholder="video_upload_type" required />
         <input name="video_320" placeholder="video_320" required />
         <input name="video_480" placeholder="video_480" />
         <input name="video_720" placeholder="video_720" />
         <input name="video_1080" placeholder="video_1080" />
         <input name="subtitle_type" value="external" placeholder="subtitle_type" required />
         <input name="subtitle_1" placeholder="subtitle_1" />
         <input name="subtitle_2" placeholder="subtitle_2" />
         <input name="subtitle_3" placeholder="subtitle_3" />
         <input name="subtitle_lang_1" placeholder="subtitle_lang_1" />
         <input name="subtitle_lang_2" placeholder="subtitle_lang_2" />
         <input name="subtitle_lang_3" placeholder="subtitle_lang_3" />
         <input name="is_premium" value="0" placeholder="is_premium" required />
         <input name="is_title" value="0" placeholder="is_title" required />
         <input name="is_download" value="0" placeholder="is_download" required />
         <button type="submit">Save</button>
       </form>
     </div>
     <div class="card" style="margin-bottom:16px;">
       <form method="get" action="/producer/tvshow-episode/${payload.showId}/${payload.typeId}" style="display:grid; grid-template-columns:1.5fr 1fr auto; gap:10px;">
         <input name="input_search" value="${payload.inputSearch}" placeholder="Search" />
         <select name="input_season">
           <option value="0" ${payload.inputSeason === '0' ? 'selected' : ''}>All Season</option>
           ${seasonOptions}
         </select>
         <button type="submit">Search</button>
       </form>
     </div>
     <div class="card" style="margin-bottom:16px;">
       <h3>Save Sort Order</h3>
       <form method="post" action="/producer/tvshow-episode/sortable">
         <input name="ids" placeholder="Example: 5,2,7,1" required />
         <input type="hidden" name="show_id" value="${payload.showId}" />
         <input type="hidden" name="type_id" value="${payload.typeId}" />
         <button type="submit">Save Sort</button>
       </form>
     </div>
     <div class="card">
       <h3>Episode List</h3>
       <div class="sticky-action-wrap">
       <table class="sticky-action-table" style="width:100%; border-collapse:collapse;">
         <thead><tr><th align="left">#</th><th align="left">Name</th><th align="left">Season</th><th align="left">Premium</th><th align="left">Views</th><th align="left">Status</th><th align="left">Sort</th><th align="left">Actions</th></tr></thead>
         <tbody>${rows}</tbody>
       </table>
       </div>
     </div>`,
  );
}

export function renderProducerShortsPage(
  payload: {
    typeId: number;
    inputSearch: string;
    inputRent: string;
    inputStatus: string;
    channels: Array<{ id: number; name: string }>;
    releasesTypes: Array<{ id: number; name: string; type: number }>;
    items: Array<{
      id: number;
      name: string;
      video_type: number;
      channel_id: number;
      category_id: string;
      language_id: string;
      cast_id: string;
      thumbnail: string;
      landscape: string;
      trailer_type: string;
      trailer_url: string;
      description: string;
      is_title: number;
      is_comment: number;
      is_like: number;
      is_rent: number;
      price: number;
      rent_day: number;
      status: number;
    }>;
  },
  message = '',
): string {
  const liveProducerShortsTemplate = fs.readFileSync(producerShortsTemplatePath, 'utf8');

  return pageTemplate(
    'Shorts',
    ejs.render(
      liveProducerShortsTemplate,
      {
        payload,
        message,
      },
      {
        filename: producerShortsTemplatePath,
      },
    ),
  );
}

export function renderProducerShortsEpisodePage(
  payload: {
    showId: number;
    typeId: number;
    inputSearch: string;
    inputSeason: string;
    seasons: Array<{ id: number; name: string }>;
    items: Array<{
      id: number;
      season_id: number;
      season_name: string;
      name: string;
      thumbnail: string;
      description: string;
      is_premium: number;
      is_title: number;
      total_view: number;
      status: number;
      sort_order: number;
      video_upload_type: string;
      video_320: string;
    }>;
  },
  message = '',
): string {
  const msgHtml = message ? `<div class="msg">${message}</div>` : '';
  const seasonOptions = payload.seasons
    .map((item) => `<option value="${item.id}" ${String(item.id) === payload.inputSeason ? 'selected' : ''}>${item.name}</option>`)
    .join('');

  const rowsHtml = payload.items
    .map(
      (item) => `<tr>
        <td>${item.id}</td>
        <td>${item.name || '-'}</td>
        <td>${item.season_name || '-'}</td>
        <td>${item.is_premium === 1 ? 'Premium' : 'Free'}</td>
        <td>${item.total_view}</td>
        <td>${item.status === 1 ? '<span class="badge badge-success">Show</span>' : '<span class="badge badge-danger">Hide</span>'}</td>
        <td>${item.sort_order}</td>
        <td>
          <div class="action-group">
            <details class="inline-editor">
              <summary>Edit</summary>
              <form method="post" action="/producer/shorts-episode/update/${item.id}">
                <input type="hidden" name="show_id" value="${payload.showId}" />
                <input type="hidden" name="type_id" value="${payload.typeId}" />
                <input name="season_id" value="${item.season_id}" placeholder="season_id" required />
                <input name="name" value="${item.name}" placeholder="Name" required />
                <input name="thumbnail" value="${item.thumbnail || ''}" placeholder="thumbnail" />
                <input name="description" value="${item.description || ''}" placeholder="description" />
                <input name="video_upload_type" value="${item.video_upload_type || 'external'}" placeholder="video_upload_type" />
                <input name="video_320" value="${item.video_320 || ''}" placeholder="video_320" />
                <input name="is_premium" value="${item.is_premium}" placeholder="is_premium" />
                <input name="is_title" value="${item.is_title}" placeholder="is_title" />
                <button type="submit">Save Changes</button>
              </form>
            </details>
            <form method="post" action="/producer/shorts-episode/status" style="width:120px;">
              <input type="hidden" name="id" value="${item.id}" />
              <input type="hidden" name="show_id" value="${payload.showId}" />
              <input type="hidden" name="type_id" value="${payload.typeId}" />
              <button type="submit">Toggle</button>
            </form>
            <form method="post" action="/producer/shorts-episode/delete/${payload.showId}/${item.id}/${payload.typeId}" style="width:120px;">
              <button type="submit">Delete</button>
            </form>
          </div>
        </td>
      </tr>`,
    )
    .join('');
  const rows = rowsHtml || renderEmptyRow(8, 'No shorts episodes yet', 'Add the first shorts episode after selecting the right season.');

  return pageTemplate(
    'Shorts Episodes',
    `${renderPageHeader('Shorts Episodes', `/producer/shorts/${payload.typeId}`, 'Back Shorts', ['Producer', 'Shorts', `Show #${payload.showId}`, 'Episodes'], 'Episode editing is folded into row actions so the table stays readable.')}
     ${msgHtml}
     <div class="card" style="margin-bottom:16px;">
       <h3>Add Episode</h3>
       <form method="post" action="/producer/shorts-episode/save">
         <input type="hidden" name="show_id" value="${payload.showId}" />
         <input type="hidden" name="type_id" value="${payload.typeId}" />
         <input name="season_id" placeholder="season_id" required />
         <input name="name" placeholder="Name" required />
         <input name="thumbnail" placeholder="thumbnail" />
         <input name="description" placeholder="description" />
         <input name="video_upload_type" value="external" placeholder="video_upload_type" required />
         <input name="video_320" placeholder="video_320" required />
         <input name="is_premium" value="0" placeholder="is_premium" required />
         <input name="is_title" value="0" placeholder="is_title" required />
         <button type="submit">Save</button>
       </form>
     </div>
     <div class="card" style="margin-bottom:16px;">
       <form method="get" action="/producer/shorts-episode/${payload.showId}/${payload.typeId}" style="display:grid; grid-template-columns:1.5fr 1fr auto; gap:10px;">
         <input name="input_search" value="${payload.inputSearch}" placeholder="Search" />
         <select name="input_season">
           <option value="0" ${payload.inputSeason === '0' ? 'selected' : ''}>All Season</option>
           ${seasonOptions}
         </select>
         <button type="submit">Search</button>
       </form>
     </div>
     <div class="card" style="margin-bottom:16px;">
       <h3>Save Sort Order</h3>
       <form method="post" action="/producer/shorts-episode/sortable">
         <input name="ids" placeholder="Example: 5,2,7,1" required />
         <input type="hidden" name="show_id" value="${payload.showId}" />
         <input type="hidden" name="type_id" value="${payload.typeId}" />
         <button type="submit">Save Sort</button>
       </form>
     </div>
     <div class="card">
       <h3>Episode List</h3>
       <div class="sticky-action-wrap">
       <table class="sticky-action-table" style="width:100%; border-collapse:collapse;">
         <thead><tr><th align="left">#</th><th align="left">Name</th><th align="left">Season</th><th align="left">Premium</th><th align="left">Views</th><th align="left">Status</th><th align="left">Sort</th><th align="left">Actions</th></tr></thead>
         <tbody>${rows}</tbody>
       </table>
       </div>
     </div>`,
  );
}

export function renderProducerWithdrawalPage(
  payload: {
    wallet: number;
    minWithdrawalAmount: number;
    currencyCode: string;
    inputStatus?: string;
    withdrawals: Array<{ id: number; price: number; status: number; createdAt: string }>;
  },
  message = '',
): string {
  const msgHtml = message ? `<div class="msg">${message}</div>` : '';
  const selectedStatus = payload.inputStatus ?? 'all';
  const rowsHtml = payload.withdrawals
    .map(
      (item) => `<tr>
        <td>${item.id}</td>
        <td>${formatAmount(payload.currencyCode, item.price)}</td>
        <td>${formatDateDMY(item.createdAt)}</td>
        <td>${renderWithdrawalStatusBadge(item.status)}</td>
      </tr>`,
    )
    .join('');
  const rows = rowsHtml || '<tr><td colspan="4" style="text-align:center;color:#6b7280;">No data available in table</td></tr>';

  return pageTemplate(
    'Withdrawal Request',
    `<div class="topbar"><h1>Withdrawal Request</h1>${renderTopbarActions('/producer/dashboard', 'Back Dashboard')}</div>
     ${msgHtml}
     <div class="card" style="margin-bottom:16px;">
       <h3>Add Withdrawal Request</h3>
       <p style="margin-top:0;color:#6b7280;">Available Wallet: ${formatAmount(payload.currencyCode, payload.wallet)} | Min Withdrawal Amount: ${formatAmount(payload.currencyCode, payload.minWithdrawalAmount)}</p>
       <form method="post" action="/producer/withdrawal">
         <input name="price" placeholder="Price Here..." required />
         <button type="submit">Save</button>
       </form>
     </div>
     <div class="card">
       <h3>Withdrawal Request</h3>
       <form id="withdrawal-filter-form" method="get" action="/producer/withdrawal" style="margin-bottom:12px;max-width:260px;">
        <select name="input_status" onchange="document.getElementById('withdrawal-filter-form')?.submit()">
          <option value="all" ${selectedStatus === 'all' ? 'selected' : ''}>All</option>
          <option value="0" ${selectedStatus === '0' ? 'selected' : ''}>Pending</option>
          <option value="1" ${selectedStatus === '1' ? 'selected' : ''}>Completed</option>
        </select>
      </form>
       <table style="width:100%; border-collapse:collapse;">
         <thead><tr><th align="left">#</th><th align="left">Price</th><th align="left">Date</th><th align="left">Status</th></tr></thead>
         <tbody>${rows}</tbody>
       </table>
     </div>`,
  );
}

export function renderProducerRentTransactionPage(
  payload: {
    summary: {
      year: { totalCommission: number; totalProducerEarning: number };
      month: { totalCommission: number; totalProducerEarning: number };
      today: { totalCommission: number; totalProducerEarning: number };
    };
    currencyCode: string;
    items: Array<{
      id: number;
      transactionId: string;
      userName: string;
      userContact: string;
      videoName: string;
      transactionStatus: number;
      price: number;
      commission: number;
      producerEarning: number;
      expiryDate: string;
      status: number;
      createdAt: string;
    }>;
    inputType: string;
    inputSearch: string;
  },
): string {
  const rowsHtml = payload.items
    .map(
      (item) => `<tr>
        <td>${item.id}</td>
        <td>-</td>
        <td>${item.userName || '-'}</td>
        <td>${item.userContact || '-'}</td>
        <td>${item.videoName || '-'}</td>
        <td>
          <div>Price: <b>${formatAmount(payload.currencyCode, item.price)}</b></div>
          <div>Commission: <b>${formatAmount(payload.currencyCode, item.commission)}</b></div>
          <div>Producer Earnings: <b>${formatAmount(payload.currencyCode, item.producerEarning)}</b></div>
        </td>
        <td>${item.transactionId || '-'}</td>
        <td>${formatDateDMY(item.createdAt)}</td>
        <td>
          <div>${formatDateDMY(item.expiryDate)}</div>
          <div style="margin-top:4px;">${renderRentExpiryBadge(item.status)}</div>
        </td>
        <td>${renderTransactionStatusBadge(item.transactionStatus)}</td>
      </tr>`,
    )
    .join('');
  const rows = rowsHtml || '<tr><td colspan="10" style="text-align:center;color:#6b7280;">No data available in table</td></tr>';

  return pageTemplate(
    'Rent Transaction',
    `<div class="topbar"><h1>Rent Transaction</h1>${renderTopbarActions('/producer/dashboard', 'Back Dashboard')}</div>
     <div class="card" style="margin-bottom:16px;">
       <p style="margin:0;"><b>Year:</b> Commission ${formatAmount(payload.currencyCode, payload.summary.year.totalCommission)} | Producer Earnings ${formatAmount(payload.currencyCode, payload.summary.year.totalProducerEarning)}</p>
       <p style="margin:8px 0 0;"><b>Month:</b> Commission ${formatAmount(payload.currencyCode, payload.summary.month.totalCommission)} | Producer Earnings ${formatAmount(payload.currencyCode, payload.summary.month.totalProducerEarning)}</p>
       <p style="margin:8px 0 0;"><b>Today:</b> Commission ${formatAmount(payload.currencyCode, payload.summary.today.totalCommission)} | Producer Earnings ${formatAmount(payload.currencyCode, payload.summary.today.totalProducerEarning)}</p>
     </div>
     <div class="card" style="margin-bottom:16px;">
       <form method="get" action="/producer/rent-transaction" style="display:grid; grid-template-columns:1fr 1fr auto; gap:10px;">
         <select name="input_type">
           <option value="all" ${payload.inputType === 'all' ? 'selected' : ''}>All</option>
           <option value="today" ${payload.inputType === 'today' ? 'selected' : ''}>Today</option>
           <option value="month" ${payload.inputType === 'month' ? 'selected' : ''}>Month</option>
           <option value="year" ${payload.inputType === 'year' ? 'selected' : ''}>Year</option>
         </select>
         <input name="input_search" value="${payload.inputSearch}" placeholder="Search" />
         <button type="submit">Search</button>
       </form>
     </div>
     <div class="card">
       <table style="width:100%; border-collapse:collapse;">
         <thead><tr><th align="left">#</th><th align="left">Coupon</th><th align="left">User</th><th align="left">Contact</th><th align="left">Content</th><th align="left">Earnings</th><th align="left">Transaction ID</th><th align="left">Date</th><th align="left">Expiry</th><th align="left">Status</th></tr></thead>
         <tbody>${rows}</tbody>
       </table>
     </div>`,
  );
}

export function renderAdminProfilePage(
  profile: { id: number; userName: string; email: string },
  profileMessage = '',
  passwordMessage = '',
): string {
  const profileMsgHtml = profileMessage ? `<div class="msg">${profileMessage}</div>` : '';
  const passwordMsgHtml = passwordMessage ? `<div class="msg">${passwordMessage}</div>` : '';

  return pageTemplate(
    'Admin Profile',
    `<div class="topbar"><h1>Admin Profile</h1>${renderTopbarActions('/admin/dashboard', 'Back Dashboard')}</div>
     <div class="card" style="margin-bottom:16px;">
       <h3>Profile</h3>
       ${profileMsgHtml}
       <form method="post" action="/admin/profile">
         <input type="hidden" name="id" value="${profile.id}" />
         <input name="user_name" value="${profile.userName}" placeholder="User Name" required />
         <input name="email" type="email" value="${profile.email}" placeholder="Email" required />
         <button type="submit">Save Profile</button>
       </form>
     </div>
     <div class="card">
       <h3>Change Password</h3>
       ${passwordMsgHtml}
       <form method="post" action="/admin/profile/changepassword">
         <input type="hidden" name="id" value="${profile.id}" />
         <input name="current_password" type="password" placeholder="Current Password" required />
         <input name="new_password" type="password" placeholder="New Password" required />
         <input name="confirm_password" type="password" placeholder="Confirm Password" required />
         <button type="submit">Change Password</button>
       </form>
     </div>`,
  );
}

export function renderProducerProfilePage(
  profile: { id: number; userName: string; fullName: string; email: string; mobileNumber: string },
  message = '',
): string {
  const msgHtml = message ? `<div class="msg">${message}</div>` : '';

  return pageTemplate(
    'Producer Profile',
    `<div class="topbar"><h1>Producer Profile</h1>${renderTopbarActions('/producer/dashboard', 'Back Dashboard')}</div>
     <div class="card">
       ${msgHtml}
       <form method="post" action="/producer/profile">
         <input type="hidden" name="id" value="${profile.id}" />
         <input name="user_name" value="${profile.userName}" placeholder="User Name" required />
         <input name="full_name" value="${profile.fullName}" placeholder="Full Name" required />
         <input name="email" type="email" value="${profile.email}" placeholder="Email" required />
         <input name="mobile_number" value="${profile.mobileNumber}" placeholder="Mobile Number" required />
         <button type="submit">Save Profile</button>
       </form>
     </div>`,
  );
}

export function renderProducerChangePasswordPage(profileId: number, message = ''): string {
  const msgHtml = message ? `<div class="msg">${message}</div>` : '';

  return pageTemplate(
    'Producer Change Password',
    `<div class="topbar"><h1>Producer Change Password</h1>${renderTopbarActions('/producer/dashboard', 'Back Dashboard')}</div>
     <div class="card">
       ${msgHtml}
       <form method="post" action="/producer/change-password">
         <input type="hidden" name="id" value="${profileId}" />
         <input name="current_password" type="password" placeholder="Current Password" required />
         <input name="new_password" type="password" placeholder="New Password" required />
         <input name="confirm_password" type="password" placeholder="Confirm Password" required />
         <button type="submit">Change Password</button>
       </form>
     </div>`,
  );
}
