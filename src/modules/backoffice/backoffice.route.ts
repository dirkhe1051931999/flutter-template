import Router from '@koa/router';
import type { Context } from 'koa';
import { env } from '../../config/env';
import { BackofficeService } from './backoffice.service';
import {
  renderAdminAvatarPage,
  renderAdminBannerPage,
  renderAdminCategoryPage,
  renderAdminChannelPage,
  renderAdminContentPlaceholderPage,
  renderAdminDashboard,
  renderAdminEpisodeHubPage,
  renderAdminLanguagePage,
  renderAdminListPage,
  renderAdminPaymentEditPage,
  renderAdminSettingsPage,
  renderBackofficeNotFoundPage,
  renderAdminProfilePage,
  renderAdminSeasonPage,
  renderAdminSectionPage,
  renderAdminShortsPage,
  renderAdminTvShowPage,
  renderAdminTypePage,
  renderAdminVideoPage,
  renderLoginPage,
  renderProducerChangePasswordPage,
  renderProducerChannelPage,
  renderProducerContentPlaceholderPage,
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

function escapeHtml(value: unknown): string {
  return String(value ?? '')
    .replaceAll('&', '&amp;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;');
}

function pickValue(row: Record<string, unknown>, keys: string[], fallback = '-'): string {
  for (const key of keys) {
    const value = row[key];
    if (value !== undefined && value !== null && String(value).trim() !== '') {
      return String(value);
    }
  }
  return fallback;
}

function sendHtml(ctx: Context, html: string): void {
  ctx.type = 'html';
  ctx.body = html;
}

type AdminTableColumn = {
  header: string;
  render: (row: Record<string, unknown>) => string;
  align?: 'left' | 'center' | 'right';
};

function renderAdminTablePage(
  ctx: Context,
  title: string,
  rows: Record<string, unknown>[],
  columns: AdminTableColumn[],
  summary?: string,
  message?: string,
  introHtml?: string,
  backHref = '/admin/dashboard',
  backLabel = 'Back Dashboard',
): void {
  sendHtml(
    ctx,
    renderAdminListPage({
      title,
      rows,
      columns,
      summary,
      message,
      introHtml,
      backHref,
      backLabel,
      emptyTitle: `No ${title.toLowerCase()}`,
      emptyDescription: 'There are no records to display yet.',
    }),
  );
}

function renderJsonSnapshot(row: Record<string, unknown>): string {
  return `<pre style="margin:0; white-space:pre-wrap; word-break:break-word; font-size:12px; line-height:1.5;">${escapeHtml(
    JSON.stringify(row, null, 2),
  )}</pre>`;
}

function renderAdminDetailPage(
  ctx: Context,
  title: string,
  row: Record<string, unknown>,
  backHref = '/admin/dashboard',
  backLabel = 'Back Dashboard',
): void {
  renderAdminTablePage(
    ctx,
    title,
    [row],
    [
      { header: 'Field', render: (item) => escapeHtml(pickValue(item, ['id'])) },
      { header: 'Data', render: (item) => renderJsonSnapshot(item) },
    ],
    '1 record',
    undefined,
    undefined,
    backHref,
    backLabel,
  );
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
  ctx.body = '<div style="padding:24px;font-family:Arial,sans-serif;"><h2>访问受限</h2><p>演示模式下禁止新增、编辑和删除。</p></div>';
}

function formatBackofficeErrorMessage(error: unknown, fallback: string): string {
  const raw = error instanceof Error ? error.message : '';
  if (!raw) {
    return fallback;
  }

  const exactMappings: Record<string, string> = {
    'ids are required': '请提供有效的排序 ID。',
    'id is invalid': '记录 ID 无效。',
    'type is required': '类型不能为空。',
    'type_id is required': '类型不能为空。',
    'show_id is required': '剧集不能为空。',
    'season_id is required': '季不能为空。',
    'name is required': '名称不能为空。',
    'category_id is required': '请至少选择一个分类。',
    'language_id is required': '请至少选择一种语言。',
    'video_upload_type is required': '视频上传类型不能为空。',
    'subtitle_type is required': '字幕类型不能为空。',
    'video_320 is required': '视频主地址/文件不能为空。',
    'video_url_320 is required': '视频地址不能为空。',
    'video_url_320 is required for live_stream_url': '直播流地址不能为空。',
    'video_url_320 is required for vdocipher_id': 'VdoCipher ID 不能为空。',
    'channel_id is required': '频道不能为空。',
    'channel_id is required for channel content': '频道内容必须绑定频道。',
    'price and rent_day are required when is_rent = 1': '启用租赁时，价格和租赁天数不能为空。',
    'user_name is required': '用户名不能为空。',
    'user_name must be at least 4 characters': '用户名至少 4 个字符。',
    'full_name must be at least 2 characters': '姓名至少 2 个字符。',
    'email must be valid': '请输入有效邮箱地址。',
    'mobile_number must be numeric': '手机号必须为数字。',
    'user_name already exists': '用户名已存在。',
    'email already exists': '邮箱已存在。',
    'mobile_number already exists': '手机号已存在。',
    'current/new/confirm password are required': '当前密码、新密码、确认密码不能为空。',
    'new_password must be at least 4 characters': '新密码至少 4 个字符。',
    'confirm_password must match new_password': '确认密码与新密码不一致。',
    'please enter right current password': '当前密码不正确。',
    'admin not found': '管理员不存在。',
    'producer not found': '制作人不存在。',
    'type not found': '类型不存在。',
    'video not found': '视频不存在。',
    'tvshow not found': '剧集不存在。',
    'shorts not found': '短剧不存在。',
    'episode not found': '分集不存在。',
    'channel not found': '频道不存在。',
    'avatar not found': '头像不存在。',
    'type not found for producer': '当前制作人下无该类型。',
    'email and password are required': '邮箱和密码不能为空。',
    'invalid credentials': '账号或密码错误。',
    'password changed successfully.': '密码修改成功。',
    'withdrawal request created successfully.': '提现申请提交成功。',
    'status changed.': '状态已更新。',
    'content deleted.': '内容已删除。',
  };

  if (exactMappings[raw]) {
    return exactMappings[raw];
  }

  if (raw.includes('not found')) {
    return '数据不存在或当前账号无权限访问。';
  }
  if (raw.includes('already exists')) {
    return '提交的数据已存在。';
  }
  if (raw.includes('is required')) {
    return '请先完善必填项后再提交。';
  }
  if (raw.includes('is invalid')) {
    return '提交的数据无效。';
  }
  if (raw.includes('must be at least')) {
    return '提交的数据长度不足。';
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
    ctx.body = renderLoginPage('admin', '邮箱和密码不能为空。');
    return;
  }

  const user = await service.loginAdmin(email, password);
  if (!user) {
    ctx.status = 400;
    ctx.type = 'html';
    ctx.body = renderLoginPage('admin', '账号或密码错误。');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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

  const shows = await service.getAdminTvShows();
  ctx.body = { status: 200, result: { mode: 'tvshow', items: shows } };
});

backofficeRouter.get('/admin/episode/shorts', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }

  const shorts = await service.getAdminShorts();
  ctx.body = { status: 200, result: { mode: 'shorts', items: shorts } };
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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

backofficeRouter.get('/admin/banner', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }

  const banners = await service.getAdminBanners();
  ctx.type = 'html';
  ctx.body = renderAdminBannerPage(banners);
});

backofficeRouter.post('/admin/banner/toggle', async (ctx: Context) => {
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
    await service.toggleAdminBannerStatus(id);
    const banners = await service.getAdminBanners();
    ctx.type = 'html';
    ctx.body = renderAdminBannerPage(banners, 'Banner status changed.');
  } catch (error) {
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
    ctx.status = 400;
    const banners = await service.getAdminBanners();
    ctx.type = 'html';
    ctx.body = renderAdminBannerPage(banners, message);
  }
});

backofficeRouter.post('/admin/banner', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  const body = parseBody(ctx);
  try {
    await service.createAdminBanner({
      isHomeScreen: Number(body.is_home_screen ?? 1),
      typeId: Number(body.type_id ?? 0),
      videoType: Number(body.video_type ?? 1),
      subvideoType: Number(body.subvideo_type ?? 0),
      videoId: Number(body.video_id ?? 0),
      sortOrder: Number(body.sort_order ?? 0),
      status: Number(body.status ?? 1),
    });
    const banners = await service.getAdminBanners();
    ctx.type = 'html'; ctx.body = renderAdminBannerPage(banners, 'Banner created successfully.');
  } catch (error) {
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
    ctx.status = 400;
    const banners = await service.getAdminBanners();
    ctx.type = 'html'; ctx.body = renderAdminBannerPage(banners, message);
  }
});

backofficeRouter.post('/admin/banner/update', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  const body = parseBody(ctx);
  try {
    await service.updateAdminBanner(Number(body.id ?? 0), {
      isHomeScreen: Number(body.is_home_screen ?? 1),
      typeId: Number(body.type_id ?? 0),
      videoType: Number(body.video_type ?? 1),
      subvideoType: Number(body.subvideo_type ?? 0),
      videoId: Number(body.video_id ?? 0),
      sortOrder: Number(body.sort_order ?? 0),
      status: Number(body.status ?? 1),
    });
    const banners = await service.getAdminBanners();
    ctx.type = 'html'; ctx.body = renderAdminBannerPage(banners, 'Banner updated successfully.');
  } catch (error) {
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
    ctx.status = 400;
    const banners = await service.getAdminBanners();
    ctx.type = 'html'; ctx.body = renderAdminBannerPage(banners, message);
  }
});


backofficeRouter.post('/admin/banner/sortable/save', async (ctx: Context) => {
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
    await service.saveAdminBannerSortOrder(ids);
    const banners = await service.getAdminBanners();
    ctx.type = 'html';
    ctx.body = renderAdminBannerPage(banners, 'Sort order saved.');
  } catch (error) {
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
    ctx.status = 400;
    const banners = await service.getAdminBanners();
    ctx.type = 'html';
    ctx.body = renderAdminBannerPage(banners, message);
  }
});

backofficeRouter.post('/admin/banner/typebydata', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.status = 401;
    ctx.body = { status: 401, errors: 'unauthorized' };
    return;
  }
  const body = parseBody(ctx);
  try {
    const result = await service.getAdminBannerTypeByData(
      Number(body.type ?? 0),
      Number(body.type_id ?? 0),
      Number(body.subvideo_type ?? 0),
    );
    ctx.body = { status: 200, result };
  } catch (error) {
    ctx.status = 400;
    ctx.body = { status: 400, errors: error instanceof Error ? error.message : 'Bad request' };
  }
});

