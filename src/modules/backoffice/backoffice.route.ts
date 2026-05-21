import Router from '@koa/router';
import type { Context } from 'koa';
import { env } from '../../config/env';
import { BackofficeService } from './backoffice.service';
import {
  renderAdminAvatarPage,
  renderAdminCategoryPage,
  renderAdminChannelPage,
  renderAdminContentPlaceholderPage,
  renderAdminDashboard,
  renderAdminEpisodeHubPage,
  renderAdminLanguagePage,
  renderBackofficeNotFoundPage,
  renderAdminProfilePage,
  renderAdminSeasonPage,
  renderAdminShortsPage,
  renderAdminTvShowPage,
  renderAdminTypePage,
  renderAdminVideoPage,
  renderLoginPage,
  renderProducerChangePasswordPage,
  renderProducerChannelPage,
  renderProducerDashboard,
  renderProducerProfilePage,
  renderProducerRentTransactionPage,
  renderProducerShortsEpisodePage,
  renderProducerShortsPage,
  renderProducerTvShowEpisodePage,
  renderProducerTvShowPage,
  renderProducerVideoPage,
  renderProducerWithdrawalPage,
} from './backoffice.views';

type SessionShape = {
  adminAuth?: { userId: number; userName: string };
  producerAuth?: { userId: number; userName: string };
};

type AdminPaginationState = {
  currentPage: number;
  totalPages: number;
  totalRows: number;
  pageSize: number;
  startRow: number;
  endRow: number;
};

function getSession(ctx: Context): SessionShape {
  return (ctx.session ?? {}) as SessionShape;
}

function parseBody(ctx: Context): Record<string, unknown> {
  const body = (ctx.request as typeof ctx.request & { body?: unknown }).body;
  if (!body || typeof body !== 'object') {
    return {};
  }

  return body as Record<string, unknown>;
}

function parsePage(value: unknown, fallback = 1): number {
  const parsed = Number(value);
  if (!Number.isFinite(parsed)) {
    return fallback;
  }
  return Math.max(1, Math.floor(parsed));
}

function paginateItems<T>(items: T[], requestedPage: number, pageSize: number): { pageItems: T[]; pagination: AdminPaginationState } {
  const safePageSize = Math.max(1, pageSize);
  const totalRows = items.length;
  const totalPages = Math.max(1, Math.ceil(totalRows / safePageSize));
  const currentPage = Math.min(Math.max(1, requestedPage), totalPages);
  const startIndex = (currentPage - 1) * safePageSize;
  const pageItems = items.slice(startIndex, startIndex + safePageSize);
  const startRow = totalRows === 0 ? 0 : startIndex + 1;
  const endRow = Math.min(totalRows, startIndex + pageItems.length);

  return {
    pageItems,
    pagination: {
      currentPage,
      totalPages,
      totalRows,
      pageSize: safePageSize,
      startRow,
      endRow,
    },
  };
}

function setSession(ctx: Context, sessionValue: SessionShape): void {
  (ctx as Context & { session?: SessionShape }).session = sessionValue;
}

function parseLoginForm(ctx: Context): { email: string; password: string } {
  const body = (ctx.request as typeof ctx.request & { body?: unknown }).body;
  if (!body || typeof body !== 'object') {
    return { email: '', password: '' };
  }

  const data = body as Record<string, unknown>;
  return {
    email: String(data.email ?? '').trim(),
    password: String(data.password ?? ''),
  };
}

function isCheckAdminBlocked(): boolean {
  return String(process.env.DEMO_MODE ?? '').toUpperCase() === 'ON';
}

function respondDemoBlocked(ctx: Context): void {
  ctx.status = 403;
  ctx.type = 'html';
  ctx.body = '<div style="padding:24px;font-family:Arial,sans-serif;"><h2>Access denied</h2><p>Access denied: can not add/edit/delete in demo mode.</p></div>';
}

function formatBackofficeErrorMessage(error: unknown, fallback: string): string {
  const raw = error instanceof Error ? error.message : '';
  if (!raw) {
    return fallback;
  }

  const exactMappings: Record<string, string> = {
    'ids are required': '请先提供有效的排序 ID 列表。',
    'id is invalid': '提交的记录标识无效，请刷新页面后重试。',
    'type is required': '请选择有效的类型。',
    'type_id is required': '请选择有效的类型。',
    'show_id is required': '请选择所属内容。',
    'season_id is required': '请选择有效的季。',
    'name is required': '名称不能为空。',
    'category_id is required': '请至少选择一个分类。',
    'language_id is required': '请至少选择一个语言。',
    'video_upload_type is required': '请选择视频上传类型。',
    'subtitle_type is required': '请选择字幕类型。',
    'video_320 is required': '请填写或上传主视频地址。',
    'video_url_320 is required': '请填写主视频地址。',
    'video_url_320 is required for live_stream_url': '直播流地址不能为空。',
    'video_url_320 is required for vdocipher_id': 'VdoCipher ID 不能为空。',
    'channel_id is required': '请选择频道。',
    'channel_id is required for channel content': '当前内容类型需要绑定频道，请先选择频道。',
    'price and rent_day are required when is_rent = 1': '开启租赁后，请同时填写价格和租赁天数。',
    'user_name is required': '用户名不能为空。',
    'user_name must be at least 4 characters': '用户名至少需要 4 个字符。',
    'full_name must be at least 2 characters': '姓名至少需要 2 个字符。',
    'email must be valid': '请输入有效的邮箱地址。',
    'mobile_number must be numeric': '手机号只能包含数字。',
    'user_name already exists': '用户名已存在，请更换后再试。',
    'email already exists': '邮箱已存在，请更换后再试。',
    'mobile_number already exists': '手机号已存在，请更换后再试。',
    'current/new/confirm password are required': '请完整填写当前密码、新密码和确认密码。',
    'new_password must be at least 4 characters': '新密码至少需要 4 个字符。',
    'confirm_password must match new_password': '确认密码与新密码不一致。',
    'please enter right current password': '当前密码不正确，请重新输入。',
    'admin not found': '当前管理员账号不存在，请重新登录。',
    'producer not found': '当前制作人账号不存在，请重新登录。',
    'type not found': '未找到可用的类型，请刷新后重试。',
    'video not found': '未找到对应视频，或你没有操作权限。',
    'tvshow not found': '未找到对应剧集内容，或你没有操作权限。',
    'shorts not found': '未找到对应短剧内容，或你没有操作权限。',
    'episode not found': '未找到对应分集，或你没有操作权限。',
    'channel not found': '未找到对应频道，请刷新后重试。',
    'avatar not found': '未找到对应头像记录，请刷新后重试。',
    'type not found for producer': '当前内容类型不可用，请重新选择。',
  };

  if (exactMappings[raw]) {
    return exactMappings[raw];
  }

  if (raw.includes('not found')) {
    return '未找到对应数据，或当前账号没有操作权限。';
  }
  if (raw.includes('already exists')) {
    return '提交的数据已存在，请检查后重试。';
  }
  if (raw.includes('is required')) {
    return '请完整填写必填信息后再提交。';
  }
  if (raw.includes('is invalid')) {
    return '提交的数据格式不正确，请刷新页面后重试。';
  }
  if (raw.includes('must be at least')) {
    return '提交的信息长度不足，请按页面要求填写。';
  }

  return fallback;
}

function getRouteErrorMessage(error: unknown, fallback: string): string {
  return formatBackofficeErrorMessage(error, fallback);
}

const backofficeRouter = new Router();
const service = new BackofficeService();

backofficeRouter.get('/admin/login', async (ctx: Context) => {
  const session = getSession(ctx);
  if (session.adminAuth) {
    ctx.redirect('/admin/dashboard');
    return;
  }

  ctx.type = 'html';
  ctx.body = renderLoginPage('admin');
});

backofficeRouter.post('/admin/login', async (ctx: Context) => {
  const { email, password } = parseLoginForm(ctx);
  if (!email || !password) {
    ctx.status = 400;
    ctx.type = 'html';
    ctx.body = renderLoginPage('admin', 'Email and password are required.');
    return;
  }

  const user = await service.loginAdmin(email, password);
  if (!user) {
    ctx.status = 400;
    ctx.type = 'html';
    ctx.body = renderLoginPage('admin', 'Invalid credentials.');
    return;
  }

  const session = getSession(ctx);
  setSession(ctx, { ...session, adminAuth: { userId: user.id, userName: user.userName } });
  ctx.redirect('/admin/dashboard');
});

backofficeRouter.get('/admin/logout', async (ctx: Context) => {
  const session = getSession(ctx);
  delete session.adminAuth;
  setSession(ctx, session);
  ctx.redirect('/admin/login');
});

backofficeRouter.get('/admin/dashboard', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }

  const stats = await service.getAdminDashboardStats();
  ctx.type = 'html';
  ctx.body = renderAdminDashboard(session.adminAuth.userName, stats);
});

backofficeRouter.get('/admin/video', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }

  const query = ctx.query as Record<string, string | undefined>;
  const requestedPage = parsePage(query.page, 1);
  const items = await service.getAdminVideos();
  const { pageItems, pagination } = paginateItems(items, requestedPage, env.pageLimit);
  const message = typeof query.message === 'string' ? query.message : '';
  ctx.type = 'html';
  ctx.body = renderAdminVideoPage(pageItems, pagination, message);
});

backofficeRouter.post('/admin/video/toggle', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    respondDemoBlocked(ctx);
    return;
  }

  const body = parseBody(ctx);
  const id = Number(body.id ?? 0);
  const requestedPage = parsePage(body.page, 1);

  try {
    await service.toggleAdminVideoStatus(id);
    ctx.status = 303;
    ctx.redirect(`/admin/video?page=${requestedPage}&message=${encodeURIComponent('Video status changed.')}`);
    return;
  } catch (error) {
    const message = getRouteErrorMessage(error, '操作失败，请稍后重试。');
    ctx.status = 400;
    const items = await service.getAdminVideos();
    const { pageItems, pagination } = paginateItems(items, requestedPage, env.pageLimit);
    ctx.type = 'html';
    ctx.body = renderAdminVideoPage(pageItems, pagination, message);
  }
});

