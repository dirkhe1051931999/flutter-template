import type { RowDataPacket } from 'mysql2';
import { dbPool } from '../../config/database';

type Row = RowDataPacket & Record<string, unknown>;

export type AdminUser = {
  id: number;
  user_name: string;
  email: string;
  password: string;
  status: number;
};

export type AvatarItem = {
  id: number;
  name: string;
  storage_type: number;
  image: string;
  sort_order: number;
  status: number;
};

export type ChannelItem = {
  id: number;
  name: string;
  storage_type: number;
  portrait_img: string;
  landscape_img: string;
  is_title: number;
  status: number;
};

export type ProducerUser = {
  id: number;
  user_name: string;
  full_name: string;
  email: string;
  mobile_number?: string;
  password: string;
  status: number;
};

export type AdminDashboardStats = {
  users: number;
  videos: number;
  tvShows: number;
  channels: number;
  casts: number;
  producers: number;
  packages: number;
  shorts: number;
  totalWithdrawal: number;
};

export type ProducerDashboardStats = {
  videos: number;
  tvShows: number;
  shorts: number;
  totalWithdrawal: number;
  wallet: number;
};

export type ProducerDashboardTypeLinks = {
  videoTypeId: number | null;
  tvShowTypeId: number | null;
  shortsTypeId: number | null;
};

export type ProducerWithdrawalSetup = {
  wallet: number;
  minWithdrawalAmount: number;
  currencyCode: string;
};

export type ProducerWithdrawalItem = {
  id: number;
  price: number;
  status: number;
  createdAt: string;
};

export type AdminVideoItem = {
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
};

export type AdminShortsItem = {
  id: number;
  type_id: number;
  video_type: number;
  producer_id: number;
  name: string;
  thumbnail: string;
  total_view: number;
  status: number;
  created_at: string;
};

export type AdminTvShowItem = {
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
};

export type ProducerVideoItem = {
  id: number;
  type_id: number;
  video_type: number;
  channel_id: number;
  name: string;
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
  total_view: number;
  status: number;
  video_upload_type: string;
  video_320: string;
  video_480: string;
  video_720: string;
  video_1080: string;
  video_storage_type: number;
  trailer_type: string;
  trailer_url: string;
  subtitle_type: string;
  subtitle_1: string;
  subtitle_2: string;
  subtitle_3: string;
  subtitle_lang_1: string;
  subtitle_lang_2: string;
  subtitle_lang_3: string;
  category_id: string;
  language_id: string;
  cast_id: string;
  release_date: string;
};

export type ProducerVideoDetail = {
  id: number;
  type_id: number;
  video_type: number;
  channel_id: number;
  category_id: string;
  language_id: string;
  cast_id: string;
  name: string;
  thumbnail: string;
  landscape: string;
  description: string;
  release_date: string;
  is_premium: number;
  is_title: number;
  is_download: number;
  is_comment: number;
  is_like: number;
  is_rent: number;
  price: number;
  rent_day: number;
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
};

export type ProducerTvShowItem = {
  id: number;
  type_id: number;
  video_type: number;
  channel_id: number;
  category_id: string;
  language_id: string;
  cast_id: string;
  name: string;
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
  total_view: number;
  status: number;
  release_date: string;
};

export type ProducerTvShowDetail = {
  id: number;
  type_id: number;
  video_type: number;
  channel_id: number;
  category_id: string;
  language_id: string;
  cast_id: string;
  name: string;
  thumbnail: string;
  landscape: string;
  trailer_type: string;
  trailer_url: string;
  description: string;
  release_date: string;
  is_title: number;
  is_comment: number;
  is_like: number;
  is_rent: number;
  price: number;
  rent_day: number;
};

export type ProducerTvShowEpisodeItem = {
  id: number;
  show_id: number;
  season_id: number;
  season_name: string;
  name: string;
  thumbnail: string;
  landscape: string;
  description: string;
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
  video_storage_type: number;
  is_premium: number;
  is_title: number;
  is_download: number;
  total_view: number;
  status: number;
  sort_order: number;
};

export type ProducerTvShowEpisodeDetail = {
  id: number;
  show_id: number;
  season_id: number;
  name: string;
  thumbnail: string;
  landscape: string;
  description: string;
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
  is_premium: number;
  is_title: number;
  is_download: number;
};

export type ProducerShortsItem = {
  id: number;
  type_id: number;
  video_type: number;
  channel_id: number;
  category_id: string;
  language_id: string;
  cast_id: string;
  name: string;
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
  total_view: number;
  status: number;
  release_date: string;
};

export type ProducerShortsDetail = {
  id: number;
  type_id: number;
  video_type: number;
  channel_id: number;
  category_id: string;
  language_id: string;
  cast_id: string;
  name: string;
  thumbnail: string;
  landscape: string;
  trailer_type: string;
  trailer_url: string;
  description: string;
  release_date: string;
  is_title: number;
  is_comment: number;
  is_like: number;
  is_rent: number;
  price: number;
  rent_day: number;
};

export type ProducerShortsEpisodeItem = {
  id: number;
  show_id: number;
  season_id: number;
  season_name: string;
  name: string;
  thumbnail: string;
  landscape: string;
  description: string;
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
  video_storage_type: number;
  is_premium: number;
  is_title: number;
  is_download: number;
  total_view: number;
  status: number;
  sort_order: number;
};

export type ProducerShortsEpisodeDetail = {
  id: number;
  show_id: number;
  season_id: number;
  name: string;
  thumbnail: string;
  landscape: string;
  description: string;
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
  is_premium: number;
  is_title: number;
  is_download: number;
};

export type TypeItem = {
  id: number;
  name: string;
  type: number;
  storage_type: number;
  icon: string;
  sort_order: number;
  status: number;
};

export type SeasonItem = {
  id: number;
  name: string;
  sort_order: number;
  status: number;
};

export type ProducerRentSummary = {
  totalCommission: number;
  totalProducerEarning: number;
};

export type ProducerRentTransactionItem = {
  id: number;
  transactionId: string;
  userName: string;
  userContact: string;
  videoName: string;
  paymentType: number;
  transactionStatus: number;
  price: number;
  commission: number;
  producerEarning: number;
  expiryDate: string;
  status: number;
  createdAt: string;
};

export type CategoryItem = {
  id: number;
  name: string;
  storage_type: number;
  image: string;
  sort_order: number;
  status: number;
};

export type LanguageItem = {
  id: number;
  name: string;
  storage_type: number;
  image: string;
  sort_order: number;
  status: number;
};

async function getCount(query: string, params: unknown[] = []): Promise<number> {
  const [rows] = await dbPool.query<Row[]>(query, params);
  return Number(rows[0]?.total ?? 0);
}

export class BackofficeRepository {
  async getGeneralSettingValue(key: string): Promise<string> {
    const [rows] = await dbPool.query<Row[]>('SELECT value FROM tbl_general_setting WHERE `key` = ? LIMIT 1', [key]);
    return String(rows[0]?.value ?? '');
  }

  async expireRentTransactions(): Promise<void> {
    await dbPool.query('UPDATE tbl_rent_transaction SET status = 0, updated_at = NOW() WHERE status = 1 AND expiry_date <= NOW()');
  }