backofficeRouter.post('/admin/banner/list', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.status = 401;
    ctx.body = { status: 401, errors: 'unauthorized' };
    return;
  }
  const body = parseBody(ctx);
  try {
    const result = await service.getAdminBannerList(
      Number(body.is_home_screen ?? 1),
      Number(body.type_id ?? 0),
    );
    ctx.body = { status: 200, result };
  } catch (error) {
    ctx.status = 400;
    ctx.body = { status: 400, errors: error instanceof Error ? error.message : 'Bad request' };
  }
});

backofficeRouter.get('/admin/section', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }

  const sections = await service.getAdminHomeSections();
  ctx.type = 'html';
  ctx.body = renderAdminSectionPage(sections);
});

backofficeRouter.post('/admin/section/toggle', async (ctx: Context) => {
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
    await service.toggleAdminHomeSectionStatus(id);
    const sections = await service.getAdminHomeSections();
    ctx.type = 'html';
    ctx.body = renderAdminSectionPage(sections, 'Section status changed.');
  } catch (error) {
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
    ctx.status = 400;
    const sections = await service.getAdminHomeSections();
    ctx.type = 'html';
    ctx.body = renderAdminSectionPage(sections, message);
  }
});

backofficeRouter.post('/admin/section', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  const body = parseBody(ctx);
  try {
    await service.createAdminHomeSection({
      sectionType: Number(body.section_type ?? 1),
      isHomeScreen: Number(body.is_home_screen ?? 1),
      videoType: Number(body.video_type ?? 1),
      subVideoType: Number(body.sub_video_type ?? 0),
      typeId: Number(body.type_id ?? 0),
      title: String(body.title ?? '').trim(),
      shortTitle: String(body.short_title ?? '').trim(),
      screenLayout: String(body.screen_layout ?? '').trim(),
      contentIds: String(body.content_ids ?? '').trim(),
      categoryId: Number(body.category_id ?? 0),
      languageId: Number(body.language_id ?? 0),
      channelId: Number(body.channel_id ?? 0),
      orderByUpload: Number(body.order_by_upload ?? 0),
      orderByView: Number(body.order_by_view ?? 0),
      premiumVideo: Number(body.premium_video ?? 0),
      noOfContent: Number(body.no_of_content ?? 0),
      viewAll: Number(body.view_all ?? 0),
      isTitle: Number(body.is_title ?? 0),
      sortOrder: Number(body.sort_order ?? 0),
      status: Number(body.status ?? 1),
    });
    const sections = await service.getAdminHomeSections();
    ctx.type = 'html'; ctx.body = renderAdminSectionPage(sections, 'Section created successfully.');
  } catch (error) {
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
    ctx.status = 400;
    const sections = await service.getAdminHomeSections();
    ctx.type = 'html'; ctx.body = renderAdminSectionPage(sections, message);
  }
});

backofficeRouter.post('/admin/section/update', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  const body = parseBody(ctx);
  try {
    await service.updateAdminHomeSection(Number(body.id ?? 0), {
      sectionType: Number(body.section_type ?? 1),
      isHomeScreen: Number(body.is_home_screen ?? 1),
      videoType: Number(body.video_type ?? 1),
      subVideoType: Number(body.sub_video_type ?? 0),
      typeId: Number(body.type_id ?? 0),
      title: String(body.title ?? '').trim(),
      shortTitle: String(body.short_title ?? '').trim(),
      screenLayout: String(body.screen_layout ?? '').trim(),
      contentIds: String(body.content_ids ?? '').trim(),
      categoryId: Number(body.category_id ?? 0),
      languageId: Number(body.language_id ?? 0),
      channelId: Number(body.channel_id ?? 0),
      orderByUpload: Number(body.order_by_upload ?? 0),
      orderByView: Number(body.order_by_view ?? 0),
      premiumVideo: Number(body.premium_video ?? 0),
      noOfContent: Number(body.no_of_content ?? 0),
      viewAll: Number(body.view_all ?? 0),
      isTitle: Number(body.is_title ?? 0),
      sortOrder: Number(body.sort_order ?? 0),
      status: Number(body.status ?? 1),
    });
    const sections = await service.getAdminHomeSections();
    ctx.type = 'html'; ctx.body = renderAdminSectionPage(sections, 'Section updated successfully.');
  } catch (error) {
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
    ctx.status = 400;
    const sections = await service.getAdminHomeSections();
    ctx.type = 'html'; ctx.body = renderAdminSectionPage(sections, message);
  }
});


backofficeRouter.post('/admin/section/sortable/save', async (ctx: Context) => {
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
    await service.saveAdminHomeSectionSortOrder(ids);
    const sections = await service.getAdminHomeSections();
    ctx.type = 'html';
    ctx.body = renderAdminSectionPage(sections, 'Sort order saved.');
  } catch (error) {
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
    ctx.status = 400;
    const sections = await service.getAdminHomeSections();
    ctx.type = 'html';
    ctx.body = renderAdminSectionPage(sections, message);
  }
});

backofficeRouter.post('/admin/section/data', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.status = 401;
    ctx.body = { status: 401, errors: 'unauthorized' };
    return;
  }
  const body = parseBody(ctx);
  try {
    const result = await service.getAdminSectionData(
      Number(body.is_home_screen ?? 1),
      Number(body.top_type_id ?? 0),
    );
    ctx.body = { status: 200, result };
  } catch (error) {
    ctx.status = 400;
    ctx.body = { status: 400, errors: error instanceof Error ? error.message : 'Bad request' };
  }
});

backofficeRouter.post('/admin/section/edit', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.status = 401;
    ctx.body = { status: 401, errors: 'unauthorized' };
    return;
  }
  const body = parseBody(ctx);
  try {
    const result = await service.getAdminSectionDataEdit(Number(body.id ?? 0));
    ctx.body = { status: 200, result };
  } catch (error) {
    ctx.status = 400;
    ctx.body = { status: 400, errors: error instanceof Error ? error.message : 'Bad request' };
  }
});

backofficeRouter.post('/admin/section/content', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.status = 401;
    ctx.body = { status: 401, errors: 'unauthorized' };
    return;
  }
  const body = parseBody(ctx);
  try {
    const result = await service.getAdminSectionContent({
      videoType: Number(body.video_type ?? 0),
      typeId: Number(body.type_id ?? 0),
      subVideoType: Number(body.sub_video_type ?? 0),
      channelId: Number(body.channel_id ?? 0),
      typeType: Number(body.type_type ?? 0),
    });
    ctx.body = { status: 200, result };
  } catch (error) {
    ctx.status = 400;
    ctx.body = { status: 400, errors: error instanceof Error ? error.message : 'Bad request' };
  }
});

backofficeRouter.post('/admin/section/sortable', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.status = 401;
    ctx.body = { status: 401, errors: 'unauthorized' };
    return;
  }
  const body = parseBody(ctx);
  try {
    const result = await service.getAdminSectionSortable(
      Number(body.is_home_screen ?? 1),
      Number(body.top_type_id ?? 0),
    );
    ctx.body = { status: 200, result };
  } catch (error) {
    ctx.status = 400;
    ctx.body = { status: 400, errors: error instanceof Error ? error.message : 'Bad request' };
  }
});

backofficeRouter.get('/admin/sectionstatus', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }
  if (isCheckAdminBlocked()) {
    respondDemoBlocked(ctx);
    return;
  }
  const query = ctx.query as Record<string, string | undefined>;
  const id = Number(query.id ?? 0);
  try {
    await service.toggleAdminHomeSectionStatus(id);
    ctx.body = { status: 200, success: 'Status changed.' };
  } catch (error) {
    ctx.status = 400;
    ctx.body = { status: 400, errors: error instanceof Error ? error.message : 'Bad request' };
  }
});

backofficeRouter.get('/admin/notifications/setting', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }
  try {
    const result = await service.getAdminNotificationSettings();
    sendHtml(
      ctx,
      renderAdminSettingsPage({
        title: 'Notification Setting',
        action: '/admin/notifications/setting',
        settings: result,
        summary: `${Object.keys(result).length} settings`,
      }),
    );
  } catch (error) {
    ctx.status = 400;
    ctx.body = { status: 400, errors: error instanceof Error ? error.message : 'Bad request' };
  }
});

backofficeRouter.post('/admin/notifications/setting', async (ctx: Context) => {
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
  try {
    await service.saveAdminNotificationSettings(body);
    ctx.body = { status: 200, success: 'Setting saved.' };
  } catch (error) {
    ctx.status = 400;
    ctx.body = { status: 400, errors: error instanceof Error ? error.message : 'Bad request' };
  }
});

backofficeRouter.post('/admin/reviews/approve/:id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }
  if (isCheckAdminBlocked()) {
    respondDemoBlocked(ctx);
    return;
  }
  try {
    await service.approveReview(Number(ctx.params.id ?? 0));
    ctx.body = { status: 200, success: 'Review approved.' };
  } catch (error) {
    ctx.status = 400;
    ctx.body = { status: 400, errors: error instanceof Error ? error.message : 'Bad request' };
  }
});

backofficeRouter.post('/admin/reviews/reject/:id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }
  if (isCheckAdminBlocked()) {
    respondDemoBlocked(ctx);
    return;
  }
  try {
    await service.rejectReview(Number(ctx.params.id ?? 0));
    ctx.body = { status: 200, success: 'Review rejected.' };
  } catch (error) {
    ctx.status = 400;
    ctx.body = { status: 400, errors: error instanceof Error ? error.message : 'Bad request' };
  }
});

backofficeRouter.get('/admin/reviews/destroy/:id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }
  if (isCheckAdminBlocked()) {
    respondDemoBlocked(ctx);
    return;
  }
  try {
    await service.destroyReview(Number(ctx.params.id ?? 0));
    ctx.status = 303;
    ctx.redirect('/admin/reviews');
  } catch (error) {
    ctx.status = 400;
    ctx.body = { status: 400, errors: error instanceof Error ? error.message : 'Bad request' };
  }
});

backofficeRouter.delete('/admin/coupon/:id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }
  if (isCheckAdminBlocked()) {
    respondDemoBlocked(ctx);
    return;
  }
  try {
    await service.destroyCoupon(Number(ctx.params.id ?? 0));
    ctx.body = { status: 200, success: 'Coupon deleted.' };
  } catch (error) {
    ctx.status = 400;
    ctx.body = { status: 400, errors: error instanceof Error ? error.message : 'Bad request' };
  }
});

