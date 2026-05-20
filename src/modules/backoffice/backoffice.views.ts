function pageTemplate(title: string, body: string): string {
  return `<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>${title}</title>
  <style>
    body { font-family: Arial, sans-serif; background:#f5f6f8; margin:0; }
    .container { max-width: 980px; margin: 40px auto; padding: 0 20px; }
    .card { background: #fff; border-radius: 12px; box-shadow: 0 4px 18px rgba(0,0,0,.06); padding: 24px; }
    h1 { margin-top: 0; }
    h3 { margin-top: 0; }
    .grid { display:grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)); gap: 12px; }
    .metric { padding: 14px; border:1px solid #e9ebee; border-radius: 10px; }
    .metric .label { color:#6b7280; font-size: 12px; }
    .metric .value { font-size: 20px; font-weight: 700; margin-top: 6px; }
    input, select { width:100%; box-sizing:border-box; padding:10px; border:1px solid #d0d5dd; border-radius: 8px; margin-bottom: 10px; background:#fff; }
    button { width:100%; padding:10px; border:none; border-radius: 8px; background:#1f2937; color:#fff; cursor:pointer; }
    .topbar { display:flex; justify-content:space-between; align-items:center; margin-bottom: 16px; }
    a { color:#2563eb; text-decoration:none; }
    .msg { margin-bottom:16px; padding:12px 14px; border-radius:10px; border:1px solid #fecaca; background:#fef2f2; color:#991b1b; }
    .badge { display:inline-block; padding:3px 8px; border-radius:999px; font-size:12px; font-weight:700; }
    .badge-success { background:#dcfce7; color:#166534; }
    .badge-danger { background:#fee2e2; color:#991b1b; }
    .badge-primary { background:#dbeafe; color:#1e3a8a; }
    .navlinks { margin-bottom:12px; color:#6b7280; display:flex; flex-wrap:wrap; gap:8px; }
    .muted { color:#6b7280; font-size:14px; }
    .section-note { margin-top:8px; color:#6b7280; font-size:13px; }
    .empty { text-align:center; color:#6b7280; padding:18px 12px; }
    .action-group { display:flex; flex-wrap:wrap; gap:8px; align-items:flex-start; }
    .action-group form, .action-group details, .action-group a { margin:0; }
    .action-link { display:inline-flex; align-items:center; justify-content:center; min-width:110px; padding:10px 12px; border-radius:8px; background:#eef2ff; color:#1e3a8a; }
    details.inline-editor { display:inline-block; min-width:320px; background:#f8fafc; border:1px solid #e5e7eb; border-radius:8px; padding:8px 10px; }
    details.inline-editor summary { cursor:pointer; font-weight:700; color:#1f2937; }
    details.inline-editor form { margin-top:10px; width:280px; }
    table td { vertical-align:top; padding:10px 8px; border-top:1px solid #eef2f7; }
    table th { padding:10px 8px; }
  </style>
</head>
<body>
  <div class="container">${body}</div>
</body>
</html>`;
}