backofficeRouter.get('/admin/tvshow', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }

  const query = ctx.query as Record<string, string | undefined>;
  const requestedPage = parsePage(query.page, 1);
  const items = await service.getAdminTvShows();
  const { pageItems, pagination } = paginateItems(items, requestedPage, env.pageLimit);
  const message = typeof query.message === 'string' ? query.message : '';
  ctx.type = 'html';
  ctx.body = renderAdminTvShowPage(pageItems, pagination, message);
});

backofficeRouter.post('/admin/tvshow/toggle', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    respondDemoBlocked(ctx);
    return;
  }

  const body = parseBody(ctx);
  const id = Number(body.id ?? 0);
  const requestedPage = parsePage(body.page, 1);

  try {
    await service.toggleAdminTvShowStatus(id);
    ctx.status = 303;
    ctx.redirect(`/admin/tvshow?page=${requestedPage}&message=${encodeURIComponent('TV show status changed.')}`);
    return;
  } catch (error) {
    const message = getRouteErrorMessage(error, '状态更新失败，请稍后重试。');
    ctx.status = 400;
    const items = await service.getAdminTvShows();
    const { pageItems, pagination } = paginateItems(items, requestedPage, env.pageLimit);
    ctx.type = 'html';
    ctx.body = renderAdminTvShowPage(pageItems, pagination, message);
  }
});

backofficeRouter.get('/admin/shorts', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }

  const query = ctx.query as Record<string, string | undefined>;
  const requestedPage = parsePage(query.page, 1);
  const items = await service.getAdminShorts();
  const { pageItems, pagination } = paginateItems(items, requestedPage, env.pageLimit);
  const message = typeof query.message === 'string' ? query.message : '';
  ctx.type = 'html';
  ctx.body = renderAdminShortsPage(pageItems, pagination, message);
});

backofficeRouter.post('/admin/shorts/toggle', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    respondDemoBlocked(ctx);
    return;
  }

  const body = parseBody(ctx);
  const id = Number(body.id ?? 0);
  const requestedPage = parsePage(body.page, 1);

  try {
    await service.toggleAdminShortsStatus(id);
    ctx.status = 303;
    ctx.redirect(`/admin/shorts?page=${requestedPage}&message=${encodeURIComponent('Shorts status changed.')}`);
    return;
  } catch (error) {
    const message = getRouteErrorMessage(error, '状态更新失败，请稍后重试。');
    ctx.status = 400;
    const items = await service.getAdminShorts();
    const { pageItems, pagination } = paginateItems(items, requestedPage, env.pageLimit);
    ctx.type = 'html';
    ctx.body = renderAdminShortsPage(pageItems, pagination, message);
  }
});

backofficeRouter.get('/admin/episode', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }

  ctx.type = 'html';
  ctx.body = renderAdminEpisodeHubPage();
});

backofficeRouter.get('/admin/episode/tvshow', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }

  ctx.type = 'html';
  ctx.body = renderAdminContentPlaceholderPage('Admin TV Show Episodes', 'Admin TV show episode management is the next migration step.');
});

backofficeRouter.get('/admin/episode/shorts', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }

  ctx.type = 'html';
  ctx.body = renderAdminContentPlaceholderPage('Admin Shorts Episodes', 'Admin shorts episode management is the next migration step.');
});

backofficeRouter.get('/admin/profile', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }

  const profile = await service.getAdminProfile(session.adminAuth.userId);
  if (!profile) {
    ctx.redirect('/admin/logout');
    return;
  }

  ctx.type = 'html';
  ctx.body = renderAdminProfilePage(profile);
});

backofficeRouter.post('/admin/profile', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }

  const body = parseBody(ctx);
  const userName = String(body.user_name ?? '');
  const email = String(body.email ?? '');

  const profile = await service.getAdminProfile(session.adminAuth.userId);
  if (!profile) {
    ctx.redirect('/admin/logout');
    return;
  }

  try {
    await service.updateAdminProfile(session.adminAuth.userId, userName, email);
    const nextProfile = await service.getAdminProfile(session.adminAuth.userId);
    ctx.type = 'html';
    ctx.body = renderAdminProfilePage(nextProfile ?? profile, 'Profile updated successfully.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '资料更新失败，请稍后重试。');
    ctx.status = 400;
    ctx.type = 'html';
    ctx.body = renderAdminProfilePage(profile, message);
  }
});

backofficeRouter.get('/admin/category', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }

  const categories = await service.getAdminCategories();
  ctx.type = 'html';
  ctx.body = renderAdminCategoryPage(categories);
});

backofficeRouter.get('/admin/type', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }

  const types = await service.getAdminTypes();
  ctx.type = 'html';
  ctx.body = renderAdminTypePage(types);
});

backofficeRouter.post('/admin/type', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    respondDemoBlocked(ctx);
    return;
  }

  const body = parseBody(ctx);
  const name = String(body.name ?? '');
  const type = Number(body.type ?? 0);
  const icon = String(body.icon ?? '');

  try {
    await service.createAdminType(name, type, icon);
    const types = await service.getAdminTypes();
    ctx.type = 'html';
    ctx.body = renderAdminTypePage(types, 'Type created successfully.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '类型创建失败，请稍后重试。');
    ctx.status = 400;
    const types = await service.getAdminTypes();
    ctx.type = 'html';
    ctx.body = renderAdminTypePage(types, message);
  }
});

backofficeRouter.post('/admin/type/update', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    respondDemoBlocked(ctx);
    return;
  }

  const body = parseBody(ctx);
  const id = Number(body.id ?? 0);
  const name = String(body.name ?? '');
  const type = Number(body.type ?? 0);
  const icon = String(body.icon ?? '');

  try {
    await service.updateAdminType(id, name, type, icon);
    const types = await service.getAdminTypes();
    ctx.type = 'html';
    ctx.body = renderAdminTypePage(types, 'Type updated successfully.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '类型更新失败，请稍后重试。');
    ctx.status = 400;
    const types = await service.getAdminTypes();
    ctx.type = 'html';
    ctx.body = renderAdminTypePage(types, message);
  }
});

backofficeRouter.post('/admin/type/toggle', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    respondDemoBlocked(ctx);
    return;
  }

  const body = parseBody(ctx);
  const id = Number(body.id ?? 0);

  try {
    await service.toggleAdminTypeStatus(id);
    const types = await service.getAdminTypes();
    ctx.type = 'html';
    ctx.body = renderAdminTypePage(types, 'Type status changed.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '状态更新失败，请稍后重试。');
    ctx.status = 400;
    const types = await service.getAdminTypes();
    ctx.type = 'html';
    ctx.body = renderAdminTypePage(types, message);
  }
});

backofficeRouter.post('/admin/type/sortable/save', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    respondDemoBlocked(ctx);
    return;
  }

  const body = parseBody(ctx);
  const ids = String(body.ids ?? '');

  try {
    await service.saveAdminTypeSortOrder(ids);
    const types = await service.getAdminTypes();
    ctx.type = 'html';
    ctx.body = renderAdminTypePage(types, 'Sort order saved.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '排序保存失败，请稍后重试。');
    ctx.status = 400;
    const types = await service.getAdminTypes();
    ctx.type = 'html';
    ctx.body = renderAdminTypePage(types, message);
  }
});

backofficeRouter.get('/admin/avatar', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }

  const avatars = await service.getAdminAvatars();
  ctx.type = 'html';
  ctx.body = renderAdminAvatarPage(avatars);
});

backofficeRouter.post('/admin/avatar', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    respondDemoBlocked(ctx);
    return;
  }

  const body = parseBody(ctx);
  const name = String(body.name ?? '');
  const image = String(body.image ?? '');

  try {
    await service.createAdminAvatar(name, image);
    const avatars = await service.getAdminAvatars();
    ctx.type = 'html';
    ctx.body = renderAdminAvatarPage(avatars, 'Avatar created successfully.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '头像创建失败，请稍后重试。');
    ctx.status = 400;
    const avatars = await service.getAdminAvatars();
    ctx.type = 'html';
    ctx.body = renderAdminAvatarPage(avatars, message);
  }
});

backofficeRouter.post('/admin/avatar/update', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    respondDemoBlocked(ctx);
    return;
  }

  const body = parseBody(ctx);
  const id = Number(body.id ?? 0);
  const name = String(body.name ?? '');
  const image = String(body.image ?? '');

  try {
    await service.updateAdminAvatar(id, name, image);
    const avatars = await service.getAdminAvatars();
    ctx.type = 'html';
    ctx.body = renderAdminAvatarPage(avatars, 'Avatar updated successfully.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '头像更新失败，请稍后重试。');
    ctx.status = 400;
    const avatars = await service.getAdminAvatars();
    ctx.type = 'html';
    ctx.body = renderAdminAvatarPage(avatars, message);
  }
});

backofficeRouter.post('/admin/avatar/toggle', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    respondDemoBlocked(ctx);
    return;
  }

  const body = parseBody(ctx);
  const id = Number(body.id ?? 0);

  try {
    await service.toggleAdminAvatarStatus(id);
    const avatars = await service.getAdminAvatars();
    ctx.type = 'html';
    ctx.body = renderAdminAvatarPage(avatars, 'Avatar status changed.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '状态更新失败，请稍后重试。');
    ctx.status = 400;
    const avatars = await service.getAdminAvatars();
    ctx.type = 'html';
    ctx.body = renderAdminAvatarPage(avatars, message);
  }
});