backofficeRouter.get('/admin/coupon/:id(\\d+)', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }
  if (isCheckAdminBlocked()) {
    respondDemoBlocked(ctx);
    return;
  }
  try {
    await service.destroyCoupon(Number(ctx.params.id ?? 0));
    ctx.status = 303;
    ctx.redirect('/admin/coupon');
  } catch (error) {
    ctx.status = 400;
    ctx.body = { status: 400, errors: error instanceof Error ? error.message : 'Bad request' };
  }
});

backofficeRouter.delete('/admin/rent-price-list/:id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }
  if (isCheckAdminBlocked()) {
    respondDemoBlocked(ctx);
    return;
  }
  try {
    await service.destroyRentPrice(Number(ctx.params.id ?? 0));
    ctx.body = { status: 200, success: 'Rent price deleted.' };
  } catch (error) {
    ctx.status = 400;
    ctx.body = { status: 400, errors: error instanceof Error ? error.message : 'Bad request' };
  }
});

backofficeRouter.get('/admin/rent-price-list/:id(\\d+)', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) {
    ctx.redirect('/admin/login');
    return;
  }
  if (isCheckAdminBlocked()) {
    respondDemoBlocked(ctx);
    return;
  }
  try {
    await service.destroyRentPrice(Number(ctx.params.id ?? 0));
    ctx.status = 303;
    ctx.redirect('/admin/rent-price-list');
  } catch (error) {
    ctx.status = 400;
    ctx.body = { status: 400, errors: error instanceof Error ? error.message : 'Bad request' };
  }
});

backofficeRouter.delete('/admin/type/:id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  await service.destroyType(Number(ctx.params.id ?? 0));
  ctx.body = { status: 200, success: 'Deleted.' };
});
backofficeRouter.delete('/admin/category/:id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  await service.destroyCategory(Number(ctx.params.id ?? 0));
  ctx.body = { status: 200, success: 'Deleted.' };
});
backofficeRouter.delete('/admin/language/:id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  await service.destroyLanguage(Number(ctx.params.id ?? 0));
  ctx.body = { status: 200, success: 'Deleted.' };
});
backofficeRouter.delete('/admin/season/:id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  await service.destroySeason(Number(ctx.params.id ?? 0));
  ctx.body = { status: 200, success: 'Deleted.' };
});
backofficeRouter.delete('/admin/avatar/:id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  await service.destroyAvatar(Number(ctx.params.id ?? 0));
  ctx.body = { status: 200, success: 'Deleted.' };
});
backofficeRouter.delete('/admin/channel/:id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  await service.destroyChannel(Number(ctx.params.id ?? 0));
  ctx.body = { status: 200, success: 'Deleted.' };
});
backofficeRouter.delete('/admin/user/:id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  await service.destroyUser(Number(ctx.params.id ?? 0));
  ctx.body = { status: 200, success: 'Deleted.' };
});
backofficeRouter.delete('/admin/producer/:id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  await service.destroyProducer(Number(ctx.params.id ?? 0));
  ctx.body = { status: 200, success: 'Deleted.' };
});
backofficeRouter.delete('/admin/cast/:id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  await service.destroyCast(Number(ctx.params.id ?? 0));
  ctx.body = { status: 200, success: 'Deleted.' };
});
backofficeRouter.get('/admin/section/:id(\\d+)', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  await service.destroySection(Number(ctx.params.id ?? 0));
  ctx.status = 303;
  ctx.redirect('/admin/section');
});
backofficeRouter.delete('/admin/notification/:id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  await service.destroyNotification(Number(ctx.params.id ?? 0));
  ctx.body = { status: 200, success: 'Deleted.' };
});

backofficeRouter.get('/admin/payment/:id/edit', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  try {
    const result = await service.getAdminPaymentById(Number(ctx.params.id ?? 0));
    if (!result) {
      ctx.status = 404;
      ctx.body = { status: 404, errors: 'data not found' };
      return;
    }
    sendHtml(ctx, renderAdminPaymentEditPage(result));
  } catch (error) {
    ctx.status = 400;
    ctx.body = { status: 400, errors: error instanceof Error ? error.message : 'Bad request' };
  }
});

backofficeRouter.post('/admin/payment/update', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  const body = parseBody(ctx);
  try {
    await service.updateAdminPayment({
      id: Number(body.id ?? 0),
      key1: String(body.key_1 ?? ''),
      key2: String(body.key_2 ?? ''),
      key3: String(body.key_3 ?? ''),
      key4: String(body.key_4 ?? ''),
      visibility: Number(body.visibility ?? Number.NaN),
      isLive: Number(body.is_live ?? Number.NaN),
    });
    ctx.body = { status: 200, success: 'Payment updated successfully.' };
  } catch (error) {
    ctx.status = 400;
    ctx.body = { status: 400, errors: error instanceof Error ? error.message : 'Bad request' };
  }
});

backofficeRouter.post('/admin/payment/:id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  const body = parseBody(ctx);
  try {
    await service.updateAdminPayment({
      id: Number(ctx.params.id ?? body.id ?? 0),
      key1: String(body.key_1 ?? ''),
      key2: String(body.key_2 ?? ''),
      key3: String(body.key_3 ?? ''),
      key4: String(body.key_4 ?? ''),
      visibility: Number(body.visibility ?? Number.NaN),
      isLive: Number(body.is_live ?? Number.NaN),
    });
    ctx.body = { status: 200, success: 'Payment updated successfully.' };
  } catch (error) {
    ctx.status = 400;
    ctx.body = { status: 400, errors: error instanceof Error ? error.message : 'Bad request' };
  }
});

backofficeRouter.delete('/admin/transaction/:id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  await service.destroyTransaction(Number(ctx.params.id ?? 0));
  ctx.body = { status: 200, success: 'Deleted.' };
});
backofficeRouter.get('/admin/transaction/:id(\\d+)', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  await service.destroyTransaction(Number(ctx.params.id ?? 0));
  ctx.status = 303;
  ctx.redirect('/admin/transaction');
});

backofficeRouter.delete('/admin/package/:id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  await service.destroyPackage(Number(ctx.params.id ?? 0));
  ctx.body = { status: 200, success: 'Deleted.' };
});
backofficeRouter.get('/admin/package/:id(\\d+)', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  await service.destroyPackage(Number(ctx.params.id ?? 0));
  ctx.status = 303;
  ctx.redirect('/admin/package');
});

backofficeRouter.delete('/admin/rent-transaction/:id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  await service.destroyRentTransaction(Number(ctx.params.id ?? 0));
  ctx.body = { status: 200, success: 'Deleted.' };
});
backofficeRouter.get('/admin/rent-transaction/:id(\\d+)', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  await service.destroyRentTransaction(Number(ctx.params.id ?? 0));
  ctx.status = 303;
  ctx.redirect('/admin/rent-transaction');
});

backofficeRouter.delete('/admin/page/:id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  await service.destroyPage(Number(ctx.params.id ?? 0));
  ctx.body = { status: 200, success: 'Deleted.' };
});
backofficeRouter.get('/admin/page/:id(\\d+)', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  await service.destroyPage(Number(ctx.params.id ?? 0));
  ctx.status = 303;
  ctx.redirect('/admin/page');
});

backofficeRouter.get('/admin/payment', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const rows = await service.getAdminPaymentOptions();
  renderAdminTablePage(
    ctx,
    'Payment',
    rows,
    [
      { header: 'ID', render: (row) => escapeHtml(pickValue(row, ['id'])) },
      { header: 'Gateway', render: (row) => escapeHtml(pickValue(row, ['name', 'title', 'gateway_name'])) },
      { header: 'Status', render: (row) => escapeHtml(pickValue(row, ['visibility', 'is_live', 'status'])) },
      {
        header: 'Edit',
        render: (row) => `<a href="/admin/payment/${encodeURIComponent(pickValue(row, ['id'], '0'))}/edit">Edit</a>`,
      },
    ],
    `${rows.length} payment options`,
    undefined,
  );
});

backofficeRouter.get('/admin/refer-earn', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const result = await service.getAdminReferEarnRows();
  renderAdminTablePage(
    ctx,
    'Refer Earn',
    result,
    [
      { header: 'ID', render: (row) => escapeHtml(pickValue(row, ['id'])) },
      { header: 'Data', render: (row) => renderJsonSnapshot(row) },
    ],
    `${result.length} records`,
  );
});

backofficeRouter.get('/admin/wallet-transaction', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const result = await service.getAdminWalletTransactions();
  renderAdminTablePage(
    ctx,
    'Wallet Transaction',
    result,
    [
      { header: 'ID', render: (row) => escapeHtml(pickValue(row, ['id'])) },
      { header: 'Data', render: (row) => renderJsonSnapshot(row) },
    ],
    `${result.length} records`,
  );
});

backofficeRouter.get('/admin/withdrawal', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const result = await service.getAdminWithdrawalRows();
  renderAdminTablePage(
    ctx,
    'Withdrawal',
    result,
    [
      { header: 'ID', render: (row) => escapeHtml(pickValue(row, ['id'])) },
      { header: 'Data', render: (row) => renderJsonSnapshot(row) },
    ],
    `${result.length} records`,
  );
});

backofficeRouter.get('/admin/admob', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const result = await service.getAdminAdmobRows();
  renderAdminTablePage(
    ctx,
    'Admob',
    result,
    [
      { header: 'ID', render: (row) => escapeHtml(pickValue(row, ['id'])) },
      { header: 'Data', render: (row) => renderJsonSnapshot(row) },
    ],
    `${result.length} records`,
  );
});

backofficeRouter.post('/admin/admob/status', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  const body = parseBody(ctx);
  await service.saveAdminAdmob(body);
  ctx.body = { status: 200, success: 'Admob status updated.' };
});

backofficeRouter.post('/admin/admob/android', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  const body = parseBody(ctx);
  await service.saveAdminAdmob(body);
  ctx.body = { status: 200, success: 'Android admob updated.' };
});

backofficeRouter.post('/admin/admob/ios', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  const body = parseBody(ctx);
  await service.saveAdminAdmob(body);
  ctx.body = { status: 200, success: 'iOS admob updated.' };
});

backofficeRouter.get('/admin/app-setting', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const result = await service.getAdminNotificationSettings();
  sendHtml(
    ctx,
    renderAdminSettingsPage({
      title: 'App Setting',
      action: '/admin/app-setting/app',
      settings: result,
      summary: `${Object.keys(result).length} settings`,
    }),
  );
});