function renderPageHeader(title: string, backHref: string, backLabel: string, links: string[] = [], description = ''): string {
  const nav = links.length > 0 ? `<div class="navlinks">${links.join('<span>/</span>')}</div>` : '';
  const desc = description ? `<div class="muted" style="margin-bottom:16px;">${description}</div>` : '';
  return `<div class="topbar"><div><h1>${title}</h1>${nav}</div><a href="${backHref}">${backLabel}</a></div>${desc}`;
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
        <td>${item.name}</td>
        <td>${item.image || '-'}</td>
        <td>${item.status === 1 ? 'Show' : 'Hide'}</td>
        <td>
          <form method="post" action="/admin/category/update" style="display:inline-block; width:260px;">
            <input type="hidden" name="id" value="${item.id}" />
            <input name="name" value="${item.name}" placeholder="Name" required />
            <input name="image" value="${item.image}" placeholder="Image filename" />
            <button type="submit">Update</button>
          </form>
          <form method="post" action="/admin/category/toggle" style="display:inline-block; width:140px; margin-left:8px;">
            <input type="hidden" name="id" value="${item.id}" />
            <button type="submit">Toggle Status</button>
          </form>
        </td>
      </tr>`,
    )
    .join('');

  return pageTemplate(
    'Admin Category',
    `<div class="topbar"><h1>Admin Category</h1><a href="/admin/dashboard">Back Dashboard</a></div>
     ${msgHtml}
     <div class="card" style="margin-bottom:16px;">
       <h3>Create Category</h3>
       <form method="post" action="/admin/category">
         <input name="name" placeholder="Name" required />
         <input name="image" placeholder="Image filename" />
         <button type="submit">Create</button>
       </form>
     </div>
     <div class="card">
       <h3>Category List</h3>
       <table style="width:100%; border-collapse:collapse;">
         <thead><tr><th align="left">ID</th><th align="left">Name</th><th align="left">Image</th><th align="left">Status</th><th align="left">Actions</th></tr></thead>
         <tbody>${rows}</tbody>
       </table>
     </div>`,
  );
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
        <td>${item.name}</td>
        <td>${item.portrait_img || '-'}</td>
        <td>${item.landscape_img || '-'}</td>
        <td>${item.is_title}</td>
        <td>${item.status === 1 ? 'Show' : 'Hide'}</td>
        <td>
          <form method="post" action="/admin/channel/update" style="display:inline-block; width:420px;">
            <input type="hidden" name="id" value="${item.id}" />
            <input name="name" value="${item.name}" placeholder="Name" required />
            <input name="portrait_img" value="${item.portrait_img}" placeholder="Portrait image" />
            <input name="landscape_img" value="${item.landscape_img}" placeholder="Landscape image" />
            <input name="is_title" value="${item.is_title}" placeholder="Is title (0/1)" required />
            <button type="submit">Update</button>
          </form>
          <form method="post" action="/admin/channel/toggle" style="display:inline-block; width:140px; margin-left:8px;">
            <input type="hidden" name="id" value="${item.id}" />
            <button type="submit">Toggle Status</button>
          </form>
        </td>
      </tr>`,
    )
    .join('');

  return pageTemplate(
    'Admin Channel',
    `<div class="topbar"><h1>Admin Channel</h1><a href="/admin/dashboard">Back Dashboard</a></div>
     ${msgHtml}
     <div class="card" style="margin-bottom:16px;">
       <h3>Create Channel</h3>
       <form method="post" action="/admin/channel">
         <input name="name" placeholder="Name" required />
         <input name="portrait_img" placeholder="Portrait image" />
         <input name="landscape_img" placeholder="Landscape image" />
         <input name="is_title" placeholder="Is title (0/1)" required />
         <button type="submit">Create</button>
       </form>
     </div>
     <div class="card">
       <h3>Channel List</h3>
       <table style="width:100%; border-collapse:collapse;">
         <thead><tr><th align="left">ID</th><th align="left">Name</th><th align="left">Portrait</th><th align="left">Landscape</th><th align="left">Is Title</th><th align="left">Status</th><th align="left">Actions</th></tr></thead>
         <tbody>${rows}</tbody>
       </table>
     </div>`,
  );
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
        <td>${item.name}</td>
        <td>${item.image || '-'}</td>
        <td>${item.status === 1 ? 'Show' : 'Hide'}</td>
        <td>
          <form method="post" action="/admin/avatar/update" style="display:inline-block; width:260px;">
            <input type="hidden" name="id" value="${item.id}" />
            <input name="name" value="${item.name}" placeholder="Name" required />
            <input name="image" value="${item.image}" placeholder="Image filename" />
            <button type="submit">Update</button>
          </form>
          <form method="post" action="/admin/avatar/toggle" style="display:inline-block; width:140px; margin-left:8px;">
            <input type="hidden" name="id" value="${item.id}" />
            <button type="submit">Toggle Status</button>
          </form>
        </td>
      </tr>`,
    )
    .join('');

  return pageTemplate(
    'Admin Avatar',
    `<div class="topbar"><h1>Admin Avatar</h1><a href="/admin/dashboard">Back Dashboard</a></div>
     ${msgHtml}
     <div class="card" style="margin-bottom:16px;">
       <h3>Create Avatar</h3>
       <form method="post" action="/admin/avatar">
         <input name="name" placeholder="Name" required />
         <input name="image" placeholder="Image filename" />
         <button type="submit">Create</button>
       </form>
     </div>
     <div class="card" style="margin-bottom:16px;">
       <h3>Save Sort Order</h3>
       <form method="post" action="/admin/avatar/sortable/save">
         <input name="ids" placeholder="Example: 5,2,7,1" required />
         <button type="submit">Save Sort</button>
       </form>
     </div>
     <div class="card">
       <h3>Avatar List</h3>
       <table style="width:100%; border-collapse:collapse;">
         <thead><tr><th align="left">ID</th><th align="left">Name</th><th align="left">Image</th><th align="left">Status</th><th align="left">Actions</th></tr></thead>
         <tbody>${rows}</tbody>
       </table>
     </div>`,
  );
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
        <td>${item.name}</td>
        <td>${item.type}</td>
        <td>${item.icon || '-'}</td>
        <td>${item.status === 1 ? 'Show' : 'Hide'}</td>
        <td>
          <form method="post" action="/admin/type/update" style="display:inline-block; width:320px;">
            <input type="hidden" name="id" value="${item.id}" />
            <input name="name" value="${item.name}" placeholder="Name" required />
            <input name="type" value="${item.type}" placeholder="Type number" required />
            <input name="icon" value="${item.icon}" placeholder="Icon filename" />
            <button type="submit">Update</button>
          </form>
          <form method="post" action="/admin/type/toggle" style="display:inline-block; width:140px; margin-left:8px;">
            <input type="hidden" name="id" value="${item.id}" />
            <button type="submit">Toggle Status</button>
          </form>
        </td>
      </tr>`,
    )
    .join('');

  return pageTemplate(
    'Admin Type',
    `<div class="topbar"><h1>Admin Type</h1><a href="/admin/dashboard">Back Dashboard</a></div>
     ${msgHtml}
     <div class="card" style="margin-bottom:16px;">
       <h3>Create Type</h3>
       <form method="post" action="/admin/type">
         <input name="name" placeholder="Name" required />
         <input name="type" placeholder="Type number" required />
         <input name="icon" placeholder="Icon filename" />
         <button type="submit">Create</button>
       </form>
     </div>
     <div class="card" style="margin-bottom:16px;">
       <h3>Save Sort Order</h3>
       <form method="post" action="/admin/type/sortable/save">
         <input name="ids" placeholder="Example: 5,2,7,1" required />
         <button type="submit">Save Sort</button>
       </form>
     </div>
     <div class="card">
       <h3>Type List</h3>
       <table style="width:100%; border-collapse:collapse;">
         <thead><tr><th align="left">ID</th><th align="left">Name</th><th align="left">Type</th><th align="left">Icon</th><th align="left">Status</th><th align="left">Actions</th></tr></thead>
         <tbody>${rows}</tbody>
       </table>
     </div>`,
  );
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
        <td>${item.name}</td>
        <td>${item.sort_order}</td>
        <td>${item.status === 1 ? 'Active' : 'Inactive'}</td>
        <td>
          <form method="post" action="/admin/season/update" style="display:inline-block; width:260px;">
            <input type="hidden" name="id" value="${item.id}" />
            <input name="name" value="${item.name}" placeholder="Name" required />
            <button type="submit">Update</button>
          </form>
        </td>
      </tr>`,
    )
    .join('');

  return pageTemplate(
    'Admin Season',
    `<div class="topbar"><h1>Admin Season</h1><a href="/admin/dashboard">Back Dashboard</a></div>
     ${msgHtml}
     <div class="card" style="margin-bottom:16px;">
       <h3>Create Season</h3>
       <form method="post" action="/admin/season">
         <input name="name" placeholder="Name" required />
         <button type="submit">Create</button>
       </form>
     </div>
     <div class="card" style="margin-bottom:16px;">
       <h3>Save Sort Order</h3>
       <form method="post" action="/admin/season/sortable/save">
         <input name="ids" placeholder="Example: 5,2,7,1" required />
         <button type="submit">Save Sort</button>
       </form>
     </div>
     <div class="card">
       <h3>Season List</h3>
       <table style="width:100%; border-collapse:collapse;">
         <thead><tr><th align="left">ID</th><th align="left">Name</th><th align="left">Sort Order</th><th align="left">Status</th><th align="left">Actions</th></tr></thead>
         <tbody>${rows}</tbody>
       </table>
     </div>`,
  );
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
        <td>${item.name}</td>
        <td>${item.image || '-'}</td>
        <td>${item.status === 1 ? 'Show' : 'Hide'}</td>
        <td>
          <form method="post" action="/admin/language/update" style="display:inline-block; width:260px;">
            <input type="hidden" name="id" value="${item.id}" />
            <input name="name" value="${item.name}" placeholder="Name" required />
            <input name="image" value="${item.image}" placeholder="Image filename" />
            <button type="submit">Update</button>
          </form>
          <form method="post" action="/admin/language/toggle" style="display:inline-block; width:140px; margin-left:8px;">
            <input type="hidden" name="id" value="${item.id}" />
            <button type="submit">Toggle Status</button>
          </form>
        </td>
      </tr>`,
    )
    .join('');

  return pageTemplate(
    'Admin Language',
    `<div class="topbar"><h1>Admin Language</h1><a href="/admin/dashboard">Back Dashboard</a></div>
     ${msgHtml}
     <div class="card" style="margin-bottom:16px;">
       <h3>Create Language</h3>
       <form method="post" action="/admin/language">
         <input name="name" placeholder="Name" required />
         <input name="image" placeholder="Image filename" />
         <button type="submit">Create</button>
       </form>
     </div>
     <div class="card">
       <h3>Language List</h3>
       <table style="width:100%; border-collapse:collapse;">
         <thead><tr><th align="left">ID</th><th align="left">Name</th><th align="left">Image</th><th align="left">Status</th><th align="left">Actions</th></tr></thead>
         <tbody>${rows}</tbody>
       </table>
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
    `<div class="topbar"><h1>Admin Dashboard</h1><a href="/admin/logout">Logout</a></div>
     <div style="margin-bottom:12px;"><a href="/admin/profile">Profile</a> | <a href="/admin/type">Type</a> | <a href="/admin/category">Category</a> | <a href="/admin/language">Language</a> | <a href="/admin/season">Season</a> | <a href="/admin/avatar">Avatar</a> | <a href="/admin/channel">Channel</a> | <a href="/admin/video">Video</a> | <a href="/admin/tvshow">TV Show</a> | <a href="/admin/shorts">Shorts</a> | <a href="/admin/episode">Episodes</a></div>
     <div class="card"><p>Welcome, ${userName}</p><div class="grid">${metrics}</div></div>`,
  );
}

export function renderAdminContentPlaceholderPage(title: string, message: string): string {
  return pageTemplate(
    title,
    `<div class="topbar"><h1>${title}</h1><a href="/admin/dashboard">Back Dashboard</a></div>
     <div class="card"><p>${message}</p></div>`,
  );
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
  message = '',
): string {
  const msgHtml = message ? `<div class="msg">${message}</div>` : '';
  const rowsHtml = items
    .map(
      (item) => `<tr>
        <td>${item.id}</td>
        <td>${item.name || '-'}</td>
        <td>${item.type_id}</td>
        <td>${item.video_type}</td>
        <td>${item.producer_id}</td>
        <td>${item.is_premium === 1 ? 'Premium' : 'Free'}</td>
        <td>${item.is_rent === 1 ? `Rent (${item.price})` : 'No'}</td>
        <td>${item.total_view}</td>
        <td>${formatDateDMY(item.created_at)}</td>
        <td>${item.status === 1 ? '<span class="badge badge-success">Show</span>' : '<span class="badge badge-danger">Hide</span>'}</td>
        <td>
          <form method="post" action="/admin/video/toggle" style="display:inline-block; width:140px;">
            <input type="hidden" name="id" value="${item.id}" />
            <button type="submit">Toggle Status</button>
          </form>
        </td>
      </tr>`,
    )
    .join('');
  const rows = rowsHtml || '<tr><td colspan="11" style="text-align:center;color:#6b7280;">No data available in table</td></tr>';

  return pageTemplate(
    'Admin Video',
    `<div class="topbar"><h1>Admin Video</h1><a href="/admin/dashboard">Back Dashboard</a></div>
     ${msgHtml}
     <div class="card">
       <table style="width:100%; border-collapse:collapse;">
         <thead><tr><th align="left">#</th><th align="left">Name</th><th align="left">Type ID</th><th align="left">Video Type</th><th align="left">Producer</th><th align="left">Premium</th><th align="left">Rent</th><th align="left">Views</th><th align="left">Created</th><th align="left">Status</th><th align="left">Actions</th></tr></thead>
         <tbody>${rows}</tbody>
       </table>
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
  message = '',
): string {
  const msgHtml = message ? `<div class="msg">${message}</div>` : '';
  const rowsHtml = items
    .map(
      (item) => `<tr>
        <td>${item.id}</td>
        <td>${item.name || '-'}</td>
        <td>${item.type_id}</td>
        <td>${item.video_type}</td>
        <td>${item.producer_id}</td>
        <td>${item.is_rent === 1 ? `Rent (${item.price})` : 'No'}</td>
        <td>${item.total_view}</td>
        <td>${formatDateDMY(item.created_at)}</td>
        <td>${item.status === 1 ? '<span class="badge badge-success">Show</span>' : '<span class="badge badge-danger">Hide</span>'}</td>
        <td>
          <form method="post" action="/admin/tvshow/toggle" style="display:inline-block; width:140px;">
            <input type="hidden" name="id" value="${item.id}" />
            <button type="submit">Toggle Status</button>
          </form>
        </td>
      </tr>`,
    )
    .join('');
  const rows = rowsHtml || '<tr><td colspan="10" style="text-align:center;color:#6b7280;">No data available in table</td></tr>';

  return pageTemplate(
    'Admin TV Show',
    `<div class="topbar"><h1>Admin TV Show</h1><a href="/admin/dashboard">Back Dashboard</a></div>
     ${msgHtml}
     <div class="card">
       <table style="width:100%; border-collapse:collapse;">
         <thead><tr><th align="left">#</th><th align="left">Name</th><th align="left">Type ID</th><th align="left">Video Type</th><th align="left">Producer</th><th align="left">Rent</th><th align="left">Views</th><th align="left">Created</th><th align="left">Status</th><th align="left">Actions</th></tr></thead>
         <tbody>${rows}</tbody>
       </table>
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
  message = '',
): string {
  const msgHtml = message ? `<div class="msg">${message}</div>` : '';
  const rowsHtml = items
    .map(
      (item) => `<tr>
        <td>${item.id}</td>
        <td>${item.name || '-'}</td>
        <td>${item.type_id}</td>
        <td>${item.video_type}</td>
        <td>${item.producer_id}</td>
        <td>${item.total_view}</td>
        <td>${formatDateDMY(item.created_at)}</td>
        <td>${item.status === 1 ? '<span class="badge badge-success">Show</span>' : '<span class="badge badge-danger">Hide</span>'}</td>
        <td>
          <form method="post" action="/admin/shorts/toggle" style="display:inline-block; width:140px;">
            <input type="hidden" name="id" value="${item.id}" />
            <button type="submit">Toggle Status</button>
          </form>
        </td>
      </tr>`,
    )
    .join('');
  const rows = rowsHtml || '<tr><td colspan="9" style="text-align:center;color:#6b7280;">No data available in table</td></tr>';

  return pageTemplate(
    'Admin Shorts',
    `<div class="topbar"><h1>Admin Shorts</h1><a href="/admin/dashboard">Back Dashboard</a></div>
     ${msgHtml}
     <div class="card">
       <table style="width:100%; border-collapse:collapse;">
         <thead><tr><th align="left">#</th><th align="left">Name</th><th align="left">Type ID</th><th align="left">Video Type</th><th align="left">Producer</th><th align="left">Views</th><th align="left">Created</th><th align="left">Status</th><th align="left">Actions</th></tr></thead>
         <tbody>${rows}</tbody>
       </table>
     </div>`,
  );
}

export function renderAdminEpisodeHubPage(): string {
  return pageTemplate(
    'Admin Episodes',
    `<div class="topbar"><h1>Admin Episodes</h1><a href="/admin/dashboard">Back Dashboard</a></div>
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
    `<div class="topbar"><h1>Producer Dashboard</h1><a href="/producer/logout">Logout</a></div>
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
    `<div class="topbar"><h1>Channel</h1><a href="/producer/dashboard">Back Dashboard</a></div>
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
  const msgHtml = message ? `<div class="msg">${message}</div>` : '';
  const channelOptions = payload.channels
    .map((item) => `<option value="${item.id}">${item.name}</option>`)
    .join('');
  const releaseTypeOptions = payload.releasesTypes
    .map((item) => `<option value="${item.id}">${item.name}</option>`)
    .join('');

  const rowsHtml = payload.items
    .map(
      (item) => `<tr>
        <td>${item.id}</td>
        <td>${item.name || '-'}</td>
        <td>${item.video_type}</td>
        <td>${item.is_premium === 1 ? 'Premium' : 'Free'}</td>
        <td>${item.is_rent === 1 ? 'Rent' : 'No'}</td>
        <td>${item.status === 1 ? '<span class="badge badge-success">Show</span>' : '<span class="badge badge-danger">Hide</span>'}</td>
        <td>${formatDateDMY(item.release_date)}</td>
        <td>
          <div class="action-group">
            <details class="inline-editor">
              <summary>Edit</summary>
              <form method="post" action="/producer/video/update/${item.id}">
                <input type="hidden" name="type_id" value="${payload.typeId}" />
                <input type="hidden" name="video_type" value="${item.video_type}" />
                <input name="name" value="${item.name}" placeholder="Name" required />
                <input name="category_id" value="${item.category_id || ''}" placeholder="Category IDs: 1,2" />
                <input name="language_id" value="${item.language_id || ''}" placeholder="Language IDs: 1,2" />
                <input name="cast_id" value="${item.cast_id || ''}" placeholder="Cast IDs: 1,2" />
                <input name="thumbnail" value="${item.thumbnail || ''}" placeholder="Thumbnail" />
                <input name="landscape" value="${item.landscape || ''}" placeholder="Landscape" />
                <input name="release_date" value="${item.release_date || ''}" placeholder="YYYY-MM-DD" />
                <input name="video_upload_type" value="${item.video_upload_type || 'external'}" placeholder="video_upload_type" />
                <input name="video_320" value="${item.video_320 || ''}" placeholder="video_320" />
                <input name="description" value="${item.description || ''}" placeholder="Description" />
                <input name="is_premium" value="${item.is_premium}" placeholder="is_premium" />
                <input name="is_title" value="${item.is_title}" placeholder="is_title" />
                <input name="is_download" value="${item.is_download}" placeholder="is_download" />
                <input name="is_comment" value="${item.is_comment}" placeholder="is_comment" />
                <input name="is_like" value="${item.is_like}" placeholder="is_like" />
                <input name="is_rent" value="${item.is_rent}" placeholder="is_rent" />
                <input name="price" value="${item.price}" placeholder="price" />
                <input name="rent_day" value="${item.rent_day}" placeholder="rent_day" />
                <input name="channel_id" value="${item.channel_id}" placeholder="channel_id" />
                <button type="submit">Save Changes</button>
              </form>
            </details>
            <form method="post" action="/producer/video-status" style="width:120px;">
              <input type="hidden" name="id" value="${item.id}" />
              <input type="hidden" name="type_id" value="${payload.typeId}" />
              <button type="submit">Toggle</button>
            </form>
            <form method="post" action="/producer/video/releases" style="width:240px;">
              <input type="hidden" name="id" value="${item.id}" />
              <select name="type_id">${releaseTypeOptions}</select>
              <select name="channel_id"><option value="0">No Channel</option>${channelOptions}</select>
              <button type="submit">Release</button>
            </form>
            <form method="post" action="/producer/video/delete/${item.id}/${payload.typeId}" style="width:120px;">
              <button type="submit">Delete</button>
            </form>
          </div>
        </td>
      </tr>`,
    )
    .join('');
  const rows = rowsHtml || renderEmptyRow(8, 'No videos yet', 'Create your first video or adjust the search filters.');

  return pageTemplate(
    'Video',
    `${renderPageHeader('Video', '/producer/dashboard', 'Back Dashboard', ['Producer', 'Content', 'Video'], 'Manage producer video content, release targets, and basic publishing state from one place.')}
     ${msgHtml}
     <div class="card" style="margin-bottom:16px;">
       <form method="get" action="/producer/video/${payload.typeId}" style="display:grid; grid-template-columns:1.5fr 1fr 1fr 1fr auto; gap:10px;">
         <input name="input_search" value="${payload.inputSearch}" placeholder="Search" />
         <select name="input_rent">
           <option value="0" ${payload.inputRent === '0' ? 'selected' : ''}>All Rent</option>
           <option value="1" ${payload.inputRent === '1' ? 'selected' : ''}>Rent Only</option>
         </select>
         <select name="input_premium">
           <option value="all" ${payload.inputPremium === 'all' ? 'selected' : ''}>All Premium</option>
           <option value="0" ${payload.inputPremium === '0' ? 'selected' : ''}>Free</option>
           <option value="1" ${payload.inputPremium === '1' ? 'selected' : ''}>Premium</option>
         </select>
         <select name="input_status">
           <option value="all" ${payload.inputStatus === 'all' ? 'selected' : ''}>All Status</option>
           <option value="0" ${payload.inputStatus === '0' ? 'selected' : ''}>Hide</option>
           <option value="1" ${payload.inputStatus === '1' ? 'selected' : ''}>Show</option>
         </select>
         <button type="submit">Search</button>
       </form>
     </div>
     <div class="card" style="margin-bottom:16px;">
       <h3>Add Video</h3>
       <div class="section-note">Use the create form for new content. Use the row-level Edit action for small corrections.</div>
       <form method="post" action="/producer/video/save">
         <input type="hidden" name="type_id" value="${payload.typeId}" />
         <input name="name" placeholder="Name" required />
         <input name="video_type" placeholder="video_type (1/5/6/7)" required />
         <input name="channel_id" placeholder="channel_id" />
         <input name="category_id" placeholder="Category IDs: 1,2" required />
         <input name="language_id" placeholder="Language IDs: 1,2" required />
         <input name="cast_id" placeholder="Cast IDs: 1,2" />
         <input name="thumbnail" placeholder="Thumbnail" />
         <input name="landscape" placeholder="Landscape" />
         <input name="description" placeholder="Description" />
         <input name="release_date" placeholder="YYYY-MM-DD" />
         <input name="video_upload_type" value="external" placeholder="video_upload_type" />
         <input name="video_320" placeholder="video_320" required />
         <input name="video_480" placeholder="video_480" />
         <input name="video_720" placeholder="video_720" />
         <input name="video_1080" placeholder="video_1080" />
         <input name="trailer_type" value="external" placeholder="trailer_type" />
         <input name="trailer_url" placeholder="trailer_url" />
         <input name="subtitle_type" value="external" placeholder="subtitle_type" />
         <input name="subtitle_1" placeholder="subtitle_1" />
         <input name="subtitle_2" placeholder="subtitle_2" />
         <input name="subtitle_3" placeholder="subtitle_3" />
         <input name="subtitle_lang_1" placeholder="subtitle_lang_1" />
         <input name="subtitle_lang_2" placeholder="subtitle_lang_2" />
         <input name="subtitle_lang_3" placeholder="subtitle_lang_3" />
         <input name="is_premium" value="0" placeholder="is_premium" required />
         <input name="is_title" value="0" placeholder="is_title" required />
         <input name="is_download" value="0" placeholder="is_download" required />
         <input name="is_comment" value="1" placeholder="is_comment" required />
         <input name="is_like" value="1" placeholder="is_like" required />
         <input name="is_rent" value="0" placeholder="is_rent" required />
         <input name="price" value="0" placeholder="price" />
         <input name="rent_day" value="0" placeholder="rent_day" />
         <button type="submit">Save</button>
       </form>
     </div>
     <div class="card">
       <h3>Video List</h3>
       <table style="width:100%; border-collapse:collapse;">
         <thead><tr><th align="left">#</th><th align="left">Name</th><th align="left">Video Type</th><th align="left">Premium</th><th align="left">Rent</th><th align="left">Status</th><th align="left">Release Date</th><th align="left">Actions</th></tr></thead>
         <tbody>${rows}</tbody>
       </table>
     </div>`,
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
  const msgHtml = message ? `<div class="msg">${message}</div>` : '';
  const channelOptions = payload.channels
    .map((item) => `<option value="${item.id}">${item.name}</option>`)
    .join('');
  const releaseTypeOptions = payload.releasesTypes
    .map((item) => `<option value="${item.id}">${item.name}</option>`)
    .join('');

  const rowsHtml = payload.items
    .map(
      (item) => `<tr>
        <td>${item.id}</td>
        <td>${item.name || '-'}</td>
        <td>${item.video_type}</td>
        <td>${item.is_rent === 1 ? 'Rent' : 'No'}</td>
        <td>${item.status === 1 ? '<span class="badge badge-success">Show</span>' : '<span class="badge badge-danger">Hide</span>'}</td>
        <td>${formatDateDMY(item.release_date)}</td>
        <td>
          <div class="action-group">
            <a class="action-link" href="/producer/tvshow-episode/${item.id}/${payload.typeId}">Episodes</a>
            <details class="inline-editor">
              <summary>Edit</summary>
              <form method="post" action="/producer/tvshow/update/${item.id}">
                <input type="hidden" name="type_id" value="${payload.typeId}" />
                <input type="hidden" name="video_type" value="${item.video_type}" />
                <input name="name" value="${item.name}" placeholder="Name" required />
                <input name="category_id" value="${item.category_id || ''}" placeholder="Category IDs: 1,2" />
                <input name="language_id" value="${item.language_id || ''}" placeholder="Language IDs: 1,2" />
                <input name="cast_id" value="${item.cast_id || ''}" placeholder="Cast IDs: 1,2" />
                <input name="thumbnail" value="${item.thumbnail || ''}" placeholder="Thumbnail" />
                <input name="landscape" value="${item.landscape || ''}" placeholder="Landscape" />
                <input name="description" value="${item.description || ''}" placeholder="Description" />
                <input name="release_date" value="${item.release_date || ''}" placeholder="YYYY-MM-DD" />
                <input name="is_title" value="${item.is_title}" placeholder="is_title" />
                <input name="is_comment" value="${item.is_comment}" placeholder="is_comment" />
                <input name="is_like" value="${item.is_like}" placeholder="is_like" />
                <input name="is_rent" value="${item.is_rent}" placeholder="is_rent" />
                <input name="price" value="${item.price}" placeholder="price" />
                <input name="rent_day" value="${item.rent_day}" placeholder="rent_day" />
                <input name="channel_id" value="${item.channel_id}" placeholder="channel_id" />
                <button type="submit">Save Changes</button>
              </form>
            </details>
            <form method="post" action="/producer/tvshow-status" style="width:120px;">
              <input type="hidden" name="id" value="${item.id}" />
              <input type="hidden" name="type_id" value="${payload.typeId}" />
              <button type="submit">Toggle</button>
            </form>
            <form method="post" action="/producer/tvshow/releases" style="width:240px;">
              <input type="hidden" name="id" value="${item.id}" />
              <select name="type_id">${releaseTypeOptions}</select>
              <select name="channel_id"><option value="0">No Channel</option>${channelOptions}</select>
              <button type="submit">Release</button>
            </form>
            <form method="post" action="/producer/tvshow/delete/${item.id}/${payload.typeId}" style="width:120px;">
              <button type="submit">Delete</button>
            </form>
          </div>
        </td>
      </tr>`,
    )
    .join('');
  const rows = rowsHtml || renderEmptyRow(7, 'No TV shows yet', 'Create your first show or change the filter conditions.');

  return pageTemplate(
    'TV Show',
    `${renderPageHeader('TV Show', '/producer/dashboard', 'Back Dashboard', ['Producer', 'Content', 'TV Show'], 'Use episodes, release targets, and publishing actions from a cleaner action area.')}
     ${msgHtml}
     <div class="card" style="margin-bottom:16px;">
       <form method="get" action="/producer/tvshow/${payload.typeId}" style="display:grid; grid-template-columns:1.5fr 1fr 1fr auto; gap:10px;">
         <input name="input_search" value="${payload.inputSearch}" placeholder="Search" />
         <select name="input_rent">
           <option value="0" ${payload.inputRent === '0' ? 'selected' : ''}>All Rent</option>
           <option value="1" ${payload.inputRent === '1' ? 'selected' : ''}>Rent Only</option>
         </select>
         <select name="input_status">
           <option value="all" ${payload.inputStatus === 'all' ? 'selected' : ''}>All Status</option>
           <option value="0" ${payload.inputStatus === '0' ? 'selected' : ''}>Hide</option>
           <option value="1" ${payload.inputStatus === '1' ? 'selected' : ''}>Show</option>
         </select>
         <button type="submit">Search</button>
       </form>
     </div>
     <div class="card" style="margin-bottom:16px;">
       <h3>Add TV Show</h3>
       <div class="section-note">Create new shows here. For existing rows, use Episodes, Edit, Release, or Toggle actions from the table.</div>
       <form method="post" action="/producer/tvshow/save">
         <input type="hidden" name="type_id" value="${payload.typeId}" />
         <input name="name" placeholder="Name" required />
         <input name="video_type" placeholder="video_type (2/5/6/7)" required />
         <input name="channel_id" placeholder="channel_id" />
         <input name="category_id" placeholder="Category IDs: 1,2" required />
         <input name="language_id" placeholder="Language IDs: 1,2" required />
         <input name="cast_id" placeholder="Cast IDs: 1,2" />
         <input name="thumbnail" placeholder="Thumbnail" />
         <input name="landscape" placeholder="Landscape" />
         <input name="trailer_type" value="external" placeholder="trailer_type" />
         <input name="trailer_url" placeholder="trailer_url" />
         <input name="description" placeholder="Description" />
         <input name="release_date" placeholder="YYYY-MM-DD" />
         <input name="is_title" value="0" placeholder="is_title" required />
         <input name="is_comment" value="1" placeholder="is_comment" required />
         <input name="is_like" value="1" placeholder="is_like" required />
         <input name="is_rent" value="0" placeholder="is_rent" required />
         <input name="price" value="0" placeholder="price" />
         <input name="rent_day" value="0" placeholder="rent_day" />
         <button type="submit">Save</button>
       </form>
     </div>
     <div class="card">
       <h3>TV Show List</h3>
       <table style="width:100%; border-collapse:collapse;">
         <thead><tr><th align="left">#</th><th align="left">Name</th><th align="left">Video Type</th><th align="left">Rent</th><th align="left">Status</th><th align="left">Release Date</th><th align="left">Actions</th></tr></thead>
         <tbody>${rows}</tbody>
       </table>
     </div>`,
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
       <table style="width:100%; border-collapse:collapse;">
         <thead><tr><th align="left">#</th><th align="left">Name</th><th align="left">Season</th><th align="left">Premium</th><th align="left">Views</th><th align="left">Status</th><th align="left">Sort</th><th align="left">Actions</th></tr></thead>
         <tbody>${rows}</tbody>
       </table>
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
  const msgHtml = message ? `<div class="msg">${message}</div>` : '';
  const channelOptions = payload.channels
    .map((item) => `<option value="${item.id}">${item.name}</option>`)
    .join('');
  const releaseTypeOptions = payload.releasesTypes
    .map((item) => `<option value="${item.id}">${item.name}</option>`)
    .join('');

  const rowsHtml = payload.items
    .map(
      (item) => `<tr>
        <td>${item.id}</td>
        <td>${item.name || '-'}</td>
        <td>${item.video_type}</td>
        <td>${item.status === 1 ? '<span class="badge badge-success">Show</span>' : '<span class="badge badge-danger">Hide</span>'}</td>
        <td>
          <div class="action-group">
            <a class="action-link" href="/producer/shorts-episode/${item.id}/${payload.typeId}">Episodes</a>
            <details class="inline-editor">
              <summary>Edit</summary>
              <form method="post" action="/producer/shorts/update/${item.id}">
                <input type="hidden" name="type_id" value="${payload.typeId}" />
                <input type="hidden" name="video_type" value="${item.video_type}" />
                <input name="name" value="${item.name}" placeholder="Name" required />
                <input name="category_id" value="${item.category_id || ''}" placeholder="Category IDs: 1,2" />
                <input name="language_id" value="${item.language_id || ''}" placeholder="Language IDs: 1,2" />
                <input name="cast_id" value="${item.cast_id || ''}" placeholder="Cast IDs: 1,2" />
                <input name="thumbnail" value="${item.thumbnail || ''}" placeholder="Thumbnail" />
                <input name="description" value="${item.description || ''}" placeholder="Description" />
                <input name="is_title" value="${item.is_title}" placeholder="is_title" />
                <input name="is_comment" value="${item.is_comment}" placeholder="is_comment" />
                <input name="is_like" value="${item.is_like}" placeholder="is_like" />
                <button type="submit">Save Changes</button>
              </form>
            </details>
            <form method="post" action="/producer/shorts-status" style="width:120px;">
              <input type="hidden" name="id" value="${item.id}" />
              <input type="hidden" name="type_id" value="${payload.typeId}" />
              <button type="submit">Toggle</button>
            </form>
            <form method="post" action="/producer/shorts/releases" style="width:240px;">
              <input type="hidden" name="id" value="${item.id}" />
              <select name="type_id">${releaseTypeOptions}</select>
              <select name="channel_id"><option value="0">No Channel</option>${channelOptions}</select>
              <button type="submit">Release</button>
            </form>
            <form method="post" action="/producer/shorts/delete/${item.id}/${payload.typeId}" style="width:120px;">
              <button type="submit">Delete</button>
            </form>
          </div>
        </td>
      </tr>`,
    )
    .join('');
  const rows = rowsHtml || renderEmptyRow(5, 'No shorts yet', 'Create shorts content first, then continue with episode management if needed.');

  return pageTemplate(
    'Shorts',
    `${renderPageHeader('Shorts', '/producer/dashboard', 'Back Dashboard', ['Producer', 'Content', 'Shorts'], 'Shorts keep a lighter schema, so the list now emphasizes actions over inline field noise.')}
     ${msgHtml}
     <div class="card" style="margin-bottom:16px;">
       <form method="get" action="/producer/shorts/${payload.typeId}" style="display:grid; grid-template-columns:1.5fr 1fr auto; gap:10px;">
         <input name="input_search" value="${payload.inputSearch}" placeholder="Search" />
         <select name="input_status">
           <option value="all" ${payload.inputStatus === 'all' ? 'selected' : ''}>All Status</option>
           <option value="0" ${payload.inputStatus === '0' ? 'selected' : ''}>Hide</option>
           <option value="1" ${payload.inputStatus === '1' ? 'selected' : ''}>Show</option>
         </select>
         <button type="submit">Search</button>
       </form>
     </div>
     <div class="card" style="margin-bottom:16px;">
       <h3>Add Shorts</h3>
       <div class="section-note">Use this form for new shorts. Existing rows keep their actions compact inside the list.</div>
       <form method="post" action="/producer/shorts/save">
         <input type="hidden" name="type_id" value="${payload.typeId}" />
         <input name="name" placeholder="Name" required />
         <input name="video_type" placeholder="video_type" required />
         <input name="category_id" placeholder="Category IDs: 1,2" required />
         <input name="language_id" placeholder="Language IDs: 1,2" required />
         <input name="cast_id" placeholder="Cast IDs: 1,2" />
         <input name="thumbnail" placeholder="Thumbnail" />
         <input name="trailer_type" value="external" placeholder="trailer_type" />
         <input name="trailer_url" placeholder="trailer_url" />
         <input name="description" placeholder="Description" />
         <input name="is_title" value="0" placeholder="is_title" required />
         <input name="is_comment" value="1" placeholder="is_comment" required />
         <input name="is_like" value="1" placeholder="is_like" required />
         <button type="submit">Save</button>
       </form>
     </div>
     <div class="card">
       <h3>Shorts List</h3>
       <table style="width:100%; border-collapse:collapse;">
         <thead><tr><th align="left">#</th><th align="left">Name</th><th align="left">Video Type</th><th align="left">Status</th><th align="left">Actions</th></tr></thead>
         <tbody>${rows}</tbody>
       </table>
     </div>`,
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
       <table style="width:100%; border-collapse:collapse;">
         <thead><tr><th align="left">#</th><th align="left">Name</th><th align="left">Season</th><th align="left">Premium</th><th align="left">Views</th><th align="left">Status</th><th align="left">Sort</th><th align="left">Actions</th></tr></thead>
         <tbody>${rows}</tbody>
       </table>
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
    `<div class="topbar"><h1>Withdrawal Request</h1><a href="/producer/dashboard">Back Dashboard</a></div>
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
    `<div class="topbar"><h1>Rent Transaction</h1><a href="/producer/dashboard">Back Dashboard</a></div>
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
    `<div class="topbar"><h1>Admin Profile</h1><a href="/admin/dashboard">Back Dashboard</a></div>
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
    `<div class="topbar"><h1>Producer Profile</h1><a href="/producer/dashboard">Back Dashboard</a></div>
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
    `<div class="topbar"><h1>Producer Change Password</h1><a href="/producer/dashboard">Back Dashboard</a></div>
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