backofficeRouter.post('/admin/avatar/sortable/save', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    respondDemoBlocked(ctx);
    return;
  }

  const body = parseBody(ctx);
  const ids = String(body.ids ?? '');

  try {
    await service.saveAdminAvatarSortOrder(ids);
    const avatars = await service.getAdminAvatars();
    ctx.type = 'html';
    ctx.body = renderAdminAvatarPage(avatars, 'Sort order saved.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '排序保存失败，请稍后重试。');
    ctx.status = 400;
    const avatars = await service.getAdminAvatars();
    ctx.type = 'html';
    ctx.body = renderAdminAvatarPage(avatars, message);
  }
});

backofficeRouter.get('/admin/channel', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }

  const channels = await service.getAdminChannels();
  ctx.type = 'html';
  ctx.body = renderAdminChannelPage(channels);
});

backofficeRouter.post('/admin/channel', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    respondDemoBlocked(ctx);
    return;
  }

  const body = parseBody(ctx);
  const name = String(body.name ?? '');
  const portraitImg = String(body.portrait_img ?? '');
  const landscapeImg = String(body.landscape_img ?? '');
  const isTitle = Number(body.is_title ?? 0);

  try {
    await service.createAdminChannel(name, portraitImg, landscapeImg, isTitle);
    const channels = await service.getAdminChannels();
    ctx.type = 'html';
    ctx.body = renderAdminChannelPage(channels, 'Channel created successfully.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '频道创建失败，请稍后重试。');
    ctx.status = 400;
    const channels = await service.getAdminChannels();
    ctx.type = 'html';
    ctx.body = renderAdminChannelPage(channels, message);
  }
});

backofficeRouter.post('/admin/channel/update', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    respondDemoBlocked(ctx);
    return;
  }

  const body = parseBody(ctx);
  const id = Number(body.id ?? 0);
  const name = String(body.name ?? '');
  const portraitImg = String(body.portrait_img ?? '');
  const landscapeImg = String(body.landscape_img ?? '');
  const isTitle = Number(body.is_title ?? 0);

  try {
    await service.updateAdminChannel(id, name, portraitImg, landscapeImg, isTitle);
    const channels = await service.getAdminChannels();
    ctx.type = 'html';
    ctx.body = renderAdminChannelPage(channels, 'Channel updated successfully.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '频道更新失败，请稍后重试。');
    ctx.status = 400;
    const channels = await service.getAdminChannels();
    ctx.type = 'html';
    ctx.body = renderAdminChannelPage(channels, message);
  }
});

backofficeRouter.post('/admin/channel/toggle', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    respondDemoBlocked(ctx);
    return;
  }

  const body = parseBody(ctx);
  const id = Number(body.id ?? 0);

  try {
    await service.toggleAdminChannelStatus(id);
    const channels = await service.getAdminChannels();
    ctx.type = 'html';
    ctx.body = renderAdminChannelPage(channels, 'Channel status changed.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '状态更新失败，请稍后重试。');
    ctx.status = 400;
    const channels = await service.getAdminChannels();
    ctx.type = 'html';
    ctx.body = renderAdminChannelPage(channels, message);
  }
});

backofficeRouter.post('/admin/category', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    respondDemoBlocked(ctx);
    return;
  }

  const body = parseBody(ctx);
  const name = String(body.name ?? '');
  const image = String(body.image ?? '');

  try {
    await service.createAdminCategory(name, image);
    const categories = await service.getAdminCategories();
    ctx.type = 'html';
    ctx.body = renderAdminCategoryPage(categories, 'Category created successfully.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '分类创建失败，请稍后重试。');
    ctx.status = 400;
    const categories = await service.getAdminCategories();
    ctx.type = 'html';
    ctx.body = renderAdminCategoryPage(categories, message);
  }
});

backofficeRouter.post('/admin/category/sortable/save', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    respondDemoBlocked(ctx);
    return;
  }

  const body = parseBody(ctx);
  const ids = String(body.ids ?? '');

  try {
    await service.saveAdminCategorySortOrder(ids);
    const categories = await service.getAdminCategories();
    ctx.type = 'html';
    ctx.body = renderAdminCategoryPage(categories, 'Sort order saved.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '排序保存失败，请稍后重试。');
    ctx.status = 400;
    const categories = await service.getAdminCategories();
    ctx.type = 'html';
    ctx.body = renderAdminCategoryPage(categories, message);
  }
});

backofficeRouter.post('/admin/category/update', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    respondDemoBlocked(ctx);
    return;
  }

  const body = parseBody(ctx);
  const id = Number(body.id ?? 0);
  const name = String(body.name ?? '');
  const image = String(body.image ?? '');

  try {
    await service.updateAdminCategory(id, name, image);
    const categories = await service.getAdminCategories();
    ctx.type = 'html';
    ctx.body = renderAdminCategoryPage(categories, 'Category updated successfully.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '分类更新失败，请稍后重试。');
    ctx.status = 400;
    const categories = await service.getAdminCategories();
    ctx.type = 'html';
    ctx.body = renderAdminCategoryPage(categories, message);
  }
});

backofficeRouter.post('/admin/category/toggle', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    respondDemoBlocked(ctx);
    return;
  }

  const body = parseBody(ctx);
  const id = Number(body.id ?? 0);

  try {
    await service.toggleAdminCategoryStatus(id);
    const categories = await service.getAdminCategories();
    ctx.type = 'html';
    ctx.body = renderAdminCategoryPage(categories, 'Category status changed.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '状态更新失败，请稍后重试。');
    ctx.status = 400;
    const categories = await service.getAdminCategories();
    ctx.type = 'html';
    ctx.body = renderAdminCategoryPage(categories, message);
  }
});

backofficeRouter.get('/admin/language', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }

  const languages = await service.getAdminLanguages();
  ctx.type = 'html';
  ctx.body = renderAdminLanguagePage(languages);
});

backofficeRouter.post('/admin/language', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    respondDemoBlocked(ctx);
    return;
  }

  const body = parseBody(ctx);
  const name = String(body.name ?? '');
  const image = String(body.image ?? '');

  try {
    await service.createAdminLanguage(name, image);
    const languages = await service.getAdminLanguages();
    ctx.type = 'html';
    ctx.body = renderAdminLanguagePage(languages, 'Language created successfully.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '语言创建失败，请稍后重试。');
    ctx.status = 400;
    const languages = await service.getAdminLanguages();
    ctx.type = 'html';
    ctx.body = renderAdminLanguagePage(languages, message);
  }
});

backofficeRouter.get('/admin/season', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }

  const seasons = await service.getAdminSeasons();
  ctx.type = 'html';
  ctx.body = renderAdminSeasonPage(seasons);
});

backofficeRouter.post('/admin/season', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    respondDemoBlocked(ctx);
    return;
  }

  const body = parseBody(ctx);
  const name = String(body.name ?? '');

  try {
    await service.createAdminSeason(name);
    const seasons = await service.getAdminSeasons();
    ctx.type = 'html';
    ctx.body = renderAdminSeasonPage(seasons, 'Season created successfully.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '季信息创建失败，请稍后重试。');
    ctx.status = 400;
    const seasons = await service.getAdminSeasons();
    ctx.type = 'html';
    ctx.body = renderAdminSeasonPage(seasons, message);
  }
});

backofficeRouter.post('/admin/season/update', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    respondDemoBlocked(ctx);
    return;
  }

  const body = parseBody(ctx);
  const id = Number(body.id ?? 0);
  const name = String(body.name ?? '');

  try {
    await service.updateAdminSeason(id, name);
    const seasons = await service.getAdminSeasons();
    ctx.type = 'html';
    ctx.body = renderAdminSeasonPage(seasons, 'Season updated successfully.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '季信息更新失败，请稍后重试。');
    ctx.status = 400;
    const seasons = await service.getAdminSeasons();
    ctx.type = 'html';
    ctx.body = renderAdminSeasonPage(seasons, message);
  }
});

backofficeRouter.post('/admin/season/sortable/save', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    respondDemoBlocked(ctx);
    return;
  }

  const body = parseBody(ctx);
  const ids = String(body.ids ?? '');

  try {
    await service.saveAdminSeasonSortOrder(ids);
    const seasons = await service.getAdminSeasons();
    ctx.type = 'html';
    ctx.body = renderAdminSeasonPage(seasons, 'Sort order saved.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '排序保存失败，请稍后重试。');
    ctx.status = 400;
    const seasons = await service.getAdminSeasons();
    ctx.type = 'html';
    ctx.body = renderAdminSeasonPage(seasons, message);
  }
});

backofficeRouter.post('/admin/language/sortable/save', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    respondDemoBlocked(ctx);
    return;
  }

  const body = parseBody(ctx);
  const ids = String(body.ids ?? '');

  try {
    await service.saveAdminLanguageSortOrder(ids);
    const languages = await service.getAdminLanguages();
    ctx.type = 'html';
    ctx.body = renderAdminLanguagePage(languages, 'Sort order saved.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '排序保存失败，请稍后重试。');
    ctx.status = 400;
    const languages = await service.getAdminLanguages();
    ctx.type = 'html';
    ctx.body = renderAdminLanguagePage(languages, message);
  }
});

backofficeRouter.post('/admin/language/update', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    respondDemoBlocked(ctx);
    return;
  }

  const body = parseBody(ctx);
  const id = Number(body.id ?? 0);
  const name = String(body.name ?? '');
  const image = String(body.image ?? '');

  try {
    await service.updateAdminLanguage(id, name, image);
    const languages = await service.getAdminLanguages();
    ctx.type = 'html';
    ctx.body = renderAdminLanguagePage(languages, 'Language updated successfully.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '语言更新失败，请稍后重试。');
    ctx.status = 400;
    const languages = await service.getAdminLanguages();
    ctx.type = 'html';
    ctx.body = renderAdminLanguagePage(languages, message);
  }
});