async function handleAdminSettingSave(ctx: Context): Promise<void> {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  const body = parseBody(ctx);
  await service.saveAdminSettings(body);
  ctx.body = { status: 200, success: 'Setting saved.' };
}
backofficeRouter.post('/admin/app-setting/app', handleAdminSettingSave);
backofficeRouter.post('/admin/app-setting/apitoken', handleAdminSettingSave);
backofficeRouter.post('/admin/app-setting/tmdbkey', handleAdminSettingSave);
backofficeRouter.post('/admin/app-setting/currency', handleAdminSettingSave);
backofficeRouter.post('/admin/app-setting/appdownload', handleAdminSettingSave);
backofficeRouter.post('/admin/app-setting/basicconfigrations', handleAdminSettingSave);
backofficeRouter.post('/admin/app-setting/smtp', handleAdminSettingSave);
backofficeRouter.post('/admin/app-setting/storagesetting', handleAdminSettingSave);
backofficeRouter.post('/admin/app-setting/sociallink', handleAdminSettingSave);
backofficeRouter.post('/admin/app-setting/onboardingscreen', handleAdminSettingSave);
backofficeRouter.post('/admin/app-setting/vapidkey', handleAdminSettingSave);
backofficeRouter.post('/admin/app-setting/commission', handleAdminSettingSave);
backofficeRouter.post('/admin/app-setting/withdrawal-amount', handleAdminSettingSave);
backofficeRouter.post('/admin/app-setting/vdocipher', handleAdminSettingSave);
backofficeRouter.post('/admin/app-setting/webclientid', handleAdminSettingSave);
backofficeRouter.post('/admin/app-setting/refer-and-earn', handleAdminSettingSave);

backofficeRouter.get('/admin/panel-setting', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const result = await service.getAdminNotificationSettings();
  sendHtml(
    ctx,
    renderAdminSettingsPage({
      title: 'Panel Setting',
      action: '/admin/panel-setting/save',
      settings: result,
      summary: `${Object.keys(result).length} settings`,
    }),
  );
});

backofficeRouter.post('/admin/panel-setting/save', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  const body = parseBody(ctx);
  await service.saveAdminSettings(body);
  ctx.body = { status: 200, success: 'Panel setting saved.' };
});

backofficeRouter.get('/admin/system-setting', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const result = await service.getAdminNotificationSettings();
  sendHtml(
    ctx,
    renderAdminSettingsPage({
      title: 'System Setting',
      settings: result,
      summary: `${Object.keys(result).length} settings`,
    }),
  );
});

backofficeRouter.post('/admin/system-setting/cleardata', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  ctx.body = { status: 200, success: 'Clear data executed.' };
});

backofficeRouter.post('/admin/system-setting/cleandatabase', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  ctx.body = { status: 200, success: 'Clean database executed.' };
});

backofficeRouter.get('/admin/systemsetting/downloadsqlfile', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  ctx.body = { status: 200, success: 'Download sql requested.' };
});

backofficeRouter.get('/admin/notificationconfiguration', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const result = await service.getAdminNotificationConfigurationRows();
  renderAdminTablePage(
    ctx,
    'Notification Config',
    result,
    [
      { header: 'ID', render: (row) => escapeHtml(pickValue(row, ['id'])) },
      { header: 'Data', render: (row) => renderJsonSnapshot(row) },
    ],
    `${result.length} records`,
  );
});

backofficeRouter.post('/admin/notificationconfiguration', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  const body = parseBody(ctx);
  await service.saveAdminNotificationConfiguration(body);
  ctx.body = { status: 200, success: 'Notification configuration saved.' };
});

backofficeRouter.get('/admin/reviews', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const result = await service.getAdminReviews();
  renderAdminTablePage(
    ctx,
    'Reviews',
    result,
    [
      { header: 'ID', render: (row) => escapeHtml(pickValue(row, ['id'])) },
      { header: 'Data', render: (row) => renderJsonSnapshot(row) },
    ],
    `${result.length} records`,
  );
});

backofficeRouter.all('/admin/search_user', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const query = ctx.query as Record<string, string | undefined>;
  const body = parseBody(ctx);
  const keyword = String(query.name ?? body.name ?? '');
  const result = await service.searchAdminUsers(keyword);
  ctx.body = { status: 200, result };
});

backofficeRouter.all('/admin/rentsearchuser', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const query = ctx.query as Record<string, string | undefined>;
  const body = parseBody(ctx);
  const keyword = String(query.name ?? body.name ?? '');
  const result = await service.searchAdminUsers(keyword);
  ctx.body = { status: 200, result };
});

backofficeRouter.post('/admin/page/pagesetting', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  const body = parseBody(ctx);
  await service.saveAdminSettings(body);
  ctx.body = { status: 200, success: 'Page setting saved.' };
});

backofficeRouter.get('/admin/coupon', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const result = await service.getAdminCoupons();
  renderAdminTablePage(
    ctx,
    'Coupon',
    result,
    [
      { header: 'ID', render: (row) => escapeHtml(pickValue(row, ['id'])) },
      { header: 'Data', render: (row) => renderJsonSnapshot(row) },
    ],
    `${result.length} records`,
  );
});

backofficeRouter.get('/admin/rent-price-list', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const result = await service.getAdminRentPriceList();
  renderAdminTablePage(
    ctx,
    'Rent Price',
    result,
    [
      { header: 'ID', render: (row) => escapeHtml(pickValue(row, ['id'])) },
      { header: 'Data', render: (row) => renderJsonSnapshot(row) },
    ],
    `${result.length} records`,
  );
});

backofficeRouter.get('/admin/package', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const result = await service.getAdminPackages();
  renderAdminTablePage(
    ctx,
    'Package',
    result,
    [
      { header: 'ID', render: (row) => escapeHtml(pickValue(row, ['id'])) },
      { header: 'Data', render: (row) => renderJsonSnapshot(row) },
    ],
    `${result.length} records`,
  );
});

backofficeRouter.get('/admin/transaction', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const result = await service.getAdminTransactions();
  renderAdminTablePage(
    ctx,
    'Transaction',
    result,
    [
      { header: 'ID', render: (row) => escapeHtml(pickValue(row, ['id'])) },
      { header: 'Data', render: (row) => renderJsonSnapshot(row) },
    ],
    `${result.length} records`,
  );
});

backofficeRouter.get('/admin/rent-transaction', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const result = await service.getAdminRentTransactions();
  renderAdminTablePage(
    ctx,
    'Rent Transaction',
    result,
    [
      { header: 'ID', render: (row) => escapeHtml(pickValue(row, ['id'])) },
      { header: 'Data', render: (row) => renderJsonSnapshot(row) },
    ],
    `${result.length} records`,
  );
});

backofficeRouter.get('/admin/user', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const result = await service.getAdminUsers();
  renderAdminTablePage(
    ctx,
    'User',
    result,
    [
      { header: 'ID', render: (row) => escapeHtml(pickValue(row, ['id'])) },
      { header: 'Data', render: (row) => renderJsonSnapshot(row) },
    ],
    `${result.length} records`,
  );
});

backofficeRouter.get('/admin/user/dashboard/:id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const result = await service.getAdminUserDashboard(Number(ctx.params.id ?? 0));
  ctx.body = { status: 200, result };
});

backofficeRouter.get('/admin/producer', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const result = await service.getAdminProducers();
  renderAdminTablePage(
    ctx,
    'Producer',
    result,
    [
      { header: 'ID', render: (row) => escapeHtml(pickValue(row, ['id'])) },
      { header: 'Data', render: (row) => renderJsonSnapshot(row) },
    ],
    `${result.length} records`,
  );
});

backofficeRouter.get('/admin/cast', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const result = await service.getAdminCasts();
  renderAdminTablePage(
    ctx,
    'Cast',
    result,
    [
      { header: 'ID', render: (row) => escapeHtml(pickValue(row, ['id'])) },
      { header: 'Data', render: (row) => renderJsonSnapshot(row) },
    ],
    `${result.length} records`,
  );
});

backofficeRouter.get('/admin/notification', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const rows = (await service.getAdminNotificationConfigurationRows()) as Record<string, unknown>[];
  renderAdminTablePage(
    ctx,
    'Notification',
    rows,
    [
      { header: 'ID', render: (row) => escapeHtml(pickValue(row, ['id'])) },
      { header: 'Data', render: (row) => renderJsonSnapshot(row) },
    ],
    `${rows.length} records`,
  );
});

backofficeRouter.get('/admin/page', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const result = await service.getAdminSettingsByKeys(['page_background_color', 'page_title_color']);
  sendHtml(
    ctx,
    renderAdminSettingsPage({
      title: 'Page',
      action: '/admin/page/pagesetting',
      settings: result,
      summary: `${Object.keys(result).length} settings`,
    }),
  );
});

// PHP compatibility aliases for admin content routes
backofficeRouter.get('/admin/video/:type_id', async (ctx: Context) => {
  const query = ctx.query as Record<string, string | undefined>;
  const page = String(query.page ?? '1');
  ctx.redirect(`/admin/video?page=${encodeURIComponent(page)}`);
});
backofficeRouter.get('/admin/video/add/:type_id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const typeId = Number(ctx.params.type_id ?? 0);
  ctx.redirect(`/admin/video?type_id=${encodeURIComponent(String(typeId))}&mode=create`);
});
backofficeRouter.post('/admin/video/save', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  const body = parseBody(ctx);
  const id = await service.createAdminVideoCompat(body);
  ctx.body = { status: 200, success: 'Video created.', id };
});
backofficeRouter.get('/admin/video/edit/:video_id/:type_id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const videoId = Number(ctx.params.video_id ?? 0);
  const typeId = Number(ctx.params.type_id ?? 0);
  ctx.redirect(`/admin/video?type_id=${encodeURIComponent(String(typeId))}&edit_video_id=${encodeURIComponent(String(videoId))}`);
});
backofficeRouter.post('/admin/video/update/:video_id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  const body = parseBody(ctx);
  await service.updateAdminVideoCompat(Number(ctx.params.video_id ?? 0), body);
  ctx.body = { status: 200, success: 'Video updated.' };
});
backofficeRouter.post('/admin/video/serachname/:txtVal', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const result = await service.searchAdminVideoNames(String(ctx.params.txtVal ?? ''));
  ctx.body = { status: 200, result };
});
backofficeRouter.post('/admin/video/getdata/:id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const result = await service.getAdminVideoDataForFill(Number(ctx.params.id ?? 0));
  ctx.body = { status: 200, result };
});
backofficeRouter.get('/admin/videostatus', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  const query = ctx.query as Record<string, string | undefined>;
  const id = Number(query.id ?? 0);
  await service.toggleAdminVideoStatus(id);
  ctx.body = { status: 200, success: 'Status changed.' };
});

