import { dbPool } from '../../config/database';
import type { ResultSetHeader, RowDataPacket } from 'mysql2';

type Row = RowDataPacket & Record<string, unknown>;

export type DtliveUserRow = {
  id: number;
  user_name: string;
  full_name: string;
  email: string;
  password: string;
  mobile_number: string;
  storage_type: number;
  image_type: number;
  image: string;
  type: number;
  parent_control_status: number;
  parent_control_password: string;
  status: number;
  created_at: string;
  updated_at: string;
};

export type DtliveDeviceSyncRow = {
  id: number;
  user_id: number;
  device_name: string;
  device_id: string;
  device_type: number;
  device_token: string;
  kids_mode: number;
  status: number;
  created_at: string;
  updated_at: string;
};

export class DtliveRepository {
  async createTvLoginCode(uniqueCode: string): Promise<Row | null> {
    const [result] = await dbPool.query<ResultSetHeader>(
      `INSERT INTO tbl_tv_login (unique_code, user_id, status, created_at, updated_at)
       VALUES (?, 0, 0, NOW(), NOW())`,
      [uniqueCode],
    );

    const insertedId = Number(result.insertId ?? 0);
    if (insertedId <= 0) {
      return null;
    }

    const [rows] = await dbPool.query<Row[]>(
      'SELECT * FROM tbl_tv_login WHERE id = ? LIMIT 1',
      [insertedId],
    );
    return rows[0] ?? null;
  }

  async bindTvLoginCode(uniqueCode: string, userId: number): Promise<boolean> {
    const [result] = await dbPool.query<ResultSetHeader>(
      `UPDATE tbl_tv_login
       SET status = 1, user_id = ?, updated_at = NOW()
       WHERE unique_code = ? AND status = 0 AND user_id = 0`,
      [userId, uniqueCode],
    );
    return Number(result.affectedRows ?? 0) > 0;
  }