backofficeRouter.post('/admin/language/toggle', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    respondDemoBlocked(ctx);
    return;
  }

  const body = parseBody(ctx);
  const id = Number(body.id ?? 0);

  try {
    await service.toggleAdminLanguageStatus(id);
    const languages = await service.getAdminLanguages();
    ctx.type = 'html';
    ctx.body = renderAdminLanguagePage(languages, 'Language status changed.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '状态更新失败，请稍后重试。');
    ctx.status = 400;
    const languages = await service.getAdminLanguages();
    ctx.type = 'html';
    ctx.body = renderAdminLanguagePage(languages, message);
  }
});

backofficeRouter.post('/admin/profile/changepassword', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    respondDemoBlocked(ctx);
    return;
  }

  const body = parseBody(ctx);
  const currentPassword = String(body.current_password ?? '');
  const newPassword = String(body.new_password ?? '');
  const confirmPassword = String(body.confirm_password ?? '');

  const profile = await service.getAdminProfile(session.adminAuth.userId);
  if (!profile) {
    ctx.redirect('/admin/logout');
    return;
  }

  try {
    await service.changeAdminPassword(session.adminAuth.userId, currentPassword, newPassword, confirmPassword);
    ctx.type = 'html';
    ctx.body = renderAdminProfilePage(profile, '', 'Password changed successfully.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '密码修改失败，请稍后重试。');
    ctx.status = 400;
    ctx.type = 'html';
    ctx.body = renderAdminProfilePage(profile, '', message);
  }
});

backofficeRouter.get('/producer/login', async (ctx: Context) => {
  const session = getSession(ctx);
  if (session.producerAuth) {
    ctx.redirect('/producer/dashboard');
    return;
  }

  ctx.type = 'html';
  ctx.body = renderLoginPage('producer');
});

backofficeRouter.post('/producer/login', async (ctx: Context) => {
  const { email, password } = parseLoginForm(ctx);
  if (!email || !password) {
    ctx.status = 400;
    ctx.type = 'html';
    ctx.body = renderLoginPage('producer', 'Email and password are required.');
    return;
  }

  const user = await service.loginProducer(email, password);
  if (!user) {
    ctx.status = 400;
    ctx.type = 'html';
    ctx.body = renderLoginPage('producer', 'Invalid credentials.');
    return;
  }

  const session = getSession(ctx);
  setSession(ctx, { ...session, producerAuth: { userId: user.id, userName: user.userName } });
  ctx.redirect('/producer/dashboard');
});

backofficeRouter.get('/producer/logout', async (ctx: Context) => {
  const session = getSession(ctx);
  delete session.producerAuth;
  setSession(ctx, session);
  ctx.redirect('/producer/login');
});

backofficeRouter.get('/producer/dashboard', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  const stats = await service.getProducerDashboardStats(session.producerAuth.userId);
  ctx.type = 'html';
  ctx.body = renderProducerDashboard(session.producerAuth.userName, stats);
});

backofficeRouter.get('/producer/profile', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  const profile = await service.getProducerProfile(session.producerAuth.userId);
  if (!profile) {
    ctx.redirect('/producer/logout');
    return;
  }

  ctx.type = 'html';
  ctx.body = renderProducerProfilePage(profile);
});

backofficeRouter.post('/producer/profile', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  const body = parseBody(ctx);
  const userName = String(body.user_name ?? '');
  const fullName = String(body.full_name ?? '');
  const email = String(body.email ?? '');
  const mobileNumber = String(body.mobile_number ?? '');

  const profile = await service.getProducerProfile(session.producerAuth.userId);
  if (!profile) {
    ctx.redirect('/producer/logout');
    return;
  }

  try {
    await service.updateProducerProfile(session.producerAuth.userId, userName, fullName, email, mobileNumber);
    const nextProfile = await service.getProducerProfile(session.producerAuth.userId);
    ctx.type = 'html';
    ctx.body = renderProducerProfilePage(nextProfile ?? profile, 'Profile updated successfully.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '资料更新失败，请稍后重试。');
    ctx.status = 400;
    ctx.type = 'html';
    ctx.body = renderProducerProfilePage(profile, message);
  }
});

backofficeRouter.get('/producer/change-password', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  ctx.type = 'html';
  ctx.body = renderProducerChangePasswordPage(session.producerAuth.userId);
});

backofficeRouter.get('/producer/channel', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  const query = ctx.query as Record<string, string | undefined>;
  const inputSearch = String(query.input_search ?? '');
  const payload = await service.getProducerChannelsViewPayload(inputSearch);

  ctx.type = 'html';
  ctx.body = renderProducerChannelPage(payload);
});

backofficeRouter.get('/producer/video/:typeId', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  const typeId = Number(ctx.params.typeId ?? 0);
  const query = ctx.query as Record<string, string | undefined>;
  const payload = await service.getProducerVideosViewPayload(session.producerAuth.userId, typeId, {
    input_search: String(query.input_search ?? ''),
    input_rent: String(query.input_rent ?? '0'),
    input_premium: String(query.input_premium ?? 'all'),
    input_status: String(query.input_status ?? 'all'),
    page: String(query.page ?? '1'),
  });

  ctx.type = 'html';
  ctx.body = renderProducerVideoPage(payload);
});

backofficeRouter.post('/producer/video/save', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    const typeId = Number(parseBody(ctx).type_id ?? 0);
    const payload = await service.getProducerVideosViewPayload(session.producerAuth.userId, typeId, {
      input_search: '',
      input_rent: '0',
      input_premium: 'all',
      input_status: 'all',
    });
    ctx.status = 403;
    ctx.type = 'html';
    ctx.body = renderProducerVideoPage(payload, 'Access denied: can not add/edit/delete in demo mode.');
    return;
  }

  const body = parseBody(ctx);
  const typeId = Number(body.type_id ?? 0);
  try {
    await service.createProducerVideo(session.producerAuth.userId, body, typeId);
    const payload = await service.getProducerVideosViewPayload(session.producerAuth.userId, typeId, {
      input_search: '',
      input_rent: '0',
      input_premium: 'all',
      input_status: 'all',
    });
    ctx.type = 'html';
    ctx.body = renderProducerVideoPage(payload, 'Video added successfully.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '视频创建失败，请检查后重试。');
    ctx.status = 400;
    const payload = await service.getProducerVideosViewPayload(session.producerAuth.userId, typeId, {
      input_search: '',
      input_rent: '0',
      input_premium: 'all',
      input_status: 'all',
    });
    ctx.type = 'html';
    ctx.body = renderProducerVideoPage(payload, message);
  }
});

backofficeRouter.post('/producer/video/update/:videoId', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    const body = parseBody(ctx);
    const typeId = Number(body.type_id ?? 0);
    const payload = await service.getProducerVideosViewPayload(session.producerAuth.userId, typeId, {
      input_search: '',
      input_rent: '0',
      input_premium: 'all',
      input_status: 'all',
    });
    ctx.status = 403;
    ctx.type = 'html';
    ctx.body = renderProducerVideoPage(payload, 'Access denied: can not add/edit/delete in demo mode.');
    return;
  }

  const videoId = Number(ctx.params.videoId ?? 0);
  const body = parseBody(ctx);
  const typeId = Number(body.type_id ?? 0);

  try {
    await service.updateProducerVideo(session.producerAuth.userId, videoId, body, typeId);
    const payload = await service.getProducerVideosViewPayload(session.producerAuth.userId, typeId, {
      input_search: '',
      input_rent: '0',
      input_premium: 'all',
      input_status: 'all',
    });
    ctx.type = 'html';
    ctx.body = renderProducerVideoPage(payload, 'Video updated successfully.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '视频更新失败，请检查后重试。');
    ctx.status = 400;
    const payload = await service.getProducerVideosViewPayload(session.producerAuth.userId, typeId, {
      input_search: '',
      input_rent: '0',
      input_premium: 'all',
      input_status: 'all',
    });
    ctx.type = 'html';
    ctx.body = renderProducerVideoPage(payload, message);
  }
});

backofficeRouter.post('/producer/video/delete/:videoId/:typeId', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  const videoId = Number(ctx.params.videoId ?? 0);
  const typeId = Number(ctx.params.typeId ?? 0);

   if (isCheckAdminBlocked()) {
    ctx.status = 403;
    const payload = await service.getProducerVideosViewPayload(session.producerAuth.userId, typeId, {
      input_search: '',
      input_rent: '0',
      input_premium: 'all',
      input_status: 'all',
    });
    ctx.type = 'html';
    ctx.body = renderProducerVideoPage(payload, 'Access denied: can not add/edit/delete in demo mode.');
    return;
  }

  try {
    await service.deleteProducerVideo(session.producerAuth.userId, videoId);
    const payload = await service.getProducerVideosViewPayload(session.producerAuth.userId, typeId, {
      input_search: '',
      input_rent: '0',
      input_premium: 'all',
      input_status: 'all',
    });
    ctx.type = 'html';
    ctx.body = renderProducerVideoPage(payload, 'Content deleted.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '视频删除失败，请稍后重试。');
    ctx.status = 400;
    const payload = await service.getProducerVideosViewPayload(session.producerAuth.userId, typeId, {
      input_search: '',
      input_rent: '0',
      input_premium: 'all',
      input_status: 'all',
    });
    ctx.type = 'html';
    ctx.body = renderProducerVideoPage(payload, message);
  }
});

backofficeRouter.post('/producer/video-status', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    const body = parseBody(ctx);
    const typeId = Number(body.type_id ?? 0);
    const payload = await service.getProducerVideosViewPayload(session.producerAuth.userId, typeId, {
      input_search: '',
      input_rent: '0',
      input_premium: 'all',
      input_status: 'all',
    });
    ctx.status = 403;
    ctx.type = 'html';
    ctx.body = renderProducerVideoPage(payload, 'Access denied: can not add/edit/delete in demo mode.');
    return;
  }

  const body = parseBody(ctx);
  const id = Number(body.id ?? 0);
  const typeId = Number(body.type_id ?? 0);

  try {
    await service.toggleProducerVideoStatus(session.producerAuth.userId, id);
    const payload = await service.getProducerVideosViewPayload(session.producerAuth.userId, typeId, {
      input_search: '',
      input_rent: '0',
      input_premium: 'all',
      input_status: 'all',
    });
    ctx.type = 'html';
    ctx.body = renderProducerVideoPage(payload, 'Status changed.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '状态更新失败，请稍后重试。');
    ctx.status = 400;
    const payload = await service.getProducerVideosViewPayload(session.producerAuth.userId, typeId, {
      input_search: '',
      input_rent: '0',
      input_premium: 'all',
      input_status: 'all',
    });
    ctx.type = 'html';
    ctx.body = renderProducerVideoPage(payload, message);
  }
});