backofficeRouter.get('/admin/tvshow/:type_id', async (ctx: Context) => {
  const query = ctx.query as Record<string, string | undefined>;
  const page = String(query.page ?? '1');
  ctx.redirect(`/admin/tvshow?page=${encodeURIComponent(page)}`);
});
backofficeRouter.get('/admin/shorts/:type_id', async (ctx: Context) => {
  const query = ctx.query as Record<string, string | undefined>;
  const page = String(query.page ?? '1');
  ctx.redirect(`/admin/shorts?page=${encodeURIComponent(page)}`);
});
backofficeRouter.get('/admin/tvshowstatus', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  const query = ctx.query as Record<string, string | undefined>;
  const id = Number(query.id ?? 0);
  await service.toggleAdminTvShowStatus(id);
  ctx.body = { status: 200, success: 'Status changed.' };
});
backofficeRouter.get('/admin/shortsstatus', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  const query = ctx.query as Record<string, string | undefined>;
  const id = Number(query.id ?? 0);
  await service.toggleAdminShortsStatus(id);
  ctx.body = { status: 200, success: 'Status changed.' };
});

backofficeRouter.get('/admin/tvshow-episode/:id/:type_id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const showId = Number(ctx.params.id ?? 0);
  const typeId = Number(ctx.params.type_id ?? 0);
  ctx.redirect(`/admin/tvshow?page=1&type_id=${encodeURIComponent(String(typeId))}&show_id=${encodeURIComponent(String(showId))}`);
});
backofficeRouter.get('/admin/shorts-episode/:id/:type_id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const showId = Number(ctx.params.id ?? 0);
  const typeId = Number(ctx.params.type_id ?? 0);
  ctx.redirect(`/admin/shorts?page=1&type_id=${encodeURIComponent(String(typeId))}&show_id=${encodeURIComponent(String(showId))}`);
});

// More PHP compatibility aliases for tvshow/shorts/episode routes
backofficeRouter.get('/admin/tvshow/add/:type_id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const typeId = Number(ctx.params.type_id ?? 0);
  ctx.redirect(`/admin/tvshow?type_id=${encodeURIComponent(String(typeId))}&mode=create`);
});
backofficeRouter.post('/admin/tvshow/save', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  const body = parseBody(ctx);
  const id = await service.createAdminTvShowCompat(body);
  ctx.body = { status: 200, success: 'TV show created.', id };
});
backofficeRouter.get('/admin/tvshow/edit/:tvshow_id/:type_id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const tvshowId = Number(ctx.params.tvshow_id ?? 0);
  const typeId = Number(ctx.params.type_id ?? 0);
  ctx.redirect(`/admin/tvshow?type_id=${encodeURIComponent(String(typeId))}&edit_tvshow_id=${encodeURIComponent(String(tvshowId))}`);
});
backofficeRouter.post('/admin/tvshow/update/:tvshow_id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  const body = parseBody(ctx);
  await service.updateAdminTvShowCompat(Number(ctx.params.tvshow_id ?? 0), body);
  ctx.body = { status: 200, success: 'TV show updated.' };
});
backofficeRouter.post('/admin/tvshow/releases', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  const body = parseBody(ctx);
  await service.releaseAdminTvShow(body);
  ctx.body = { status: 200, success: 'TV show release updated.' };
});
backofficeRouter.post('/admin/tvshow/serachname/:txtVal', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const result = await service.searchAdminTvShowNames(String(ctx.params.txtVal ?? ''));
  ctx.body = { status: 200, result };
});
backofficeRouter.post('/admin/tvshow/getdata/:id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const result = await service.getAdminTvShowDataForFill(Number(ctx.params.id ?? 0));
  ctx.body = { status: 200, result };
});

backofficeRouter.post('/admin/shorts/serachname/:txtVal', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const result = await service.searchAdminShortsNames(String(ctx.params.txtVal ?? ''));
  ctx.body = { status: 200, result };
});
backofficeRouter.post('/admin/shorts/getdata/:id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const result = await service.getAdminShortsDataForFill(Number(ctx.params.id ?? 0));
  ctx.body = { status: 200, result };
});
backofficeRouter.get('/admin/tvshow/show/:tvshow_id/:type_id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  await service.destroyTvShow(Number(ctx.params.tvshow_id ?? 0));
  ctx.status = 303;
  ctx.redirect('/admin/tvshow');
});

backofficeRouter.get('/admin/tvshow-episode/add/:id/:type_id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const showId = Number(ctx.params.id ?? 0);
  const typeId = Number(ctx.params.type_id ?? 0);
  ctx.redirect(`/admin/tvshow?page=1&type_id=${encodeURIComponent(String(typeId))}&show_id=${encodeURIComponent(String(showId))}&mode=episode-create`);
});
backofficeRouter.post('/admin/tvshow-episode/save', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  const body = parseBody(ctx);
  const id = await service.createAdminTvShowEpisodeCompat(body);
  ctx.body = { status: 200, success: 'TV show episode created.', id };
});
backofficeRouter.get('/admin/tvshow-episode/edit/:id/:type_id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const episodeId = Number(ctx.params.id ?? 0);
  const typeId = Number(ctx.params.type_id ?? 0);
  ctx.redirect(`/admin/tvshow?page=1&type_id=${encodeURIComponent(String(typeId))}&edit_episode_id=${encodeURIComponent(String(episodeId))}`);
});
backofficeRouter.post('/admin/tvshow-episode/update/:id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  const body = parseBody(ctx);
  await service.updateAdminTvShowEpisodeCompat(Number(ctx.params.id ?? 0), body);
  ctx.body = { status: 200, success: 'TV show episode updated.' };
});
backofficeRouter.post('/admin/tvshow-episode/sortable', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  const body = parseBody(ctx);
  await service.sortAdminTvShowEpisodes(String(body.ids ?? body.id ?? ''));
  ctx.body = { status: 200, success: 'TV show episode sort order saved.' };
});
backofficeRouter.get('/admin/tvshow-episode/status', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  const query = ctx.query as Record<string, string | undefined>;
  await service.toggleAdminTvShowEpisodeCompat(Number(query.id ?? 0));
  ctx.body = { status: 200, success: 'TV show episode status changed.' };
});
backofficeRouter.get('/admin/tvshow-episode/delete/:tvshow_id/:id/:type_id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  await service.destroyTvShowEpisode(Number(ctx.params.id ?? 0));
  ctx.status = 303;
  ctx.redirect('/admin/tvshow');
});

backofficeRouter.get('/admin/shorts/add/:type_id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const typeId = Number(ctx.params.type_id ?? 0);
  ctx.redirect(`/admin/shorts?type_id=${encodeURIComponent(String(typeId))}&mode=create`);
});
backofficeRouter.post('/admin/shorts/save', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  const body = parseBody(ctx);
  const id = await service.createAdminShortsCompat(body);
  ctx.body = { status: 200, success: 'Shorts created.', id };
});
backofficeRouter.get('/admin/shorts/edit/:shorts_id/:type_id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const shortsId = Number(ctx.params.shorts_id ?? 0);
  const typeId = Number(ctx.params.type_id ?? 0);
  ctx.redirect(`/admin/shorts?type_id=${encodeURIComponent(String(typeId))}&edit_shorts_id=${encodeURIComponent(String(shortsId))}`);
});
backofficeRouter.post('/admin/shorts/update/:shorts_id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  const body = parseBody(ctx);
  await service.updateAdminShortsCompat(Number(ctx.params.shorts_id ?? 0), body);
  ctx.body = { status: 200, success: 'Shorts updated.' };
});
backofficeRouter.get('/admin/shorts/show/:shorts_id/:type_id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  await service.destroyShorts(Number(ctx.params.shorts_id ?? 0));
  ctx.status = 303;
  ctx.redirect('/admin/shorts');
});

backofficeRouter.get('/admin/shorts-episode/add/:id/:type_id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const showId = Number(ctx.params.id ?? 0);
  const typeId = Number(ctx.params.type_id ?? 0);
  ctx.redirect(`/admin/shorts?page=1&type_id=${encodeURIComponent(String(typeId))}&show_id=${encodeURIComponent(String(showId))}&mode=episode-create`);
});
backofficeRouter.post('/admin/shorts-episode/save', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  const body = parseBody(ctx);
  const id = await service.createAdminShortsEpisodeCompat(body);
  ctx.body = { status: 200, success: 'Shorts episode created.', id };
});
backofficeRouter.get('/admin/shorts-episode/edit/:id/:type_id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const episodeId = Number(ctx.params.id ?? 0);
  const typeId = Number(ctx.params.type_id ?? 0);
  ctx.redirect(`/admin/shorts?page=1&type_id=${encodeURIComponent(String(typeId))}&edit_episode_id=${encodeURIComponent(String(episodeId))}`);
});
backofficeRouter.post('/admin/shorts-episode/update/:id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  const body = parseBody(ctx);
  await service.updateAdminShortsEpisodeCompat(Number(ctx.params.id ?? 0), body);
  ctx.body = { status: 200, success: 'Shorts episode updated.' };
});
backofficeRouter.post('/admin/shorts-episode/sortable', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  const body = parseBody(ctx);
  await service.sortAdminShortsEpisodes(String(body.ids ?? body.id ?? ''));
  ctx.body = { status: 200, success: 'Shorts episode sort order saved.' };
});
backofficeRouter.get('/admin/shorts-episode/status', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  const query = ctx.query as Record<string, string | undefined>;
  await service.toggleAdminShortsEpisodeCompat(Number(query.id ?? 0));
  ctx.body = { status: 200, success: 'Shorts episode status changed.' };
});
backofficeRouter.get('/admin/shorts-episode/delete/:shorts_id/:id/:type_id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  await service.destroyShortsEpisode(Number(ctx.params.id ?? 0));
  ctx.status = 303;
  ctx.redirect('/admin/shorts');
});

