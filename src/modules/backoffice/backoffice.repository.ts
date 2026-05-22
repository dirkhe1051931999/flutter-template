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

export type BannerItem = {
  id: number;
  is_home_screen: number;
  type_id: number;
  video_type: number;
  subvideo_type: number;
  video_id: number;
  sort_order: number;
  status: number;
};

export type HomeSectionItem = {
  id: number;
  title: string;
  short_title: string;
  section_type: number;
  is_home_screen: number;
  type_id: number;
  video_type: number;
  sub_video_type: number;
  screen_layout: string;
  content_ids: string;
  category_id: number;
  language_id: number;
  channel_id: number;
  order_by_upload: number;
  order_by_view: number;
  premium_video: number;
  no_of_content: number;
  view_all: number;
  is_title: number;
  sort_order: number;
  status: number;
};

async function getCount(query: string, params: unknown[] = []): Promise<number> {
  const [rows] = await dbPool.query<Row[]>(query, params);
  return Number(rows[0]?.total ?? 0);
}

export class BackofficeRepository {
  async getNotificationSettings(): Promise<Record<string, string>> {
    const [rows] = await dbPool.query<Row[]>('SELECT `key`, `value` FROM tbl_general_setting');
    const result: Record<string, string> = {};
    for (const row of rows) {
      result[String(row.key ?? '')] = String(row.value ?? '');
    }
    return result;
  }

  async saveGeneralSettings(data: Record<string, unknown>): Promise<void> {
    const keys = Object.keys(data);
    for (const key of keys) {
      const value = String(data[key] ?? '');
      await dbPool.query('UPDATE tbl_general_setting SET `value` = ?, updated_at = NOW() WHERE `key` = ?', [value, key]);
    }
  }

  async getReviewById(id: number): Promise<Row | null> {
    const [rows] = await dbPool.query<Row[]>('SELECT * FROM tbl_review WHERE id = ? LIMIT 1', [id]);
    return rows[0] ?? null;
  }

  async updateReviewStatus(id: number, status: number): Promise<void> {
    await dbPool.query('UPDATE tbl_review SET status = ?, updated_at = NOW() WHERE id = ?', [status, id]);
  }

  async deleteReviewById(id: number): Promise<void> {
    await dbPool.query('DELETE FROM tbl_review WHERE id = ?', [id]);
  }