backofficeRouter.post('/producer/video/releases', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    const body = parseBody(ctx);
    const typeId = Number(body.type_id ?? 0);
    const payload = await service.getProducerVideosViewPayload(session.producerAuth.userId, typeId, {
      input_search: '',
      input_rent: '0',
      input_premium: 'all',
      input_status: 'all',
    });
    ctx.status = 403;
    ctx.type = 'html';
    ctx.body = renderProducerVideoPage(payload, 'Access denied: can not add/edit/delete in demo mode.');
    return;
  }

  const body = parseBody(ctx);
  const id = Number(body.id ?? 0);
  const typeId = Number(body.type_id ?? 0);
  const channelId = Number(body.channel_id ?? 0);

  try {
    await service.releaseProducerVideo(session.producerAuth.userId, id, typeId, channelId);
    const payload = await service.getProducerVideosViewPayload(session.producerAuth.userId, typeId, {
      input_search: '',
      input_rent: '0',
      input_premium: 'all',
      input_status: 'all',
    });
    ctx.type = 'html';
    ctx.body = renderProducerVideoPage(payload, 'Video released.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '视频发布失败，请检查发布信息后重试。');
    ctx.status = 400;
    const fallbackTypeId = Number(body.current_type_id ?? typeId ?? 0);
    const payload = await service.getProducerVideosViewPayload(session.producerAuth.userId, fallbackTypeId, {
      input_search: '',
      input_rent: '0',
      input_premium: 'all',
      input_status: 'all',
    });
    ctx.type = 'html';
    ctx.body = renderProducerVideoPage(payload, message);
  }
});

backofficeRouter.post('/producer/video/serachname/:txtVal', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.status = 401;
    ctx.body = { status: 401, errors: 'unauthorized' };
    return;
  }

  const txtVal = String(ctx.params.txtVal ?? '');
  const data = await service.searchProducerVideoNames(session.producerAuth.userId, txtVal);
  ctx.body = { status: 200, data };
});

backofficeRouter.post('/producer/video/getdata/:id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.status = 401;
    ctx.body = { status: 401, errors: 'unauthorized' };
    return;
  }

  const id = Number(ctx.params.id ?? 0);
  try {
    const data = await service.getProducerVideoDataForFill(session.producerAuth.userId, id);
    ctx.body = { status: 200, data };
  } catch (error) {
    const message = getRouteErrorMessage(error, '读取内容失败，请稍后重试。');
    ctx.status = 400;
    ctx.body = { status: 400, errors: message };
  }
});

backofficeRouter.get('/producer/tvshow/:typeId', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  const typeId = Number(ctx.params.typeId ?? 0);
  const query = ctx.query as Record<string, string | undefined>;
  const payload = await service.getProducerTvShowsViewPayload(session.producerAuth.userId, typeId, {
    input_search: String(query.input_search ?? ''),
    input_rent: String(query.input_rent ?? '0'),
    input_status: String(query.input_status ?? 'all'),
    page: String(query.page ?? '1'),
  });

  ctx.type = 'html';
  ctx.body = renderProducerTvShowPage(payload);
});

backofficeRouter.post('/producer/tvshow/save', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    const typeId = Number(parseBody(ctx).type_id ?? 0);
    const payload = await service.getProducerTvShowsViewPayload(session.producerAuth.userId, typeId, {
      input_search: '',
      input_rent: '0',
      input_status: 'all',
    });
    ctx.status = 403;
    ctx.type = 'html';
    ctx.body = renderProducerTvShowPage(payload, 'Access denied: can not add/edit/delete in demo mode.');
    return;
  }

  const body = parseBody(ctx);
  const typeId = Number(body.type_id ?? 0);
  try {
    await service.createProducerTvShow(session.producerAuth.userId, body, typeId);
    const payload = await service.getProducerTvShowsViewPayload(session.producerAuth.userId, typeId, {
      input_search: '',
      input_rent: '0',
      input_status: 'all',
    });
    ctx.type = 'html';
    ctx.body = renderProducerTvShowPage(payload, 'TV Show added successfully.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '剧集内容创建失败，请检查后重试。');
    ctx.status = 400;
    const payload = await service.getProducerTvShowsViewPayload(session.producerAuth.userId, typeId, {
      input_search: '',
      input_rent: '0',
      input_status: 'all',
    });
    ctx.type = 'html';
    ctx.body = renderProducerTvShowPage(payload, message);
  }
});

backofficeRouter.post('/producer/tvshow/update/:tvShowId', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    const body = parseBody(ctx);
    const typeId = Number(body.type_id ?? 0);
    const payload = await service.getProducerTvShowsViewPayload(session.producerAuth.userId, typeId, {
      input_search: '',
      input_rent: '0',
      input_status: 'all',
    });
    ctx.status = 403;
    ctx.type = 'html';
    ctx.body = renderProducerTvShowPage(payload, 'Access denied: can not add/edit/delete in demo mode.');
    return;
  }

  const tvShowId = Number(ctx.params.tvShowId ?? 0);
  const body = parseBody(ctx);
  const typeId = Number(body.type_id ?? 0);

  try {
    await service.updateProducerTvShow(session.producerAuth.userId, tvShowId, body, typeId);
    const payload = await service.getProducerTvShowsViewPayload(session.producerAuth.userId, typeId, {
      input_search: '',
      input_rent: '0',
      input_status: 'all',
    });
    ctx.type = 'html';
    ctx.body = renderProducerTvShowPage(payload, 'TV Show updated successfully.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '剧集内容更新失败，请检查后重试。');
    ctx.status = 400;
    const payload = await service.getProducerTvShowsViewPayload(session.producerAuth.userId, typeId, {
      input_search: '',
      input_rent: '0',
      input_status: 'all',
    });
    ctx.type = 'html';
    ctx.body = renderProducerTvShowPage(payload, message);
  }
});

backofficeRouter.post('/producer/tvshow/delete/:tvShowId/:typeId', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  const tvShowId = Number(ctx.params.tvShowId ?? 0);
  const typeId = Number(ctx.params.typeId ?? 0);

  if (isCheckAdminBlocked()) {
    ctx.status = 403;
    const payload = await service.getProducerTvShowsViewPayload(session.producerAuth.userId, typeId, {
      input_search: '',
      input_rent: '0',
      input_status: 'all',
    });
    ctx.type = 'html';
    ctx.body = renderProducerTvShowPage(payload, 'Access denied: can not add/edit/delete in demo mode.');
    return;
  }

  try {
    await service.deleteProducerTvShow(session.producerAuth.userId, tvShowId);
    const payload = await service.getProducerTvShowsViewPayload(session.producerAuth.userId, typeId, {
      input_search: '',
      input_rent: '0',
      input_status: 'all',
    });
    ctx.type = 'html';
    ctx.body = renderProducerTvShowPage(payload, 'Content deleted.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '剧集内容删除失败，请稍后重试。');
    ctx.status = 400;
    const payload = await service.getProducerTvShowsViewPayload(session.producerAuth.userId, typeId, {
      input_search: '',
      input_rent: '0',
      input_status: 'all',
    });
    ctx.type = 'html';
    ctx.body = renderProducerTvShowPage(payload, message);
  }
});

backofficeRouter.post('/producer/tvshow-status', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    const body = parseBody(ctx);
    const typeId = Number(body.type_id ?? 0);
    const payload = await service.getProducerTvShowsViewPayload(session.producerAuth.userId, typeId, {
      input_search: '',
      input_rent: '0',
      input_status: 'all',
    });
    ctx.status = 403;
    ctx.type = 'html';
    ctx.body = renderProducerTvShowPage(payload, 'Access denied: can not add/edit/delete in demo mode.');
    return;
  }

  const body = parseBody(ctx);
  const id = Number(body.id ?? 0);
  const typeId = Number(body.type_id ?? 0);

  try {
    await service.toggleProducerTvShowStatus(session.producerAuth.userId, id);
    const payload = await service.getProducerTvShowsViewPayload(session.producerAuth.userId, typeId, {
      input_search: '',
      input_rent: '0',
      input_status: 'all',
    });
    ctx.type = 'html';
    ctx.body = renderProducerTvShowPage(payload, 'Status changed.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '状态更新失败，请稍后重试。');
    ctx.status = 400;
    const payload = await service.getProducerTvShowsViewPayload(session.producerAuth.userId, typeId, {
      input_search: '',
      input_rent: '0',
      input_status: 'all',
    });
    ctx.type = 'html';
    ctx.body = renderProducerTvShowPage(payload, message);
  }
});

backofficeRouter.post('/producer/tvshow/releases', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    const body = parseBody(ctx);
    const typeId = Number(body.type_id ?? 0);
    const payload = await service.getProducerTvShowsViewPayload(session.producerAuth.userId, typeId, {
      input_search: '',
      input_rent: '0',
      input_status: 'all',
    });
    ctx.status = 403;
    ctx.type = 'html';
    ctx.body = renderProducerTvShowPage(payload, 'Access denied: can not add/edit/delete in demo mode.');
    return;
  }

  const body = parseBody(ctx);
  const id = Number(body.id ?? 0);
  const typeId = Number(body.type_id ?? 0);
  const channelId = Number(body.channel_id ?? 0);

  try {
    await service.releaseProducerTvShow(session.producerAuth.userId, id, typeId, channelId);
    const payload = await service.getProducerTvShowsViewPayload(session.producerAuth.userId, typeId, {
      input_search: '',
      input_rent: '0',
      input_status: 'all',
    });
    ctx.type = 'html';
    ctx.body = renderProducerTvShowPage(payload, 'TV Show released.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '剧集内容发布失败，请检查发布信息后重试。');
    ctx.status = 400;
    const fallbackTypeId = Number(body.current_type_id ?? typeId ?? 0);
    const payload = await service.getProducerTvShowsViewPayload(session.producerAuth.userId, fallbackTypeId, {
      input_search: '',
      input_rent: '0',
      input_status: 'all',
    });
    ctx.type = 'html';
    ctx.body = renderProducerTvShowPage(payload, message);
  }
});