// Generic create/edit compatibility entry points for admin resources
for (const createPath of [
  '/admin/type/create',
  '/admin/category/create',
  '/admin/language/create',
  '/admin/season/create',
  '/admin/avatar/create',
  '/admin/channel/create',
  '/admin/banner/create',
  '/admin/section/create',
  '/admin/cast/create',
  '/admin/user/create',
  '/admin/producer/create',
  '/admin/page/create',
  '/admin/package/create',
  '/admin/transaction/create',
  '/admin/rent-transaction/create',
  '/admin/coupon/create',
  '/admin/rent-price-list/create',
  '/admin/notification/create',
  '/admin/notificationconfiguration/create',
  '/admin/payment/create',
  '/admin/withdrawal/create',
  '/admin/wallet-transaction/create',
]) {
  backofficeRouter.get(createPath, async (ctx: Context) => {
    const session = getSession(ctx);
    if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
    const basePath = createPath.replace(/\/create$/, '');
    ctx.redirect(`${basePath}?mode=create`);
  });
}

for (const editPattern of [
  '/admin/type/:id/edit',
  '/admin/category/:id/edit',
  '/admin/language/:id/edit',
  '/admin/season/:id/edit',
  '/admin/avatar/:id/edit',
  '/admin/channel/:id/edit',
  '/admin/banner/:id/edit',
  '/admin/section/:id/edit',
  '/admin/cast/:id/edit',
  '/admin/user/:id/edit',
  '/admin/producer/:id/edit',
  '/admin/page/:id/edit',
  '/admin/package/:id/edit',
  '/admin/transaction/:id/edit',
  '/admin/rent-transaction/:id/edit',
  '/admin/coupon/:id/edit',
  '/admin/rent-price-list/:id/edit',
  '/admin/notification/:id/edit',
  '/admin/notificationconfiguration/:id/edit',
  '/admin/withdrawal/:id/edit',
  '/admin/wallet-transaction/:id/edit',
  '/admin/profile/:id/edit',
]) {
  backofficeRouter.get(editPattern, async (ctx: Context) => {
    const session = getSession(ctx);
    if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
    const id = Number(ctx.params.id ?? 0);
    const basePath = editPattern.replace(/\/:id\/edit$/, '');
    ctx.redirect(`${basePath}?edit_id=${encodeURIComponent(String(id))}`);
  });
}

backofficeRouter.get('/admin/profile/create', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const profile = await service.getAdminProfile(session.adminAuth.userId);
  if (!profile) {
    ctx.status = 404;
    sendHtml(ctx, renderBackofficeNotFoundPage('admin', ctx.path));
    return;
  }
  sendHtml(ctx, renderAdminProfilePage(profile));
});
backofficeRouter.get('/admin/profile/:id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const profile = await service.getAdminProfile(session.adminAuth.userId);
  if (!profile) {
    ctx.status = 404;
    sendHtml(ctx, renderBackofficeNotFoundPage('admin', ctx.path));
    return;
  }
  sendHtml(ctx, renderAdminProfilePage(profile));
});

backofficeRouter.get('/admin/banner/:id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  // Laravel resource destroy compatibility
  await service.destroyBanner(Number(ctx.params.id ?? 0));
  ctx.status = 303;
  ctx.redirect('/admin/banner');
});

backofficeRouter.get('/admin/withdrawal/:id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const rows = await service.getAdminWithdrawalRows();
  const id = Number(ctx.params.id ?? 0);
  const result = rows.find((row) => Number((row as Record<string, unknown>).id ?? 0) === id) ?? null;
  if (!result) {
    ctx.status = 404;
    sendHtml(ctx, renderBackofficeNotFoundPage('admin', ctx.path));
    return;
  }
  renderAdminTablePage(
    ctx,
    'Withdrawal Detail',
    [result as Record<string, unknown>],
    [
      { header: 'ID', render: (row) => escapeHtml(pickValue(row, ['id'])) },
      { header: 'Data', render: (row) => renderJsonSnapshot(row) },
    ],
    '1 record',
  );
});

backofficeRouter.get('/admin/wallet-transaction/:id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const rows = await service.getAdminWalletTransactions();
  const id = Number(ctx.params.id ?? 0);
  const result = rows.find((row) => Number((row as Record<string, unknown>).id ?? 0) === id) ?? null;
  if (!result) {
    ctx.status = 404;
    sendHtml(ctx, renderBackofficeNotFoundPage('admin', ctx.path));
    return;
  }
  renderAdminTablePage(
    ctx,
    'Wallet Transaction Detail',
    [result as Record<string, unknown>],
    [
      { header: 'ID', render: (row) => escapeHtml(pickValue(row, ['id'])) },
      { header: 'Data', render: (row) => renderJsonSnapshot(row) },
    ],
    '1 record',
  );
});

backofficeRouter.get('/admin/refer-earn/:id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const rows = await service.getAdminReferEarnRows();
  const id = Number(ctx.params.id ?? 0);
  const result = rows.find((row) => Number((row as Record<string, unknown>).id ?? 0) === id) ?? null;
  if (!result) {
    ctx.status = 404;
    sendHtml(ctx, renderBackofficeNotFoundPage('admin', ctx.path));
    return;
  }
  renderAdminTablePage(
    ctx,
    'Refer Earn Detail',
    [result as Record<string, unknown>],
    [
      { header: 'ID', render: (row) => escapeHtml(pickValue(row, ['id'])) },
      { header: 'Data', render: (row) => renderJsonSnapshot(row) },
    ],
    '1 record',
  );
});

backofficeRouter.get('/admin/notificationconfiguration/:id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const rows = await service.getAdminNotificationConfigurationRows();
  const id = Number(ctx.params.id ?? 0);
  const result = rows.find((row) => Number((row as Record<string, unknown>).id ?? 0) === id) ?? null;
  if (!result) {
    ctx.status = 404;
    sendHtml(ctx, renderBackofficeNotFoundPage('admin', ctx.path));
    return;
  }
  renderAdminTablePage(
    ctx,
    'Notification Config Detail',
    [result as Record<string, unknown>],
    [
      { header: 'ID', render: (row) => escapeHtml(pickValue(row, ['id'])) },
      { header: 'Data', render: (row) => renderJsonSnapshot(row) },
    ],
    '1 record',
  );
});

backofficeRouter.get('/admin/admob/create', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  ctx.redirect('/admin/admob?mode=create');
});
backofficeRouter.get('/admin/admob/:id/edit', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const rows = await service.getAdminAdmobRows();
  const id = Number(ctx.params.id ?? 0);
  const result = rows.find((row) => Number((row as Record<string, unknown>).id ?? 0) === id) ?? null;
  if (!result) {
    ctx.status = 404;
    sendHtml(ctx, renderBackofficeNotFoundPage('admin', ctx.path));
    return;
  }
  renderAdminTablePage(
    ctx,
    'Admob Detail',
    [result as Record<string, unknown>],
    [
      { header: 'ID', render: (row) => escapeHtml(pickValue(row, ['id'])) },
      { header: 'Data', render: (row) => renderJsonSnapshot(row) },
    ],
    '1 record',
  );
});
backofficeRouter.get('/admin/admob/:id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const rows = await service.getAdminAdmobRows();
  const id = Number(ctx.params.id ?? 0);
  const result = rows.find((row) => Number((row as Record<string, unknown>).id ?? 0) === id) ?? null;
  if (!result) {
    ctx.status = 404;
    sendHtml(ctx, renderBackofficeNotFoundPage('admin', ctx.path));
    return;
  }
  renderAdminTablePage(
    ctx,
    'Admob Detail',
    [result as Record<string, unknown>],
    [
      { header: 'ID', render: (row) => escapeHtml(pickValue(row, ['id'])) },
      { header: 'Data', render: (row) => renderJsonSnapshot(row) },
    ],
    '1 record',
  );
});

backofficeRouter.post('/admin/producer/content_status', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  const body = parseBody(ctx);
  await service.toggleAdminProducerContentStatus(body);
  ctx.body = { status: 200, success: 'Producer content status changed.' };
});
backofficeRouter.get('/admin/producer/content/:producer_id/:content_type', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const producerId = Number(ctx.params.producer_id ?? 0);
  const contentType = Number(ctx.params.content_type ?? 0);
  ctx.redirect(`/admin/producer?page=1&producer_id=${encodeURIComponent(String(producerId))}&content_type=${encodeURIComponent(String(contentType))}`);
});

backofficeRouter.post('/admin/video/saveChunk', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  const body = parseBody(ctx);
  const result = await service.saveAdminVideoChunk(body);
  ctx.body = { status: 200, success: 'Chunk saved.', result };
});
backofficeRouter.get('/admin/video/delete/:video_id/:type_id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  await service.destroyVideo(Number(ctx.params.video_id ?? 0));
  ctx.status = 303;
  ctx.redirect('/admin/video');
});
backofficeRouter.get('/admin/video/details/:type_id/:id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const id = Number(ctx.params.id ?? 0);
  const video = await service.getAdminVideoDataForFill(id);
  if (!video) {
    ctx.status = 404;
    sendHtml(ctx, renderBackofficeNotFoundPage('admin', ctx.path));
    return;
  }
  renderAdminDetailPage(ctx, 'Video Detail', video as Record<string, unknown>, '/admin/video', 'Back Video');
});
backofficeRouter.post('/admin/video/releases', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  const body = parseBody(ctx);
  const id = Number(body.id ?? body.video_id ?? 0);
  await service.updateAdminVideoCompat(id, {
    type_id: Number(body.type_id ?? 0),
    video_type: Number(body.video_type ?? 1),
    channel_id: Number(body.channel_id ?? 0),
    updated_at: new Date().toISOString().slice(0, 19).replace('T', ' '),
  });
  ctx.body = { status: 200, success: 'Video release updated.' };
});

// Explicit create/edit compatibility routes (for migration parity checks)
const renderCreateCompat = async (ctx: Context, title: string, path: string) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const basePath = path.replace(/\/create$/, '');
  ctx.redirect(`${basePath}?mode=create`);
};
const renderEditCompat = async (ctx: Context, title: string, path: string) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const id = Number(ctx.params.id ?? 0);
  const basePath = path.replace(/\/:id\/edit$/, '');
  ctx.redirect(`${basePath}?edit_id=${encodeURIComponent(String(id))}`);
};