  async getTvLoginByUniqueCode(uniqueCode: string): Promise<Row | null> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT * FROM tbl_tv_login WHERE unique_code = ? LIMIT 1',
      [uniqueCode],
    );
    return rows[0] ?? null;
  }

  async getChannels(): Promise<Row[]> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT * FROM tbl_channel WHERE status = 1 ORDER BY id DESC',
    );
    return rows;
  }

  async getGeneralSettings(): Promise<Array<{ key: string; value: string }>> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT `key`, `value` FROM tbl_general_setting',
    );
    return rows.map((row) => ({
      key: String(row.key ?? ''),
      value: String(row.value ?? ''),
    }));
  }

  async getGeneralSettingValue(key: string): Promise<string> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT `value` FROM tbl_general_setting WHERE `key` = ? LIMIT 1',
      [key],
    );
    return String(rows[0]?.value ?? '');
  }

  async getPaymentOptions(): Promise<Row[]> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT * FROM tbl_payment_option',
    );
    return rows;
  }

  async getPaymentOptionById(id: number): Promise<Row | null> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT * FROM tbl_payment_option WHERE id = ? LIMIT 1',
      [id],
    );
    return rows[0] ?? null;
  }

  async getSocialLinks(): Promise<Row[]> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT * FROM tbl_social_link',
    );
    return rows;
  }

  async getOnboardingScreens(): Promise<Row[]> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT * FROM tbl_onboarding_screen',
    );
    return rows;
  }

  async getPages(): Promise<Row[]> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT * FROM tbl_page WHERE status = 1',
    );
    return rows;
  }

  async getHomeSectionById(sectionId: number): Promise<Row | null> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT * FROM tbl_home_section WHERE id = ? LIMIT 1',
      [sectionId],
    );
    return rows[0] ?? null;
  }

  async getBanners(isHomeScreen: number, typeId: number, userParentControlStatus: number): Promise<Row[]> {
    if (isHomeScreen === 1) {
      if (userParentControlStatus === 1) {
        const [rows] = await dbPool.query<Row[]>(
          'SELECT * FROM tbl_banner WHERE is_home_screen = 1 AND video_type = 7 ORDER BY sort_order ASC, id DESC',
        );
        return rows;
      }

      const [rows] = await dbPool.query<Row[]>(
        'SELECT * FROM tbl_banner WHERE is_home_screen = 1 ORDER BY sort_order ASC, id DESC',
      );
      return rows;
    }

    if (isHomeScreen === 2) {
      if (userParentControlStatus === 1) {
        const [rows] = await dbPool.query<Row[]>(
          'SELECT * FROM tbl_banner WHERE is_home_screen = 2 AND video_type = 7 AND type_id = ? ORDER BY sort_order ASC, id DESC',
          [typeId],
        );
        return rows;
      }

      const [rows] = await dbPool.query<Row[]>(
        'SELECT * FROM tbl_banner WHERE is_home_screen = 2 AND type_id = ? ORDER BY sort_order ASC, id DESC',
        [typeId],
      );
      return rows;
    }

    return [];
  }

  async getVideoByIdAndType(videoId: number, videoType: number): Promise<Row | null> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT * FROM tbl_video WHERE id = ? AND video_type = ? AND status = 1 LIMIT 1',
      [videoId, videoType],
    );
    return rows[0] ?? null;
  }

  async getTvShowByIdAndType(videoId: number, videoType: number): Promise<Row | null> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT * FROM tbl_tv_show WHERE id = ? AND video_type = ? AND status = 1 LIMIT 1',
      [videoId, videoType],
    );
    return rows[0] ?? null;
  }

  async getShortByIdAndType(videoId: number, videoType: number): Promise<Row | null> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT * FROM tbl_shorts WHERE id = ? AND video_type = ? AND status = 1 LIMIT 1',
      [videoId, videoType],
    );
    return rows[0] ?? null;
  }

  async getVideosByCategory(categoryId: number, videoTypes: number[]): Promise<Row[]> {
    if (videoTypes.length === 0) {
      return [];
    }

    const placeholders = videoTypes.map(() => '?').join(',');
    const [rows] = await dbPool.query<Row[]>(
      `SELECT * FROM tbl_video
       WHERE status = 1
         AND video_type IN (${placeholders})
         AND FIND_IN_SET(?, category_id)
       ORDER BY id DESC`,
      [...videoTypes, categoryId],
    );
    return rows;
  }

  async getTvShowsByCategory(categoryId: number, videoTypes: number[]): Promise<Row[]> {
    if (videoTypes.length === 0) {
      return [];
    }

    const placeholders = videoTypes.map(() => '?').join(',');
    const [rows] = await dbPool.query<Row[]>(
      `SELECT * FROM tbl_tv_show
       WHERE status = 1
         AND video_type IN (${placeholders})
         AND FIND_IN_SET(?, category_id)
       ORDER BY id DESC`,
      [...videoTypes, categoryId],
    );
    return rows;
  }

  async getVideosByLanguage(languageId: number, videoTypes: number[]): Promise<Row[]> {
    if (videoTypes.length === 0) {
      return [];
    }

    const placeholders = videoTypes.map(() => '?').join(',');
    const [rows] = await dbPool.query<Row[]>(
      `SELECT * FROM tbl_video
       WHERE status = 1
         AND video_type IN (${placeholders})
         AND FIND_IN_SET(?, language_id)
       ORDER BY id DESC`,
      [...videoTypes, languageId],
    );
    return rows;
  }

  async getTvShowsByLanguage(languageId: number, videoTypes: number[]): Promise<Row[]> {
    if (videoTypes.length === 0) {
      return [];
    }

    const placeholders = videoTypes.map(() => '?').join(',');
    const [rows] = await dbPool.query<Row[]>(
      `SELECT * FROM tbl_tv_show
       WHERE status = 1
         AND video_type IN (${placeholders})
         AND FIND_IN_SET(?, language_id)
       ORDER BY id DESC`,
      [...videoTypes, languageId],
    );
    return rows;
  }

  async getVideosByCast(castId: number, videoTypes: number[]): Promise<Row[]> {
    if (videoTypes.length === 0) {
      return [];
    }

    const placeholders = videoTypes.map(() => '?').join(',');
    const [rows] = await dbPool.query<Row[]>(
      `SELECT * FROM tbl_video
       WHERE status = 1
         AND video_type IN (${placeholders})
         AND FIND_IN_SET(?, cast_id)
       ORDER BY id DESC`,
      [...videoTypes, castId],
    );
    return rows;
  }

  async getTvShowsByCast(castId: number, videoTypes: number[]): Promise<Row[]> {
    if (videoTypes.length === 0) {
      return [];
    }

    const placeholders = videoTypes.map(() => '?').join(',');
    const [rows] = await dbPool.query<Row[]>(
      `SELECT * FROM tbl_tv_show
       WHERE status = 1
         AND video_type IN (${placeholders})
         AND FIND_IN_SET(?, cast_id)
       ORDER BY id DESC`,
      [...videoTypes, castId],
    );
    return rows;
  }

  async getCastById(castId: number): Promise<Row | null> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT * FROM tbl_cast WHERE id = ? AND status = 1 LIMIT 1',
      [castId],
    );
    return rows[0] ?? null;
  }

  async getRelatedVideosByCategoriesCount(videoType: number, excludeVideoId: number, categoryIds: number[]): Promise<number> {
    if (categoryIds.length === 0) {
      return 0;
    }

    const categoryFilter = categoryIds.map(() => 'FIND_IN_SET(?, category_id)').join(' OR ');
    const [rows] = await dbPool.query<Row[]>(
      `SELECT COUNT(*) AS total
       FROM tbl_video
       WHERE status = 1 AND video_type = ? AND id <> ? AND (${categoryFilter})`,
      [videoType, excludeVideoId, ...categoryIds],
    );
    return Number(rows[0]?.total ?? 0);
  }

  async getRelatedVideosByCategories(videoType: number, excludeVideoId: number, categoryIds: number[], offset: number, limit: number): Promise<Row[]> {
    if (categoryIds.length === 0) {
      return [];
    }

    const categoryFilter = categoryIds.map(() => 'FIND_IN_SET(?, category_id)').join(' OR ');
    const [rows] = await dbPool.query<Row[]>(
      `SELECT *
       FROM tbl_video
       WHERE status = 1 AND video_type = ? AND id <> ? AND (${categoryFilter})
       ORDER BY id DESC
       LIMIT ? OFFSET ?`,
      [videoType, excludeVideoId, ...categoryIds, limit, offset],
    );
    return rows;
  }

  async getRelatedTvShowsByCategoriesCount(videoType: number, excludeVideoId: number, categoryIds: number[]): Promise<number> {
    if (categoryIds.length === 0) {
      return 0;
    }

    const categoryFilter = categoryIds.map(() => 'FIND_IN_SET(?, category_id)').join(' OR ');
    const [rows] = await dbPool.query<Row[]>(
      `SELECT COUNT(*) AS total
       FROM tbl_tv_show
       WHERE status = 1 AND video_type = ? AND id <> ? AND (${categoryFilter})`,
      [videoType, excludeVideoId, ...categoryIds],
    );
    return Number(rows[0]?.total ?? 0);
  }

  async getRelatedTvShowsByCategories(videoType: number, excludeVideoId: number, categoryIds: number[], offset: number, limit: number): Promise<Row[]> {
    if (categoryIds.length === 0) {
      return [];
    }

    const categoryFilter = categoryIds.map(() => 'FIND_IN_SET(?, category_id)').join(' OR ');
    const [rows] = await dbPool.query<Row[]>(
      `SELECT *
       FROM tbl_tv_show
       WHERE status = 1 AND video_type = ? AND id <> ? AND (${categoryFilter})
       ORDER BY id DESC
       LIMIT ? OFFSET ?`,
      [videoType, excludeVideoId, ...categoryIds, limit, offset],
    );
    return rows;
  }

  async getCategoryIdsByExactName(name: string): Promise<number[]> {
    if (!name.trim()) {
      return [];
    }

    const [rows] = await dbPool.query<Row[]>(
      'SELECT id FROM tbl_category WHERE name = ? AND status = 1 ORDER BY id DESC',
      [name.trim()],
    );
    return rows.map((row) => Number(row.id ?? 0)).filter((id) => id > 0);
  }

  async getLanguageIdsByExactName(name: string): Promise<number[]> {
    if (!name.trim()) {
      return [];
    }

    const [rows] = await dbPool.query<Row[]>(
      'SELECT id FROM tbl_language WHERE name = ? AND status = 1 ORDER BY id DESC',
      [name.trim()],
    );
    return rows.map((row) => Number(row.id ?? 0)).filter((id) => id > 0);
  }

  async searchVideosByNameCategoryLanguage(name: string, categoryIds: number[], languageIds: number[], videoTypes: number[]): Promise<Row[]> {
    if (videoTypes.length === 0) {
      return [];
    }

    const typePlaceholders = videoTypes.map(() => '?').join(',');
    const conditions: string[] = ['name LIKE ?'];
    const params: Array<string | number> = [`%${name}%`];

    if (categoryIds.length > 0) {
      const categoryCondition = categoryIds.map(() => 'FIND_IN_SET(?, category_id)').join(' OR ');
      conditions.push(`(${categoryCondition})`);
      params.push(...categoryIds);
    }

    if (languageIds.length > 0) {
      const languageCondition = languageIds.map(() => 'FIND_IN_SET(?, language_id)').join(' OR ');
      conditions.push(`(${languageCondition})`);
      params.push(...languageIds);
    }

    const [rows] = await dbPool.query<Row[]>(
      `SELECT * FROM tbl_video
       WHERE video_type IN (${typePlaceholders})
         AND status = 1
         AND (${conditions.join(' OR ')})
       ORDER BY id DESC`,
      [...videoTypes, ...params],
    );
    return rows;
  }

  async searchTvShowsByNameCategoryLanguage(name: string, categoryIds: number[], languageIds: number[], videoTypes: number[]): Promise<Row[]> {
    if (videoTypes.length === 0) {
      return [];
    }

    const typePlaceholders = videoTypes.map(() => '?').join(',');
    const conditions: string[] = ['name LIKE ?'];
    const params: Array<string | number> = [`%${name}%`];

    if (categoryIds.length > 0) {
      const categoryCondition = categoryIds.map(() => 'FIND_IN_SET(?, category_id)').join(' OR ');
      conditions.push(`(${categoryCondition})`);
      params.push(...categoryIds);
    }

    if (languageIds.length > 0) {
      const languageCondition = languageIds.map(() => 'FIND_IN_SET(?, language_id)').join(' OR ');
      conditions.push(`(${languageCondition})`);
      params.push(...languageIds);
    }

    const [rows] = await dbPool.query<Row[]>(
      `SELECT * FROM tbl_tv_show
       WHERE video_type IN (${typePlaceholders})
         AND status = 1
         AND (${conditions.join(' OR ')})
       ORDER BY id DESC`,
      [...videoTypes, ...params],
    );
    return rows;
  }

  async getUserById(userId: number): Promise<DtliveUserRow | null> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT
         id, user_name, full_name, email, password, mobile_number,
         storage_type, image_type, image, type, parent_control_status,
         parent_control_password, status, created_at, updated_at
       FROM tbl_user
       WHERE id = ?
       LIMIT 1`,
      [userId],
    );
    return this.mapUserRow(rows[0]);
  }

  async getUserByEmailAndType(email: string, type: number): Promise<DtliveUserRow | null> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT
         id, user_name, full_name, email, password, mobile_number,
         storage_type, image_type, image, type, parent_control_status,
         parent_control_password, status, created_at, updated_at
       FROM tbl_user
       WHERE email = ? AND type = ?
       ORDER BY id DESC
       LIMIT 1`,
      [email, type],
    );
    return this.mapUserRow(rows[0]);
  }

  async getUserByMobileAndType(mobileNumber: string, type: number): Promise<DtliveUserRow | null> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT
         id, user_name, full_name, email, password, mobile_number,
         storage_type, image_type, image, type, parent_control_status,
         parent_control_password, status, created_at, updated_at
       FROM tbl_user
       WHERE mobile_number = ? AND type = ?
       ORDER BY id DESC
       LIMIT 1`,
      [mobileNumber, type],
    );
    return this.mapUserRow(rows[0]);
  }

  async existsUserName(userName: string, exceptUserId?: number): Promise<boolean> {
    const params: unknown[] = [userName];
    let query = 'SELECT id FROM tbl_user WHERE user_name = ?';
    if (exceptUserId && exceptUserId > 0) {
      query += ' AND id <> ?';
      params.push(exceptUserId);
    }
    query += ' LIMIT 1';

    const [rows] = await dbPool.query<Row[]>(query, params);
    return rows.length > 0;
  }

  async existsUserEmail(email: string, exceptUserId?: number): Promise<boolean> {
    const params: unknown[] = [email];
    let query = 'SELECT id FROM tbl_user WHERE email = ?';
    if (exceptUserId && exceptUserId > 0) {
      query += ' AND id <> ?';
      params.push(exceptUserId);
    }
    query += ' LIMIT 1';

    const [rows] = await dbPool.query<Row[]>(query, params);
    return rows.length > 0;
  }

  async existsUserMobile(mobileNumber: string, exceptUserId?: number): Promise<boolean> {
    const params: unknown[] = [mobileNumber];
    let query = 'SELECT id FROM tbl_user WHERE mobile_number = ?';
    if (exceptUserId && exceptUserId > 0) {
      query += ' AND id <> ?';
      params.push(exceptUserId);
    }
    query += ' LIMIT 1';

    const [rows] = await dbPool.query<Row[]>(query, params);
    return rows.length > 0;
  }

  async createUser(input: {
    userName: string;
    fullName: string;
    email: string;
    password: string;
    mobileNumber: string;
    storageType: number;
    imageType: number;
    image: string;
    type: number;
    parentControlStatus: number;
    parentControlPassword: string;
    status: number;
  }): Promise<number> {
    const [result] = await dbPool.query<ResultSetHeader>(
      `INSERT INTO tbl_user
      (
        user_name, full_name, email, password, mobile_number,
        storage_type, image_type, image, type, parent_control_status,
        parent_control_password, status, created_at, updated_at
      )
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())`,
      [
        input.userName,
        input.fullName,
        input.email,
        input.password,
        input.mobileNumber,
        input.storageType,
        input.imageType,
        input.image,
        input.type,
        input.parentControlStatus,
        input.parentControlPassword,
        input.status,
      ],
    );

    return Number(result.insertId ?? 0);
  }

  async updateUserProfile(
    userId: number,
    fields: Partial<{
      user_name: string;
      full_name: string;
      email: string;
      mobile_number: string;
      storage_type: number;
      image_type: number;
      image: string;
      parent_control_status: number;
      parent_control_password: string;
    }>,
  ): Promise<void> {
    const entries = Object.entries(fields).filter(([, value]) => value !== undefined);
    if (entries.length === 0) {
      return;
    }

    const setClause = entries.map(([key]) => `\`${key}\` = ?`).join(', ');
    const params = entries.map(([, value]) => value);
    params.push(userId);

    await dbPool.query(`UPDATE tbl_user SET ${setClause}, updated_at = NOW() WHERE id = ?`, params);
  }

  async getUserDeviceSyncList(userId: number): Promise<DtliveDeviceSyncRow[]> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT
         id, user_id, device_name, device_id, device_type,
         device_token, kids_mode, status, created_at, updated_at
       FROM tbl_device_sync
       WHERE user_id = ?
       ORDER BY id DESC`,
      [userId],
    );
    return rows.map((row) => this.mapDeviceSyncRow(row)).filter((row): row is DtliveDeviceSyncRow => row !== null);
  }

  async getUserDeviceSyncByDeviceId(userId: number, deviceId: string): Promise<DtliveDeviceSyncRow | null> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT
         id, user_id, device_name, device_id, device_type,
         device_token, kids_mode, status, created_at, updated_at
       FROM tbl_device_sync
       WHERE user_id = ? AND device_id = ?
       LIMIT 1`,
      [userId, deviceId],
    );
    return this.mapDeviceSyncRow(rows[0]);
  }

  async deleteDeviceSync(deviceSyncId: number, deviceId: string): Promise<number> {
    const [result] = await dbPool.query<ResultSetHeader>(
      'DELETE FROM tbl_device_sync WHERE id = ? AND device_id = ? AND status = 1',
      [deviceSyncId, deviceId],
    );
    return Number(result.affectedRows ?? 0);
  }

  async createUserDeviceSync(input: {
    userId: number;
    deviceName: string;
    deviceId: string;
    deviceType: number;
    deviceToken: string;
    kidsMode?: number;
    status?: number;
  }): Promise<DtliveDeviceSyncRow | null> {
    const [result] = await dbPool.query<ResultSetHeader>(
      `INSERT INTO tbl_device_sync
      (user_id, device_name, device_id, device_type, device_token, kids_mode, status, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, NOW(), NOW())`,
      [
        input.userId,
        input.deviceName,
        input.deviceId,
        input.deviceType,
        input.deviceToken,
        input.kidsMode ?? 0,
        input.status ?? 1,
      ],
    );

    const insertedId = Number(result.insertId ?? 0);
    if (insertedId <= 0) {
      return null;
    }

    const [rows] = await dbPool.query<Row[]>(
      `SELECT
         id, user_id, device_name, device_id, device_type,
         device_token, kids_mode, status, created_at, updated_at
       FROM tbl_device_sync
       WHERE id = ?
       LIMIT 1`,
      [insertedId],
    );
    return this.mapDeviceSyncRow(rows[0]);
  }

  async expirePackageTransactions(): Promise<void> {
    await dbPool.query(
      `UPDATE tbl_transaction
       SET status = 0, updated_at = NOW()
       WHERE status = 1
         AND transaction_status = 2
         AND COALESCE(
           STR_TO_DATE(expiry_date, '%Y-%m-%d %H:%i:%s'),
           STR_TO_DATE(expiry_date, '%Y-%m-%d')
         ) <= NOW()`,
    );
  }

  async getUserPackageDeviceLimit(userId: number): Promise<number | null> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT p.no_of_device_sync AS no_of_device_sync
       FROM tbl_transaction t
       INNER JOIN tbl_package p ON p.id = t.package_id
       WHERE t.user_id = ? AND t.status = 1 AND t.transaction_status = 2
       ORDER BY t.id ASC
       LIMIT 1`,
      [userId],
    );

    if (rows.length === 0) {
      return null;
    }

    return Number(rows[0].no_of_device_sync ?? 0);
  }

  async hasAnyActivePackage(userId: number): Promise<boolean> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT id
       FROM tbl_transaction
       WHERE user_id = ? AND status = 1 AND transaction_status = 2
       ORDER BY id DESC
       LIMIT 1`,
      [userId],
    );
    return rows.length > 0;
  }

  async getDeviceWatchingByUserAndDevice(userId: number, deviceId: string): Promise<Row | null> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT * FROM tbl_device_watching WHERE user_id = ? AND device_id = ? LIMIT 1',
      [userId, deviceId],
    );
    return rows[0] ?? null;
  }

  async createDeviceWatching(userId: number, deviceId: string): Promise<number> {
    const [result] = await dbPool.query<ResultSetHeader>(
      `INSERT INTO tbl_device_watching (user_id, device_id, status, created_at, updated_at)
       VALUES (?, ?, 1, NOW(), NOW())`,
      [userId, deviceId],
    );
    return Number(result.insertId ?? 0);
  }

  async deleteDeviceWatchingByUserAndDevice(userId: number, deviceId: string): Promise<number> {
    const [result] = await dbPool.query<ResultSetHeader>(
      'DELETE FROM tbl_device_watching WHERE user_id = ? AND device_id = ?',
      [userId, deviceId],
    );
    return Number(result.affectedRows ?? 0);
  }

  async getDeviceWatchingWithSync(userId: number): Promise<Row[]> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT ds.*
       FROM tbl_device_watching dw
       LEFT JOIN tbl_device_sync ds
         ON ds.user_id = dw.user_id AND ds.device_id = dw.device_id
       WHERE dw.user_id = ?
       ORDER BY dw.id DESC`,
      [userId],
    );
    return rows.filter((row) => Number(row.id ?? 0) > 0);
  }

  async getActivePackageMeta(userId: number): Promise<{ packageName: string; expiryDate: string }> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT p.name AS package_name, t.expiry_date AS expiry_date
       FROM tbl_transaction t
       LEFT JOIN tbl_package p ON p.id = t.package_id
       WHERE t.user_id = ? AND t.status = 1 AND t.transaction_status = 2
       ORDER BY t.id ASC
       LIMIT 1`,
      [userId],
    );

    if (rows.length === 0) {
      return { packageName: '', expiryDate: '' };
    }

    return {
      packageName: String(rows[0].package_name ?? ''),
      expiryDate: String(rows[0].expiry_date ?? ''),
    };
  }

  async getUpcomingPackages(userId: number): Promise<Row[]> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT p.*
       FROM tbl_transaction t
       LEFT JOIN tbl_package p ON p.id = t.package_id
       WHERE t.user_id = ? AND t.status = 1 AND t.transaction_status = 2
       ORDER BY t.id ASC`,
      [userId],
    );

    if (rows.length <= 1) {
      return [];
    }

    return rows.slice(1);
  }

  async getAvatarById(avatarId: number): Promise<Row | null> {
    if (!Number.isFinite(avatarId) || avatarId <= 0) {
      return null;
    }

    const [rows] = await dbPool.query<Row[]>(
      'SELECT id, name, storage_type, image, status FROM tbl_avatar WHERE id = ? LIMIT 1',
      [avatarId],
    );
    return rows[0] ?? null;
  }

  async getAvatars(): Promise<Row[]> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT * FROM tbl_avatar WHERE status = 1 ORDER BY id DESC',
    );
    return rows;
  }

  async getCategories(): Promise<Row[]> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT * FROM tbl_category WHERE status = 1 ORDER BY sort_order ASC, id DESC',
    );
    return rows;
  }

  async getLanguages(): Promise<Row[]> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT * FROM tbl_language WHERE status = 1 ORDER BY sort_order ASC, id DESC',
    );
    return rows;
  }

  async getTypes(userParentControlStatus: number): Promise<Row[]> {
    if (userParentControlStatus === 1) {
      const [rows] = await dbPool.query<Row[]>(
        'SELECT * FROM tbl_type WHERE type = 7 AND status = 1 ORDER BY sort_order ASC, id DESC',
      );
      return rows;
    }

    const [rows] = await dbPool.query<Row[]>(
      'SELECT * FROM tbl_type WHERE status = 1 ORDER BY sort_order ASC, id DESC',
    );
    return rows;
  }

  async getPackages(): Promise<Row[]> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT id, package_type, name, price, time, type, android_product_package, ios_product_package, web_product_package
       FROM tbl_package
       WHERE status = 1
       ORDER BY price ASC, id ASC`,
    );
    return rows;
  }

  async getPackageDetails(packageId: number): Promise<Row[]> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT * FROM tbl_package_detail WHERE package_id = ? ORDER BY id ASC',
      [packageId],
    );
    return rows;
  }

  async getActiveTransactionByUser(userId: number): Promise<Row | null> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT *
       FROM tbl_transaction
       WHERE user_id = ? AND status = 1 AND transaction_status = 2
       ORDER BY id ASC
       LIMIT 1`,
      [userId],
    );
    return rows[0] ?? null;
  }

  async hasSuccessfulPackageTransaction(userId: number, packageId: number): Promise<boolean> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT id
       FROM tbl_transaction
       WHERE user_id = ? AND package_id = ? AND status = 1 AND transaction_status = 2
       LIMIT 1`,
      [userId, packageId],
    );
    return rows.length > 0;
  }

  async getPackageById(packageId: number): Promise<Row | null> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT * FROM tbl_package WHERE id = ? AND status = 1 LIMIT 1',
      [packageId],
    );
    return rows[0] ?? null;
  }

  async hasAnyPackageTransaction(userId: number, packageId: number): Promise<boolean> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT id FROM tbl_transaction WHERE user_id = ? AND package_id = ? LIMIT 1',
      [userId, packageId],
    );
    return rows.length > 0;
  }

  async getLatestSuccessfulPackageTransaction(userId: number): Promise<Row | null> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT *
       FROM tbl_transaction
       WHERE user_id = ? AND status = 1 AND transaction_status = 2
       ORDER BY id DESC
       LIMIT 1`,
      [userId],
    );
    return rows[0] ?? null;
  }

  async createTransaction(input: {
    uniqueId: string;
    userId: number;
    packageId: number;
    transactionId: string;
    price: number;
    description: string;
    expiryDate: string;
    transactionStatus: number;
    status: number;
  }): Promise<Row | null> {
    const [result] = await dbPool.query<ResultSetHeader>(
      `INSERT INTO tbl_transaction
       (unique_id, user_id, package_id, transaction_id, price, description, expiry_date, transaction_status, status, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())`,
      [
        input.uniqueId,
        input.userId,
        input.packageId,
        input.transactionId,
        String(input.price),
        input.description,
        input.expiryDate,
        input.transactionStatus,
        input.status,
      ],
    );

    const insertId = Number(result.insertId ?? 0);
    if (insertId <= 0) {
      return null;
    }

    const [rows] = await dbPool.query<Row[]>('SELECT * FROM tbl_transaction WHERE id = ? LIMIT 1', [insertId]);
    return rows[0] ?? null;
  }

  async getRentContent(videoType: number, subVideoType: number, videoId: number): Promise<Row | null> {
    if (videoType === 1) {
      const [rows] = await dbPool.query<Row[]>(
        'SELECT * FROM tbl_video WHERE id = ? AND video_type = 1 AND status = 1 AND is_rent = 1 LIMIT 1',
        [videoId],
      );
      return rows[0] ?? null;
    }

    if (videoType === 2) {
      const [rows] = await dbPool.query<Row[]>(
        'SELECT * FROM tbl_tv_show WHERE id = ? AND video_type = 2 AND status = 1 AND is_rent = 1 LIMIT 1',
        [videoId],
      );
      return rows[0] ?? null;
    }

    if ([5, 6, 7].includes(videoType)) {
      if (subVideoType === 1) {
        const [rows] = await dbPool.query<Row[]>(
          'SELECT * FROM tbl_video WHERE id = ? AND video_type = ? AND status = 1 AND is_rent = 1 LIMIT 1',
          [videoId, videoType],
        );
        return rows[0] ?? null;
      }

      if (subVideoType === 2) {
        const [rows] = await dbPool.query<Row[]>(
          'SELECT * FROM tbl_tv_show WHERE id = ? AND video_type = ? AND status = 1 AND is_rent = 1 LIMIT 1',
          [videoId, videoType],
        );
        return rows[0] ?? null;
      }
    }

    return null;
  }

  async createRentTransaction(input: {
    uniqueId: string;
    userId: number;
    producerId: number;
    videoType: number;
    subVideoType: number;
    videoId: number;
    price: number;
    producerEarning: number;
    commission: number;
    transactionId: string;
    description: string;
    expiryDate: string;
    transactionStatus: number;
    status: number;
  }): Promise<Row | null> {
    const [result] = await dbPool.query<ResultSetHeader>(
      `INSERT INTO tbl_rent_transaction
       (unique_id, user_id, producer_id, video_type, sub_video_type, video_id, price, producer_earning, commission, transaction_id, description, expiry_date, transaction_status, status, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())`,
      [
        input.uniqueId,
        input.userId,
        input.producerId,
        input.videoType,
        input.subVideoType,
        input.videoId,
        input.price,
        input.producerEarning,
        input.commission,
        input.transactionId,
        input.description,
        input.expiryDate,
        input.transactionStatus,
        input.status,
      ],
    );

    const insertId = Number(result.insertId ?? 0);
    if (insertId <= 0) {
      return null;
    }

    const [rows] = await dbPool.query<Row[]>('SELECT * FROM tbl_rent_transaction WHERE id = ? LIMIT 1', [insertId]);
    return rows[0] ?? null;
  }

  async updateTransactionStatus(type: number, userId: number, transactionId: number, transactionStatus: number): Promise<boolean> {
    if (type === 1) {
      return this.updateTransactionStatusInTable('tbl_transaction', userId, transactionId, transactionStatus);
    }
    if (type === 2) {
      return this.updateTransactionStatusInTable('tbl_rent_transaction', userId, transactionId, transactionStatus);
    }
    return false;
  }

  async getTransactionsCount(userId: number): Promise<number> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT COUNT(*) AS total FROM tbl_transaction WHERE user_id = ? AND transaction_status != 1',
      [userId],
    );
    return Number(rows[0]?.total ?? 0);
  }

  async getTransactions(userId: number, offset: number, limit: number): Promise<Row[]> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT t.*, p.name AS package_name, p.price AS package_price
       FROM tbl_transaction t
       LEFT JOIN tbl_package p ON p.id = t.package_id
       WHERE t.user_id = ? AND t.transaction_status != 1
       ORDER BY t.id DESC
       LIMIT ? OFFSET ?`,
      [userId, limit, offset],
    );
    return rows;
  }

  async getCouponsCount(): Promise<number> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT COUNT(*) AS total FROM tbl_coupon WHERE status = 1',
    );
    return Number(rows[0]?.total ?? 0);
  }

  async getCoupons(offset: number, limit: number): Promise<Row[]> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT * FROM tbl_coupon WHERE status = 1 ORDER BY id DESC LIMIT ? OFFSET ?',
      [limit, offset],
    );
    return rows;
  }

  async getAllActiveCoupons(): Promise<Row[]> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT * FROM tbl_coupon WHERE status = 1 ORDER BY id DESC',
    );
    return rows;
  }

  async expireRentTransactions(): Promise<void> {
    await dbPool.query(
      `UPDATE tbl_rent_transaction
       SET status = 0, updated_at = NOW()
       WHERE status = 1
         AND transaction_status = 2
         AND COALESCE(
           STR_TO_DATE(expiry_date, '%Y-%m-%d %H:%i:%s'),
           STR_TO_DATE(expiry_date, '%Y-%m-%d')
         ) <= NOW()`,
    );
  }

  async getSuccessfulRentTransactionsByUser(userId: number): Promise<Row[]> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT *
       FROM tbl_rent_transaction
       WHERE user_id = ? AND status = 1 AND transaction_status = 2
       ORDER BY id DESC`,
      [userId],
    );
    return rows;
  }

  async getVideosByIds(ids: number[]): Promise<Row[]> {
    if (ids.length === 0) {
      return [];
    }

    const placeholders = ids.map(() => '?').join(',');
    const [rows] = await dbPool.query<Row[]>(
      `SELECT *
       FROM tbl_video
       WHERE status = 1 AND id IN (${placeholders})
       ORDER BY id DESC`,
      ids,
    );
    return rows;
  }

  async getTvShowsByIds(ids: number[]): Promise<Row[]> {
    if (ids.length === 0) {
      return [];
    }

    const placeholders = ids.map(() => '?').join(',');
    const [rows] = await dbPool.query<Row[]>(
      `SELECT *
       FROM tbl_tv_show
       WHERE status = 1 AND id IN (${placeholders})
       ORDER BY id DESC`,
      ids,
    );
    return rows;
  }

  async getRentVideosCount(videoTypes: number[]): Promise<number> {
    if (videoTypes.length === 0) {
      return 0;
    }

    const placeholders = videoTypes.map(() => '?').join(',');
    const [rows] = await dbPool.query<Row[]>(
      `SELECT COUNT(*) AS total
       FROM tbl_video
       WHERE status = 1 AND is_rent = 1 AND video_type IN (${placeholders})`,
      videoTypes,
    );
    return Number(rows[0]?.total ?? 0);
  }

  async getRentVideos(videoTypes: number[], offset: number, limit: number): Promise<Row[]> {
    if (videoTypes.length === 0) {
      return [];
    }

    const placeholders = videoTypes.map(() => '?').join(',');
    const [rows] = await dbPool.query<Row[]>(
      `SELECT *
       FROM tbl_video
       WHERE status = 1 AND is_rent = 1 AND video_type IN (${placeholders})
       ORDER BY id DESC
       LIMIT ? OFFSET ?`,
      [...videoTypes, limit, offset],
    );
    return rows;
  }

  async getAllRentVideos(videoTypes: number[]): Promise<Row[]> {
    if (videoTypes.length === 0) {
      return [];
    }

    const placeholders = videoTypes.map(() => '?').join(',');
    const [rows] = await dbPool.query<Row[]>(
      `SELECT *
       FROM tbl_video
       WHERE status = 1 AND is_rent = 1 AND video_type IN (${placeholders})
       ORDER BY id DESC`,
      videoTypes,
    );
    return rows;
  }

  async getRentTvShowsCount(videoTypes: number[]): Promise<number> {
    if (videoTypes.length === 0) {
      return 0;
    }

    const placeholders = videoTypes.map(() => '?').join(',');
    const [rows] = await dbPool.query<Row[]>(
      `SELECT COUNT(*) AS total
       FROM tbl_tv_show
       WHERE status = 1 AND is_rent = 1 AND video_type IN (${placeholders})`,
      videoTypes,
    );
    return Number(rows[0]?.total ?? 0);
  }

  async getRentTvShows(videoTypes: number[], offset: number, limit: number): Promise<Row[]> {
    if (videoTypes.length === 0) {
      return [];
    }

    const placeholders = videoTypes.map(() => '?').join(',');
    const [rows] = await dbPool.query<Row[]>(
      `SELECT *
       FROM tbl_tv_show
       WHERE status = 1 AND is_rent = 1 AND video_type IN (${placeholders})
       ORDER BY id DESC
       LIMIT ? OFFSET ?`,
      [...videoTypes, limit, offset],
    );
    return rows;
  }

  async getAllRentTvShows(videoTypes: number[]): Promise<Row[]> {
    if (videoTypes.length === 0) {
      return [];
    }

    const placeholders = videoTypes.map(() => '?').join(',');
    const [rows] = await dbPool.query<Row[]>(
      `SELECT *
       FROM tbl_tv_show
       WHERE status = 1 AND is_rent = 1 AND video_type IN (${placeholders})
       ORDER BY id DESC`,
      videoTypes,
    );
    return rows;
  }

  async getCouponByUniqueId(uniqueId: string): Promise<Row | null> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT * FROM tbl_coupon WHERE unique_id = ? AND status = 1 LIMIT 1',
      [uniqueId],
    );
    return rows[0] ?? null;
  }

  async existsTable(tableName: string): Promise<boolean> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT COUNT(*) AS total
       FROM information_schema.tables
       WHERE table_schema = DATABASE() AND table_name = ?
       LIMIT 1`,
      [tableName],
    );
    return Number(rows[0]?.total ?? 0) > 0;
  }

  async existsColumn(tableName: string, columnName: string): Promise<boolean> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT COUNT(*) AS total
       FROM information_schema.columns
       WHERE table_schema = DATABASE() AND table_name = ? AND column_name = ?
       LIMIT 1`,
      [tableName, columnName],
    );
    return Number(rows[0]?.total ?? 0) > 0;
  }

  async getReferEarnHistoryCount(userId: number): Promise<number> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT COUNT(*) AS total FROM tbl_refer_earn WHERE parent_user_id = ?',
      [userId],
    );
    return Number(rows[0]?.total ?? 0);
  }

  async getReferEarnHistory(userId: number, offset: number, limit: number): Promise<Row[]> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT
         re.*,
         u.user_name AS child_user_name,
         u.full_name AS child_full_name,
         u.email AS child_email,
         u.mobile_number AS child_mobile_number
       FROM tbl_refer_earn re
       LEFT JOIN tbl_user u ON u.id = re.child_user_id
       WHERE re.parent_user_id = ?
       ORDER BY re.id DESC
       LIMIT ? OFFSET ?`,
      [userId, limit, offset],
    );
    return rows;
  }

  async createWalletTransaction(input: {
    userId: number;
    amount: number;
    transactionId: string;
    description: string;
    status: number;
  }): Promise<number> {
    const [result] = await dbPool.query<ResultSetHeader>(
      `INSERT INTO tbl_wallet_transaction
       (user_id, amount, transaction_id, description, status, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, NOW(), NOW())`,
      [input.userId, input.amount, input.transactionId, input.description, input.status],
    );
    return Number(result.insertId ?? 0);
  }

  async incrementUserWalletAmount(userId: number, amount: number): Promise<number> {
    const [result] = await dbPool.query<ResultSetHeader>(
      'UPDATE tbl_user SET wallet_amount = wallet_amount + ?, updated_at = NOW() WHERE id = ?',
      [amount, userId],
    );
    return Number(result.affectedRows ?? 0);
  }

  async getUserWalletAmount(userId: number): Promise<number> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT wallet_amount FROM tbl_user WHERE id = ? LIMIT 1',
      [userId],
    );
    return Number(rows[0]?.wallet_amount ?? 0);
  }

  async getWalletTransactionsCount(userId: number): Promise<number> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT COUNT(*) AS total FROM tbl_wallet_transaction WHERE user_id = ?',
      [userId],
    );
    return Number(rows[0]?.total ?? 0);
  }

  async getWalletTransactions(userId: number, offset: number, limit: number): Promise<Row[]> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT *
       FROM tbl_wallet_transaction
       WHERE user_id = ?
       ORDER BY id DESC
       LIMIT ? OFFSET ?`,
      [userId, limit, offset],
    );
    return rows;
  }

  async countCouponUsageByUniqueId(uniqueId: string): Promise<number> {
    const [packageRows] = await dbPool.query<Row[]>(
      'SELECT COUNT(*) AS total FROM tbl_transaction WHERE unique_id = ?',
      [uniqueId],
    );
    const [rentRows] = await dbPool.query<Row[]>(
      'SELECT COUNT(*) AS total FROM tbl_rent_transaction WHERE unique_id = ?',
      [uniqueId],
    );
    return Number(packageRows[0]?.total ?? 0) + Number(rentRows[0]?.total ?? 0);
  }

  async userUsedCouponUniqueId(userId: number, uniqueId: string): Promise<boolean> {
    const [packageRows] = await dbPool.query<Row[]>(
      'SELECT id FROM tbl_transaction WHERE user_id = ? AND unique_id = ? LIMIT 1',
      [userId, uniqueId],
    );
    if (packageRows.length > 0) {
      return true;
    }

    const [rentRows] = await dbPool.query<Row[]>(
      'SELECT id FROM tbl_rent_transaction WHERE user_id = ? AND unique_id = ? LIMIT 1',
      [userId, uniqueId],
    );
    return rentRows.length > 0;
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

  async getSectionVideoContent(section: Record<string, unknown>): Promise<Row[]> {
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

  async getSectionShortsContent(section: Record<string, unknown>): Promise<Row[]> {
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

  async getContinueWatchingAll(userId: number, isKidsProfile: number): Promise<Row[]> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT * FROM tbl_video_watch WHERE user_id = ? AND is_kids_profile = ? AND status = 1 ORDER BY id DESC',
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

  async getVideoMetaForReview(videoType: number, subVideoType: number, videoId: number): Promise<Row | null> {
    if (videoType === 8) {
      const [rows] = await dbPool.query<Row[]>(
        'SELECT id, avg_rating, total_review FROM tbl_shorts WHERE id = ? LIMIT 1',
        [videoId],
      );
      return rows[0] ?? null;
    }

    const useVideoTable = videoType === 1 || ((videoType === 6 || videoType === 7) && subVideoType === 1);
    if (useVideoTable) {
      const [rows] = await dbPool.query<Row[]>(
        'SELECT id, avg_rating, total_review FROM tbl_video WHERE id = ? LIMIT 1',
        [videoId],
      );
      return rows[0] ?? null;
    }

    const useShowTable = videoType === 2 || ((videoType === 6 || videoType === 7) && subVideoType === 2);
    if (useShowTable) {
      const [rows] = await dbPool.query<Row[]>(
        'SELECT id, avg_rating, total_review FROM tbl_tv_show WHERE id = ? LIMIT 1',
        [videoId],
      );
      return rows[0] ?? null;
    }

    return null;
  }

  async getReviewByUserContent(userId: number, videoType: number, subVideoType: number, videoId: number): Promise<Row | null> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT *
       FROM tbl_review
       WHERE user_id = ? AND video_type = ? AND sub_video_type = ? AND video_id = ?
       LIMIT 1`,
      [userId, videoType, subVideoType, videoId],
    );
    return rows[0] ?? null;
  }

  async updateReview(reviewId: number, rating: number, reviewText: string, status: number): Promise<number> {
    const [result] = await dbPool.query<ResultSetHeader>(
      'UPDATE tbl_review SET rating = ?, review_text = ?, status = ?, updated_at = NOW() WHERE id = ?',
      [rating, reviewText, status, reviewId],
    );
    return Number(result.affectedRows ?? 0);
  }

  async createReview(userId: number, videoType: number, subVideoType: number, videoId: number, rating: number, reviewText: string, status: number): Promise<number> {
    const [result] = await dbPool.query<ResultSetHeader>(
      `INSERT INTO tbl_review
       (user_id, video_type, sub_video_type, video_id, rating, review_text, status, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, NOW(), NOW())`,
      [userId, videoType, subVideoType, videoId, rating, reviewText, status],
    );
    return Number(result.insertId ?? 0);
  }

  async getApprovedReviewAggregate(videoType: number, subVideoType: number, videoId: number): Promise<{ avgRating: number; totalReview: number }> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT AVG(rating) AS avg_rating, COUNT(*) AS total_review
       FROM tbl_review
       WHERE video_type = ? AND sub_video_type = ? AND video_id = ? AND status = 1`,
      [videoType, subVideoType, videoId],
    );

    return {
      avgRating: Number(rows[0]?.avg_rating ?? 0),
      totalReview: Number(rows[0]?.total_review ?? 0),
    };
  }

  async updateContentReviewSummary(videoType: number, subVideoType: number, videoId: number, avgRating: number, totalReview: number): Promise<void> {
    if (videoType === 8) {
      await dbPool.query(
        'UPDATE tbl_shorts SET avg_rating = ?, total_review = ?, updated_at = NOW() WHERE id = ?',
        [avgRating, totalReview, videoId],
      );
      return;
    }

    const useVideoTable = videoType === 1 || ((videoType === 6 || videoType === 7) && subVideoType === 1);
    if (useVideoTable) {
      await dbPool.query(
        'UPDATE tbl_video SET avg_rating = ?, total_review = ?, updated_at = NOW() WHERE id = ?',
        [avgRating, totalReview, videoId],
      );
      return;
    }

    const useShowTable = videoType === 2 || ((videoType === 6 || videoType === 7) && subVideoType === 2);
    if (useShowTable) {
      await dbPool.query(
        'UPDATE tbl_tv_show SET avg_rating = ?, total_review = ?, updated_at = NOW() WHERE id = ?',
        [avgRating, totalReview, videoId],
      );
    }
  }

  async getReviewBreakdown(videoType: number, subVideoType: number, videoId: number): Promise<Record<number, number>> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT rating, COUNT(*) AS cnt
       FROM tbl_review
       WHERE video_type = ? AND sub_video_type = ? AND video_id = ? AND status = 1
       GROUP BY rating`,
      [videoType, subVideoType, videoId],
    );

    const map: Record<number, number> = {};
    for (const row of rows) {
      const rating = Number(row.rating ?? 0);
      map[rating] = Number(row.cnt ?? 0);
    }
    return map;
  }

  async getApprovedReviewsCount(videoType: number, subVideoType: number, videoId: number): Promise<number> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT COUNT(*) AS total FROM tbl_review WHERE video_type = ? AND sub_video_type = ? AND video_id = ? AND status = 1',
      [videoType, subVideoType, videoId],
    );
    return Number(rows[0]?.total ?? 0);
  }

  async getApprovedReviews(videoType: number, subVideoType: number, videoId: number, offset: number, limit: number): Promise<Row[]> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT r.*,
              u.full_name AS user_full_name,
              u.image_type AS user_image_type,
              u.image AS user_image
       FROM tbl_review r
       LEFT JOIN tbl_user u ON u.id = r.user_id
       WHERE r.video_type = ? AND r.sub_video_type = ? AND r.video_id = ? AND r.status = 1
       ORDER BY r.id DESC
       LIMIT ? OFFSET ?`,
      [videoType, subVideoType, videoId, limit, offset],
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

  async getStopTimeByEpisode(
    userId: number,
    videoType: number,
    subVideoType: number,
    videoId: number,
    episodeId: number,
  ): Promise<number> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT stop_time
       FROM tbl_video_watch
       WHERE user_id = ? AND video_type = ? AND sub_video_type = ? AND video_id = ? AND episode_id = ? AND status = 1
       ORDER BY id DESC
       LIMIT 1`,
      [userId, videoType, subVideoType, videoId, episodeId],
    );

    return Number(rows[0]?.stop_time ?? 0);
  }

  async isAnyPackageBuy(userId: number): Promise<boolean> {
    if (userId <= 0) {
      return false;
    }

    await this.expirePackageTransactions();

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

  async removeContinueWatching(
    userId: number,
    isKidsProfile: number,
    videoType: number,
    subVideoType: number,
    videoId: number,
  ): Promise<number> {
    const [result] = await dbPool.query<ResultSetHeader>(
      `DELETE FROM tbl_video_watch
       WHERE user_id = ? AND is_kids_profile = ? AND video_type = ? AND sub_video_type = ? AND video_id = ?`,
      [userId, isKidsProfile, videoType, subVideoType, videoId],
    );
    return Number(result.affectedRows ?? 0);
  }

  async getBookmarks(userId: number, isKidsProfile: number): Promise<Row[]> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT * FROM tbl_bookmark WHERE user_id = ? AND is_kids_profile = ? AND status = 1 ORDER BY id DESC',
      [userId, isKidsProfile],
    );
    return rows;
  }

  async getTvShowById(showId: number): Promise<Row | null> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT * FROM tbl_tv_show WHERE id = ? AND status = 1 LIMIT 1',
      [showId],
    );
    return rows[0] ?? null;
  }

  async getTvShowVideosBySeasonCount(showId: number, seasonId: number): Promise<number> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT COUNT(*) AS total FROM tbl_tv_show_video WHERE show_id = ? AND season_id = ? AND status = 1',
      [showId, seasonId],
    );
    return Number(rows[0]?.total ?? 0);
  }

  async getTvShowVideosBySeason(showId: number, seasonId: number, offset: number, limit: number): Promise<Row[]> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT *
       FROM tbl_tv_show_video
       WHERE show_id = ? AND season_id = ? AND status = 1
       ORDER BY sort_order ASC, id DESC
       LIMIT ? OFFSET ?`,
      [showId, seasonId, limit, offset],
    );
    return rows;
  }

  async getTvShowEpisodeById(showId: number, episodeId: number): Promise<Row | null> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT * FROM tbl_tv_show_video WHERE show_id = ? AND id = ? AND status = 1 LIMIT 1',
      [showId, episodeId],
    );
    return rows[0] ?? null;
  }

  async findViewRecord(userId: number, videoType: number, subVideoType: number, videoId: number, episodeId: number): Promise<Row | null> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT id
       FROM tbl_view
       WHERE user_id = ? AND video_type = ? AND sub_video_type = ? AND video_id = ? AND episode_id = ?
       LIMIT 1`,
      [userId, videoType, subVideoType, videoId, episodeId],
    );
    return rows[0] ?? null;
  }

  async createViewRecord(userId: number, videoType: number, subVideoType: number, videoId: number, episodeId: number): Promise<number> {
    const [result] = await dbPool.query<ResultSetHeader>(
      `INSERT INTO tbl_view
       (user_id, video_type, sub_video_type, video_id, episode_id, status, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, 1, NOW(), NOW())`,
      [userId, videoType, subVideoType, videoId, episodeId],
    );
    return Number(result.insertId ?? 0);
  }

  async incrementTotalView(videoType: number, subVideoType: number, videoId: number, episodeId: number): Promise<void> {
    if (videoType === 1 || ((videoType === 6 || videoType === 7) && subVideoType === 1)) {
      await dbPool.query('UPDATE tbl_video SET total_view = total_view + 1 WHERE id = ?', [videoId]);
      return;
    }

    if (videoType === 2 || ((videoType === 6 || videoType === 7) && subVideoType === 2)) {
      await dbPool.query('UPDATE tbl_tv_show SET total_view = total_view + 1 WHERE id = ?', [videoId]);
      if (episodeId > 0) {
        await dbPool.query('UPDATE tbl_tv_show_video SET total_view = total_view + 1 WHERE show_id = ? AND id = ?', [videoId, episodeId]);
      }
      return;
    }

    if (videoType === 8) {
      await dbPool.query('UPDATE tbl_shorts SET total_view = total_view + 1 WHERE id = ?', [videoId]);
      if (subVideoType === 3 && episodeId > 0) {
        await dbPool.query('UPDATE tbl_shorts_episode SET total_view = total_view + 1 WHERE show_id = ? AND id = ?', [videoId, episodeId]);
      }
    }
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

  async createComment(
    commentId: number,
    userId: number,
    videoType: number,
    subVideoType: number,
    videoId: number,
    comment: string,
  ): Promise<number> {
    const [result] = await dbPool.query<ResultSetHeader>(
      `INSERT INTO tbl_comment
       (comment_id, user_id, video_type, sub_video_type, video_id, comment, status, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, ?, 1, NOW(), NOW())`,
      [commentId, userId, videoType, subVideoType, videoId, comment],
    );
    return Number(result.insertId ?? 0);
  }

  async updateComment(commentId: number, userId: number, comment: string): Promise<number> {
    const [result] = await dbPool.query<ResultSetHeader>(
      'UPDATE tbl_comment SET comment = ?, updated_at = NOW() WHERE id = ? AND user_id = ?',
      [comment, commentId, userId],
    );
    return Number(result.affectedRows ?? 0);
  }

  async deleteComment(commentId: number, userId: number): Promise<number> {
    const [result] = await dbPool.query<ResultSetHeader>(
      'DELETE FROM tbl_comment WHERE id = ? AND user_id = ?',
      [commentId, userId],
    );
    return Number(result.affectedRows ?? 0);
  }

  async getCommentsCount(videoType: number, subVideoType: number, videoId: number): Promise<number> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT COUNT(*) AS total
       FROM tbl_comment
       WHERE comment_id = 0 AND video_type = ? AND sub_video_type = ? AND video_id = ? AND status = 1`,
      [videoType, subVideoType, videoId],
    );
    return Number(rows[0]?.total ?? 0);
  }

  async getComments(videoType: number, subVideoType: number, videoId: number, offset: number, limit: number): Promise<Row[]> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT c.*,
              u.user_name AS user_user_name,
              u.full_name AS user_full_name,
              u.image_type AS user_image_type,
              u.image AS user_image,
              u.storage_type AS user_storage_type
       FROM tbl_comment c
       LEFT JOIN tbl_user u ON u.id = c.user_id
       WHERE c.comment_id = 0 AND c.video_type = ? AND c.sub_video_type = ? AND c.video_id = ? AND c.status = 1
       ORDER BY c.id DESC
       LIMIT ? OFFSET ?`,
      [videoType, subVideoType, videoId, limit, offset],
    );
    return rows;
  }

  async getReplayCommentsCount(commentId: number): Promise<number> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT COUNT(*) AS total FROM tbl_comment WHERE comment_id = ? AND status = 1',
      [commentId],
    );
    return Number(rows[0]?.total ?? 0);
  }

  async getReplayComments(commentId: number, offset: number, limit: number): Promise<Row[]> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT c.*,
              u.user_name AS user_user_name,
              u.full_name AS user_full_name,
              u.image_type AS user_image_type,
              u.image AS user_image,
              u.storage_type AS user_storage_type
       FROM tbl_comment c
       LEFT JOIN tbl_user u ON u.id = c.user_id
       WHERE c.comment_id = ? AND c.status = 1
       ORDER BY c.id DESC
       LIMIT ? OFFSET ?`,
      [commentId, limit, offset],
    );
    return rows;
  }

  async getReplyCount(commentId: number, activeOnly: boolean): Promise<number> {
    if (activeOnly) {
      const [rows] = await dbPool.query<Row[]>(
        'SELECT COUNT(*) AS total FROM tbl_comment WHERE comment_id = ? AND status = 1',
        [commentId],
      );
      return Number(rows[0]?.total ?? 0);
    }

    const [rows] = await dbPool.query<Row[]>(
      'SELECT COUNT(*) AS total FROM tbl_comment WHERE comment_id = ?',
      [commentId],
    );
    return Number(rows[0]?.total ?? 0);
  }

  async getUnreadNotificationsCount(userId: number): Promise<number> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT COUNT(*) AS total
       FROM tbl_notification n
       WHERE NOT EXISTS (
         SELECT 1 FROM tbl_read_notification rn
         WHERE rn.user_id = ? AND rn.notification_id = n.id
       )`,
      [userId],
    );
    return Number(rows[0]?.total ?? 0);
  }

  async getUnreadNotifications(userId: number, offset: number, limit: number): Promise<Row[]> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT n.*
       FROM tbl_notification n
       WHERE NOT EXISTS (
         SELECT 1 FROM tbl_read_notification rn
         WHERE rn.user_id = ? AND rn.notification_id = n.id
       )
       ORDER BY n.id DESC
       LIMIT ? OFFSET ?`,
      [userId, limit, offset],
    );
    return rows;
  }

  async markNotificationAsRead(userId: number, notificationId: number): Promise<number> {
    const [result] = await dbPool.query<ResultSetHeader>(
      `INSERT INTO tbl_read_notification
       (user_id, notification_id, status, created_at, updated_at)
       VALUES (?, ?, 1, NOW(), NOW())`,
      [userId, notificationId],
    );
    return Number(result.insertId ?? 0);
  }

  async updateKidsMode(userId: number, deviceId: string, kidsMode: number): Promise<number> {
    const [result] = await dbPool.query<ResultSetHeader>(
      'UPDATE tbl_device_sync SET kids_mode = ?, updated_at = NOW() WHERE user_id = ? AND device_id = ?',
      [kidsMode, userId, deviceId],
    );
    return Number(result.affectedRows ?? 0);
  }

  async getShortsListCount(): Promise<number> {
    const [rows] = await dbPool.query<Row[]>(
      'SELECT COUNT(*) AS total FROM tbl_shorts WHERE status = 1',
    );
    return Number(rows[0]?.total ?? 0);
  }

  async getShortsList(shortsId: number, offset: number, limit: number): Promise<Row[]> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT *
       FROM tbl_shorts
       WHERE status = 1
       ORDER BY CASE WHEN id = ? THEN 0 ELSE 1 END, total_view DESC, total_like DESC, id DESC
       LIMIT ? OFFSET ?`,
      [shortsId, limit, offset],
    );
    return rows;
  }

  async getShortsEpisodes(shortsId: number, seasonId: number): Promise<Row[]> {
    if (seasonId > 0) {
      const [rows] = await dbPool.query<Row[]>(
        `SELECT *
         FROM tbl_shorts_episode
         WHERE show_id = ? AND season_id = ? AND status = 1
         ORDER BY sort_order ASC, id DESC`,
        [shortsId, seasonId],
      );
      return rows;
    }

    const [rows] = await dbPool.query<Row[]>(
      `SELECT *
       FROM tbl_shorts_episode
       WHERE show_id = ? AND status = 1
       ORDER BY sort_order ASC, id DESC`,
      [shortsId],
    );
    return rows;
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

  private async updateTransactionStatusInTable(table: 'tbl_transaction' | 'tbl_rent_transaction', userId: number, transactionId: number, transactionStatus: number): Promise<boolean> {
    const [rows] = await dbPool.query<Row[]>(
      `SELECT id FROM ${table} WHERE id = ? AND user_id = ? LIMIT 1`,
      [transactionId, userId],
    );
    if (rows.length === 0) {
      return false;
    }

    const status = transactionStatus === 3 ? 0 : 1;
    const [result] = await dbPool.query<ResultSetHeader>(
      `UPDATE ${table}
       SET transaction_status = ?, status = ?, updated_at = NOW()
       WHERE id = ? AND user_id = ?`,
      [transactionStatus, status, transactionId, userId],
    );
    return Number(result.affectedRows ?? 0) > 0;
  }

  private mapUserRow(row: Row | undefined): DtliveUserRow | null {
    if (!row) {
      return null;
    }

    return {
      id: Number(row.id ?? 0),
      user_name: String(row.user_name ?? ''),
      full_name: String(row.full_name ?? ''),
      email: String(row.email ?? ''),
      password: String(row.password ?? ''),
      mobile_number: String(row.mobile_number ?? ''),
      storage_type: Number(row.storage_type ?? 1),
      image_type: Number(row.image_type ?? 1),
      image: String(row.image ?? ''),
      type: Number(row.type ?? 0),
      parent_control_status: Number(row.parent_control_status ?? 0),
      parent_control_password: String(row.parent_control_password ?? ''),
      status: Number(row.status ?? 0),
      created_at: String(row.created_at ?? ''),
      updated_at: String(row.updated_at ?? ''),
    };
  }

  private mapDeviceSyncRow(row: Row | undefined): DtliveDeviceSyncRow | null {
    if (!row) {
      return null;
    }

    return {
      id: Number(row.id ?? 0),
      user_id: Number(row.user_id ?? 0),
      device_name: String(row.device_name ?? ''),
      device_id: String(row.device_id ?? ''),
      device_type: Number(row.device_type ?? 0),
      device_token: String(row.device_token ?? ''),
      kids_mode: Number(row.kids_mode ?? 0),
      status: Number(row.status ?? 0),
      created_at: String(row.created_at ?? ''),
      updated_at: String(row.updated_at ?? ''),
    };
  }
}