backofficeRouter.post('/producer/tvshow/serachname/:txtVal', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.status = 401;
    ctx.body = { status: 401, errors: 'unauthorized' };
    return;
  }

  const txtVal = String(ctx.params.txtVal ?? '');
  const data = await service.searchProducerTvShowNames(session.producerAuth.userId, txtVal);
  ctx.body = { status: 200, data };
});

backofficeRouter.post('/producer/tvshow/getdata/:id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.status = 401;
    ctx.body = { status: 401, errors: 'unauthorized' };
    return;
  }

  const id = Number(ctx.params.id ?? 0);
  try {
    const data = await service.getProducerTvShowDataForFill(session.producerAuth.userId, id);
    ctx.body = { status: 200, data };
  } catch (error) {
    const message = getRouteErrorMessage(error, '读取内容失败，请稍后重试。');
    ctx.status = 400;
    ctx.body = { status: 400, errors: message };
  }
});

backofficeRouter.get('/producer/tvshow-episode/:showId/:typeId', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  const showId = Number(ctx.params.showId ?? 0);
  const typeId = Number(ctx.params.typeId ?? 0);
  const query = ctx.query as Record<string, string | undefined>;

  const payload = await service.getProducerTvShowEpisodesViewPayload(session.producerAuth.userId, showId, typeId, {
    input_search: String(query.input_search ?? ''),
    input_season: String(query.input_season ?? '0'),
  });
  ctx.type = 'html';
  ctx.body = renderProducerTvShowEpisodePage(payload);
});

backofficeRouter.post('/producer/tvshow-episode/save', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    const body = parseBody(ctx);
    const showId = Number(body.show_id ?? 0);
    const typeId = Number(body.type_id ?? 0);
    const payload = await service.getProducerTvShowEpisodesViewPayload(session.producerAuth.userId, showId, typeId, {
      input_search: '',
      input_season: '0',
    });
    ctx.status = 403;
    ctx.type = 'html';
    ctx.body = renderProducerTvShowEpisodePage(payload, 'Access denied: can not add/edit/delete in demo mode.');
    return;
  }

  const body = parseBody(ctx);
  const showId = Number(body.show_id ?? 0);
  const typeId = Number(body.type_id ?? 0);
  try {
    await service.createProducerTvShowEpisode(session.producerAuth.userId, body, showId);
    const payload = await service.getProducerTvShowEpisodesViewPayload(session.producerAuth.userId, showId, typeId, {
      input_search: '',
      input_season: '0',
    });
    ctx.type = 'html';
    ctx.body = renderProducerTvShowEpisodePage(payload, 'Episode added successfully.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '分集创建失败，请检查后重试。');
    ctx.status = 400;
    const payload = await service.getProducerTvShowEpisodesViewPayload(session.producerAuth.userId, showId, typeId, {
      input_search: '',
      input_season: '0',
    });
    ctx.type = 'html';
    ctx.body = renderProducerTvShowEpisodePage(payload, message);
  }
});

backofficeRouter.post('/producer/tvshow-episode/update/:episodeId', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    const body = parseBody(ctx);
    const showId = Number(body.show_id ?? 0);
    const typeId = Number(body.type_id ?? 0);
    const payload = await service.getProducerTvShowEpisodesViewPayload(session.producerAuth.userId, showId, typeId, {
      input_search: '',
      input_season: '0',
    });
    ctx.status = 403;
    ctx.type = 'html';
    ctx.body = renderProducerTvShowEpisodePage(payload, 'Access denied: can not add/edit/delete in demo mode.');
    return;
  }

  const episodeId = Number(ctx.params.episodeId ?? 0);
  const body = parseBody(ctx);
  const showId = Number(body.show_id ?? 0);
  const typeId = Number(body.type_id ?? 0);

  try {
    await service.updateProducerTvShowEpisode(session.producerAuth.userId, episodeId, body, showId);
    const payload = await service.getProducerTvShowEpisodesViewPayload(session.producerAuth.userId, showId, typeId, {
      input_search: '',
      input_season: '0',
    });
    ctx.type = 'html';
    ctx.body = renderProducerTvShowEpisodePage(payload, 'Episode updated successfully.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '分集更新失败，请检查后重试。');
    ctx.status = 400;
    const payload = await service.getProducerTvShowEpisodesViewPayload(session.producerAuth.userId, showId, typeId, {
      input_search: '',
      input_season: '0',
    });
    ctx.type = 'html';
    ctx.body = renderProducerTvShowEpisodePage(payload, message);
  }
});

backofficeRouter.post('/producer/tvshow-episode/delete/:showId/:episodeId/:typeId', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  const showId = Number(ctx.params.showId ?? 0);
  const episodeId = Number(ctx.params.episodeId ?? 0);
  const typeId = Number(ctx.params.typeId ?? 0);

  if (isCheckAdminBlocked()) {
    ctx.status = 403;
    const payload = await service.getProducerTvShowEpisodesViewPayload(session.producerAuth.userId, showId, typeId, {
      input_search: '',
      input_season: '0',
    });
    ctx.type = 'html';
    ctx.body = renderProducerTvShowEpisodePage(payload, 'Access denied: can not add/edit/delete in demo mode.');
    return;
  }

  try {
    await service.deleteProducerTvShowEpisode(session.producerAuth.userId, showId, episodeId);
    const payload = await service.getProducerTvShowEpisodesViewPayload(session.producerAuth.userId, showId, typeId, {
      input_search: '',
      input_season: '0',
    });
    ctx.type = 'html';
    ctx.body = renderProducerTvShowEpisodePage(payload, 'Episode deleted.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '分集删除失败，请稍后重试。');
    ctx.status = 400;
    const payload = await service.getProducerTvShowEpisodesViewPayload(session.producerAuth.userId, showId, typeId, {
      input_search: '',
      input_season: '0',
    });
    ctx.type = 'html';
    ctx.body = renderProducerTvShowEpisodePage(payload, message);
  }
});

backofficeRouter.post('/producer/tvshow-episode/status', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    const body = parseBody(ctx);
    const showId = Number(body.show_id ?? 0);
    const typeId = Number(body.type_id ?? 0);
    const payload = await service.getProducerTvShowEpisodesViewPayload(session.producerAuth.userId, showId, typeId, {
      input_search: '',
      input_season: '0',
    });
    ctx.status = 403;
    ctx.type = 'html';
    ctx.body = renderProducerTvShowEpisodePage(payload, 'Access denied: can not add/edit/delete in demo mode.');
    return;
  }

  const body = parseBody(ctx);
  const episodeId = Number(body.id ?? 0);
  const showId = Number(body.show_id ?? 0);
  const typeId = Number(body.type_id ?? 0);

  try {
    await service.toggleProducerTvShowEpisodeStatus(session.producerAuth.userId, episodeId);
    const payload = await service.getProducerTvShowEpisodesViewPayload(session.producerAuth.userId, showId, typeId, {
      input_search: '',
      input_season: '0',
    });
    ctx.type = 'html';
    ctx.body = renderProducerTvShowEpisodePage(payload, 'Status changed.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '状态更新失败，请稍后重试。');
    ctx.status = 400;
    const payload = await service.getProducerTvShowEpisodesViewPayload(session.producerAuth.userId, showId, typeId, {
      input_search: '',
      input_season: '0',
    });
    ctx.type = 'html';
    ctx.body = renderProducerTvShowEpisodePage(payload, message);
  }
});

backofficeRouter.post('/producer/tvshow-episode/sortable', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    const body = parseBody(ctx);
    const showId = Number(body.show_id ?? 0);
    const typeId = Number(body.type_id ?? 0);
    const payload = await service.getProducerTvShowEpisodesViewPayload(session.producerAuth.userId, showId, typeId, {
      input_search: '',
      input_season: '0',
    });
    ctx.status = 403;
    ctx.type = 'html';
    ctx.body = renderProducerTvShowEpisodePage(payload, 'Access denied: can not add/edit/delete in demo mode.');
    return;
  }

  const body = parseBody(ctx);
  const ids = String(body.ids ?? '');
  const showId = Number(body.show_id ?? 0);
  const typeId = Number(body.type_id ?? 0);

  try {
    await service.saveProducerTvShowEpisodeSortOrder(session.producerAuth.userId, showId, ids);
    const payload = await service.getProducerTvShowEpisodesViewPayload(session.producerAuth.userId, showId, typeId, {
      input_search: '',
      input_season: '0',
    });
    ctx.type = 'html';
    ctx.body = renderProducerTvShowEpisodePage(payload, 'Sort order saved.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '排序保存失败，请稍后重试。');
    ctx.status = 400;
    const payload = await service.getProducerTvShowEpisodesViewPayload(session.producerAuth.userId, showId, typeId, {
      input_search: '',
      input_season: '0',
    });
    ctx.type = 'html';
    ctx.body = renderProducerTvShowEpisodePage(payload, message);
  }
});

backofficeRouter.get('/producer/shorts/:typeId', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  const typeId = Number(ctx.params.typeId ?? 0);
  const query = ctx.query as Record<string, string | undefined>;
  const payload = await service.getProducerShortsViewPayload(session.producerAuth.userId, typeId, {
    input_search: String(query.input_search ?? ''),
    input_rent: String(query.input_rent ?? '0'),
    input_status: String(query.input_status ?? 'all'),
    page: String(query.page ?? '1'),
  });

  ctx.type = 'html';
  ctx.body = renderProducerShortsPage(payload);
});