  async getApprovedReviewStats(videoType: number, subVideoType: number, videoId: number): Promise<{ avg: number; total: number }> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT COALESCE(AVG(rating), 0) AS avg_rating, COUNT(*) AS total_reviews
       FROM tbl_review
       WHERE video_type = ? AND sub_video_type = ? AND video_id = ? AND status = 1`,
      [videoType, subVideoType, videoId],
    );
    return {
      avg: Number(rows[0]?.avg_rating ?? 0),
      total: Number(rows[0]?.total_reviews ?? 0),
    };
  }

  async updateVideoRating(videoId: number, avg: number, total: number): Promise<void> {
    await dbPool.query('UPDATE tbl_video SET avg_rating = ?, total_review = ?, updated_at = NOW() WHERE id = ?', [avg, total, videoId]);
  }

  async updateTvShowRating(videoId: number, avg: number, total: number): Promise<void> {
    await dbPool.query('UPDATE tbl_tv_show SET avg_rating = ?, total_review = ?, updated_at = NOW() WHERE id = ?', [avg, total, videoId]);
  }

  async updateShortsRating(videoId: number, avg: number, total: number): Promise<void> {
    await dbPool.query('UPDATE tbl_shorts SET avg_rating = ?, total_review = ?, updated_at = NOW() WHERE id = ?', [avg, total, videoId]);
  }

  async deleteCouponById(id: number): Promise<void> {
    await dbPool.query('DELETE FROM tbl_coupon WHERE id = ?', [id]);
  }

  async deleteRentPriceById(id: number): Promise<void> {
    await dbPool.query('DELETE FROM tbl_rent_price_list WHERE id = ?', [id]);
  }

  async deleteTypeById(id: number): Promise<void> {
    await dbPool.query('DELETE FROM tbl_type WHERE id = ?', [id]);
  }

  async deleteCategoryById(id: number): Promise<void> {
    await dbPool.query('DELETE FROM tbl_category WHERE id = ?', [id]);
  }

  async deleteLanguageById(id: number): Promise<void> {
    await dbPool.query('DELETE FROM tbl_language WHERE id = ?', [id]);
  }

  async deleteSeasonById(id: number): Promise<void> {
    await dbPool.query('DELETE FROM tbl_season WHERE id = ?', [id]);
  }

  async deleteAvatarById(id: number): Promise<void> {
    await dbPool.query('DELETE FROM tbl_avatar WHERE id = ?', [id]);
  }

  async deleteChannelById(id: number): Promise<void> {
    await dbPool.query('DELETE FROM tbl_channel WHERE id = ?', [id]);
  }

  async deleteUserById(id: number): Promise<void> {
    await dbPool.query('DELETE FROM tbl_user WHERE id = ?', [id]);
  }

  async deleteProducerById(id: number): Promise<void> {
    await dbPool.query('DELETE FROM tbl_producer WHERE id = ?', [id]);
  }

  async deleteCastById(id: number): Promise<void> {
    await dbPool.query('DELETE FROM tbl_cast WHERE id = ?', [id]);
  }

  async deleteSectionById(id: number): Promise<void> {
    await dbPool.query('DELETE FROM tbl_home_section WHERE id = ?', [id]);
  }

  async deleteNotificationById(id: number): Promise<void> {
    await dbPool.query('DELETE FROM tbl_notification WHERE id = ?', [id]);
  }

  async getPaymentOptionById(id: number): Promise<Row | null> {
    const [rows] = await dbPool.query<Row[]>('SELECT * FROM tbl_payment_option WHERE id = ? LIMIT 1', [id]);
    return rows[0] ?? null;
  }

  async getPaymentOptions(): Promise<Row[]> {
    const [rows] = await dbPool.query<Row[]>('SELECT * FROM tbl_payment_option ORDER BY id DESC');
    return rows;
  }

  async updatePaymentOptionById(id: number, payload: {
    key1: string; key2: string; key3: string; key4: string; visibility: number; isLive: number;
  }): Promise<void> {
    await dbPool.query(
      `UPDATE tbl_payment_option
       SET key_1 = ?, key_2 = ?, key_3 = ?, key_4 = ?, visibility = ?, is_live = ?, updated_at = NOW()
       WHERE id = ?`,
      [payload.key1, payload.key2, payload.key3, payload.key4, payload.visibility, payload.isLive, id],
    );
  }

  async deleteTransactionById(id: number): Promise<void> {
    await dbPool.query('DELETE FROM tbl_transaction WHERE id = ?', [id]);
  }

  async deletePackageById(id: number): Promise<void> {
    await dbPool.query('DELETE FROM tbl_package WHERE id = ?', [id]);
    await dbPool.query('DELETE FROM tbl_package_detail WHERE package_id = ?', [id]);
  }

  async deleteRentTransactionById(id: number): Promise<void> {
    await dbPool.query('DELETE FROM tbl_rent_transaction WHERE id = ?', [id]);
  }

  async deletePageById(id: number): Promise<void> {
    await dbPool.query('DELETE FROM tbl_page WHERE id = ?', [id]);
  }

  async getTypeTypeById(typeId: number): Promise<number> {
    const [rows] = await dbPool.query<Row[]>('SELECT type FROM tbl_type WHERE id = ? LIMIT 1', [typeId]);
    return Number(rows[0]?.type ?? 0);
  }

  async getBannerUsedVideoIdsByType(typeId: number): Promise<number[]> {
    const [rows] = await dbPool.query<Row[]>('SELECT video_id FROM tbl_banner WHERE type_id = ?', [typeId]);
    return rows.map((row) => Number(row.video_id ?? 0)).filter((value) => value > 0);
  }

  async getVideoOptionsByType(typeId: number, excludedIds: number[]): Promise<Array<{ id: number; name: string }>> {
    const params: unknown[] = [typeId];
    let where = 'WHERE type_id = ? AND status = 1';
    if (excludedIds.length > 0) {
      where += ` AND id NOT IN (${excludedIds.map(() => '?').join(',')})`;
      params.push(...excludedIds);
    }
    const [rows] = await dbPool.query<Row[]>(`SELECT id, name FROM tbl_video ${where} ORDER BY id DESC`, params);
    return rows.map((row) => ({ id: Number(row.id ?? 0), name: String(row.name ?? '') }));
  }

  async getTvShowOptionsByType(typeId: number, excludedIds: number[]): Promise<Array<{ id: number; name: string }>> {
    const params: unknown[] = [typeId];
    let where = 'WHERE type_id = ? AND status = 1';
    if (excludedIds.length > 0) {
      where += ` AND id NOT IN (${excludedIds.map(() => '?').join(',')})`;
      params.push(...excludedIds);
    }
    const [rows] = await dbPool.query<Row[]>(`SELECT id, name FROM tbl_tv_show ${where} ORDER BY id DESC`, params);
    return rows.map((row) => ({ id: Number(row.id ?? 0), name: String(row.name ?? '') }));
  }

  async getShortsOptionsByType(typeId: number, excludedIds: number[]): Promise<Array<{ id: number; name: string }>> {
    const params: unknown[] = [typeId];
    let where = 'WHERE type_id = ? AND status = 1';
    if (excludedIds.length > 0) {
      where += ` AND id NOT IN (${excludedIds.map(() => '?').join(',')})`;
      params.push(...excludedIds);
    }
    const [rows] = await dbPool.query<Row[]>(`SELECT id, name FROM tbl_shorts ${where} ORDER BY id DESC`, params);
    return rows.map((row) => ({ id: Number(row.id ?? 0), name: String(row.name ?? '') }));
  }

  async getBannerListByScreenAndType(isHomeScreen: number, typeId: number): Promise<Row[]> {
    if (isHomeScreen === 1) {
      const [rows] = await dbPool.query<Row[]>('SELECT * FROM tbl_banner WHERE is_home_screen = ? ORDER BY sort_order ASC, id DESC', [isHomeScreen]);
      return rows;
    }
    const [rows] = await dbPool.query<Row[]>(
      'SELECT * FROM tbl_banner WHERE is_home_screen = ? AND type_id = ? ORDER BY sort_order ASC, id DESC',
      [isHomeScreen, typeId],
    );
    return rows;
  }

  async getVideoNameById(id: number): Promise<string> {
    const [rows] = await dbPool.query<Row[]>('SELECT name FROM tbl_video WHERE id = ? LIMIT 1', [id]);
    return String(rows[0]?.name ?? '');
  }

  async getTvShowNameById(id: number): Promise<string> {
    const [rows] = await dbPool.query<Row[]>('SELECT name FROM tbl_tv_show WHERE id = ? LIMIT 1', [id]);
    return String(rows[0]?.name ?? '');
  }

  async getShortsNameById(id: number): Promise<string> {
    const [rows] = await dbPool.query<Row[]>('SELECT name FROM tbl_shorts WHERE id = ? LIMIT 1', [id]);
    return String(rows[0]?.name ?? '');
  }

  async getTypeNameById(id: number): Promise<string> {
    const [rows] = await dbPool.query<Row[]>('SELECT name FROM tbl_type WHERE id = ? LIMIT 1', [id]);
    return String(rows[0]?.name ?? '');
  }

  async getSectionListData(isHomeScreen: number, topTypeId: number): Promise<Row[]> {
    if (isHomeScreen === 1) {
      const [rows] = await dbPool.query<Row[]>('SELECT * FROM tbl_home_section WHERE is_home_screen = ? ORDER BY status DESC, sort_order ASC, id DESC', [isHomeScreen]);
      return rows;
    }
    const [rows] = await dbPool.query<Row[]>(
      'SELECT * FROM tbl_home_section WHERE is_home_screen = ? AND type_id = ? ORDER BY status DESC, sort_order ASC, id DESC',
      [isHomeScreen, topTypeId],
    );
    return rows;
  }

  async getSectionById(id: number): Promise<Row | null> {
    const [rows] = await dbPool.query<Row[]>('SELECT * FROM tbl_home_section WHERE id = ? LIMIT 1', [id]);
    return rows[0] ?? null;
  }

  async getCategoryOptions(): Promise<Array<{ id: number; name: string }>> {
    const [rows] = await dbPool.query<Row[]>('SELECT id, name FROM tbl_category WHERE status = 1 ORDER BY sort_order ASC, id DESC');
    return rows.map((row) => ({ id: Number(row.id ?? 0), name: String(row.name ?? '') }));
  }

  async getLanguageOptions(): Promise<Array<{ id: number; name: string }>> {
    const [rows] = await dbPool.query<Row[]>('SELECT id, name FROM tbl_language WHERE status = 1 ORDER BY sort_order ASC, id DESC');
    return rows.map((row) => ({ id: Number(row.id ?? 0), name: String(row.name ?? '') }));
  }

  async getChannelOptions(): Promise<Array<{ id: number; name: string }>> {
    const [rows] = await dbPool.query<Row[]>('SELECT id, name FROM tbl_channel WHERE status = 1 ORDER BY id DESC');
    return rows.map((row) => ({ id: Number(row.id ?? 0), name: String(row.name ?? '') }));
  }
  async getGeneralSettingValue(key: string): Promise<string> {
    const [rows] = await dbPool.query<Row[]>('SELECT value FROM tbl_general_setting WHERE `key` = ? LIMIT 1', [key]);
    return String(rows[0]?.value ?? '');
  }

  async getGeneralSettingsByKeys(keys: string[]): Promise<Record<string, string>> {
    if (keys.length === 0) return {};
    const placeholders = keys.map(() => '?').join(',');
    const [rows] = await dbPool.query<Row[]>(`SELECT \`key\`, \`value\` FROM tbl_general_setting WHERE \`key\` IN (${placeholders})`, keys);
    const result: Record<string, string> = {};
    for (const row of rows) {
      result[String(row.key ?? '')] = String(row.value ?? '');
    }
    return result;
  }

  async getAdminReferEarnRows(): Promise<Row[]> {
    const [rows] = await dbPool.query<Row[]>('SELECT * FROM tbl_refer_earn ORDER BY id DESC');
    return rows;
  }

  async getAdminWalletTransactions(): Promise<Row[]> {
    const [rows] = await dbPool.query<Row[]>('SELECT * FROM tbl_wallet_transaction ORDER BY id DESC');
    return rows;
  }

  async getAdminWithdrawalRows(): Promise<Row[]> {
    const [rows] = await dbPool.query<Row[]>('SELECT * FROM tbl_withdrawal_request ORDER BY id DESC');
    return rows;
  }

  async getAdminAdmobRows(): Promise<Row[]> {
    const [rows] = await dbPool.query<Row[]>('SELECT * FROM tbl_admob ORDER BY id DESC');
    return rows;
  }

  async updateAdminAdmobById(id: number, payload: Record<string, unknown>): Promise<void> {
    const entries = Object.entries(payload).filter(([key]) => key !== 'id');
    if (entries.length === 0) return;
    const setClause = entries.map(([key]) => `${key} = ?`).join(', ');
    const params = entries.map(([, value]) => value);
    await dbPool.query(`UPDATE tbl_admob SET ${setClause}, updated_at = NOW() WHERE id = ?`, [...params, id]);
  }

  async getNotificationConfigurationRows(): Promise<Row[]> {
    const [rows] = await dbPool.query<Row[]>('SELECT * FROM tbl_notification_configuration ORDER BY id DESC');
    return rows;
  }

  async upsertNotificationConfiguration(payload: Record<string, unknown>): Promise<void> {
    const id = Number(payload.id ?? 0);
    const keys = Object.keys(payload).filter((key) => key !== 'id');
    if (id > 0) {
      if (keys.length === 0) return;
      const setClause = keys.map((key) => `${key} = ?`).join(', ');
      const params = keys.map((key) => payload[key]);
      await dbPool.query(`UPDATE tbl_notification_configuration SET ${setClause}, updated_at = NOW() WHERE id = ?`, [...params, id]);
      return;
    }

    if (keys.length === 0) return;
    const fields = keys.join(', ');
    const placeholders = keys.map(() => '?').join(', ');
    const params = keys.map((key) => payload[key]);
    await dbPool.query(`INSERT INTO tbl_notification_configuration (${fields}, created_at, updated_at) VALUES (${placeholders}, NOW(), NOW())`, params);
  }

  async getAdminReviews(): Promise<Row[]> {
    const [rows] = await dbPool.query<Row[]>('SELECT * FROM tbl_review ORDER BY id DESC');
    return rows;
  }

  async searchUsersForAdmin(keyword: string, limit = 25): Promise<Row[]> {
    const q = `%${keyword}%`;
    const [rows] = await dbPool.query<Row[]>(
      `SELECT id, full_name, mobile_number, email
       FROM tbl_user
       WHERE full_name LIKE ? OR mobile_number LIKE ? OR email LIKE ?
       ORDER BY id DESC
       LIMIT ?`,
      [q, q, q, limit],
    );
    return rows;
  }

  async getAdminCoupons(): Promise<Row[]> {
    const [rows] = await dbPool.query<Row[]>('SELECT * FROM tbl_coupon ORDER BY id DESC');
    return rows;
  }

  async getAdminRentPriceList(): Promise<Row[]> {
    const [rows] = await dbPool.query<Row[]>('SELECT * FROM tbl_rent_price_list ORDER BY id DESC');
    return rows;
  }

  async getAdminPackages(): Promise<Row[]> {
    const [rows] = await dbPool.query<Row[]>('SELECT * FROM tbl_package ORDER BY id DESC');
    return rows;
  }

  async getAdminTransactions(): Promise<Row[]> {
    const [rows] = await dbPool.query<Row[]>('SELECT * FROM tbl_transaction ORDER BY id DESC');
    return rows;
  }

  async getAdminRentTransactions(): Promise<Row[]> {
    const [rows] = await dbPool.query<Row[]>('SELECT * FROM tbl_rent_transaction ORDER BY id DESC');
    return rows;
  }

  async getAdminUsers(): Promise<Row[]> {
    const [rows] = await dbPool.query<Row[]>('SELECT * FROM tbl_user ORDER BY id DESC');
    return rows;
  }

  async getAdminUserDashboard(userId: number): Promise<Record<string, number>> {
    const [txRows] = await dbPool.query<Row[]>('SELECT COUNT(*) AS total, COALESCE(SUM(price),0) AS amount FROM tbl_transaction WHERE user_id = ?', [userId]);
    const [rentRows] = await dbPool.query<Row[]>('SELECT COUNT(*) AS total, COALESCE(SUM(price),0) AS amount FROM tbl_rent_transaction WHERE user_id = ?', [userId]);
    return {
      transaction_count: Number(txRows[0]?.total ?? 0),
      transaction_amount: Number(txRows[0]?.amount ?? 0),
      rent_count: Number(rentRows[0]?.total ?? 0),
      rent_amount: Number(rentRows[0]?.amount ?? 0),
    };
  }

  async getAdminProducers(): Promise<Row[]> {
    const [rows] = await dbPool.query<Row[]>('SELECT * FROM tbl_producer ORDER BY id DESC');
    return rows;
  }

  async getAdminCasts(): Promise<Row[]> {
    const [rows] = await dbPool.query<Row[]>('SELECT * FROM tbl_cast ORDER BY id DESC');
    return rows;
  }

  async deleteTvShowById(id: number): Promise<void> {
    await dbPool.query('DELETE FROM tbl_tv_show WHERE id = ?', [id]);
  }

  async deleteTvShowEpisodeById(id: number): Promise<void> {
    await dbPool.query('DELETE FROM tbl_episode WHERE id = ?', [id]);
  }

  async deleteShortsById(id: number): Promise<void> {
    await dbPool.query('DELETE FROM tbl_shorts WHERE id = ?', [id]);
  }

  async deleteShortsEpisodeById(id: number): Promise<void> {
    await dbPool.query('DELETE FROM tbl_shorts_episode WHERE id = ?', [id]);
  }

  async deleteVideoById(id: number): Promise<void> {
    await dbPool.query('DELETE FROM tbl_video WHERE id = ?', [id]);
  }

  async deleteBannerById(id: number): Promise<void> {
    await dbPool.query('DELETE FROM tbl_banner WHERE id = ?', [id]);
  }

  async searchAdminVideoNames(txtVal: string): Promise<Array<{ id: number; name: string }>> {
    const keyword = `%${txtVal}%`;
    const [rows] = await dbPool.query<Row[]>(
      'SELECT id, name FROM tbl_video WHERE name LIKE ? ORDER BY id DESC LIMIT 50',
      [keyword],
    );
    return rows.map((row) => ({ id: Number(row.id ?? 0), name: String(row.name ?? '') }));
  }

  async searchAdminTvShowNames(txtVal: string): Promise<Array<{ id: number; name: string }>> {
    const keyword = `%${txtVal}%`;
    const [rows] = await dbPool.query<Row[]>(
      'SELECT id, name FROM tbl_tv_show WHERE name LIKE ? ORDER BY id DESC LIMIT 50',
      [keyword],
    );
    return rows.map((row) => ({ id: Number(row.id ?? 0), name: String(row.name ?? '') }));
  }

  async searchAdminShortsNames(txtVal: string): Promise<Array<{ id: number; name: string }>> {
    const keyword = `%${txtVal}%`;
    const [rows] = await dbPool.query<Row[]>(
      'SELECT id, name FROM tbl_shorts WHERE name LIKE ? ORDER BY id DESC LIMIT 50',
      [keyword],
    );
    return rows.map((row) => ({ id: Number(row.id ?? 0), name: String(row.name ?? '') }));
  }

  async getAdminVideoById(id: number): Promise<Row | null> {
    const [rows] = await dbPool.query<Row[]>('SELECT * FROM tbl_video WHERE id = ? LIMIT 1', [id]);
    return rows[0] ?? null;
  }

  async getAdminTvShowById(id: number): Promise<Row | null> {
    const [rows] = await dbPool.query<Row[]>('SELECT * FROM tbl_tv_show WHERE id = ? LIMIT 1', [id]);
    return rows[0] ?? null;
  }

  async getAdminShortsById(id: number): Promise<Row | null> {
    const [rows] = await dbPool.query<Row[]>('SELECT * FROM tbl_shorts WHERE id = ? LIMIT 1', [id]);
    return rows[0] ?? null;
  }

  async insertWithPayload(table: string, payload: Record<string, unknown>): Promise<number> {
    const entries = Object.entries(payload).filter(([, value]) => value !== undefined);
    if (entries.length === 0) throw new Error('payload is empty');
    const columns = entries.map(([key]) => key).join(', ');
    const placeholders = entries.map(() => '?').join(', ');
    const values = entries.map(([, value]) => value);
    const [result] = await dbPool.query(
      `INSERT INTO ${table} (${columns}, created_at, updated_at) VALUES (${placeholders}, NOW(), NOW())`,
      values,
    );
    return Number((result as { insertId?: number }).insertId ?? 0);
  }

  async updateWithPayloadById(table: string, id: number, payload: Record<string, unknown>): Promise<void> {
    const entries = Object.entries(payload).filter(([key, value]) => key !== 'id' && value !== undefined);
    if (entries.length === 0) return;
    const setClause = entries.map(([key]) => `${key} = ?`).join(', ');
    const values = entries.map(([, value]) => value);
    await dbPool.query(`UPDATE ${table} SET ${setClause}, updated_at = NOW() WHERE id = ?`, [...values, id]);
  }

  async toggleTableStatusById(table: string, id: number): Promise<void> {
    const [rows] = await dbPool.query<Row[]>(`SELECT status FROM ${table} WHERE id = ? LIMIT 1`, [id]);
    if (!rows[0]) throw new Error('data not found');
    const current = Number(rows[0].status ?? 0);
    const next = current === 1 ? 0 : 1;
    await dbPool.query(`UPDATE ${table} SET status = ?, updated_at = NOW() WHERE id = ?`, [next, id]);
  }

  async saveEpisodeSortOrder(table: string, ids: number[]): Promise<void> {
    for (let index = 0; index < ids.length; index += 1) {
      await dbPool.query(`UPDATE ${table} SET sort_order = ?, updated_at = NOW() WHERE id = ?`, [index + 1, ids[index]]);
    }
  }

  async getVideoById(id: number): Promise<Row | null> {
    const [rows] = await dbPool.query<Row[]>('SELECT * FROM tbl_video WHERE id = ? LIMIT 1', [id]);
    return rows[0] ?? null;
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

  async getAdminBanners(): Promise<BannerItem[]> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT id, is_home_screen, type_id, video_type, video_id, sort_order, status
       , subvideo_type
       FROM tbl_banner
       ORDER BY status DESC, sort_order ASC, id DESC`,
    );

    return rows.map((row) => ({
      id: Number(row.id ?? 0),
      is_home_screen: Number(row.is_home_screen ?? 0),
      type_id: Number(row.type_id ?? 0),
      video_type: Number(row.video_type ?? 0),
      subvideo_type: Number(row.subvideo_type ?? 0),
      video_id: Number(row.video_id ?? 0),
      sort_order: Number(row.sort_order ?? 0),
      status: Number(row.status ?? 0),
    }));
  }

  async createAdminBanner(input: {
    isHomeScreen: number; typeId: number; videoType: number; subvideoType: number; videoId: number; sortOrder: number; status: number;
  }): Promise<void> {
    await dbPool.query(
      `INSERT INTO tbl_banner (is_home_screen, type_id, video_type, subvideo_type, video_id, sort_order, status, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, NOW(), NOW())`,
      [input.isHomeScreen, input.typeId, input.videoType, input.subvideoType, input.videoId, input.sortOrder, input.status],
    );
  }

  async updateAdminBanner(id: number, input: {
    isHomeScreen: number; typeId: number; videoType: number; subvideoType: number; videoId: number; sortOrder: number; status: number;
  }): Promise<void> {
    await dbPool.query(
      `UPDATE tbl_banner
       SET is_home_screen = ?, type_id = ?, video_type = ?, subvideo_type = ?, video_id = ?, sort_order = ?, status = ?, updated_at = NOW()
       WHERE id = ?`,
      [input.isHomeScreen, input.typeId, input.videoType, input.subvideoType, input.videoId, input.sortOrder, input.status, id],
    );
  }

  async toggleAdminBannerStatus(id: number): Promise<boolean> {
    const [rows] = await dbPool.query<Row[]>('SELECT status FROM tbl_banner WHERE id = ? LIMIT 1', [id]);
    if (rows.length === 0) {
      return false;
    }

    const current = Number(rows[0].status ?? 0);
    const next = current === 1 ? 0 : 1;
    await dbPool.query('UPDATE tbl_banner SET status = ?, updated_at = NOW() WHERE id = ?', [next, id]);
    return true;
  }

  async saveAdminBannerSortOrder(ids: number[]): Promise<void> {
    for (let index = 0; index < ids.length; index += 1) {
      await dbPool.query('UPDATE tbl_banner SET sort_order = ?, updated_at = NOW() WHERE id = ?', [index + 1, ids[index]]);
    }
  }

  async getAdminHomeSections(): Promise<HomeSectionItem[]> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT id, title, short_title, section_type, is_home_screen, type_id, video_type, sub_video_type, screen_layout,
              content_ids, category_id, language_id, channel_id, order_by_upload, order_by_view, premium_video,
              no_of_content, view_all, is_title, sort_order, status
       FROM tbl_home_section
       ORDER BY status DESC, sort_order ASC, id DESC`,
    );

    return rows.map((row) => ({
      id: Number(row.id ?? 0),
      title: String(row.title ?? ''),
      short_title: String(row.short_title ?? ''),
      section_type: Number(row.section_type ?? 0),
      is_home_screen: Number(row.is_home_screen ?? 0),
      type_id: Number(row.type_id ?? 0),
      video_type: Number(row.video_type ?? 0),
      sub_video_type: Number(row.sub_video_type ?? 0),
      screen_layout: String(row.screen_layout ?? ''),
      content_ids: String(row.content_ids ?? ''),
      category_id: Number(row.category_id ?? 0),
      language_id: Number(row.language_id ?? 0),
      channel_id: Number(row.channel_id ?? 0),
      order_by_upload: Number(row.order_by_upload ?? 0),
      order_by_view: Number(row.order_by_view ?? 0),
      premium_video: Number(row.premium_video ?? 0),
      no_of_content: Number(row.no_of_content ?? 0),
      view_all: Number(row.view_all ?? 0),
      is_title: Number(row.is_title ?? 0),
      sort_order: Number(row.sort_order ?? 0),
      status: Number(row.status ?? 0),
    }));
  }

  async createAdminHomeSection(input: {
    sectionType: number; isHomeScreen: number; videoType: number; subVideoType: number; typeId: number; title: string; shortTitle: string;
    screenLayout: string; contentIds: string; categoryId: number; languageId: number; channelId: number; orderByUpload: number; orderByView: number;
    premiumVideo: number; noOfContent: number; viewAll: number; isTitle: number; sortOrder: number; status: number;
  }): Promise<void> {
    await dbPool.query(
      `INSERT INTO tbl_home_section
      (section_type, is_home_screen, video_type, sub_video_type, type_id, title, short_title, screen_layout, content_ids, category_id, language_id, channel_id,
       order_by_upload, order_by_view, premium_video, no_of_content, view_all, is_title, sort_order, status, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())`,
      [
        input.sectionType, input.isHomeScreen, input.videoType, input.subVideoType, input.typeId, input.title, input.shortTitle,
        input.screenLayout, input.contentIds, input.categoryId, input.languageId, input.channelId, input.orderByUpload, input.orderByView,
        input.premiumVideo, input.noOfContent, input.viewAll, input.isTitle, input.sortOrder, input.status,
      ],
    );
  }

  async updateAdminHomeSection(id: number, input: {
    sectionType: number; isHomeScreen: number; videoType: number; subVideoType: number; typeId: number; title: string; shortTitle: string;
    screenLayout: string; contentIds: string; categoryId: number; languageId: number; channelId: number; orderByUpload: number; orderByView: number;
    premiumVideo: number; noOfContent: number; viewAll: number; isTitle: number; sortOrder: number; status: number;
  }): Promise<void> {
    await dbPool.query(
      `UPDATE tbl_home_section
       SET section_type = ?, is_home_screen = ?, video_type = ?, sub_video_type = ?, type_id = ?, title = ?, short_title = ?, screen_layout = ?, content_ids = ?,
           category_id = ?, language_id = ?, channel_id = ?, order_by_upload = ?, order_by_view = ?, premium_video = ?, no_of_content = ?, view_all = ?, is_title = ?, sort_order = ?, status = ?, updated_at = NOW()
       WHERE id = ?`,
      [
        input.sectionType, input.isHomeScreen, input.videoType, input.subVideoType, input.typeId, input.title, input.shortTitle, input.screenLayout, input.contentIds,
        input.categoryId, input.languageId, input.channelId, input.orderByUpload, input.orderByView, input.premiumVideo, input.noOfContent, input.viewAll, input.isTitle, input.sortOrder, input.status, id,
      ],
    );
  }

  async toggleAdminHomeSectionStatus(id: number): Promise<boolean> {
    const [rows] = await dbPool.query<Row[]>('SELECT status FROM tbl_home_section WHERE id = ? LIMIT 1', [id]);
    if (rows.length === 0) {
      return false;
    }

    const current = Number(rows[0].status ?? 0);
    const next = current === 1 ? 0 : 1;
    await dbPool.query('UPDATE tbl_home_section SET status = ?, updated_at = NOW() WHERE id = ?', [next, id]);
    return true;
  }

  async saveAdminHomeSectionSortOrder(ids: number[]): Promise<void> {
    for (let index = 0; index < ids.length; index += 1) {
      await dbPool.query('UPDATE tbl_home_section SET sort_order = ?, updated_at = NOW() WHERE id = ?', [index + 1, ids[index]]);
    }
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