  async getAdminByEmail(email: string): Promise<AdminUser | null> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT id, user_name, email, password, status FROM tbl_admin WHERE email = ? LIMIT 1',
      [email],
    );

    if (rows.length === 0) {
      return null;
    }

    const row = rows[0];
    return {
      id: Number(row.id ?? 0),
      user_name: String(row.user_name ?? ''),
      email: String(row.email ?? ''),
      password: String(row.password ?? ''),
      status: Number(row.status ?? 0),
    };
  }

  async getProducerByEmail(email: string): Promise<ProducerUser | null> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT id, user_name, full_name, email, mobile_number, password, status FROM tbl_producer WHERE email = ? LIMIT 1',
      [email],
    );

    if (rows.length === 0) {
      return null;
    }

    const row = rows[0];
    return {
      id: Number(row.id ?? 0),
      user_name: String(row.user_name ?? ''),
      full_name: String(row.full_name ?? ''),
      email: String(row.email ?? ''),
      mobile_number: String(row.mobile_number ?? ''),
      password: String(row.password ?? ''),
      status: Number(row.status ?? 0),
    };
  }

  async getAdminById(id: number): Promise<AdminUser | null> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT id, user_name, email, password, status FROM tbl_admin WHERE id = ? LIMIT 1',
      [id],
    );

    if (rows.length === 0) {
      return null;
    }

    const row = rows[0];
    return {
      id: Number(row.id ?? 0),
      user_name: String(row.user_name ?? ''),
      email: String(row.email ?? ''),
      password: String(row.password ?? ''),
      status: Number(row.status ?? 0),
    };
  }

  async getProducerById(id: number): Promise<ProducerUser | null> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT id, user_name, full_name, email, mobile_number, password, status FROM tbl_producer WHERE id = ? LIMIT 1',
      [id],
    );

    if (rows.length === 0) {
      return null;
    }

    const row = rows[0];
    return {
      id: Number(row.id ?? 0),
      user_name: String(row.user_name ?? ''),
      full_name: String(row.full_name ?? ''),
      email: String(row.email ?? ''),
      mobile_number: String(row.mobile_number ?? ''),
      password: String(row.password ?? ''),
      status: Number(row.status ?? 0),
    };
  }

  async getAdminSeasons(): Promise<SeasonItem[]> {
    const [rows] = await dbPool.query<Row[]>('SELECT id, name, sort_order, status FROM tbl_season ORDER BY sort_order ASC, id DESC');
    return rows.map((row) => ({
      id: Number(row.id ?? 0),
      name: String(row.name ?? ''),
      sort_order: Number(row.sort_order ?? 0),
      status: Number(row.status ?? 0),
    }));
  }

  async createAdminSeason(name: string): Promise<void> {
    await dbPool.query(
      `INSERT INTO tbl_season
      (name, sort_order, status, created_at, updated_at)
      VALUES (?, 0, 1, NOW(), NOW())`,
      [name],
    );
  }

  async updateAdminSeason(id: number, name: string): Promise<void> {
    await dbPool.query('UPDATE tbl_season SET name = ?, updated_at = NOW() WHERE id = ?', [name, id]);
  }

  async saveAdminSeasonSortOrder(ids: number[]): Promise<void> {
    for (let index = 0; index < ids.length; index += 1) {
      await dbPool.query('UPDATE tbl_season SET sort_order = ?, updated_at = NOW() WHERE id = ?', [index + 1, ids[index]]);
    }
  }

  async updateAdminProfile(id: number, userName: string, email: string): Promise<void> {
    await dbPool.query('UPDATE tbl_admin SET user_name = ?, email = ?, updated_at = NOW() WHERE id = ?', [userName, email, id]);
  }

  async updateProducerProfile(id: number, userName: string, fullName: string, email: string, mobileNumber: string): Promise<void> {
    await dbPool.query(
      'UPDATE tbl_producer SET user_name = ?, full_name = ?, email = ?, mobile_number = ?, updated_at = NOW() WHERE id = ?',
      [userName, fullName, email, mobileNumber, id],
    );
  }

  async updateAdminPassword(id: number, hashedPassword: string): Promise<void> {
    await dbPool.query('UPDATE tbl_admin SET password = ?, updated_at = NOW() WHERE id = ?', [hashedPassword, id]);
  }

  async updateProducerPassword(id: number, hashedPassword: string): Promise<void> {
    await dbPool.query('UPDATE tbl_producer SET password = ?, updated_at = NOW() WHERE id = ?', [hashedPassword, id]);
  }

  async existsProducerUserName(userName: string, exceptId: number): Promise<boolean> {
    const [rows] = await dbPool.query<Row[]>('SELECT id FROM tbl_producer WHERE user_name = ? AND id <> ? LIMIT 1', [userName, exceptId]);
    return rows.length > 0;
  }

  async existsProducerEmail(email: string, exceptId: number): Promise<boolean> {
    const [rows] = await dbPool.query<Row[]>('SELECT id FROM tbl_producer WHERE email = ? AND id <> ? LIMIT 1', [email, exceptId]);
    return rows.length > 0;
  }

  async existsProducerMobile(mobileNumber: string, exceptId: number): Promise<boolean> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT id FROM tbl_producer WHERE mobile_number = ? AND id <> ? LIMIT 1',
      [mobileNumber, exceptId],
    );
    return rows.length > 0;
  }

  async getAdminDashboardStats(): Promise<AdminDashboardStats> {
    const [
      users,
      videos,
      tvShows,
      channels,
      casts,
      producers,
      packages,
      shorts,
      totalWithdrawal,
    ] = await Promise.all([
      getCount('SELECT COUNT(*) AS total FROM tbl_user'),
      getCount('SELECT COUNT(*) AS total FROM tbl_video'),
      getCount('SELECT COUNT(*) AS total FROM tbl_tv_show'),
      getCount('SELECT COUNT(*) AS total FROM tbl_channel'),
      getCount('SELECT COUNT(*) AS total FROM tbl_cast'),
      getCount('SELECT COUNT(*) AS total FROM tbl_producer'),
      getCount('SELECT COUNT(*) AS total FROM tbl_package'),
      getCount('SELECT COUNT(*) AS total FROM tbl_shorts'),
      getCount('SELECT COALESCE(SUM(price), 0) AS total FROM tbl_withdrawal_request WHERE status = 1'),
    ]);

    return {
      users,
      videos,
      tvShows,
      channels,
      casts,
      producers,
      packages,
      shorts,
      totalWithdrawal,
    };
  }

  async getProducerDashboardStats(producerId: number): Promise<ProducerDashboardStats> {
    const [videos, tvShows, shorts, totalWithdrawal, walletRows] = await Promise.all([
      getCount('SELECT COUNT(*) AS total FROM tbl_video WHERE producer_id = ?', [producerId]),
      getCount('SELECT COUNT(*) AS total FROM tbl_tv_show WHERE producer_id = ?', [producerId]),
      getCount('SELECT COUNT(*) AS total FROM tbl_shorts WHERE producer_id = ?', [producerId]),
      getCount('SELECT COALESCE(SUM(price), 0) AS total FROM tbl_withdrawal_request WHERE producer_id = ? AND status = 1', [producerId]),
      dbPool.query<Row[]>('SELECT wallet FROM tbl_producer WHERE id = ? LIMIT 1', [producerId]),
    ]);

    const wallet = Number(walletRows[0][0]?.wallet ?? 0);

    return {
      videos,
      tvShows,
      shorts,
      totalWithdrawal,
      wallet,
    };
  }

  async getProducerDashboardTypeLinks(): Promise<ProducerDashboardTypeLinks> {
    const [rows] = await dbPool.query<Row[]>('SELECT id, type FROM tbl_type WHERE type IN (1, 2, 8) AND status = 1 ORDER BY id ASC');

    let videoTypeId: number | null = null;
    let tvShowTypeId: number | null = null;
    let shortsTypeId: number | null = null;

    for (const row of rows) {
      const id = Number(row.id ?? 0);
      const type = Number(row.type ?? 0);
      if (id <= 0) {
        continue;
      }

      if (type === 1 && videoTypeId === null) {
        videoTypeId = id;
      }
      if (type === 2 && tvShowTypeId === null) {
        tvShowTypeId = id;
      }
      if (type === 8 && shortsTypeId === null) {
        shortsTypeId = id;
      }
    }

    return {
      videoTypeId,
      tvShowTypeId,
      shortsTypeId,
    };
  }

  async getAdminCategories(): Promise<CategoryItem[]> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT id, name, storage_type, image, sort_order, status FROM tbl_category ORDER BY status DESC, sort_order ASC, id DESC',
    );

    return rows.map((row) => ({
      id: Number(row.id ?? 0),
      name: String(row.name ?? ''),
      storage_type: Number(row.storage_type ?? 1),
      image: String(row.image ?? ''),
      sort_order: Number(row.sort_order ?? 0),
      status: Number(row.status ?? 0),
    }));
  }

  async getAdminTypes(): Promise<TypeItem[]> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT id, name, type, storage_type, icon, sort_order, status FROM tbl_type ORDER BY status DESC, sort_order ASC, id DESC',
    );

    return rows.map((row) => ({
      id: Number(row.id ?? 0),
      name: String(row.name ?? ''),
      type: Number(row.type ?? 0),
      storage_type: Number(row.storage_type ?? 1),
      icon: String(row.icon ?? ''),
      sort_order: Number(row.sort_order ?? 0),
      status: Number(row.status ?? 0),
    }));
  }

  async createAdminType(name: string, type: number, icon: string): Promise<void> {
    await dbPool.query(
      `INSERT INTO tbl_type
      (name, type, storage_type, icon, sort_order, status, created_at, updated_at)
      VALUES (?, ?, 1, ?, 0, 1, NOW(), NOW())`,
      [name, type, icon],
    );
  }

  async updateAdminType(id: number, name: string, type: number, icon: string): Promise<void> {
    await dbPool.query(
      'UPDATE tbl_type SET name = ?, type = ?, icon = ?, updated_at = NOW() WHERE id = ?',
      [name, type, icon, id],
    );
  }

  async toggleAdminTypeStatus(id: number): Promise<boolean> {
    const [rows] = await dbPool.query<Row[]>('SELECT status FROM tbl_type WHERE id = ? LIMIT 1', [id]);
    if (rows.length === 0) {
      return false;
    }

    const current = Number(rows[0].status ?? 0);
    const next = current === 1 ? 0 : 1;
    await dbPool.query('UPDATE tbl_type SET status = ?, updated_at = NOW() WHERE id = ?', [next, id]);
    return true;
  }

  async saveAdminTypeSortOrder(ids: number[]): Promise<void> {
    for (let index = 0; index < ids.length; index += 1) {
      await dbPool.query('UPDATE tbl_type SET sort_order = ?, updated_at = NOW() WHERE id = ?', [index + 1, ids[index]]);
    }
  }

  async getAdminAvatars(): Promise<AvatarItem[]> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT id, name, storage_type, image, sort_order, status FROM tbl_avatar ORDER BY status DESC, sort_order ASC, id DESC',
    );

    return rows.map((row) => ({
      id: Number(row.id ?? 0),
      name: String(row.name ?? ''),
      storage_type: Number(row.storage_type ?? 1),
      image: String(row.image ?? ''),
      sort_order: Number(row.sort_order ?? 0),
      status: Number(row.status ?? 0),
    }));
  }

  async createAdminAvatar(name: string, image: string): Promise<void> {
    await dbPool.query(
      `INSERT INTO tbl_avatar
      (name, storage_type, image, sort_order, status, created_at, updated_at)
      VALUES (?, 1, ?, 0, 1, NOW(), NOW())`,
      [name, image],
    );
  }

  async updateAdminAvatar(id: number, name: string, image: string): Promise<void> {
    await dbPool.query(
      'UPDATE tbl_avatar SET name = ?, image = ?, updated_at = NOW() WHERE id = ?',
      [name, image, id],
    );
  }

  async toggleAdminAvatarStatus(id: number): Promise<boolean> {
    const [rows] = await dbPool.query<Row[]>('SELECT status FROM tbl_avatar WHERE id = ? LIMIT 1', [id]);
    if (rows.length === 0) {
      return false;
    }

    const current = Number(rows[0].status ?? 0);
    const next = current === 1 ? 0 : 1;
    await dbPool.query('UPDATE tbl_avatar SET status = ?, updated_at = NOW() WHERE id = ?', [next, id]);
    return true;
  }

  async saveAdminAvatarSortOrder(ids: number[]): Promise<void> {
    for (let index = 0; index < ids.length; index += 1) {
      await dbPool.query('UPDATE tbl_avatar SET sort_order = ?, updated_at = NOW() WHERE id = ?', [index + 1, ids[index]]);
    }
  }

  async getAdminChannels(): Promise<ChannelItem[]> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT id, name, storage_type, portrait_img, landscape_img, is_title, status FROM tbl_channel ORDER BY status DESC, id DESC',
    );

    return rows.map((row) => ({
      id: Number(row.id ?? 0),
      name: String(row.name ?? ''),
      storage_type: Number(row.storage_type ?? 1),
      portrait_img: String(row.portrait_img ?? ''),
      landscape_img: String(row.landscape_img ?? ''),
      is_title: Number(row.is_title ?? 0),
      status: Number(row.status ?? 0),
    }));
  }

  async getProducerChannels(inputSearch: string): Promise<ChannelItem[]> {
    const params: unknown[] = [];
    let query = 'SELECT id, name, storage_type, portrait_img, landscape_img, is_title, status FROM tbl_channel WHERE status = 1';

    if (inputSearch.trim()) {
      query += ' AND name LIKE ?';
      params.push(`%${inputSearch.trim()}%`);
    }

    query += ' ORDER BY id DESC';

    const [rows] = await dbPool.query<Row[]>(query, params);
    return rows.map((row) => ({
      id: Number(row.id ?? 0),
      name: String(row.name ?? ''),
      storage_type: Number(row.storage_type ?? 1),
      portrait_img: String(row.portrait_img ?? ''),
      landscape_img: String(row.landscape_img ?? ''),
      is_title: Number(row.is_title ?? 0),
      status: Number(row.status ?? 0),
    }));
  }

  async getProducerReleasesTypes(): Promise<Array<{ id: number; name: string; type: number }>> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT id, name, type FROM tbl_type WHERE type IN (1, 6, 7) AND status = 1 ORDER BY id DESC',
    );

    return rows.map((row) => ({
      id: Number(row.id ?? 0),
      name: String(row.name ?? ''),
      type: Number(row.type ?? 0),
    }));
  }

  async getProducerTvShows(
    producerId: number,
    typeId: number,
    inputSearch: string,
    inputRent: string,
    inputStatus: string,
  ): Promise<ProducerTvShowItem[]> {
    const params: unknown[] = [producerId, typeId];
    let where = 'WHERE producer_id = ? AND type_id = ?';

    if (inputSearch.trim()) {
      where += ' AND name LIKE ?';
      params.push(`%${inputSearch.trim()}%`);
    }
    if (inputRent === '1') {
      where += ' AND is_rent = 1';
    }
    if (inputStatus === '0' || inputStatus === '1') {
      where += ' AND status = ?';
      params.push(Number(inputStatus));
    }

    const [rows] = await dbPool.query<Row[]>(
      `SELECT
         id, type_id, video_type, channel_id, category_id, language_id, cast_id,
         name, thumbnail, landscape, trailer_type, trailer_url, description,
         is_title, is_comment, is_like, is_rent, price, rent_day,
         total_view, status, release_date
       FROM tbl_tv_show
       ${where}
       ORDER BY status DESC, id DESC`,
      params,
    );

    return rows.map((row) => ({
      id: Number(row.id ?? 0),
      type_id: Number(row.type_id ?? 0),
      video_type: Number(row.video_type ?? 0),
      channel_id: Number(row.channel_id ?? 0),
      category_id: String(row.category_id ?? ''),
      language_id: String(row.language_id ?? ''),
      cast_id: String(row.cast_id ?? ''),
      name: String(row.name ?? ''),
      thumbnail: String(row.thumbnail ?? ''),
      landscape: String(row.landscape ?? ''),
      trailer_type: String(row.trailer_type ?? ''),
      trailer_url: String(row.trailer_url ?? ''),
      description: String(row.description ?? ''),
      is_title: Number(row.is_title ?? 0),
      is_comment: Number(row.is_comment ?? 0),
      is_like: Number(row.is_like ?? 0),
      is_rent: Number(row.is_rent ?? 0),
      price: Number(row.price ?? 0),
      rent_day: Number(row.rent_day ?? 0),
      total_view: Number(row.total_view ?? 0),
      status: Number(row.status ?? 0),
      release_date: String(row.release_date ?? ''),
    }));
  }

  async getProducerTvShowById(tvShowId: number, producerId: number): Promise<ProducerTvShowDetail | null> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT
         id, type_id, video_type, channel_id, category_id, language_id, cast_id,
         name, thumbnail, landscape, trailer_type, trailer_url, description,
         release_date, is_title, is_comment, is_like, is_rent, price, rent_day
       FROM tbl_tv_show
       WHERE id = ? AND producer_id = ? LIMIT 1`,
      [tvShowId, producerId],
    );

    if (rows.length === 0) {
      return null;
    }

    const row = rows[0];
    return {
      id: Number(row.id ?? 0),
      type_id: Number(row.type_id ?? 0),
      video_type: Number(row.video_type ?? 0),
      channel_id: Number(row.channel_id ?? 0),
      category_id: String(row.category_id ?? ''),
      language_id: String(row.language_id ?? ''),
      cast_id: String(row.cast_id ?? ''),
      name: String(row.name ?? ''),
      thumbnail: String(row.thumbnail ?? ''),
      landscape: String(row.landscape ?? ''),
      trailer_type: String(row.trailer_type ?? ''),
      trailer_url: String(row.trailer_url ?? ''),
      description: String(row.description ?? ''),
      release_date: String(row.release_date ?? ''),
      is_title: Number(row.is_title ?? 0),
      is_comment: Number(row.is_comment ?? 0),
      is_like: Number(row.is_like ?? 0),
      is_rent: Number(row.is_rent ?? 0),
      price: Number(row.price ?? 0),
      rent_day: Number(row.rent_day ?? 0),
    };
  }

  async createProducerTvShow(producerId: number, payload: ProducerTvShowDetail): Promise<void> {
    await dbPool.query(
      `INSERT INTO tbl_tv_show
      (
        type_id, video_type, channel_id, producer_id, category_id, language_id, cast_id,
        name, storage_type, thumbnail, landscape, trailer_storage_type, trailer_type, trailer_url,
        description, release_date, is_title, is_comment, is_like, is_rent, price, rent_day,
        total_view, total_like, status, created_at, updated_at
      )
      VALUES
      (?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?, 1, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0, 0, 1, NOW(), NOW())`,
      [
        payload.type_id,
        payload.video_type,
        payload.channel_id,
        producerId,
        payload.category_id,
        payload.language_id,
        payload.cast_id,
        payload.name,
        payload.thumbnail,
        payload.landscape,
        payload.trailer_type,
        payload.trailer_url,
        payload.description,
        payload.release_date,
        payload.is_title,
        payload.is_comment,
        payload.is_like,
        payload.is_rent,
        payload.price,
        payload.rent_day,
      ],
    );
  }

  async updateProducerTvShow(tvShowId: number, producerId: number, payload: ProducerTvShowDetail): Promise<boolean> {
    const [result] = await dbPool.query(
      `UPDATE tbl_tv_show
       SET
         type_id = ?, video_type = ?, channel_id = ?, category_id = ?, language_id = ?, cast_id = ?,
         name = ?, thumbnail = ?, landscape = ?, trailer_type = ?, trailer_url = ?, description = ?,
         release_date = ?, is_title = ?, is_comment = ?, is_like = ?, is_rent = ?, price = ?,
         rent_day = ?, updated_at = NOW()
       WHERE id = ? AND producer_id = ?`,
      [
        payload.type_id,
        payload.video_type,
        payload.channel_id,
        payload.category_id,
        payload.language_id,
        payload.cast_id,
        payload.name,
        payload.thumbnail,
        payload.landscape,
        payload.trailer_type,
        payload.trailer_url,
        payload.description,
        payload.release_date,
        payload.is_title,
        payload.is_comment,
        payload.is_like,
        payload.is_rent,
        payload.price,
        payload.rent_day,
        tvShowId,
        producerId,
      ],
    ) as Array<{ affectedRows?: number }>;

    return Number(result?.affectedRows ?? 0) > 0;
  }

  async doesProducerTvShowEpisodeBelongToShow(producerId: number, episodeId: number, showId: number): Promise<boolean> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT e.id
       FROM tbl_tv_show_video e
       INNER JOIN tbl_tv_show t ON t.id = e.show_id
       WHERE e.id = ? AND e.show_id = ? AND t.producer_id = ? LIMIT 1`,
      [episodeId, showId, producerId],
    );

    return rows.length > 0;
  }

  async toggleProducerTvShowStatus(tvShowId: number, producerId: number): Promise<boolean> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT status FROM tbl_tv_show WHERE id = ? AND producer_id = ? LIMIT 1',
      [tvShowId, producerId],
    );
    if (rows.length === 0) {
      return false;
    }

    const current = Number(rows[0].status ?? 0);
    const next = current === 1 ? 0 : 1;
    await dbPool.query('UPDATE tbl_tv_show SET status = ?, updated_at = NOW() WHERE id = ? AND producer_id = ?', [next, tvShowId, producerId]);
    return true;
  }

  async releaseProducerTvShow(tvShowId: number, producerId: number, targetTypeId: number, targetVideoType: number, channelId: number): Promise<boolean> {
    const [result] = await dbPool.query(
      'UPDATE tbl_tv_show SET type_id = ?, video_type = ?, channel_id = ?, updated_at = NOW() WHERE id = ? AND producer_id = ?',
      [targetTypeId, targetVideoType, channelId, tvShowId, producerId],
    ) as Array<{ affectedRows?: number }>;

    return Number(result?.affectedRows ?? 0) > 0;
  }

  async deleteProducerTvShow(tvShowId: number, producerId: number): Promise<boolean> {
    const connection = await dbPool.getConnection();
    try {
      await connection.beginTransaction();
      const [rows] = await connection.query<Row[]>('SELECT id, video_type FROM tbl_tv_show WHERE id = ? AND producer_id = ? LIMIT 1', [tvShowId, producerId]);
      if (rows.length === 0) {
        await connection.rollback();
        return false;
      }

      const videoType = Number(rows[0].video_type ?? 0);
      await connection.query('DELETE FROM tbl_tv_show_video WHERE show_id = ?', [tvShowId]);
      await connection.query('DELETE FROM tbl_tv_show WHERE id = ? AND producer_id = ?', [tvShowId, producerId]);
      await connection.query('DELETE FROM tbl_bookmark WHERE video_type = ? AND video_id = ?', [videoType, tvShowId]);
      await connection.query('DELETE FROM tbl_comment WHERE video_type = ? AND video_id = ?', [videoType, tvShowId]);
      await connection.query('DELETE FROM tbl_like WHERE video_type = ? AND video_id = ?', [videoType, tvShowId]);
      await connection.query('DELETE FROM tbl_review WHERE video_type = ? AND video_id = ?', [videoType, tvShowId]);
      await connection.query('DELETE FROM tbl_video_watch WHERE video_type = ? AND video_id = ?', [videoType, tvShowId]);
      await connection.query('DELETE FROM tbl_view WHERE video_type = ? AND video_id = ?', [videoType, tvShowId]);
      await connection.commit();
      return true;
    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
  }

  async searchProducerTvShowNames(producerId: number, txtVal: string): Promise<Array<{ id: number; name: string }>> {
    const keyword = `%${txtVal.trim()}%`;
    const [rows] = await dbPool.query<Row[]>(
      'SELECT id, name FROM tbl_tv_show WHERE producer_id = ? AND name LIKE ? ORDER BY id DESC LIMIT 20',
      [producerId, keyword],
    );

    return rows.map((row) => ({
      id: Number(row.id ?? 0),
      name: String(row.name ?? ''),
    }));
  }

  async getProducerTvShowDataForFill(producerId: number, tvShowId: number): Promise<Row | null> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT
         id, name, description, release_date, thumbnail, landscape, category_id,
         language_id, cast_id
       FROM tbl_tv_show
       WHERE id = ? AND producer_id = ? LIMIT 1`,
      [tvShowId, producerId],
    );

    return rows[0] ?? null;
  }

  async getProducerSeasons(): Promise<Array<{ id: number; name: string }>> {
    const [rows] = await dbPool.query<Row[]>('SELECT id, name FROM tbl_season ORDER BY sort_order ASC, id ASC');
    return rows.map((row) => ({
      id: Number(row.id ?? 0),
      name: String(row.name ?? ''),
    }));
  }

  async getProducerTvShowEpisodes(producerId: number, showId: number, inputSearch: string, inputSeason: string): Promise<ProducerTvShowEpisodeItem[]> {
    const params: unknown[] = [producerId, showId];
    let where = 'WHERE t.producer_id = ? AND e.show_id = ?';

    if (inputSearch.trim()) {
      where += ' AND e.name LIKE ?';
      params.push(`%${inputSearch.trim()}%`);
    }
    if (inputSeason !== '0') {
      const seasonId = Number(inputSeason);
      if (Number.isFinite(seasonId) && seasonId > 0) {
        where += ' AND e.season_id = ?';
        params.push(seasonId);
      }
    }

    const [rows] = await dbPool.query<Row[]>(
      `SELECT
         e.id, e.show_id, e.season_id, e.name, e.thumbnail, e.landscape, e.description,
         e.video_upload_type, e.video_320, e.video_480, e.video_720, e.video_1080, e.video_storage_type,
         e.subtitle_type, e.subtitle_1, e.subtitle_2, e.subtitle_3,
         e.subtitle_lang_1, e.subtitle_lang_2, e.subtitle_lang_3,
         e.is_premium, e.is_title, e.is_download, e.total_view, e.status, e.sort_order,
         s.name AS season_name
       FROM tbl_tv_show_video e
       INNER JOIN tbl_tv_show t ON t.id = e.show_id
       LEFT JOIN tbl_season s ON s.id = e.season_id
       ${where}
       ORDER BY e.status DESC, e.sort_order ASC, e.id DESC`,
      params,
    );

    return rows.map((row) => ({
      id: Number(row.id ?? 0),
      show_id: Number(row.show_id ?? 0),
      season_id: Number(row.season_id ?? 0),
      season_name: String(row.season_name ?? ''),
      name: String(row.name ?? ''),
      thumbnail: String(row.thumbnail ?? ''),
      landscape: String(row.landscape ?? ''),
      description: String(row.description ?? ''),
      video_upload_type: String(row.video_upload_type ?? ''),
      video_320: String(row.video_320 ?? ''),
      video_480: String(row.video_480 ?? ''),
      video_720: String(row.video_720 ?? ''),
      video_1080: String(row.video_1080 ?? ''),
      subtitle_type: String(row.subtitle_type ?? ''),
      subtitle_1: String(row.subtitle_1 ?? ''),
      subtitle_2: String(row.subtitle_2 ?? ''),
      subtitle_3: String(row.subtitle_3 ?? ''),
      subtitle_lang_1: String(row.subtitle_lang_1 ?? ''),
      subtitle_lang_2: String(row.subtitle_lang_2 ?? ''),
      subtitle_lang_3: String(row.subtitle_lang_3 ?? ''),
      video_storage_type: Number(row.video_storage_type ?? 1),
      is_premium: Number(row.is_premium ?? 0),
      is_title: Number(row.is_title ?? 0),
      is_download: Number(row.is_download ?? 0),
      total_view: Number(row.total_view ?? 0),
      status: Number(row.status ?? 0),
      sort_order: Number(row.sort_order ?? 0),
    }));
  }

  async getProducerTvShowEpisodeById(episodeId: number): Promise<ProducerTvShowEpisodeDetail | null> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT
         id, show_id, season_id, name, thumbnail, landscape, description,
         video_upload_type, video_320, video_480, video_720, video_1080,
         subtitle_type, subtitle_1, subtitle_2, subtitle_3,
         subtitle_lang_1, subtitle_lang_2, subtitle_lang_3,
         is_premium, is_title, is_download
       FROM tbl_tv_show_video
       WHERE id = ? LIMIT 1`,
      [episodeId],
    );

    if (rows.length === 0) {
      return null;
    }

    const row = rows[0];
    return {
      id: Number(row.id ?? 0),
      show_id: Number(row.show_id ?? 0),
      season_id: Number(row.season_id ?? 0),
      name: String(row.name ?? ''),
      thumbnail: String(row.thumbnail ?? ''),
      landscape: String(row.landscape ?? ''),
      description: String(row.description ?? ''),
      video_upload_type: String(row.video_upload_type ?? ''),
      video_320: String(row.video_320 ?? ''),
      video_480: String(row.video_480 ?? ''),
      video_720: String(row.video_720 ?? ''),
      video_1080: String(row.video_1080 ?? ''),
      subtitle_type: String(row.subtitle_type ?? ''),
      subtitle_1: String(row.subtitle_1 ?? ''),
      subtitle_2: String(row.subtitle_2 ?? ''),
      subtitle_3: String(row.subtitle_3 ?? ''),
      subtitle_lang_1: String(row.subtitle_lang_1 ?? ''),
      subtitle_lang_2: String(row.subtitle_lang_2 ?? ''),
      subtitle_lang_3: String(row.subtitle_lang_3 ?? ''),
      is_premium: Number(row.is_premium ?? 0),
      is_title: Number(row.is_title ?? 0),
      is_download: Number(row.is_download ?? 0),
    };
  }

  private async getNextTvShowEpisodeSortOrder(showId: number): Promise<number> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT COALESCE(MAX(sort_order), 0) AS max_sort_order
       FROM tbl_tv_show_video
       WHERE show_id = ?`,
      [showId],
    );

    return Number(rows[0]?.max_sort_order ?? 0) + 1;
  }

  async createProducerTvShowEpisode(payload: ProducerTvShowEpisodeDetail): Promise<void> {
    const nextSortOrder = await this.getNextTvShowEpisodeSortOrder(payload.show_id);
    await dbPool.query(
      `INSERT INTO tbl_tv_show_video
      (
        show_id, season_id, name, storage_type, thumbnail, landscape, description,
        video_storage_type, video_upload_type, video_320, video_480, video_720, video_1080,
        video_extension, video_duration, subtitle_storage_type, subtitle_type,
        subtitle_lang_1, subtitle_lang_2, subtitle_lang_3, subtitle_1, subtitle_2, subtitle_3,
        is_premium, is_title, is_download, total_view, sort_order, status, created_at, updated_at
      )
      VALUES
      (?, ?, ?, 1, ?, ?, ?, 1, ?, ?, ?, ?, ?, '', 0, 1, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0, ?, 1, NOW(), NOW())`,
      [
        payload.show_id,
        payload.season_id,
        payload.name,
        payload.thumbnail,
        payload.landscape,
        payload.description,
        payload.video_upload_type,
        payload.video_320,
        payload.video_480,
        payload.video_720,
        payload.video_1080,
        payload.subtitle_type,
        payload.subtitle_lang_1,
        payload.subtitle_lang_2,
        payload.subtitle_lang_3,
        payload.subtitle_1,
        payload.subtitle_2,
        payload.subtitle_3,
        payload.is_premium,
        payload.is_title,
        payload.is_download,
        nextSortOrder,
      ],
    );
  }

  async updateProducerTvShowEpisode(episodeId: number, producerId: number, payload: ProducerTvShowEpisodeDetail): Promise<boolean> {
    const [result] = await dbPool.query(
      `UPDATE tbl_tv_show_video e
       INNER JOIN tbl_tv_show t ON t.id = e.show_id
       SET
         e.season_id = ?, e.name = ?, e.thumbnail = ?, e.landscape = ?, e.description = ?,
         e.video_upload_type = ?, e.video_320 = ?, e.video_480 = ?, e.video_720 = ?, e.video_1080 = ?,
         e.subtitle_type = ?, e.subtitle_1 = ?, e.subtitle_2 = ?, e.subtitle_3 = ?,
         e.subtitle_lang_1 = ?, e.subtitle_lang_2 = ?, e.subtitle_lang_3 = ?,
         e.is_premium = ?, e.is_title = ?, e.is_download = ?, e.updated_at = NOW()
       WHERE e.id = ? AND t.producer_id = ?`,
      [
        payload.season_id,
        payload.name,
        payload.thumbnail,
        payload.landscape,
        payload.description,
        payload.video_upload_type,
        payload.video_320,
        payload.video_480,
        payload.video_720,
        payload.video_1080,
        payload.subtitle_type,
        payload.subtitle_1,
        payload.subtitle_2,
        payload.subtitle_3,
        payload.subtitle_lang_1,
        payload.subtitle_lang_2,
        payload.subtitle_lang_3,
        payload.is_premium,
        payload.is_title,
        payload.is_download,
        episodeId,
        producerId,
      ],
    ) as Array<{ affectedRows?: number }>;

    return Number(result?.affectedRows ?? 0) > 0;
  }

  async deleteProducerTvShowEpisode(producerId: number, showId: number, episodeId: number): Promise<boolean> {
    const connection = await dbPool.getConnection();
    try {
      await connection.beginTransaction();
      const [rows] = await connection.query<Row[]>(
        `SELECT e.id
         FROM tbl_tv_show_video e
         INNER JOIN tbl_tv_show t ON t.id = e.show_id
         WHERE e.id = ? AND e.show_id = ? AND t.producer_id = ? LIMIT 1`,
        [episodeId, showId, producerId],
      );
      if (rows.length === 0) {
        await connection.rollback();
        return false;
      }

      await connection.query('DELETE FROM tbl_tv_show_video WHERE id = ? AND show_id = ?', [episodeId, showId]);
      await connection.query('DELETE FROM tbl_video_watch WHERE video_id = ? AND episode_id = ?', [showId, episodeId]);
      await connection.query('DELETE FROM tbl_view WHERE video_id = ? AND episode_id = ?', [showId, episodeId]);
      await connection.commit();
      return true;
    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
  }

  async toggleProducerTvShowEpisodeStatus(producerId: number, episodeId: number): Promise<boolean> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT e.status
       FROM tbl_tv_show_video e
       INNER JOIN tbl_tv_show t ON t.id = e.show_id
       WHERE e.id = ? AND t.producer_id = ? LIMIT 1`,
      [episodeId, producerId],
    );
    if (rows.length === 0) {
      return false;
    }

    const current = Number(rows[0].status ?? 0);
    const next = current === 1 ? 0 : 1;
    await dbPool.query(
      `UPDATE tbl_tv_show_video e
       INNER JOIN tbl_tv_show t ON t.id = e.show_id
       SET e.status = ?, e.updated_at = NOW()
       WHERE e.id = ? AND t.producer_id = ?`,
      [next, episodeId, producerId],
    );
    return true;
  }

  async saveProducerTvShowEpisodeSortOrder(producerId: number, showId: number, ids: number[]): Promise<boolean> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT e.id
       FROM tbl_tv_show_video e
       INNER JOIN tbl_tv_show t ON t.id = e.show_id
       WHERE t.producer_id = ? AND e.show_id = ? AND e.id IN (${ids.map(() => '?').join(', ')})`,
      [producerId, showId, ...ids],
    );

    if (rows.length !== ids.length) {
      return false;
    }

    for (let index = 0; index < ids.length; index += 1) {
      await dbPool.query(
        `UPDATE tbl_tv_show_video e
         INNER JOIN tbl_tv_show t ON t.id = e.show_id
         SET e.sort_order = ?, e.updated_at = NOW()
         WHERE e.id = ? AND e.show_id = ? AND t.producer_id = ?`,
        [index + 1, ids[index], showId, producerId],
      );
    }

    return true;
  }

  async getProducerShorts(
    producerId: number,
    typeId: number,
    inputSearch: string,
    inputRent: string,
    inputStatus: string,
  ): Promise<ProducerShortsItem[]> {
    const params: unknown[] = [producerId, typeId];
    let where = 'WHERE producer_id = ? AND type_id = ?';

    if (inputSearch.trim()) {
      where += ' AND name LIKE ?';
      params.push(`%${inputSearch.trim()}%`);
    }
    if (inputRent === '1') {
      where += ' AND is_rent = 1';
    }
    if (inputStatus === '0' || inputStatus === '1') {
      where += ' AND status = ?';
      params.push(Number(inputStatus));
    }

    const [rows] = await dbPool.query<Row[]>(
      `SELECT
         id, type_id, video_type, category_id, language_id, cast_id,
         name, thumbnail, trailer_type, trailer_url, description,
         is_title, is_comment, is_like, total_view, status
       FROM tbl_shorts
       ${where}
       ORDER BY status DESC, id DESC`,
      params,
    );

    return rows.map((row) => ({
      id: Number(row.id ?? 0),
      type_id: Number(row.type_id ?? 0),
      video_type: Number(row.video_type ?? 0),
      channel_id: 0,
      category_id: String(row.category_id ?? ''),
      language_id: String(row.language_id ?? ''),
      cast_id: String(row.cast_id ?? ''),
      name: String(row.name ?? ''),
      thumbnail: String(row.thumbnail ?? ''),
      landscape: '',
      trailer_type: String(row.trailer_type ?? ''),
      trailer_url: String(row.trailer_url ?? ''),
      description: String(row.description ?? ''),
      is_title: Number(row.is_title ?? 0),
      is_comment: Number(row.is_comment ?? 0),
      is_like: Number(row.is_like ?? 0),
      is_rent: 0,
      price: 0,
      rent_day: 0,
      total_view: Number(row.total_view ?? 0),
      status: Number(row.status ?? 0),
      release_date: '',
    }));
  }

  async getProducerShortsById(shortsId: number, producerId: number): Promise<ProducerShortsDetail | null> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT
         id, type_id, video_type, category_id, language_id, cast_id,
         name, thumbnail, trailer_type, trailer_url, description,
         is_title, is_comment, is_like
       FROM tbl_shorts
       WHERE id = ? AND producer_id = ? LIMIT 1`,
      [shortsId, producerId],
    );

    if (rows.length === 0) {
      return null;
    }

    const row = rows[0];
    return {
      id: Number(row.id ?? 0),
      type_id: Number(row.type_id ?? 0),
      video_type: Number(row.video_type ?? 0),
      channel_id: 0,
      category_id: String(row.category_id ?? ''),
      language_id: String(row.language_id ?? ''),
      cast_id: String(row.cast_id ?? ''),
      name: String(row.name ?? ''),
      thumbnail: String(row.thumbnail ?? ''),
      landscape: '',
      trailer_type: String(row.trailer_type ?? ''),
      trailer_url: String(row.trailer_url ?? ''),
      description: String(row.description ?? ''),
      release_date: '',
      is_title: Number(row.is_title ?? 0),
      is_comment: Number(row.is_comment ?? 0),
      is_like: Number(row.is_like ?? 0),
      is_rent: 0,
      price: 0,
      rent_day: 0,
    };
  }

  async createProducerShorts(producerId: number, payload: ProducerShortsDetail): Promise<void> {
    await dbPool.query(
      `INSERT INTO tbl_shorts
      (
        type_id, video_type, producer_id, category_id, language_id, cast_id,
        name, storage_type, thumbnail, trailer_storage_type, trailer_type, trailer_url,
        description, is_title, is_comment, is_like, total_view, total_like, status, created_at, updated_at
      )
      VALUES
      (?, ?, ?, ?, ?, ?, ?, 1, ?, 1, ?, ?, ?, ?, ?, ?, 0, 0, 1, NOW(), NOW())`,
      [
        payload.type_id,
        payload.video_type,
        producerId,
        payload.category_id,
        payload.language_id,
        payload.cast_id,
        payload.name,
        payload.thumbnail,
        payload.trailer_type,
        payload.trailer_url,
        payload.description,
        payload.is_title,
        payload.is_comment,
        payload.is_like,
      ],
    );
  }

  async updateProducerShorts(shortsId: number, producerId: number, payload: ProducerShortsDetail): Promise<boolean> {
    const [result] = await dbPool.query(
      `UPDATE tbl_shorts
       SET
         type_id = ?, video_type = ?, category_id = ?, language_id = ?, cast_id = ?,
         name = ?, thumbnail = ?, trailer_type = ?, trailer_url = ?, description = ?,
         is_title = ?, is_comment = ?, is_like = ?, updated_at = NOW()
       WHERE id = ? AND producer_id = ?`,
      [
        payload.type_id,
        payload.video_type,
        payload.category_id,
        payload.language_id,
        payload.cast_id,
        payload.name,
        payload.thumbnail,
        payload.trailer_type,
        payload.trailer_url,
        payload.description,
        payload.is_title,
        payload.is_comment,
        payload.is_like,
        shortsId,
        producerId,
      ],
    ) as Array<{ affectedRows?: number }>;

    return Number(result?.affectedRows ?? 0) > 0;
  }

  async toggleProducerShortsStatus(shortsId: number, producerId: number): Promise<boolean> {
    const [rows] = await dbPool.query<Row[]>('SELECT status FROM tbl_shorts WHERE id = ? AND producer_id = ? LIMIT 1', [shortsId, producerId]);
    if (rows.length === 0) {
      return false;
    }

    const current = Number(rows[0].status ?? 0);
    const next = current === 1 ? 0 : 1;
    await dbPool.query('UPDATE tbl_shorts SET status = ?, updated_at = NOW() WHERE id = ? AND producer_id = ?', [next, shortsId, producerId]);
    return true;
  }

  async releaseProducerShorts(shortsId: number, producerId: number, targetTypeId: number, targetVideoType: number, channelId: number): Promise<boolean> {
    const [result] = await dbPool.query(
      'UPDATE tbl_shorts SET type_id = ?, video_type = ?, updated_at = NOW() WHERE id = ? AND producer_id = ?',
      [targetTypeId, targetVideoType, shortsId, producerId],
    ) as Array<{ affectedRows?: number }>;

    return Number(result?.affectedRows ?? 0) > 0;
  }

  async deleteProducerShorts(shortsId: number, producerId: number): Promise<boolean> {
    const connection = await dbPool.getConnection();
    try {
      await connection.beginTransaction();
      const [rows] = await connection.query<Row[]>('SELECT id, video_type FROM tbl_shorts WHERE id = ? AND producer_id = ? LIMIT 1', [shortsId, producerId]);
      if (rows.length === 0) {
        await connection.rollback();
        return false;
      }

      const videoType = Number(rows[0].video_type ?? 0);
      await connection.query('DELETE FROM tbl_shorts_episode WHERE show_id = ?', [shortsId]);
      await connection.query('DELETE FROM tbl_shorts WHERE id = ? AND producer_id = ?', [shortsId, producerId]);
      await connection.query('DELETE FROM tbl_bookmark WHERE video_type = ? AND video_id = ?', [videoType, shortsId]);
      await connection.query('DELETE FROM tbl_comment WHERE video_type = ? AND video_id = ?', [videoType, shortsId]);
      await connection.query('DELETE FROM tbl_like WHERE video_type = ? AND video_id = ?', [videoType, shortsId]);
      await connection.query('DELETE FROM tbl_review WHERE video_type = ? AND video_id = ?', [videoType, shortsId]);
      await connection.query('DELETE FROM tbl_video_watch WHERE video_type = ? AND video_id = ?', [videoType, shortsId]);
      await connection.query('DELETE FROM tbl_view WHERE video_type = ? AND video_id = ?', [videoType, shortsId]);
      await connection.commit();
      return true;
    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
  }

  async searchProducerShortsNames(producerId: number, txtVal: string): Promise<Array<{ id: number; name: string }>> {
    const keyword = `%${txtVal.trim()}%`;
    const [rows] = await dbPool.query<Row[]>('SELECT id, name FROM tbl_shorts WHERE producer_id = ? AND name LIKE ? ORDER BY id DESC LIMIT 20', [
      producerId,
      keyword,
    ]);

    return rows.map((row) => ({
      id: Number(row.id ?? 0),
      name: String(row.name ?? ''),
    }));
  }

  async getProducerShortsDataForFill(producerId: number, shortsId: number): Promise<Row | null> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT
         id, name, description, thumbnail, category_id,
         language_id, cast_id
       FROM tbl_shorts
       WHERE id = ? AND producer_id = ? LIMIT 1`,
      [shortsId, producerId],
    );

    return rows[0] ?? null;
  }

  async getProducerShortsEpisodes(producerId: number, showId: number, inputSearch: string, inputSeason: string): Promise<ProducerShortsEpisodeItem[]> {
    const params: unknown[] = [producerId, showId];
    let where = 'WHERE t.producer_id = ? AND e.show_id = ?';

    if (inputSearch.trim()) {
      where += ' AND e.name LIKE ?';
      params.push(`%${inputSearch.trim()}%`);
    }
    if (inputSeason !== '0') {
      const seasonId = Number(inputSeason);
      if (Number.isFinite(seasonId) && seasonId > 0) {
        where += ' AND e.season_id = ?';
        params.push(seasonId);
      }
    }

    const [rows] = await dbPool.query<Row[]>(
      `SELECT
         e.id, e.show_id, e.season_id, e.name, e.thumbnail, e.description,
         e.video_upload_type, e.video_320, e.video_storage_type,
         e.is_premium, e.is_title, e.total_view, e.status, e.sort_order,
         s.name AS season_name
       FROM tbl_shorts_episode e
       INNER JOIN tbl_shorts t ON t.id = e.show_id
       LEFT JOIN tbl_season s ON s.id = e.season_id
       ${where}
       ORDER BY e.status DESC, e.sort_order ASC, e.id DESC`,
      params,
    );

    return rows.map((row) => ({
      id: Number(row.id ?? 0),
      show_id: Number(row.show_id ?? 0),
      season_id: Number(row.season_id ?? 0),
      season_name: String(row.season_name ?? ''),
      name: String(row.name ?? ''),
      thumbnail: String(row.thumbnail ?? ''),
      landscape: '',
      description: String(row.description ?? ''),
      video_upload_type: String(row.video_upload_type ?? ''),
      video_320: String(row.video_320 ?? ''),
      video_480: '',
      video_720: '',
      video_1080: '',
      subtitle_type: '',
      subtitle_1: '',
      subtitle_2: '',
      subtitle_3: '',
      subtitle_lang_1: '',
      subtitle_lang_2: '',
      subtitle_lang_3: '',
      video_storage_type: Number(row.video_storage_type ?? 1),
      is_premium: Number(row.is_premium ?? 0),
      is_title: Number(row.is_title ?? 0),
      is_download: 0,
      total_view: Number(row.total_view ?? 0),
      status: Number(row.status ?? 0),
      sort_order: Number(row.sort_order ?? 0),
    }));
  }

  private async getNextShortsEpisodeSortOrder(showId: number): Promise<number> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT COALESCE(MAX(sort_order), 0) AS max_sort_order
       FROM tbl_shorts_episode
       WHERE show_id = ?`,
      [showId],
    );

    return Number(rows[0]?.max_sort_order ?? 0) + 1;
  }

  async createProducerShortsEpisode(payload: ProducerShortsEpisodeDetail): Promise<void> {
    const nextSortOrder = await this.getNextShortsEpisodeSortOrder(payload.show_id);
    await dbPool.query(
      `INSERT INTO tbl_shorts_episode
      (
        show_id, season_id, name, storage_type, thumbnail, description,
        video_storage_type, video_upload_type, video_320,
        video_duration, is_premium, is_title, total_view, sort_order, status, created_at, updated_at
      )
      VALUES
      (?, ?, ?, 1, ?, ?, 1, ?, ?, 0, ?, ?, 0, ?, 1, NOW(), NOW())`,
      [
        payload.show_id,
        payload.season_id,
        payload.name,
        payload.thumbnail,
        payload.description,
        payload.video_upload_type,
        payload.video_320,
        payload.is_premium,
        payload.is_title,
        nextSortOrder,
      ],
    );
  }

  async updateProducerShortsEpisode(episodeId: number, producerId: number, payload: ProducerShortsEpisodeDetail): Promise<boolean> {
    const [result] = await dbPool.query(
      `UPDATE tbl_shorts_episode e
       INNER JOIN tbl_shorts t ON t.id = e.show_id
       SET
         e.season_id = ?, e.name = ?, e.thumbnail = ?, e.description = ?,
         e.video_upload_type = ?, e.video_320 = ?,
         e.is_premium = ?, e.is_title = ?, e.updated_at = NOW()
       WHERE e.id = ? AND t.producer_id = ?`,
      [
        payload.season_id,
        payload.name,
        payload.thumbnail,
        payload.description,
        payload.video_upload_type,
        payload.video_320,
        payload.is_premium,
        payload.is_title,
        episodeId,
        producerId,
      ],
    ) as Array<{ affectedRows?: number }>;

    return Number(result?.affectedRows ?? 0) > 0;
  }

  async doesProducerShortsEpisodeBelongToShow(producerId: number, episodeId: number, showId: number): Promise<boolean> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT e.id
       FROM tbl_shorts_episode e
       INNER JOIN tbl_shorts t ON t.id = e.show_id
       WHERE e.id = ? AND e.show_id = ? AND t.producer_id = ? LIMIT 1`,
      [episodeId, showId, producerId],
    );

    return rows.length > 0;
  }

  async deleteProducerShortsEpisode(producerId: number, showId: number, episodeId: number): Promise<boolean> {
    const connection = await dbPool.getConnection();
    try {
      await connection.beginTransaction();
      const [rows] = await connection.query<Row[]>(
        `SELECT e.id
         FROM tbl_shorts_episode e
         INNER JOIN tbl_shorts t ON t.id = e.show_id
         WHERE e.id = ? AND e.show_id = ? AND t.producer_id = ? LIMIT 1`,
        [episodeId, showId, producerId],
      );
      if (rows.length === 0) {
        await connection.rollback();
        return false;
      }

      await connection.query('DELETE FROM tbl_shorts_episode WHERE id = ? AND show_id = ?', [episodeId, showId]);
      await connection.query('DELETE FROM tbl_video_watch WHERE video_id = ? AND episode_id = ?', [showId, episodeId]);
      await connection.query('DELETE FROM tbl_view WHERE video_id = ? AND episode_id = ?', [showId, episodeId]);
      await connection.commit();
      return true;
    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
  }

  async toggleProducerShortsEpisodeStatus(producerId: number, episodeId: number): Promise<boolean> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT e.status
       FROM tbl_shorts_episode e
       INNER JOIN tbl_shorts t ON t.id = e.show_id
       WHERE e.id = ? AND t.producer_id = ? LIMIT 1`,
      [episodeId, producerId],
    );
    if (rows.length === 0) {
      return false;
    }

    const current = Number(rows[0].status ?? 0);
    const next = current === 1 ? 0 : 1;
    await dbPool.query(
      `UPDATE tbl_shorts_episode e
       INNER JOIN tbl_shorts t ON t.id = e.show_id
       SET e.status = ?, e.updated_at = NOW()
       WHERE e.id = ? AND t.producer_id = ?`,
      [next, episodeId, producerId],
    );
    return true;
  }

  async saveProducerShortsEpisodeSortOrder(producerId: number, showId: number, ids: number[]): Promise<boolean> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT e.id
       FROM tbl_shorts_episode e
       INNER JOIN tbl_shorts t ON t.id = e.show_id
       WHERE t.producer_id = ? AND e.show_id = ? AND e.id IN (${ids.map(() => '?').join(', ')})`,
      [producerId, showId, ...ids],
    );

    if (rows.length !== ids.length) {
      return false;
    }

    for (let index = 0; index < ids.length; index += 1) {
      await dbPool.query(
        `UPDATE tbl_shorts_episode e
         INNER JOIN tbl_shorts t ON t.id = e.show_id
         SET e.sort_order = ?, e.updated_at = NOW()
         WHERE e.id = ? AND e.show_id = ? AND t.producer_id = ?`,
        [index + 1, ids[index], showId, producerId],
      );
    }

    return true;
  }

  async getProducerVideos(
    producerId: number,
    typeId: number,
    inputSearch: string,
    inputRent: string,
    inputPremium: string,
    inputStatus: string,
  ): Promise<ProducerVideoItem[]> {
    const params: unknown[] = [producerId, typeId];
    let where = 'WHERE producer_id = ? AND type_id = ?';

    if (inputSearch.trim()) {
      where += ' AND name LIKE ?';
      params.push(`%${inputSearch.trim()}%`);
    }
    if (inputRent === '1') {
      where += ' AND is_rent = 1';
    }
    if (inputPremium === '0' || inputPremium === '1') {
      where += ' AND is_premium = ?';
      params.push(Number(inputPremium));
    }
    if (inputStatus === '0' || inputStatus === '1') {
      where += ' AND status = ?';
      params.push(Number(inputStatus));
    }

    const [rows] = await dbPool.query<Row[]>(
      `SELECT
         id, type_id, video_type, channel_id, category_id, language_id, cast_id,
         name, thumbnail, landscape, description,
         is_premium, is_title, is_download, is_comment, is_like, is_rent, price, rent_day,
         total_view, status,
         video_upload_type, video_320, video_480, video_720, video_1080, video_storage_type,
         trailer_type, trailer_url,
         subtitle_type, subtitle_1, subtitle_2, subtitle_3,
         subtitle_lang_1, subtitle_lang_2, subtitle_lang_3,
         release_date
       FROM tbl_video
       ${where}
       ORDER BY status DESC, id DESC`,
      params,
    );

    return rows.map((row) => ({
      id: Number(row.id ?? 0),
      type_id: Number(row.type_id ?? 0),
      video_type: Number(row.video_type ?? 0),
      channel_id: Number(row.channel_id ?? 0),
      category_id: String(row.category_id ?? ''),
      language_id: String(row.language_id ?? ''),
      cast_id: String(row.cast_id ?? ''),
      name: String(row.name ?? ''),
      thumbnail: String(row.thumbnail ?? ''),
      landscape: String(row.landscape ?? ''),
      description: String(row.description ?? ''),
      is_premium: Number(row.is_premium ?? 0),
      is_title: Number(row.is_title ?? 0),
      is_download: Number(row.is_download ?? 0),
      is_comment: Number(row.is_comment ?? 0),
      is_like: Number(row.is_like ?? 0),
      is_rent: Number(row.is_rent ?? 0),
      price: Number(row.price ?? 0),
      rent_day: Number(row.rent_day ?? 0),
      total_view: Number(row.total_view ?? 0),
      status: Number(row.status ?? 0),
      video_upload_type: String(row.video_upload_type ?? ''),
      video_320: String(row.video_320 ?? ''),
      video_480: String(row.video_480 ?? ''),
      video_720: String(row.video_720 ?? ''),
      video_1080: String(row.video_1080 ?? ''),
      video_storage_type: Number(row.video_storage_type ?? 1),
      trailer_type: String(row.trailer_type ?? ''),
      trailer_url: String(row.trailer_url ?? ''),
      subtitle_type: String(row.subtitle_type ?? ''),
      subtitle_1: String(row.subtitle_1 ?? ''),
      subtitle_2: String(row.subtitle_2 ?? ''),
      subtitle_3: String(row.subtitle_3 ?? ''),
      subtitle_lang_1: String(row.subtitle_lang_1 ?? ''),
      subtitle_lang_2: String(row.subtitle_lang_2 ?? ''),
      subtitle_lang_3: String(row.subtitle_lang_3 ?? ''),
      release_date: String(row.release_date ?? ''),
    }));
  }

  async getProducerVideoById(videoId: number, producerId: number): Promise<ProducerVideoDetail | null> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT
         id, type_id, video_type, channel_id, category_id, language_id, cast_id,
         name, thumbnail, landscape, description, release_date, is_premium, is_title, is_download, is_comment,
         is_like, is_rent, price, rent_day, video_upload_type, video_320, video_480,
         video_720, video_1080, trailer_type, trailer_url, subtitle_type, subtitle_1,
         subtitle_2, subtitle_3, subtitle_lang_1, subtitle_lang_2, subtitle_lang_3
       FROM tbl_video
       WHERE id = ? AND producer_id = ? LIMIT 1`,
      [videoId, producerId],
    );

    if (rows.length === 0) {
      return null;
    }

    const row = rows[0];
    return {
      id: Number(row.id ?? 0),
      type_id: Number(row.type_id ?? 0),
      video_type: Number(row.video_type ?? 0),
      channel_id: Number(row.channel_id ?? 0),
      category_id: String(row.category_id ?? ''),
      language_id: String(row.language_id ?? ''),
      cast_id: String(row.cast_id ?? ''),
      name: String(row.name ?? ''),
      thumbnail: String(row.thumbnail ?? ''),
      landscape: String(row.landscape ?? ''),
      description: String(row.description ?? ''),
      release_date: String(row.release_date ?? ''),
      is_premium: Number(row.is_premium ?? 0),
      is_title: Number(row.is_title ?? 0),
      is_download: Number(row.is_download ?? 0),
      is_comment: Number(row.is_comment ?? 0),
      is_like: Number(row.is_like ?? 0),
      is_rent: Number(row.is_rent ?? 0),
      price: Number(row.price ?? 0),
      rent_day: Number(row.rent_day ?? 0),
      video_upload_type: String(row.video_upload_type ?? ''),
      video_320: String(row.video_320 ?? ''),
      video_480: String(row.video_480 ?? ''),
      video_720: String(row.video_720 ?? ''),
      video_1080: String(row.video_1080 ?? ''),
      trailer_type: String(row.trailer_type ?? ''),
      trailer_url: String(row.trailer_url ?? ''),
      subtitle_type: String(row.subtitle_type ?? ''),
      subtitle_1: String(row.subtitle_1 ?? ''),
      subtitle_2: String(row.subtitle_2 ?? ''),
      subtitle_3: String(row.subtitle_3 ?? ''),
      subtitle_lang_1: String(row.subtitle_lang_1 ?? ''),
      subtitle_lang_2: String(row.subtitle_lang_2 ?? ''),
      subtitle_lang_3: String(row.subtitle_lang_3 ?? ''),
    };
  }

  async searchProducerVideoNames(producerId: number, txtVal: string): Promise<Array<{ id: number; name: string }>> {
    const keyword = `%${txtVal.trim()}%`;
    const [rows] = await dbPool.query<Row[]>(
      'SELECT id, name FROM tbl_video WHERE producer_id = ? AND name LIKE ? ORDER BY id DESC LIMIT 20',
      [producerId, keyword],
    );

    return rows.map((row) => ({
      id: Number(row.id ?? 0),
      name: String(row.name ?? ''),
    }));
  }

  async getProducerVideoDataForFill(producerId: number, videoId: number): Promise<Row | null> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT
         id, name, description, release_date, thumbnail, landscape, category_id,
         language_id, cast_id
       FROM tbl_video
       WHERE id = ? AND producer_id = ? LIMIT 1`,
      [videoId, producerId],
    );

    return rows[0] ?? null;
  }

  async createProducerVideo(producerId: number, payload: ProducerVideoDetail): Promise<void> {
    await dbPool.query(
      `INSERT INTO tbl_video
      (
        type_id, video_type, channel_id, producer_id, category_id, language_id, cast_id,
        name, storage_type, thumbnail, landscape, description, video_storage_type,
        video_upload_type, video_320, video_480, video_720, video_1080, video_extension,
        video_duration, trailer_storage_type, trailer_type, trailer_url, subtitle_storage_type,
        subtitle_type, subtitle_lang_1, subtitle_lang_2, subtitle_lang_3, subtitle_1, subtitle_2,
        subtitle_3, release_date, is_premium, is_title, is_download, is_comment, is_like,
        is_rent, price, rent_day, total_view, total_like, status,
        created_at, updated_at
      )
      VALUES
      (?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?, ?, 1, ?, ?, ?, ?, ?, '', 0, 1, ?, ?, 1, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0, 0, 1, NOW(), NOW())`,
      [
        payload.type_id,
        payload.video_type,
        payload.channel_id,
        producerId,
        payload.category_id,
        payload.language_id,
        payload.cast_id,
        payload.name,
        payload.thumbnail,
        payload.landscape,
        payload.description,
        payload.video_upload_type,
        payload.video_320,
        payload.video_480,
        payload.video_720,
        payload.video_1080,
        payload.trailer_type,
        payload.trailer_url,
        payload.subtitle_type,
        payload.subtitle_lang_1,
        payload.subtitle_lang_2,
        payload.subtitle_lang_3,
        payload.subtitle_1,
        payload.subtitle_2,
        payload.subtitle_3,
        payload.release_date,
        payload.is_premium,
        payload.is_title,
        payload.is_download,
        payload.is_comment,
        payload.is_like,
        payload.is_rent,
        payload.price,
        payload.rent_day,
      ],
    );
  }

  async updateProducerVideo(videoId: number, producerId: number, payload: ProducerVideoDetail): Promise<boolean> {
    const [result] = await dbPool.query(
      `UPDATE tbl_video
       SET
         type_id = ?, video_type = ?, channel_id = ?, category_id = ?, language_id = ?, cast_id = ?,
         name = ?, thumbnail = ?, landscape = ?, description = ?, release_date = ?, is_premium = ?, is_title = ?, is_download = ?,
         is_comment = ?, is_like = ?, is_rent = ?, price = ?, rent_day = ?, video_upload_type = ?,
         video_320 = ?, video_480 = ?, video_720 = ?, video_1080 = ?, trailer_type = ?, trailer_url = ?,
         subtitle_type = ?, subtitle_1 = ?, subtitle_2 = ?, subtitle_3 = ?, subtitle_lang_1 = ?,
         subtitle_lang_2 = ?, subtitle_lang_3 = ?, updated_at = NOW()
       WHERE id = ? AND producer_id = ?`,
      [
        payload.type_id,
        payload.video_type,
        payload.channel_id,
        payload.category_id,
        payload.language_id,
        payload.cast_id,
        payload.name,
        payload.thumbnail,
        payload.landscape,
        payload.description,
        payload.release_date,
        payload.is_premium,
        payload.is_title,
        payload.is_download,
        payload.is_comment,
        payload.is_like,
        payload.is_rent,
        payload.price,
        payload.rent_day,
        payload.video_upload_type,
        payload.video_320,
        payload.video_480,
        payload.video_720,
        payload.video_1080,
        payload.trailer_type,
        payload.trailer_url,
        payload.subtitle_type,
        payload.subtitle_1,
        payload.subtitle_2,
        payload.subtitle_3,
        payload.subtitle_lang_1,
        payload.subtitle_lang_2,
        payload.subtitle_lang_3,
        videoId,
        producerId,
      ],
    ) as Array<{ affectedRows?: number }>;

    return Number(result?.affectedRows ?? 0) > 0;
  }

  async toggleProducerVideoStatus(videoId: number, producerId: number): Promise<boolean> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT status FROM tbl_video WHERE id = ? AND producer_id = ? LIMIT 1',
      [videoId, producerId],
    );
    if (rows.length === 0) {
      return false;
    }

    const current = Number(rows[0].status ?? 0);
    const next = current === 1 ? 0 : 1;
    await dbPool.query('UPDATE tbl_video SET status = ?, updated_at = NOW() WHERE id = ? AND producer_id = ?', [next, videoId, producerId]);
    return true;
  }

  async releaseProducerVideo(videoId: number, producerId: number, targetTypeId: number, targetVideoType: number, channelId: number): Promise<boolean> {
    const [result] = await dbPool.query(
      'UPDATE tbl_video SET type_id = ?, video_type = ?, channel_id = ?, updated_at = NOW() WHERE id = ? AND producer_id = ?',
      [targetTypeId, targetVideoType, channelId, videoId, producerId],
    ) as Array<{ affectedRows?: number }>;

    return Number(result?.affectedRows ?? 0) > 0;
  }

  async deleteProducerVideo(videoId: number, producerId: number): Promise<boolean> {
    const connection = await dbPool.getConnection();
    try {
      await connection.beginTransaction();
      const [rows] = await connection.query<Row[]>('SELECT id, video_type FROM tbl_video WHERE id = ? AND producer_id = ? LIMIT 1', [videoId, producerId]);
      if (rows.length === 0) {
        await connection.rollback();
        return false;
      }

      const videoType = Number(rows[0].video_type ?? 0);
      await connection.query('DELETE FROM tbl_video WHERE id = ? AND producer_id = ?', [videoId, producerId]);
      await connection.query('DELETE FROM tbl_bookmark WHERE video_type = ? AND video_id = ?', [videoType, videoId]);
      await connection.query('DELETE FROM tbl_comment WHERE video_type = ? AND video_id = ?', [videoType, videoId]);
      await connection.query('DELETE FROM tbl_like WHERE video_type = ? AND video_id = ?', [videoType, videoId]);
      await connection.query('DELETE FROM tbl_review WHERE video_type = ? AND video_id = ?', [videoType, videoId]);
      await connection.query('DELETE FROM tbl_video_watch WHERE video_type = ? AND video_id = ? AND episode_id = 0', [videoType, videoId]);
      await connection.query('DELETE FROM tbl_view WHERE video_type = ? AND video_id = ? AND episode_id = 0', [videoType, videoId]);
      await connection.commit();
      return true;
    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
  }

  async getTypeById(id: number): Promise<{ id: number; type: number } | null> {
    const [rows] = await dbPool.query<Row[]>('SELECT id, type FROM tbl_type WHERE id = ? LIMIT 1', [id]);
    if (rows.length === 0) {
      return null;
    }

    return {
      id: Number(rows[0].id ?? 0),
      type: Number(rows[0].type ?? 0),
    };
  }

  async createAdminChannel(name: string, portraitImg: string, landscapeImg: string, isTitle: number): Promise<void> {
    await dbPool.query(
      `INSERT INTO tbl_channel
      (name, storage_type, portrait_img, landscape_img, is_title, status, created_at, updated_at)
      VALUES (?, 1, ?, ?, ?, 1, NOW(), NOW())`,
      [name, portraitImg, landscapeImg, isTitle],
    );
  }

  async updateAdminChannel(id: number, name: string, portraitImg: string, landscapeImg: string, isTitle: number): Promise<void> {
    await dbPool.query(
      'UPDATE tbl_channel SET name = ?, portrait_img = ?, landscape_img = ?, is_title = ?, updated_at = NOW() WHERE id = ?',
      [name, portraitImg, landscapeImg, isTitle, id],
    );
  }

  async toggleAdminChannelStatus(id: number): Promise<boolean> {
    const [rows] = await dbPool.query<Row[]>('SELECT status FROM tbl_channel WHERE id = ? LIMIT 1', [id]);
    if (rows.length === 0) {
      return false;
    }

    const current = Number(rows[0].status ?? 0);
    const next = current === 1 ? 0 : 1;
    await dbPool.query('UPDATE tbl_channel SET status = ?, updated_at = NOW() WHERE id = ?', [next, id]);
    return true;
  }

  async createAdminCategory(name: string, image: string): Promise<void> {
    await dbPool.query(
      `INSERT INTO tbl_category
      (name, storage_type, image, sort_order, status, created_at, updated_at)
      VALUES (?, 1, ?, 0, 1, NOW(), NOW())`,
      [name, image],
    );
  }

  async updateAdminCategory(id: number, name: string, image: string): Promise<void> {
    await dbPool.query(
      'UPDATE tbl_category SET name = ?, image = ?, updated_at = NOW() WHERE id = ?',
      [name, image, id],
    );
  }

  async toggleAdminCategoryStatus(id: number): Promise<boolean> {
    const [rows] = await dbPool.query<Row[]>('SELECT status FROM tbl_category WHERE id = ? LIMIT 1', [id]);
    if (rows.length === 0) {
      return false;
    }

    const current = Number(rows[0].status ?? 0);
    const next = current === 1 ? 0 : 1;
    await dbPool.query('UPDATE tbl_category SET status = ?, updated_at = NOW() WHERE id = ?', [next, id]);
    return true;
  }

  async saveAdminCategorySortOrder(ids: number[]): Promise<void> {
    for (let index = 0; index < ids.length; index += 1) {
      await dbPool.query('UPDATE tbl_category SET sort_order = ?, updated_at = NOW() WHERE id = ?', [index + 1, ids[index]]);
    }
  }

  async getAdminLanguages(): Promise<LanguageItem[]> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT id, name, storage_type, image, sort_order, status FROM tbl_language ORDER BY status DESC, sort_order ASC, id DESC',
    );

    return rows.map((row) => ({
      id: Number(row.id ?? 0),
      name: String(row.name ?? ''),
      storage_type: Number(row.storage_type ?? 1),
      image: String(row.image ?? ''),
      sort_order: Number(row.sort_order ?? 0),
      status: Number(row.status ?? 0),
    }));
  }

  async createAdminLanguage(name: string, image: string): Promise<void> {
    await dbPool.query(
      `INSERT INTO tbl_language
      (name, storage_type, image, sort_order, status, created_at, updated_at)
      VALUES (?, 1, ?, 0, 1, NOW(), NOW())`,
      [name, image],
    );
  }

  async updateAdminLanguage(id: number, name: string, image: string): Promise<void> {
    await dbPool.query(
      'UPDATE tbl_language SET name = ?, image = ?, updated_at = NOW() WHERE id = ?',
      [name, image, id],
    );
  }

  async toggleAdminLanguageStatus(id: number): Promise<boolean> {
    const [rows] = await dbPool.query<Row[]>('SELECT status FROM tbl_language WHERE id = ? LIMIT 1', [id]);
    if (rows.length === 0) {
      return false;
    }

    const current = Number(rows[0].status ?? 0);
    const next = current === 1 ? 0 : 1;
    await dbPool.query('UPDATE tbl_language SET status = ?, updated_at = NOW() WHERE id = ?', [next, id]);
    return true;
  }

  async saveAdminLanguageSortOrder(ids: number[]): Promise<void> {
    for (let index = 0; index < ids.length; index += 1) {
      await dbPool.query('UPDATE tbl_language SET sort_order = ?, updated_at = NOW() WHERE id = ?', [index + 1, ids[index]]);
    }
  }

  async getProducerWithdrawalSetup(producerId: number): Promise<ProducerWithdrawalSetup | null> {
    const [[producerRows], [settingRows]] = await Promise.all([
      dbPool.query<Row[]>('SELECT wallet FROM tbl_producer WHERE id = ? LIMIT 1', [producerId]),
      dbPool.query<Row[]>('SELECT `key`, value FROM tbl_general_setting WHERE `key` IN (?, ?)', ['min_withdrawal_amount', 'currency_code']),
    ]);

    if (producerRows.length === 0) {
      return null;
    }

    const settingMap = new Map<string, string>();
    for (const row of settingRows) {
      settingMap.set(String(row.key ?? ''), String(row.value ?? ''));
    }

    return {
      wallet: Number(producerRows[0]?.wallet ?? 0),
      minWithdrawalAmount: Number(settingMap.get('min_withdrawal_amount') ?? 1),
      currencyCode: settingMap.get('currency_code') || '$',
    };
  }

  async getProducerWithdrawals(producerId: number, inputStatus: 'all' | 0 | 1): Promise<ProducerWithdrawalItem[]> {
    const params: unknown[] = [producerId];
    let query = 'SELECT id, price, status, created_at FROM tbl_withdrawal_request WHERE producer_id = ?';

    if (inputStatus !== 'all') {
      query += ' AND status = ?';
      params.push(inputStatus);
    }

    query += ' ORDER BY status ASC, id DESC';

    const [rows] = await dbPool.query<Row[]>(query, params);
    return rows.map((row) => ({
      id: Number(row.id ?? 0),
      price: Number(row.price ?? 0),
      status: Number(row.status ?? 0),
      createdAt: String(row.created_at ?? ''),
    }));
  }

  async getAdminVideos(): Promise<AdminVideoItem[]> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT
         id, type_id, video_type, producer_id, name, thumbnail,
         is_premium, is_rent, price, total_view, status, created_at
       FROM tbl_video
       ORDER BY status DESC, id DESC`,
    );

    return rows.map((row) => ({
      id: Number(row.id ?? 0),
      type_id: Number(row.type_id ?? 0),
      video_type: Number(row.video_type ?? 0),
      producer_id: Number(row.producer_id ?? 0),
      name: String(row.name ?? ''),
      thumbnail: String(row.thumbnail ?? ''),
      is_premium: Number(row.is_premium ?? 0),
      is_rent: Number(row.is_rent ?? 0),
      price: Number(row.price ?? 0),
      total_view: Number(row.total_view ?? 0),
      status: Number(row.status ?? 0),
      created_at: String(row.created_at ?? ''),
    }));
  }

  async toggleAdminVideoStatus(id: number): Promise<boolean> {
    const [rows] = await dbPool.query<Row[]>('SELECT status FROM tbl_video WHERE id = ? LIMIT 1', [id]);
    if (rows.length === 0) {
      return false;
    }

    const current = Number(rows[0].status ?? 0);
    const next = current === 1 ? 0 : 1;
    await dbPool.query('UPDATE tbl_video SET status = ?, updated_at = NOW() WHERE id = ?', [next, id]);
    return true;
  }

  async getAdminTvShows(): Promise<AdminTvShowItem[]> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT
         id, type_id, video_type, producer_id, name, thumbnail,
         is_rent, price, total_view, status, created_at
       FROM tbl_tv_show
       ORDER BY status DESC, id DESC`,
    );

    return rows.map((row) => ({
      id: Number(row.id ?? 0),
      type_id: Number(row.type_id ?? 0),
      video_type: Number(row.video_type ?? 0),
      producer_id: Number(row.producer_id ?? 0),
      name: String(row.name ?? ''),
      thumbnail: String(row.thumbnail ?? ''),
      is_rent: Number(row.is_rent ?? 0),
      price: Number(row.price ?? 0),
      total_view: Number(row.total_view ?? 0),
      status: Number(row.status ?? 0),
      created_at: String(row.created_at ?? ''),
    }));
  }

  async toggleAdminTvShowStatus(id: number): Promise<boolean> {
    const [rows] = await dbPool.query<Row[]>('SELECT status FROM tbl_tv_show WHERE id = ? LIMIT 1', [id]);
    if (rows.length === 0) {
      return false;
    }

    const current = Number(rows[0].status ?? 0);
    const next = current === 1 ? 0 : 1;
    await dbPool.query('UPDATE tbl_tv_show SET status = ?, updated_at = NOW() WHERE id = ?', [next, id]);
    return true;
  }

  async getAdminShorts(): Promise<AdminShortsItem[]> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT
         id, type_id, video_type, producer_id, name, thumbnail,
         total_view, status, created_at
       FROM tbl_shorts
       ORDER BY status DESC, id DESC`,
    );

    return rows.map((row) => ({
      id: Number(row.id ?? 0),
      type_id: Number(row.type_id ?? 0),
      video_type: Number(row.video_type ?? 0),
      producer_id: Number(row.producer_id ?? 0),
      name: String(row.name ?? ''),
      thumbnail: String(row.thumbnail ?? ''),
      total_view: Number(row.total_view ?? 0),
      status: Number(row.status ?? 0),
      created_at: String(row.created_at ?? ''),
    }));
  }

  async toggleAdminShortsStatus(id: number): Promise<boolean> {
    const [rows] = await dbPool.query<Row[]>('SELECT status FROM tbl_shorts WHERE id = ? LIMIT 1', [id]);
    if (rows.length === 0) {
      return false;
    }

    const current = Number(rows[0].status ?? 0);
    const next = current === 1 ? 0 : 1;
    await dbPool.query('UPDATE tbl_shorts SET status = ?, updated_at = NOW() WHERE id = ?', [next, id]);
    return true;
  }

  async createProducerWithdrawalRequest(
    producerId: number,
    price: number,
  ): Promise<{ ok: boolean; reason?: 'producer_not_found' | 'insufficient_wallet' }> {
    const connection = await dbPool.getConnection();
    try {
      await connection.beginTransaction();

      const [producerRows] = await connection.query<Row[]>('SELECT wallet FROM tbl_producer WHERE id = ? LIMIT 1 FOR UPDATE', [producerId]);
      if (producerRows.length === 0) {
        await connection.rollback();
        return { ok: false, reason: 'producer_not_found' };
      }

      const wallet = Number(producerRows[0]?.wallet ?? 0);
      if (wallet < price) {
        await connection.rollback();
        return { ok: false, reason: 'insufficient_wallet' };
      }

      await connection.query(
        `INSERT INTO tbl_withdrawal_request
        (producer_id, price, status, created_at, updated_at)
        VALUES (?, ?, 0, NOW(), NOW())`,
        [producerId, price],
      );
      await connection.query('UPDATE tbl_producer SET wallet = wallet - ?, updated_at = NOW() WHERE id = ?', [price, producerId]);

      await connection.commit();
      return { ok: true };
    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
  }

  async getProducerRentSummary(producerId: number, inputType: 'today' | 'month' | 'year'): Promise<ProducerRentSummary> {
    let dateClause = 'AND YEAR(created_at) = YEAR(CURDATE())';
    if (inputType === 'today') {
      dateClause = 'AND DATE(created_at) = CURDATE()';
    } else if (inputType === 'month') {
      dateClause = 'AND YEAR(created_at) = YEAR(CURDATE()) AND MONTH(created_at) = MONTH(CURDATE())';
    }

    const [rows] = await dbPool.query<Row[]>(
      `SELECT COALESCE(SUM(commission), 0) AS totalCommission, COALESCE(SUM(producer_earning), 0) AS totalProducerEarning
       FROM tbl_rent_transaction
       WHERE producer_id = ? AND transaction_status = 2 ${dateClause}`,
      [producerId],
    );

    return {
      totalCommission: Number(rows[0]?.totalCommission ?? 0),
      totalProducerEarning: Number(rows[0]?.totalProducerEarning ?? 0),
    };
  }

  async getProducerRentTransactions(producerId: number, inputType: 'all' | 'today' | 'month' | 'year', inputSearch: string): Promise<ProducerRentTransactionItem[]> {
    const params: unknown[] = [producerId];
    let where = 'WHERE rt.producer_id = ?';

    if (inputType === 'today') {
      where += ' AND DATE(rt.created_at) = CURDATE()';
    } else if (inputType === 'month') {
      where += ' AND YEAR(rt.created_at) = YEAR(CURDATE()) AND MONTH(rt.created_at) = MONTH(CURDATE())';
    } else if (inputType === 'year') {
      where += ' AND YEAR(rt.created_at) = YEAR(CURDATE())';
    }

    if (inputSearch.trim()) {
      const keyword = `%${inputSearch.trim()}%`;
      where += ` AND (
        rt.transaction_id LIKE ?
        OR u.full_name LIKE ?
        OR u.email LIKE ?
        OR u.mobile_number LIKE ?
        OR v.name LIKE ?
        OR t.name LIKE ?
      )`;
      params.push(keyword, keyword, keyword, keyword, keyword, keyword);
    }

    const [rows] = await dbPool.query<Row[]>(
      `SELECT
         rt.id,
         rt.transaction_id,
         rt.video_type,
         rt.sub_video_type,
         rt.transaction_status,
         rt.price,
         rt.commission,
         rt.producer_earning,
         rt.expiry_date,
         rt.status,
         rt.created_at,
         u.full_name AS user_full_name,
         u.email AS user_email,
         u.mobile_number AS user_mobile_number,
         v.name AS video_name,
         t.name AS tvshow_name
       FROM tbl_rent_transaction rt
       LEFT JOIN tbl_user u ON u.id = rt.user_id
       LEFT JOIN tbl_video v ON v.id = rt.video_id
       LEFT JOIN tbl_tv_show t ON t.id = rt.video_id
       ${where}
       ORDER BY rt.id DESC`,
      params,
    );

    return rows.map((row) => {
      const videoType = Number(row.video_type ?? 0);
      const subVideoType = Number(row.sub_video_type ?? 0);
      let videoName = '-';
      if (videoType === 1) {
        videoName = String(row.video_name ?? '-');
      } else if (videoType === 2) {
        videoName = String(row.tvshow_name ?? '-');
      } else if (videoType === 6 || videoType === 7) {
        videoName = subVideoType === 1 ? String(row.video_name ?? '-') : String(row.tvshow_name ?? '-');
      }

      return {
        id: Number(row.id ?? 0),
        transactionId: String(row.transaction_id ?? ''),
        userName: String(row.user_full_name ?? ''),
        userContact: String(row.user_email || row.user_mobile_number || ''),
        videoName,
        paymentType: 0,
        transactionStatus: Number(row.transaction_status ?? 0),
        price: Number(row.price ?? 0),
        commission: Number(row.commission ?? 0),
        producerEarning: Number(row.producer_earning ?? 0),
        expiryDate: String(row.expiry_date ?? ''),
        status: Number(row.status ?? 0),
        createdAt: String(row.created_at ?? ''),
      };
    });
  }
}