backofficeRouter.post('/producer/shorts/save', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    const typeId = Number(parseBody(ctx).type_id ?? 0);
    const payload = await service.getProducerShortsViewPayload(session.producerAuth.userId, typeId, {
      input_search: '',
      input_rent: '0',
      input_status: 'all',
    });
    ctx.status = 403;
    ctx.type = 'html';
    ctx.body = renderProducerShortsPage(payload, 'Access denied: can not add/edit/delete in demo mode.');
    return;
  }

  const body = parseBody(ctx);
  const typeId = Number(body.type_id ?? 0);
  try {
    await service.createProducerShorts(session.producerAuth.userId, body, typeId);
    const payload = await service.getProducerShortsViewPayload(session.producerAuth.userId, typeId, {
      input_search: '',
      input_rent: '0',
      input_status: 'all',
    });
    ctx.type = 'html';
    ctx.body = renderProducerShortsPage(payload, 'Shorts added successfully.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '短剧内容创建失败，请检查后重试。');
    ctx.status = 400;
    const payload = await service.getProducerShortsViewPayload(session.producerAuth.userId, typeId, {
      input_search: '',
      input_rent: '0',
      input_status: 'all',
    });
    ctx.type = 'html';
    ctx.body = renderProducerShortsPage(payload, message);
  }
});

backofficeRouter.post('/producer/shorts/update/:shortsId', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    const body = parseBody(ctx);
    const typeId = Number(body.type_id ?? 0);
    const payload = await service.getProducerShortsViewPayload(session.producerAuth.userId, typeId, {
      input_search: '',
      input_rent: '0',
      input_status: 'all',
    });
    ctx.status = 403;
    ctx.type = 'html';
    ctx.body = renderProducerShortsPage(payload, 'Access denied: can not add/edit/delete in demo mode.');
    return;
  }

  const shortsId = Number(ctx.params.shortsId ?? 0);
  const body = parseBody(ctx);
  const typeId = Number(body.type_id ?? 0);

  try {
    await service.updateProducerShorts(session.producerAuth.userId, shortsId, body, typeId);
    const payload = await service.getProducerShortsViewPayload(session.producerAuth.userId, typeId, {
      input_search: '',
      input_rent: '0',
      input_status: 'all',
    });
    ctx.type = 'html';
    ctx.body = renderProducerShortsPage(payload, 'Shorts updated successfully.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '短剧内容更新失败，请检查后重试。');
    ctx.status = 400;
    const payload = await service.getProducerShortsViewPayload(session.producerAuth.userId, typeId, {
      input_search: '',
      input_rent: '0',
      input_status: 'all',
    });
    ctx.type = 'html';
    ctx.body = renderProducerShortsPage(payload, message);
  }
});

backofficeRouter.post('/producer/shorts/delete/:shortsId/:typeId', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  const shortsId = Number(ctx.params.shortsId ?? 0);
  const typeId = Number(ctx.params.typeId ?? 0);

  if (isCheckAdminBlocked()) {
    ctx.status = 403;
    const payload = await service.getProducerShortsViewPayload(session.producerAuth.userId, typeId, {
      input_search: '',
      input_rent: '0',
      input_status: 'all',
    });
    ctx.type = 'html';
    ctx.body = renderProducerShortsPage(payload, 'Access denied: can not add/edit/delete in demo mode.');
    return;
  }

  try {
    await service.deleteProducerShorts(session.producerAuth.userId, shortsId);
    const payload = await service.getProducerShortsViewPayload(session.producerAuth.userId, typeId, {
      input_search: '',
      input_rent: '0',
      input_status: 'all',
    });
    ctx.type = 'html';
    ctx.body = renderProducerShortsPage(payload, 'Content deleted.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '短剧内容删除失败，请稍后重试。');
    ctx.status = 400;
    const payload = await service.getProducerShortsViewPayload(session.producerAuth.userId, typeId, {
      input_search: '',
      input_rent: '0',
      input_status: 'all',
    });
    ctx.type = 'html';
    ctx.body = renderProducerShortsPage(payload, message);
  }
});

backofficeRouter.post('/producer/shorts-status', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    const body = parseBody(ctx);
    const typeId = Number(body.type_id ?? 0);
    const payload = await service.getProducerShortsViewPayload(session.producerAuth.userId, typeId, {
      input_search: '',
      input_rent: '0',
      input_status: 'all',
    });
    ctx.status = 403;
    ctx.type = 'html';
    ctx.body = renderProducerShortsPage(payload, 'Access denied: can not add/edit/delete in demo mode.');
    return;
  }

  const body = parseBody(ctx);
  const id = Number(body.id ?? 0);
  const typeId = Number(body.type_id ?? 0);

  try {
    await service.toggleProducerShortsStatus(session.producerAuth.userId, id);
    const payload = await service.getProducerShortsViewPayload(session.producerAuth.userId, typeId, {
      input_search: '',
      input_rent: '0',
      input_status: 'all',
    });
    ctx.type = 'html';
    ctx.body = renderProducerShortsPage(payload, 'Status changed.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '状态更新失败，请稍后重试。');
    ctx.status = 400;
    const payload = await service.getProducerShortsViewPayload(session.producerAuth.userId, typeId, {
      input_search: '',
      input_rent: '0',
      input_status: 'all',
    });
    ctx.type = 'html';
    ctx.body = renderProducerShortsPage(payload, message);
  }
});

backofficeRouter.post('/producer/shorts/releases', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    const body = parseBody(ctx);
    const typeId = Number(body.type_id ?? 0);
    const payload = await service.getProducerShortsViewPayload(session.producerAuth.userId, typeId, {
      input_search: '',
      input_rent: '0',
      input_status: 'all',
    });
    ctx.status = 403;
    ctx.type = 'html';
    ctx.body = renderProducerShortsPage(payload, 'Access denied: can not add/edit/delete in demo mode.');
    return;
  }

  const body = parseBody(ctx);
  const id = Number(body.id ?? 0);
  const typeId = Number(body.type_id ?? 0);
  const channelId = Number(body.channel_id ?? 0);

  try {
    await service.releaseProducerShorts(session.producerAuth.userId, id, typeId, channelId);
    const payload = await service.getProducerShortsViewPayload(session.producerAuth.userId, typeId, {
      input_search: '',
      input_rent: '0',
      input_status: 'all',
    });
    ctx.type = 'html';
    ctx.body = renderProducerShortsPage(payload, 'Shorts released.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '短剧内容发布失败，请检查发布信息后重试。');
    ctx.status = 400;
    const fallbackTypeId = Number(body.current_type_id ?? typeId ?? 0);
    const payload = await service.getProducerShortsViewPayload(session.producerAuth.userId, fallbackTypeId, {
      input_search: '',
      input_rent: '0',
      input_status: 'all',
    });
    ctx.type = 'html';
    ctx.body = renderProducerShortsPage(payload, message);
  }
});

backofficeRouter.post('/producer/shorts/serachname/:txtVal', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.status = 401;
    ctx.body = { status: 401, errors: 'unauthorized' };
    return;
  }

  const txtVal = String(ctx.params.txtVal ?? '');
  const data = await service.searchProducerShortsNames(session.producerAuth.userId, txtVal);
  ctx.body = { status: 200, data };
});

backofficeRouter.post('/producer/shorts/getdata/:id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.status = 401;
    ctx.body = { status: 401, errors: 'unauthorized' };
    return;
  }

  const id = Number(ctx.params.id ?? 0);
  try {
    const data = await service.getProducerShortsDataForFill(session.producerAuth.userId, id);
    ctx.body = { status: 200, data };
  } catch (error) {
    const message = getRouteErrorMessage(error, '读取内容失败，请稍后重试。');
    ctx.status = 400;
    ctx.body = { status: 400, errors: message };
  }
});

backofficeRouter.get('/producer/shorts-episode/:showId/:typeId', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  const showId = Number(ctx.params.showId ?? 0);
  const typeId = Number(ctx.params.typeId ?? 0);
  const query = ctx.query as Record<string, string | undefined>;

  const payload = await service.getProducerShortsEpisodesViewPayload(session.producerAuth.userId, showId, typeId, {
    input_search: String(query.input_search ?? ''),
    input_season: String(query.input_season ?? '0'),
  });
  ctx.type = 'html';
  ctx.body = renderProducerShortsEpisodePage(payload);
});

backofficeRouter.post('/producer/shorts-episode/save', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    const body = parseBody(ctx);
    const showId = Number(body.show_id ?? 0);
    const typeId = Number(body.type_id ?? 0);
    const payload = await service.getProducerShortsEpisodesViewPayload(session.producerAuth.userId, showId, typeId, {
      input_search: '',
      input_season: '0',
    });
    ctx.status = 403;
    ctx.type = 'html';
    ctx.body = renderProducerShortsEpisodePage(payload, 'Access denied: can not add/edit/delete in demo mode.');
    return;
  }

  const body = parseBody(ctx);
  const showId = Number(body.show_id ?? 0);
  const typeId = Number(body.type_id ?? 0);
  try {
    await service.createProducerShortsEpisode(session.producerAuth.userId, body, showId);
    const payload = await service.getProducerShortsEpisodesViewPayload(session.producerAuth.userId, showId, typeId, {
      input_search: '',
      input_season: '0',
    });
    ctx.type = 'html';
    ctx.body = renderProducerShortsEpisodePage(payload, 'Episode added successfully.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '分集创建失败，请检查后重试。');
    ctx.status = 400;
    const payload = await service.getProducerShortsEpisodesViewPayload(session.producerAuth.userId, showId, typeId, {
      input_search: '',
      input_season: '0',
    });
    ctx.type = 'html';
    ctx.body = renderProducerShortsEpisodePage(payload, message);
  }
});