backofficeRouter.get('/admin/type/create', async (ctx: Context) => renderCreateCompat(ctx, 'Type Create', '/admin/type/create'));
backofficeRouter.get('/admin/type/:id/edit', async (ctx: Context) => renderEditCompat(ctx, 'Type Edit', '/admin/type/:id/edit'));
backofficeRouter.get('/admin/category/create', async (ctx: Context) => renderCreateCompat(ctx, 'Category Create', '/admin/category/create'));
backofficeRouter.get('/admin/category/:id/edit', async (ctx: Context) => renderEditCompat(ctx, 'Category Edit', '/admin/category/:id/edit'));
backofficeRouter.get('/admin/language/create', async (ctx: Context) => renderCreateCompat(ctx, 'Language Create', '/admin/language/create'));
backofficeRouter.get('/admin/language/:id/edit', async (ctx: Context) => renderEditCompat(ctx, 'Language Edit', '/admin/language/:id/edit'));
backofficeRouter.get('/admin/season/create', async (ctx: Context) => renderCreateCompat(ctx, 'Season Create', '/admin/season/create'));
backofficeRouter.get('/admin/season/:id/edit', async (ctx: Context) => renderEditCompat(ctx, 'Season Edit', '/admin/season/:id/edit'));
backofficeRouter.get('/admin/avatar/create', async (ctx: Context) => renderCreateCompat(ctx, 'Avatar Create', '/admin/avatar/create'));
backofficeRouter.get('/admin/avatar/:id/edit', async (ctx: Context) => renderEditCompat(ctx, 'Avatar Edit', '/admin/avatar/:id/edit'));
backofficeRouter.get('/admin/channel/create', async (ctx: Context) => renderCreateCompat(ctx, 'Channel Create', '/admin/channel/create'));
backofficeRouter.get('/admin/channel/:id/edit', async (ctx: Context) => renderEditCompat(ctx, 'Channel Edit', '/admin/channel/:id/edit'));
backofficeRouter.get('/admin/banner/create', async (ctx: Context) => renderCreateCompat(ctx, 'Banner Create', '/admin/banner/create'));
backofficeRouter.get('/admin/banner/:id/edit', async (ctx: Context) => renderEditCompat(ctx, 'Banner Edit', '/admin/banner/:id/edit'));
backofficeRouter.get('/admin/cast/create', async (ctx: Context) => renderCreateCompat(ctx, 'Cast Create', '/admin/cast/create'));
backofficeRouter.get('/admin/cast/:id/edit', async (ctx: Context) => renderEditCompat(ctx, 'Cast Edit', '/admin/cast/:id/edit'));
backofficeRouter.get('/admin/user/create', async (ctx: Context) => renderCreateCompat(ctx, 'User Create', '/admin/user/create'));
backofficeRouter.get('/admin/user/:id/edit', async (ctx: Context) => renderEditCompat(ctx, 'User Edit', '/admin/user/:id/edit'));
backofficeRouter.get('/admin/producer/create', async (ctx: Context) => renderCreateCompat(ctx, 'Producer Create', '/admin/producer/create'));
backofficeRouter.get('/admin/producer/:id/edit', async (ctx: Context) => renderEditCompat(ctx, 'Producer Edit', '/admin/producer/:id/edit'));
backofficeRouter.get('/admin/section/create', async (ctx: Context) => renderCreateCompat(ctx, 'Section Create', '/admin/section/create'));
backofficeRouter.get('/admin/section/:id/edit', async (ctx: Context) => renderEditCompat(ctx, 'Section Edit', '/admin/section/:id/edit'));
backofficeRouter.get('/admin/section/:id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
  await service.destroySection(Number(ctx.params.id ?? 0));
  ctx.status = 303;
  ctx.redirect('/admin/section');
});
backofficeRouter.get('/admin/coupon/create', async (ctx: Context) => renderCreateCompat(ctx, 'Coupon Create', '/admin/coupon/create'));
backofficeRouter.get('/admin/coupon/:id/edit', async (ctx: Context) => renderEditCompat(ctx, 'Coupon Edit', '/admin/coupon/:id/edit'));
backofficeRouter.get('/admin/rent-price-list/create', async (ctx: Context) => renderCreateCompat(ctx, 'Rent Price Create', '/admin/rent-price-list/create'));
backofficeRouter.get('/admin/rent-price-list/:id/edit', async (ctx: Context) => renderEditCompat(ctx, 'Rent Price Edit', '/admin/rent-price-list/:id/edit'));
backofficeRouter.get('/admin/rent-transaction/create', async (ctx: Context) => renderCreateCompat(ctx, 'Rent Transaction Create', '/admin/rent-transaction/create'));
backofficeRouter.get('/admin/rent-transaction/:id/edit', async (ctx: Context) => renderEditCompat(ctx, 'Rent Transaction Edit', '/admin/rent-transaction/:id/edit'));
backofficeRouter.get('/admin/package/create', async (ctx: Context) => renderCreateCompat(ctx, 'Package Create', '/admin/package/create'));
backofficeRouter.get('/admin/package/:id/edit', async (ctx: Context) => renderEditCompat(ctx, 'Package Edit', '/admin/package/:id/edit'));
backofficeRouter.get('/admin/transaction/create', async (ctx: Context) => renderCreateCompat(ctx, 'Transaction Create', '/admin/transaction/create'));
backofficeRouter.get('/admin/transaction/:id/edit', async (ctx: Context) => renderEditCompat(ctx, 'Transaction Edit', '/admin/transaction/:id/edit'));
backofficeRouter.get('/admin/page/create', async (ctx: Context) => renderCreateCompat(ctx, 'Page Create', '/admin/page/create'));
backofficeRouter.get('/admin/page/:id/edit', async (ctx: Context) => renderEditCompat(ctx, 'Page Edit', '/admin/page/:id/edit'));
backofficeRouter.get('/admin/notification/create', async (ctx: Context) => renderCreateCompat(ctx, 'Notification Create', '/admin/notification/create'));
backofficeRouter.get('/admin/notification/:id/edit', async (ctx: Context) => renderEditCompat(ctx, 'Notification Edit', '/admin/notification/:id/edit'));
backofficeRouter.get('/admin/notificationconfiguration/create', async (ctx: Context) => renderCreateCompat(ctx, 'Notification Config Create', '/admin/notificationconfiguration/create'));
backofficeRouter.get('/admin/notificationconfiguration/:id/edit', async (ctx: Context) => renderEditCompat(ctx, 'Notification Config Edit', '/admin/notificationconfiguration/:id/edit'));
backofficeRouter.get('/admin/refer-earn/create', async (ctx: Context) => renderCreateCompat(ctx, 'Refer Earn Create', '/admin/refer-earn/create'));
backofficeRouter.get('/admin/refer-earn/:id/edit', async (ctx: Context) => renderEditCompat(ctx, 'Refer Earn Edit', '/admin/refer-earn/:id/edit'));
backofficeRouter.get('/admin/withdrawal/create', async (ctx: Context) => renderCreateCompat(ctx, 'Withdrawal Create', '/admin/withdrawal/create'));
backofficeRouter.get('/admin/withdrawal/:id/edit', async (ctx: Context) => renderEditCompat(ctx, 'Withdrawal Edit', '/admin/withdrawal/:id/edit'));
backofficeRouter.get('/admin/wallet-transaction/create', async (ctx: Context) => renderCreateCompat(ctx, 'Wallet Transaction Create', '/admin/wallet-transaction/create'));
backofficeRouter.get('/admin/wallet-transaction/:id/edit', async (ctx: Context) => renderEditCompat(ctx, 'Wallet Transaction Edit', '/admin/wallet-transaction/:id/edit'));
backofficeRouter.get('/admin/payment/create', async (ctx: Context) => renderCreateCompat(ctx, 'Payment Create', '/admin/payment/create'));
backofficeRouter.get('/admin/profile/:id/edit', async (ctx: Context) => renderEditCompat(ctx, 'Profile Edit', '/admin/profile/:id/edit'));

// Resource-style compatibility endpoints to avoid 404 during migration
const adminPostTableMap: Record<string, string> = {
  '/admin/user': 'tbl_user',
  '/admin/producer': 'tbl_producer',
  '/admin/cast': 'tbl_cast',
  '/admin/coupon': 'tbl_coupon',
  '/admin/rent-price-list': 'tbl_rent_price_list',
  '/admin/package': 'tbl_package',
  '/admin/transaction': 'tbl_transaction',
  '/admin/rent-transaction': 'tbl_rent_transaction',
  '/admin/page': 'tbl_page',
  '/admin/notification': 'tbl_notification',
};
for (const postPath of Object.keys(adminPostTableMap)) {
  backofficeRouter.post(postPath, async (ctx: Context) => {
    const session = getSession(ctx);
    if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
    if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
    const body = parseBody(ctx);
    const table = adminPostTableMap[postPath];
    const id = await service.createAdminResourceCompat(table, body);
    ctx.body = { status: 200, success: 'Created.', id };
  });
}

const adminUpdateTableMap: Record<string, string> = {
  '/admin/user/:id': 'tbl_user',
  '/admin/producer/:id': 'tbl_producer',
  '/admin/cast/:id': 'tbl_cast',
  '/admin/coupon/:id': 'tbl_coupon',
  '/admin/rent-price-list/:id': 'tbl_rent_price_list',
  '/admin/package/:id': 'tbl_package',
  '/admin/transaction/:id': 'tbl_transaction',
  '/admin/rent-transaction/:id': 'tbl_rent_transaction',
  '/admin/page/:id': 'tbl_page',
  '/admin/notification/:id': 'tbl_notification',
};
for (const updatePath of Object.keys(adminUpdateTableMap)) {
  backofficeRouter.post(updatePath, async (ctx: Context) => {
    const session = getSession(ctx);
    if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
    if (isCheckAdminBlocked()) { respondDemoBlocked(ctx); return; }
    const body = parseBody(ctx);
    const table = adminUpdateTableMap[updatePath];
    const id = Number(ctx.params.id ?? 0);
    await service.updateAdminResourceCompat(table, id, body);
    ctx.body = { status: 200, success: 'Updated.' };
  });
}

