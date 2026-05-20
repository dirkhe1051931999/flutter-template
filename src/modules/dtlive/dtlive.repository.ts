import { dbPool } from '../../config/database';
import type { RowDataPacket } from 'mysql2';

type Row = RowDataPacket & Record<string, unknown>;

export class DtliveRepository {
  async getChannels(): Promise<Row[]> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT * FROM tbl_channel WHERE status = 1 ORDER BY id DESC',
    );
    return rows;
  }

  async getLanguagesDynamic(noOfContent: number): Promise<Row[]> {
    const limit = Math.max(1, noOfContent);
    const [rows] = await dbPool.query<Row[]>(
      'SELECT * FROM tbl_language WHERE status = 1 ORDER BY sort_order ASC, id DESC LIMIT ?',
      [limit],
    );
    return rows;
  }

  async getSections(
    isHomeScreen: number,
    typeId: number,
    pageNo: number,
    pageLimit: number,
    userParentControlStatus: number,
  ): Promise<Row[]> {
    const offset = (pageNo - 1) * pageLimit;
    const parentFilter = userParentControlStatus === 1 ? ' AND video_type IN (7, 101)' : '';
    if (isHomeScreen === 1) {
      const [rows] = await dbPool.query<Row[]>(
        `SELECT * FROM tbl_home_section WHERE is_home_screen = ? AND status = 1${parentFilter} ORDER BY sort_order ASC, id DESC LIMIT ? OFFSET ?`,
        [isHomeScreen, pageLimit, offset],
      );
      return rows;
    }

    const [rows] = await dbPool.query<Row[]>(
      `SELECT * FROM tbl_home_section WHERE is_home_screen = ? AND type_id = ? AND status = 1${parentFilter} ORDER BY sort_order ASC, id DESC LIMIT ? OFFSET ?`,
      [isHomeScreen, typeId, pageLimit, offset],
    );
    return rows;
  }

  async getSectionsCount(isHomeScreen: number, typeId: number, userParentControlStatus: number): Promise<number> {
    const parentFilter = userParentControlStatus === 1 ? ' AND video_type IN (7, 101)' : '';
    let rows: Row[];
    if (isHomeScreen === 1) {
      [rows] = await dbPool.query<Row[]>(
        `SELECT COUNT(*) AS total FROM tbl_home_section WHERE is_home_screen = ? AND status = 1${parentFilter}`,
        [isHomeScreen],
      );
    } else {
      [rows] = await dbPool.query<Row[]>(
        `SELECT COUNT(*) AS total FROM tbl_home_section WHERE is_home_screen = ? AND type_id = ? AND status = 1${parentFilter}`,
        [isHomeScreen, typeId],
      );
    }

    return Number(rows[0]?.total ?? 0);
  }

  async getUserParentControlStatus(userId: number, deviceId: string): Promise<number> {
    if (userId <= 0 || !deviceId) {
      return 0;
    }

    try {
      const [settingRows] = await dbPool.query<Row[]>(
        'SELECT value FROM tbl_general_setting WHERE `key` = ? LIMIT 1',
        ['parent_control_status'],
      );
      const isParentControlEnabled = Number(settingRows[0]?.value ?? 0) === 1;
      if (!isParentControlEnabled) {
        return 0;
      }

      const [deviceRows] = await dbPool.query<Row[]>(
        'SELECT kids_mode FROM tbl_device_sync WHERE user_id = ? AND device_id = ? LIMIT 1',
        [userId, deviceId],
      );
      return Number(deviceRows[0]?.kids_mode ?? 0) === 1 ? 1 : 0;
    } catch {
      return 0;
    }
  }

  async getAiCategoryIds(userId: number, limit = 3): Promise<number[]> {
    if (userId <= 0) {
      return [];
    }

    try {
      const [rows] = await dbPool.query<Row[]>(
        'SELECT category_id FROM tbl_user_interest WHERE user_id = ? ORDER BY watch_count DESC LIMIT ?',
        [userId, limit],
      );
      return rows
        .map((row) => Number(row.category_id ?? 0))
        .filter((value) => Number.isFinite(value) && value > 0);
    } catch {
      return [];
    }
  }

  async getAiContentIds(videoType: number, subVideoType: number, categoryIds: number[], limit: number): Promise<number[]> {
    if (categoryIds.length === 0 || limit <= 0) {
      return [];
    }

    const useVideoTable = videoType === 1 || ((videoType === 5 || videoType === 6 || videoType === 7) && subVideoType === 1);
    const table = useVideoTable ? 'tbl_video' : 'tbl_tv_show';
    const categoryFilter = categoryIds.map(() => 'FIND_IN_SET(?, category_id)').join(' OR ');
    const [rows] = await dbPool.query<Row[]>(
      `SELECT id FROM ${table}
       WHERE video_type = ? AND status = 1 AND (${categoryFilter})
       ORDER BY total_view DESC
       LIMIT ?`,
      [videoType, ...categoryIds, limit],
    );

    return rows
      .map((row) => Number(row.id ?? 0))
      .filter((value) => Number.isFinite(value) && value > 0);
  }

  async getCategoriesByIds(ids: number[]): Promise<Row[]> {
    if (ids.length === 0) {
      return [];
    }

    const placeholders = ids.map(() => '?').join(',');
    const [rows] = await dbPool.query<Row[]>(
      `SELECT * FROM tbl_category WHERE id IN (${placeholders}) AND status = 1 ORDER BY sort_order ASC`,
      ids,
    );
    return rows;
  }

  async getCategoriesDynamic(noOfContent: number): Promise<Row[]> {
    const limit = Math.max(1, noOfContent);
    const [rows] = await dbPool.query<Row[]>(
      'SELECT * FROM tbl_category WHERE status = 1 ORDER BY sort_order ASC, id DESC LIMIT ?',
      [limit],
    );
    return rows;
  }

  async getLanguagesByIds(ids: number[]): Promise<Row[]> {
    if (ids.length === 0) {
      return [];
    }

    const placeholders = ids.map(() => '?').join(',');
    const [rows] = await dbPool.query<Row[]>(
      `SELECT * FROM tbl_language WHERE id IN (${placeholders}) AND status = 1 ORDER BY sort_order ASC`,
      ids,
    );
    return rows;
  }

  async getSectionVideoContent(section: Row): Promise<Row[]> {
    const videoType = Number(section.video_type ?? 0);
    const subVideoType = Number(section.sub_video_type ?? 0);
    const sectionType = Number(section.section_type ?? 0);
    const typeId = Number(section.type_id ?? 0);
    const categoryId = Number(section.category_id ?? 0);
    const languageId = Number(section.language_id ?? 0);
    const channelId = Number(section.channel_id ?? 0);
    const premiumVideo = Number(section.premium_video ?? -1);
    const orderByUpload = Number(section.order_by_upload ?? 0);
    const orderByView = Number(section.order_by_view ?? 0);
    const noOfContent = Math.max(1, Number(section.no_of_content ?? 10));
    const contentIdsRaw = String(section.content_ids ?? '').trim();

    const useVideoTable = videoType === 1 || ((videoType === 5 || videoType === 6 || videoType === 7) && subVideoType !== 2);
    const table = useVideoTable ? 'tbl_video' : 'tbl_tv_show';

    if (sectionType === 1 && contentIdsRaw.length > 0) {
      const ids = contentIdsRaw
        .split(',')
        .map((value) => Number(value.trim()))
        .filter((value) => Number.isFinite(value) && value > 0);

      if (ids.length === 0) {
        return [];
      }

      const placeholders = ids.map(() => '?').join(',');
      const [rows] = await dbPool.query<Row[]>(
        `SELECT * FROM ${table} WHERE id IN (${placeholders}) AND status = 1 ORDER BY FIELD(id, ${placeholders}) LIMIT ?`,
        [...ids, ...ids, noOfContent],
      );
      return rows;
    }

    const params: Array<number | string> = [videoType];
    const filters: string[] = ['video_type = ?', 'status = 1'];

    if (typeId > 0) {
      filters.push('type_id = ?');
      params.push(typeId);
    }

    if (categoryId > 0) {
      filters.push('FIND_IN_SET(?, category_id)');
      params.push(categoryId);
    }

    if (languageId > 0) {
      filters.push('FIND_IN_SET(?, language_id)');
      params.push(languageId);
    }

    if (channelId > 0 && table === 'tbl_video') {
      filters.push('channel_id = ?');
      params.push(channelId);
    }

    if (table === 'tbl_video' && premiumVideo === 1) {
      filters.push('is_premium = 1');
    } else if (table === 'tbl_video' && premiumVideo === 0) {
      filters.push('is_premium = 0');
    }

    let orderBy = 'id DESC';
    if (orderByView === 2) {
      orderBy = 'total_view DESC';
    } else if (orderByUpload === 2) {
      orderBy = 'id DESC';
    }

    params.push(noOfContent);
    const [rows] = await dbPool.query<Row[]>(
      `SELECT * FROM ${table} WHERE ${filters.join(' AND ')} ORDER BY ${orderBy} LIMIT ?`,
      params,
    );
    return rows;
  }

  async getSectionShortsContent(section: Row): Promise<Row[]> {
    const sectionType = Number(section.section_type ?? 0);
    const typeId = Number(section.type_id ?? 0);
    const categoryId = Number(section.category_id ?? 0);
    const languageId = Number(section.language_id ?? 0);
    const noOfContent = Math.max(1, Number(section.no_of_content ?? 10));
    const contentIdsRaw = String(section.content_ids ?? '').trim();

    if (sectionType === 1 && contentIdsRaw.length > 0) {
      const ids = contentIdsRaw
        .split(',')
        .map((value) => Number(value.trim()))
        .filter((value) => Number.isFinite(value) && value > 0);

      if (ids.length === 0) {
        return [];
      }

      const placeholders = ids.map(() => '?').join(',');
      const [rows] = await dbPool.query<Row[]>(
        `SELECT * FROM tbl_shorts WHERE id IN (${placeholders}) AND status = 1 ORDER BY FIELD(id, ${placeholders}) LIMIT ?`,
        [...ids, ...ids, noOfContent],
      );
      return rows;
    }

    const params: Array<number> = [];
    const filters: string[] = ['status = 1'];

    if (typeId > 0) {
      filters.push('type_id = ?');
      params.push(typeId);
    }

    if (categoryId > 0) {
      filters.push('FIND_IN_SET(?, category_id)');
      params.push(categoryId);
    }

    if (languageId > 0) {
      filters.push('FIND_IN_SET(?, language_id)');
      params.push(languageId);
    }

    params.push(noOfContent);
    const [rows] = await dbPool.query<Row[]>(
      `SELECT * FROM tbl_shorts WHERE ${filters.join(' AND ')} ORDER BY id DESC LIMIT ?`,
      params,
    );
    return rows;
  }

  async getContinueWatching(userId: number, isKidsProfile: number): Promise<Row[]> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT * FROM tbl_video_watch WHERE user_id = ? AND is_kids_profile = ? AND status = 1 ORDER BY id DESC LIMIT 10',
      [userId, isKidsProfile],
    );
    return rows;
  }

  async getContentDetail(videoType: number, typeId: number, videoId: number, subVideoType: number): Promise<Row | null> {
    if (videoType === 8) {
      const [rows] = await dbPool.query<Row[]>(
        'SELECT * FROM tbl_shorts WHERE id = ? AND video_type = ? AND type_id = ? AND status = 1 LIMIT 1',
        [videoId, videoType, typeId],
      );
      return rows[0] ?? null;
    }

    const useVideoTable = videoType === 1 || ((videoType === 5 || videoType === 6 || videoType === 7) && subVideoType !== 2);
    const table = useVideoTable ? 'tbl_video' : 'tbl_tv_show';
    const [rows] = await dbPool.query<Row[]>(
      `SELECT * FROM ${table} WHERE id = ? AND video_type = ? AND type_id = ? AND status = 1 LIMIT 1`,
      [videoId, videoType, typeId],
    );

    return rows[0] ?? null;
  }

  async getChannelContent(channelId: number): Promise<Row[]> {
    const [videoRows] = await dbPool.query<Row[]>(
      'SELECT *, 1 AS sub_video_type FROM tbl_video WHERE status = 1 AND video_type = 6 AND channel_id = ?',
      [channelId],
    );
    const [tvShowRows] = await dbPool.query<Row[]>(
      'SELECT *, 2 AS sub_video_type FROM tbl_tv_show WHERE status = 1 AND video_type = 6 AND channel_id = ?',
      [channelId],
    );

    return [...videoRows, ...tvShowRows];
  }

  async getCategoryNamesByIds(idsRaw: string): Promise<string[]> {
    const ids = idsRaw
      .split(',')
      .map((value) => Number(value.trim()))
      .filter((value) => Number.isFinite(value) && value > 0);

    if (ids.length === 0) {
      return [];
    }

    const placeholders = ids.map(() => '?').join(',');
    const [rows] = await dbPool.query<Row[]>(
      `SELECT name FROM tbl_category WHERE id IN (${placeholders}) ORDER BY sort_order ASC`,
      ids,
    );

    return rows.map((row) => String(row.name ?? ''));
  }

  async getLanguageNamesByIds(idsRaw: string): Promise<string[]> {
    const ids = idsRaw
      .split(',')
      .map((value) => Number(value.trim()))
      .filter((value) => Number.isFinite(value) && value > 0);

    if (ids.length === 0) {
      return [];
    }

    const placeholders = ids.map(() => '?').join(',');
    const [rows] = await dbPool.query<Row[]>(
      `SELECT name FROM tbl_language WHERE id IN (${placeholders}) ORDER BY sort_order ASC`,
      ids,
    );

    return rows.map((row) => String(row.name ?? ''));
  }

  async getCastsByIds(idsRaw: string): Promise<Row[]> {
    const ids = idsRaw
      .split(',')
      .map((value) => Number(value.trim()))
      .filter((value) => Number.isFinite(value) && value > 0);

    if (ids.length === 0) {
      return [];
    }

    const placeholders = ids.map(() => '?').join(',');
    const [rows] = await dbPool.query<Row[]>(
      `SELECT * FROM tbl_cast WHERE id IN (${placeholders}) AND status = 1 ORDER BY FIELD(id, ${placeholders})`,
      [...ids, ...ids],
    );

    return rows;
  }

  async getStopTime(userId: number, videoType: number, subVideoType: number, videoId: number): Promise<number> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT stop_time FROM tbl_video_watch WHERE user_id = ? AND video_type = ? AND sub_video_type = ? AND video_id = ? ORDER BY id DESC LIMIT 1',
      [userId, videoType, subVideoType, videoId],
    );

    return Number(rows[0]?.stop_time ?? 0);
  }

  async isAnyPackageBuy(userId: number): Promise<boolean> {
    if (userId <= 0) {
      return false;
    }

    const [rows] = await dbPool.query<Row[]>(
      'SELECT id FROM tbl_transaction WHERE user_id = ? AND status = 1 AND transaction_status = 2 ORDER BY id ASC LIMIT 1',
      [userId],
    );
    return rows.length > 0;
  }

  async isRentBuy(userId: number, videoType: number, subVideoType: number, videoId: number): Promise<boolean> {
    if (userId <= 0) {
      return false;
    }

    const [rows] = await dbPool.query<Row[]>(
      `SELECT id
       FROM tbl_rent_transaction
       WHERE user_id = ? AND video_type = ? AND sub_video_type = ? AND video_id = ?
         AND status = 1 AND transaction_status = 2
       LIMIT 1`,
      [userId, videoType, subVideoType, videoId],
    );

    return rows.length > 0;
  }

  async getRentExpiryDate(userId: number, videoType: number, subVideoType: number, videoId: number): Promise<string> {
    if (userId <= 0) {
      return '';
    }

    const [rows] = await dbPool.query<Row[]>(
      `SELECT expiry_date
       FROM tbl_rent_transaction
       WHERE user_id = ? AND video_type = ? AND sub_video_type = ? AND video_id = ?
         AND status = 1 AND transaction_status = 2
       LIMIT 1`,
      [userId, videoType, subVideoType, videoId],
    );

    return String(rows[0]?.expiry_date ?? '');
  }

  async getRentPriceDetailById(priceId: number): Promise<Row | null> {
    if (priceId <= 0) {
      return null;
    }

    const [rows] = await dbPool.query<Row[]>(
      'SELECT id, price, android_product_package, ios_product_package, web_price_id FROM tbl_rent_price_list WHERE id = ? LIMIT 1',
      [priceId],
    );

    return rows[0] ?? null;
  }

  async isBookmarked(userId: number, isKidsProfile: number, videoType: number, subVideoType: number, videoId: number): Promise<boolean> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT id FROM tbl_bookmark WHERE user_id = ? AND is_kids_profile = ? AND video_type = ? AND sub_video_type = ? AND video_id = ? LIMIT 1',
      [userId, isKidsProfile, videoType, subVideoType, videoId],
    );
    return rows.length > 0;
  }

  async isLiked(userId: number, videoType: number, subVideoType: number, videoId: number): Promise<boolean> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT id FROM tbl_like WHERE user_id = ? AND video_type = ? AND sub_video_type = ? AND video_id = ? LIMIT 1',
      [userId, videoType, subVideoType, videoId],
    );
    return rows.length > 0;
  }

  async getTotalComment(videoType: number, subVideoType: number, videoId: number): Promise<number> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT COUNT(*) AS total FROM tbl_comment WHERE video_type = ? AND sub_video_type = ? AND video_id = ? AND status = 1',
      [videoType, subVideoType, videoId],
    );

    return Number(rows[0]?.total ?? 0);
  }

  async getSeasonsByShowId(showId: number): Promise<Row[]> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT s.*
       FROM tbl_season s
       INNER JOIN (
         SELECT DISTINCT season_id FROM tbl_tv_show_video WHERE show_id = ? AND status = 1
       ) ss ON ss.season_id = s.id
       ORDER BY s.sort_order ASC`,
      [showId],
    );

    return rows;
  }

  async getSeasonsByShortsId(showId: number): Promise<Row[]> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT s.*
       FROM tbl_season s
       INNER JOIN (
         SELECT DISTINCT season_id FROM tbl_shorts_episode WHERE show_id = ? AND status = 1
       ) ss ON ss.season_id = s.id
       ORDER BY s.sort_order ASC`,
      [showId],
    );

    return rows;
  }

  async upsertContinueWatching(input: {
    userId: number;
    isKidsProfile: number;
    videoType: number;
    subVideoType: number;
    videoId: number;
    episodeId: number;
    stopTime: number;
  }): Promise<void> {
    const [existingRows] = await dbPool.query<Row[]>(
      'SELECT id FROM tbl_video_watch WHERE user_id = ? AND is_kids_profile = ? AND video_type = ? AND video_id = ? ORDER BY id DESC LIMIT 1',
      [input.userId, input.isKidsProfile, input.videoType, input.videoId],
    );

    if (existingRows.length > 0) {
      const existingId = Number(existingRows[0].id);
      const shouldUpdateEpisode =
        input.videoType === 2 ||
        ((input.videoType === 6 || input.videoType === 7) && input.subVideoType === 2);

      if (shouldUpdateEpisode) {
        await dbPool.query(
          'UPDATE tbl_video_watch SET sub_video_type = ?, episode_id = ?, stop_time = ?, status = 1, updated_at = NOW() WHERE id = ?',
          [input.subVideoType, input.episodeId, input.stopTime, existingId],
        );
      } else {
        await dbPool.query(
          'UPDATE tbl_video_watch SET sub_video_type = ?, stop_time = ?, status = 1, updated_at = NOW() WHERE id = ?',
          [input.subVideoType, input.stopTime, existingId],
        );
      }
      return;
    }

    await dbPool.query(
      `INSERT INTO tbl_video_watch
      (user_id, is_kids_profile, video_type, sub_video_type, video_id, episode_id, stop_time, status, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, 1, NOW(), NOW())`,
      [
        input.userId,
        input.isKidsProfile,
        input.videoType,
        input.subVideoType,
        input.videoId,
        input.episodeId,
        input.stopTime,
      ],
    );
  }

  async toggleLike(userId: number, videoType: number, subVideoType: number, videoId: number): Promise<boolean> {
    const [existingRows] = await dbPool.query<Row[]>(
      'SELECT id FROM tbl_like WHERE user_id = ? AND video_type = ? AND sub_video_type = ? AND video_id = ? LIMIT 1',
      [userId, videoType, subVideoType, videoId],
    );

    if (existingRows.length > 0) {
      const existingId = Number(existingRows[0].id);
      await dbPool.query('DELETE FROM tbl_like WHERE id = ?', [existingId]);
      await this.decrementTotalLike(videoType, subVideoType, videoId);
      return false;
    }

    await dbPool.query(
      'INSERT INTO tbl_like (user_id, video_type, sub_video_type, video_id, status, created_at, updated_at) VALUES (?, ?, ?, ?, 1, NOW(), NOW())',
      [userId, videoType, subVideoType, videoId],
    );
    await this.incrementTotalLike(videoType, subVideoType, videoId);
    return true;
  }

  async toggleBookmark(
    userId: number,
    isKidsProfile: number,
    videoType: number,
    subVideoType: number,
    videoId: number,
  ): Promise<boolean> {
    const [existingRows] = await dbPool.query<Row[]>(
      'SELECT id FROM tbl_bookmark WHERE user_id = ? AND is_kids_profile = ? AND video_type = ? AND sub_video_type = ? AND video_id = ? LIMIT 1',
      [userId, isKidsProfile, videoType, subVideoType, videoId],
    );

    if (existingRows.length > 0) {
      const existingId = Number(existingRows[0].id);
      await dbPool.query('DELETE FROM tbl_bookmark WHERE id = ?', [existingId]);
      return false;
    }

    await dbPool.query(
      `INSERT INTO tbl_bookmark
      (user_id, is_kids_profile, video_type, sub_video_type, video_id, status, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, 1, NOW(), NOW())`,
      [userId, isKidsProfile, videoType, subVideoType, videoId],
    );
    return true;
  }

  private async incrementTotalLike(videoType: number, subVideoType: number, videoId: number): Promise<void> {
    if (videoType === 8) {
      await dbPool.query('UPDATE tbl_shorts SET total_like = total_like + 1 WHERE id = ?', [videoId]);
      return;
    }

    const useVideoTable = videoType === 1 || ((videoType === 5 || videoType === 6 || videoType === 7) && subVideoType !== 2);
    if (useVideoTable) {
      await dbPool.query('UPDATE tbl_video SET total_like = total_like + 1 WHERE id = ?', [videoId]);
      return;
    }

    await dbPool.query('UPDATE tbl_tv_show SET total_like = total_like + 1 WHERE id = ?', [videoId]);
  }

  private async decrementTotalLike(videoType: number, subVideoType: number, videoId: number): Promise<void> {
    if (videoType === 8) {
      await dbPool.query('UPDATE tbl_shorts SET total_like = GREATEST(total_like - 1, 0) WHERE id = ?', [videoId]);
      return;
    }

    const useVideoTable = videoType === 1 || ((videoType === 5 || videoType === 6 || videoType === 7) && subVideoType !== 2);
    if (useVideoTable) {
      await dbPool.query('UPDATE tbl_video SET total_like = GREATEST(total_like - 1, 0) WHERE id = ?', [videoId]);
      return;
    }

    await dbPool.query('UPDATE tbl_tv_show SET total_like = GREATEST(total_like - 1, 0) WHERE id = ?', [videoId]);
  }
}