backofficeRouter.post('/producer/shorts-episode/update/:episodeId', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    const body = parseBody(ctx);
    const showId = Number(body.show_id ?? 0);
    const typeId = Number(body.type_id ?? 0);
    const payload = await service.getProducerShortsEpisodesViewPayload(session.producerAuth.userId, showId, typeId, {
      input_search: '',
      input_season: '0',
    });
    ctx.status = 403;
    ctx.type = 'html';
    ctx.body = renderProducerShortsEpisodePage(payload, 'Access denied: can not add/edit/delete in demo mode.');
    return;
  }

  const episodeId = Number(ctx.params.episodeId ?? 0);
  const body = parseBody(ctx);
  const showId = Number(body.show_id ?? 0);
  const typeId = Number(body.type_id ?? 0);

  try {
    await service.updateProducerShortsEpisode(session.producerAuth.userId, episodeId, body, showId);
    const payload = await service.getProducerShortsEpisodesViewPayload(session.producerAuth.userId, showId, typeId, {
      input_search: '',
      input_season: '0',
    });
    ctx.type = 'html';
    ctx.body = renderProducerShortsEpisodePage(payload, 'Episode updated successfully.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '分集更新失败，请检查后重试。');
    ctx.status = 400;
    const payload = await service.getProducerShortsEpisodesViewPayload(session.producerAuth.userId, showId, typeId, {
      input_search: '',
      input_season: '0',
    });
    ctx.type = 'html';
    ctx.body = renderProducerShortsEpisodePage(payload, message);
  }
});

backofficeRouter.post('/producer/shorts-episode/delete/:showId/:episodeId/:typeId', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  const showId = Number(ctx.params.showId ?? 0);
  const episodeId = Number(ctx.params.episodeId ?? 0);
  const typeId = Number(ctx.params.typeId ?? 0);

  if (isCheckAdminBlocked()) {
    ctx.status = 403;
    const payload = await service.getProducerShortsEpisodesViewPayload(session.producerAuth.userId, showId, typeId, {
      input_search: '',
      input_season: '0',
    });
    ctx.type = 'html';
    ctx.body = renderProducerShortsEpisodePage(payload, 'Access denied: can not add/edit/delete in demo mode.');
    return;
  }

  try {
    await service.deleteProducerShortsEpisode(session.producerAuth.userId, showId, episodeId);
    const payload = await service.getProducerShortsEpisodesViewPayload(session.producerAuth.userId, showId, typeId, {
      input_search: '',
      input_season: '0',
    });
    ctx.type = 'html';
    ctx.body = renderProducerShortsEpisodePage(payload, 'Episode deleted.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '分集删除失败，请稍后重试。');
    ctx.status = 400;
    const payload = await service.getProducerShortsEpisodesViewPayload(session.producerAuth.userId, showId, typeId, {
      input_search: '',
      input_season: '0',
    });
    ctx.type = 'html';
    ctx.body = renderProducerShortsEpisodePage(payload, message);
  }
});

backofficeRouter.post('/producer/shorts-episode/status', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    const body = parseBody(ctx);
    const showId = Number(body.show_id ?? 0);
    const typeId = Number(body.type_id ?? 0);
    const payload = await service.getProducerShortsEpisodesViewPayload(session.producerAuth.userId, showId, typeId, {
      input_search: '',
      input_season: '0',
    });
    ctx.status = 403;
    ctx.type = 'html';
    ctx.body = renderProducerShortsEpisodePage(payload, 'Access denied: can not add/edit/delete in demo mode.');
    return;
  }

  const body = parseBody(ctx);
  const episodeId = Number(body.id ?? 0);
  const showId = Number(body.show_id ?? 0);
  const typeId = Number(body.type_id ?? 0);

  try {
    await service.toggleProducerShortsEpisodeStatus(session.producerAuth.userId, episodeId);
    const payload = await service.getProducerShortsEpisodesViewPayload(session.producerAuth.userId, showId, typeId, {
      input_search: '',
      input_season: '0',
    });
    ctx.type = 'html';
    ctx.body = renderProducerShortsEpisodePage(payload, 'Status changed.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '状态更新失败，请稍后重试。');
    ctx.status = 400;
    const payload = await service.getProducerShortsEpisodesViewPayload(session.producerAuth.userId, showId, typeId, {
      input_search: '',
      input_season: '0',
    });
    ctx.type = 'html';
    ctx.body = renderProducerShortsEpisodePage(payload, message);
  }
});

backofficeRouter.post('/producer/shorts-episode/sortable', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    const body = parseBody(ctx);
    const showId = Number(body.show_id ?? 0);
    const typeId = Number(body.type_id ?? 0);
    const payload = await service.getProducerShortsEpisodesViewPayload(session.producerAuth.userId, showId, typeId, {
      input_search: '',
      input_season: '0',
    });
    ctx.status = 403;
    ctx.type = 'html';
    ctx.body = renderProducerShortsEpisodePage(payload, 'Access denied: can not add/edit/delete in demo mode.');
    return;
  }

  const body = parseBody(ctx);
  const ids = String(body.ids ?? '');
  const showId = Number(body.show_id ?? 0);
  const typeId = Number(body.type_id ?? 0);

  try {
    await service.saveProducerShortsEpisodeSortOrder(session.producerAuth.userId, showId, ids);
    const payload = await service.getProducerShortsEpisodesViewPayload(session.producerAuth.userId, showId, typeId, {
      input_search: '',
      input_season: '0',
    });
    ctx.type = 'html';
    ctx.body = renderProducerShortsEpisodePage(payload, 'Sort order saved.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '排序保存失败，请稍后重试。');
    ctx.status = 400;
    const payload = await service.getProducerShortsEpisodesViewPayload(session.producerAuth.userId, showId, typeId, {
      input_search: '',
      input_season: '0',
    });
    ctx.type = 'html';
    ctx.body = renderProducerShortsEpisodePage(payload, message);
  }
});

backofficeRouter.get('/producer/withdrawal', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  const query = ctx.query as Record<string, string | undefined>;
  const inputStatus = String(query.input_status ?? 'all');

  const setup = await service.getProducerWithdrawalSetup(session.producerAuth.userId);
  if (!setup) {
    ctx.redirect('/producer/logout');
    return;
  }

  const withdrawals = await service.getProducerWithdrawals(session.producerAuth.userId, inputStatus);
  ctx.type = 'html';
  ctx.body = renderProducerWithdrawalPage({ ...setup, inputStatus, withdrawals });
});

backofficeRouter.get('/producer/rent-transaction', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  const query = ctx.query as Record<string, string | undefined>;
  const inputType = String(query.input_type ?? 'all');
  const inputSearch = String(query.input_search ?? '');

  const payload = await service.getProducerRentTransactionsViewPayload(session.producerAuth.userId, inputType, inputSearch);
  ctx.type = 'html';
  ctx.body = renderProducerRentTransactionPage(payload);
});

backofficeRouter.post('/producer/withdrawal', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  if (isCheckAdminBlocked()) {
    const setup = await service.getProducerWithdrawalSetup(session.producerAuth.userId);
    if (!setup) {
      ctx.redirect('/producer/logout');
      return;
    }
    const withdrawals = await service.getProducerWithdrawals(session.producerAuth.userId, 'all');
    ctx.status = 403;
    ctx.type = 'html';
    ctx.body = renderProducerWithdrawalPage({ ...setup, inputStatus: 'all', withdrawals }, 'Access denied: can not add/edit/delete in demo mode.');
    return;
  }

  const body = parseBody(ctx);
  const price = String(body.price ?? '');

  const setup = await service.getProducerWithdrawalSetup(session.producerAuth.userId);
  if (!setup) {
    ctx.redirect('/producer/logout');
    return;
  }

  try {
    await service.createProducerWithdrawalRequest(session.producerAuth.userId, price);
    const nextSetup = await service.getProducerWithdrawalSetup(session.producerAuth.userId);
    if (!nextSetup) {
      ctx.redirect('/producer/logout');
      return;
    }
    const withdrawals = await service.getProducerWithdrawals(session.producerAuth.userId, 'all');
    ctx.type = 'html';
    ctx.body = renderProducerWithdrawalPage({ ...nextSetup, inputStatus: 'all', withdrawals }, 'Withdrawal request created successfully.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '提现申请提交失败，请检查金额后重试。');
    ctx.status = 400;
    const withdrawals = await service.getProducerWithdrawals(session.producerAuth.userId, 'all');
    ctx.type = 'html';
    ctx.body = renderProducerWithdrawalPage({ ...setup, inputStatus: 'all', withdrawals }, message);
  }
});

backofficeRouter.post('/producer/change-password', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  const body = parseBody(ctx);
  const currentPassword = String(body.current_password ?? '');
  const newPassword = String(body.new_password ?? '');
  const confirmPassword = String(body.confirm_password ?? '');

  try {
    await service.changeProducerPassword(session.producerAuth.userId, currentPassword, newPassword, confirmPassword);
    ctx.type = 'html';
    ctx.body = renderProducerChangePasswordPage(session.producerAuth.userId, 'Password changed successfully.');
  } catch (error) {
    const message = getRouteErrorMessage(error, '密码修改失败，请稍后重试。');
    ctx.status = 400;
    ctx.type = 'html';
    ctx.body = renderProducerChangePasswordPage(session.producerAuth.userId, message);
  }
});

backofficeRouter.all('/admin/(.*)', async (ctx: Context) => {
  ctx.status = 404;
  ctx.type = 'html';
  ctx.body = renderBackofficeNotFoundPage('admin', ctx.path);
});

backofficeRouter.all('/producer/(.*)', async (ctx: Context) => {
  ctx.status = 404;
  ctx.type = 'html';
  ctx.body = renderBackofficeNotFoundPage('producer', ctx.path);
});

export { backofficeRouter };