backofficeRouter.get('/admin/user/:id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const rows = await service.getAdminUsers();
  const id = Number(ctx.params.id ?? 0);
  const result = rows.find((row) => Number((row as Record<string, unknown>).id ?? 0) === id) ?? null;
  if (!result) {
    ctx.status = 404;
    sendHtml(ctx, renderBackofficeNotFoundPage('admin', ctx.path));
    return;
  }
  renderAdminDetailPage(ctx, 'User Detail', result as Record<string, unknown>, '/admin/user', 'Back User');
});
backofficeRouter.get('/admin/producer/:id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const rows = await service.getAdminProducers();
  const id = Number(ctx.params.id ?? 0);
  const result = rows.find((row) => Number((row as Record<string, unknown>).id ?? 0) === id) ?? null;
  if (!result) {
    ctx.status = 404;
    sendHtml(ctx, renderBackofficeNotFoundPage('admin', ctx.path));
    return;
  }
  renderAdminDetailPage(ctx, 'Producer Detail', result as Record<string, unknown>, '/admin/producer', 'Back Producer');
});
backofficeRouter.get('/admin/cast/:id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.adminAuth) { ctx.redirect('/admin/login'); return; }
  const rows = await service.getAdminCasts();
  const id = Number(ctx.params.id ?? 0);
  const result = rows.find((row) => Number((row as Record<string, unknown>).id ?? 0) === id) ?? null;
  if (!result) {
    ctx.status = 404;
    sendHtml(ctx, renderBackofficeNotFoundPage('admin', ctx.path));
    return;
  }
  renderAdminDetailPage(ctx, 'Cast Detail', result as Record<string, unknown>, '/admin/cast', 'Back Cast');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    ctx.body = renderLoginPage('producer', '邮箱和密码不能为空。');
    return;
  }

  const user = await service.loginProducer(email, password);
  if (!user) {
    ctx.status = 400;
    ctx.type = 'html';
    ctx.body = renderLoginPage('producer', '账号或密码错误。');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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

// Producer compatibility GET routes (legacy php style)
backofficeRouter.get('/producer/video/add/:typeId', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) { ctx.redirect('/producer/login'); return; }
  const typeId = Number(ctx.params.typeId ?? 0);
  ctx.redirect(`/producer/video/${encodeURIComponent(String(typeId))}`);
});
backofficeRouter.get('/producer/video/edit/:videoId/:typeId', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) { ctx.redirect('/producer/login'); return; }
  const videoId = Number(ctx.params.videoId ?? 0);
  const typeId = Number(ctx.params.typeId ?? 0);
  ctx.redirect(`/producer/video/${encodeURIComponent(String(typeId))}?edit_video_id=${encodeURIComponent(String(videoId))}`);
});
backofficeRouter.get('/producer/video/details/:id', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) { ctx.redirect('/producer/login'); return; }
  const videoId = Number(ctx.params.id ?? 0);
  const typeId = Number((ctx.query as Record<string, string | undefined>).type_id ?? (ctx.query as Record<string, string | undefined>).typeId ?? 0);
  ctx.redirect(`/producer/video/${encodeURIComponent(String(typeId > 0 ? typeId : 0))}?detail_video_id=${encodeURIComponent(String(videoId))}`);
});
backofficeRouter.get('/producer/tvshow/add/:typeId', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) { ctx.redirect('/producer/login'); return; }
  const typeId = Number(ctx.params.typeId ?? 0);
  ctx.redirect(`/producer/tvshow/${encodeURIComponent(String(typeId))}`);
});
backofficeRouter.get('/producer/tvshow/edit/:tvShowId/:typeId', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) { ctx.redirect('/producer/login'); return; }
  const tvShowId = Number(ctx.params.tvShowId ?? 0);
  const typeId = Number(ctx.params.typeId ?? 0);
  ctx.redirect(`/producer/tvshow/${encodeURIComponent(String(typeId))}?edit_tvshow_id=${encodeURIComponent(String(tvShowId))}`);
});
backofficeRouter.get('/producer/shorts/add/:typeId', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) { ctx.redirect('/producer/login'); return; }
  const typeId = Number(ctx.params.typeId ?? 0);
  ctx.redirect(`/producer/shorts/${encodeURIComponent(String(typeId))}`);
});
backofficeRouter.get('/producer/shorts/edit/:shortsId/:typeId', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) { ctx.redirect('/producer/login'); return; }
  const shortsId = Number(ctx.params.shortsId ?? 0);
  const typeId = Number(ctx.params.typeId ?? 0);
  ctx.redirect(`/producer/shorts/${encodeURIComponent(String(typeId))}?edit_shorts_id=${encodeURIComponent(String(shortsId))}`);
});
backofficeRouter.get('/producer/tvshow-episode/add/:showId/:typeId', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) { ctx.redirect('/producer/login'); return; }
  const showId = Number(ctx.params.showId ?? 0);
  const typeId = Number(ctx.params.typeId ?? 0);
  ctx.redirect(`/producer/tvshow-episode/${encodeURIComponent(String(showId))}/${encodeURIComponent(String(typeId))}`);
});
backofficeRouter.get('/producer/tvshow-episode/edit/:showId/:typeId', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) { ctx.redirect('/producer/login'); return; }
  const showId = Number((ctx.query as Record<string, string | undefined>).show_id ?? ctx.params.showId ?? 0);
  const typeId = Number(ctx.params.typeId ?? 0);
  const episodeId = Number(ctx.params.showId ?? 0);
  ctx.redirect(`/producer/tvshow-episode/${encodeURIComponent(String(showId))}/${encodeURIComponent(String(typeId))}?edit_episode_id=${encodeURIComponent(String(episodeId))}`);
});
backofficeRouter.get('/producer/shorts-episode/add/:showId/:typeId', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) { ctx.redirect('/producer/login'); return; }
  const showId = Number(ctx.params.showId ?? 0);
  const typeId = Number(ctx.params.typeId ?? 0);
  ctx.redirect(`/producer/shorts-episode/${encodeURIComponent(String(showId))}/${encodeURIComponent(String(typeId))}`);
});
backofficeRouter.get('/producer/shorts-episode/edit/:showId/:typeId', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) { ctx.redirect('/producer/login'); return; }
  const showId = Number((ctx.query as Record<string, string | undefined>).show_id ?? ctx.params.showId ?? 0);
  const typeId = Number(ctx.params.typeId ?? 0);
  const episodeId = Number(ctx.params.showId ?? 0);
  ctx.redirect(`/producer/shorts-episode/${encodeURIComponent(String(showId))}/${encodeURIComponent(String(typeId))}?edit_episode_id=${encodeURIComponent(String(episodeId))}`);
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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

backofficeRouter.get('/producer/video/delete/:videoId/:typeId', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  const videoId = Number(ctx.params.videoId ?? 0);
  const typeId = Number(ctx.params.typeId ?? 0);
  if (videoId > 0) {
    await service.deleteProducerVideo(session.producerAuth.userId, videoId);
  }
  ctx.redirect(`/producer/video/${encodeURIComponent(String(typeId > 0 ? typeId : 0))}`);
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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

backofficeRouter.get('/producer/video-status', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  const query = ctx.query as Record<string, string | undefined>;
  const id = Number(query.id ?? 0);
  const typeId = Number(query.type_id ?? query.typeId ?? 0);
  if (id > 0) {
    await service.toggleProducerVideoStatus(session.producerAuth.userId, id);
  }
  ctx.redirect(`/producer/video/${encodeURIComponent(String(typeId > 0 ? typeId : 0))}`);
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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

backofficeRouter.get('/producer/tvshow/show/:tvShowId/:typeId', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  const tvShowId = Number(ctx.params.tvShowId ?? 0);
  const typeId = Number(ctx.params.typeId ?? 0);
  if (tvShowId > 0) {
    await service.deleteProducerTvShow(session.producerAuth.userId, tvShowId);
  }
  ctx.redirect(`/producer/tvshow/${encodeURIComponent(String(typeId > 0 ? typeId : 0))}`);
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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

backofficeRouter.get('/producer/tvshow-status', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  const query = ctx.query as Record<string, string | undefined>;
  const id = Number(query.id ?? 0);
  const typeId = Number(query.type_id ?? query.typeId ?? 0);
  if (id > 0) {
    await service.toggleProducerTvShowStatus(session.producerAuth.userId, id);
  }
  ctx.redirect(`/producer/tvshow/${encodeURIComponent(String(typeId > 0 ? typeId : 0))}`);
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
    ctx.status = 400;
    const payload = await service.getProducerTvShowEpisodesViewPayload(session.producerAuth.userId, showId, typeId, {
      input_search: '',
      input_season: '0',
    });
    ctx.type = 'html';
    ctx.body = renderProducerTvShowEpisodePage(payload, message);
  }
});

backofficeRouter.get('/producer/tvshow-episode/delete/:showId/:episodeId/:typeId', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  const showId = Number(ctx.params.showId ?? 0);
  const episodeId = Number(ctx.params.episodeId ?? 0);
  const typeId = Number(ctx.params.typeId ?? 0);
  if (showId > 0 && episodeId > 0) {
    await service.deleteProducerTvShowEpisode(session.producerAuth.userId, showId, episodeId);
  }
  ctx.redirect(`/producer/tvshow-episode/${encodeURIComponent(String(showId))}/${encodeURIComponent(String(typeId > 0 ? typeId : 0))}`);
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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

backofficeRouter.get('/producer/shorts/show/:shortsId/:typeId', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  const shortsId = Number(ctx.params.shortsId ?? 0);
  const typeId = Number(ctx.params.typeId ?? 0);
  if (shortsId > 0) {
    await service.deleteProducerShorts(session.producerAuth.userId, shortsId);
  }
  ctx.redirect(`/producer/shorts/${encodeURIComponent(String(typeId > 0 ? typeId : 0))}`);
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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

backofficeRouter.get('/producer/shorts/status', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  const query = ctx.query as Record<string, string | undefined>;
  const id = Number(query.id ?? 0);
  const typeId = Number(query.type_id ?? query.typeId ?? 0);
  if (id > 0) {
    await service.toggleProducerShortsStatus(session.producerAuth.userId, id);
  }
  ctx.redirect(`/producer/shorts/${encodeURIComponent(String(typeId > 0 ? typeId : 0))}`);
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
    ctx.status = 400;
    const payload = await service.getProducerShortsEpisodesViewPayload(session.producerAuth.userId, showId, typeId, {
      input_search: '',
      input_season: '0',
    });
    ctx.type = 'html';
    ctx.body = renderProducerShortsEpisodePage(payload, message);
  }
});

backofficeRouter.get('/producer/shorts-episode/delete/:showId/:episodeId/:typeId', async (ctx: Context) => {
  const session = getSession(ctx);
  if (!session.producerAuth) {
    ctx.redirect('/producer/login');
    return;
  }

  const showId = Number(ctx.params.showId ?? 0);
  const episodeId = Number(ctx.params.episodeId ?? 0);
  const typeId = Number(ctx.params.typeId ?? 0);
  if (showId > 0 && episodeId > 0) {
    await service.deleteProducerShortsEpisode(session.producerAuth.userId, showId, episodeId);
  }
  ctx.redirect(`/producer/shorts-episode/${encodeURIComponent(String(showId))}/${encodeURIComponent(String(typeId > 0 ? typeId : 0))}`);
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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
    const message = getRouteErrorMessage(error, 'Operation failed, please try again later.');
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


