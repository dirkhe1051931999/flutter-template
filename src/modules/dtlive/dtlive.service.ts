import bcrypt from 'bcryptjs';
import { env } from '../../config/env';
import { DtliveRepository } from './dtlive.repository';

type GenericRecord = Record<string, unknown>;
type LoginType = 1 | 2 | 3 | 4;

function normalizeBcryptHash(hash: string): string {
  if (hash.startsWith('$2y$')) {
    return `$2a$${hash.slice(4)}`;
  }

  return hash;
}

export class DtliveService {
  private readonly repository = new DtliveRepository();

  async registerUser(payload: GenericRecord): Promise<GenericRecord> {
    const fullName = String(payload.full_name ?? '').trim();
    const email = String(payload.email ?? '').trim();
    const password = String(payload.password ?? '');
    const mobileNumber = String(payload.mobile_number ?? '').trim();

    if (fullName.length < 2) {
      throw new Error('The full name field is required.');
    }
    if (!this.isValidEmail(email)) {
      throw new Error('The email must be a valid email address.');
    }
    if (password.length < 4) {
      throw new Error('The password must be at least 4 characters.');
    }
    if (!/^\d+$/.test(mobileNumber)) {
      throw new Error('The mobile number must be a number.');
    }

    const [existsEmail, existsMobile] = await Promise.all([
      this.repository.existsUserEmail(email),
      this.repository.existsUserMobile(mobileNumber),
    ]);

    if (existsEmail) {
      throw new Error('The email has already been taken.');
    }
    if (existsMobile) {
      throw new Error('The mobile number has already been taken.');
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const userName = await this.createUniqueUserName(email.split('@')[0] ?? 'user');
    const userId = await this.repository.createUser({
      userName,
      fullName,
      email,
      password: hashedPassword,
      mobileNumber,
      storageType: 1,
      imageType: 1,
      image: '',
      type: 4,
      parentControlStatus: 0,
      parentControlPassword: '',
      status: 1,
    });

    if (userId <= 0) {
      throw new Error('Data Not Saved.');
    }

    const deviceMeta = this.extractDeviceMeta(payload);
    await this.repository.createUserDeviceSync({
      userId,
      deviceName: deviceMeta.deviceName,
      deviceId: deviceMeta.deviceId,
      deviceType: deviceMeta.deviceType,
      deviceToken: deviceMeta.deviceToken,
      kidsMode: 0,
      status: 1,
    });

    const user = await this.repository.getUserById(userId);
    if (!user) {
      throw new Error('Data Not Found.');
    }

    const enriched = await this.enrichUserForApi(user, true);
    return {
      ...enriched,
      device_id: deviceMeta.deviceId,
      device_type: deviceMeta.deviceType,
      device_token: deviceMeta.deviceToken,
    };
  }

  async loginUser(payload: GenericRecord): Promise<GenericRecord> {
    const rawType = Number(payload.type);
    if (!Number.isFinite(rawType)) {
      throw new Error('The type field is required.');
    }

    const loginType = Math.floor(rawType) as LoginType;
    if (![1, 2, 3, 4].includes(loginType)) {
      throw new Error('Type is Wrong.');
    }

    const fullName = String(payload.full_name ?? '').trim();
    const email = String(payload.email ?? '').trim();
    const password = String(payload.password ?? '');
    const mobileNumber = String(payload.mobile_number ?? '').trim();
    const imageType = this.optionalNumber(payload.image_type, 1);
    const image = String(payload.image ?? '').trim();
    const deviceMeta = this.extractDeviceMeta(payload);

    if (loginType === 1) {
      if (!/^\d+$/.test(mobileNumber)) {
        throw new Error('The mobile number field is required.');
      }
    } else if (loginType === 2 || loginType === 3) {
      if (!email) {
        throw new Error('The email field is required.');
      }
    } else if (loginType === 4) {
      if (!this.isValidEmail(email)) {
        throw new Error('The email must be a valid email address.');
      }
      if (password.length < 4) {
        throw new Error('The password must be at least 4 characters.');
      }
    }

    let user =
      loginType === 1
        ? await this.repository.getUserByMobileAndType(mobileNumber, loginType)
        : await this.repository.getUserByEmailAndType(email, loginType);

    if (loginType === 4) {
      if (!user) {
        throw new Error('Email and Password Worng.');
      }

      const matched = await bcrypt.compare(password, normalizeBcryptHash(String(user.password ?? '')));
      if (!matched) {
        throw new Error('Email and Password Worng.');
      }
    }

    if (!user && (loginType === 1 || loginType === 2 || loginType === 3)) {
      const userNameSeed = loginType === 1 ? mobileNumber : email.split('@')[0] ?? 'user';
      const userName = await this.createUniqueUserName(userNameSeed || 'user');
      const hashedPassword = password ? await bcrypt.hash(password, 10) : '';
      const userId = await this.repository.createUser({
        userName,
        fullName,
        email,
        password: hashedPassword,
        mobileNumber,
        storageType: 1,
        imageType: imageType === 2 ? 2 : 1,
        image: imageType === 2 ? image : '',
        type: loginType,
        parentControlStatus: 0,
        parentControlPassword: '',
        status: 1,
      });

      if (userId <= 0) {
        throw new Error('Data Not Saved.');
      }

      user = await this.repository.getUserById(userId);
      if (!user) {
        throw new Error('Data Not Found.');
      }
    }

    if (!user) {
      throw new Error('Data Not Found.');
    }

    const assignedDevice = await this.syncUserDevice(user.id, deviceMeta);
    const freshUser = await this.repository.getUserById(user.id);
    if (!freshUser) {
      throw new Error('Data Not Found.');
    }

    const enriched = await this.enrichUserForApi(freshUser, true);
    return {
      ...enriched,
      device_id: assignedDevice.device_id,
      device_type: assignedDevice.device_type,
      device_token: assignedDevice.device_token,
    };
  }

  async getProfile(payload: GenericRecord): Promise<GenericRecord | null> {
    const userId = this.requiredNumber(payload.user_id, 'user_id');
    const user = await this.repository.getUserById(userId);
    if (!user) {
      return null;
    }

    return this.enrichUserForApi(user, true);
  }

  async updateProfile(payload: GenericRecord): Promise<GenericRecord | null> {
    const userId = this.requiredNumber(payload.user_id, 'user_id');
    const user = await this.repository.getUserById(userId);
    if (!user) {
      return null;
    }

    const updates: Partial<{
      user_name: string;
      full_name: string;
      email: string;
      mobile_number: string;
      storage_type: number;
      image_type: number;
      image: string;
      parent_control_status: number;
      parent_control_password: string;
    }> = {};

    const userName = String(payload.user_name ?? '').trim();
    if (userName) {
      const exists = await this.repository.existsUserName(userName, userId);
      if (exists) {
        throw new Error('This User Name already Exists.');
      }
      updates.user_name = userName;
    }

    const fullName = String(payload.full_name ?? '').trim();
    if (fullName) {
      updates.full_name = fullName;
    }

    const email = String(payload.email ?? '').trim();
    if (email) {
      const exists = await this.repository.existsUserEmail(email, userId);
      if (exists) {
        throw new Error('This Email is already exists.');
      }
      updates.email = email;
    }

    const mobileNumber = String(payload.mobile_number ?? '').trim();
    if (mobileNumber) {
      const exists = await this.repository.existsUserMobile(mobileNumber, userId);
      if (exists) {
        throw new Error('This Mobile Number is already exists.');
      }
      updates.mobile_number = mobileNumber;
    }

    const imageTypeRaw = payload.image_type;
    if (imageTypeRaw !== undefined && imageTypeRaw !== null && String(imageTypeRaw) !== '' && Number(imageTypeRaw) !== 0) {
      const imageType = this.requiredNumber(imageTypeRaw, 'image_type');
      updates.image_type = imageType;
      if (imageType === 1) {
        const image = String(payload.image ?? '').trim();
        if (image) {
          updates.storage_type = 1;
          updates.image = image;
        }
      } else if (imageType === 2) {
        updates.image = String(payload.image ?? '').trim();
      }
    }

    if (Object.prototype.hasOwnProperty.call(payload, 'parent_control_status') && String(payload.parent_control_status ?? '') !== '') {
      updates.parent_control_status = this.optionalNumber(payload.parent_control_status, 0);
    }
    if (Object.prototype.hasOwnProperty.call(payload, 'parent_control_password') && String(payload.parent_control_password ?? '') !== '') {
      updates.parent_control_password = String(payload.parent_control_password ?? '');
    }

    await this.repository.updateUserProfile(userId, updates);
    const updatedUser = await this.repository.getUserById(userId);
    if (!updatedUser) {
      return null;
    }

    return this.enrichUserForApi(updatedUser, false);
  }

  async getTvLoginCode(): Promise<GenericRecord> {
    const uniqueCode = this.generateTvLoginCode();
    const row = await this.repository.createTvLoginCode(uniqueCode);
    if (!row) {
      throw new Error('Data Not Saved.');
    }
    return row;
  }

  async tvLogin(payload: GenericRecord): Promise<GenericRecord | null> {
    const userId = this.requiredNumber(payload.user_id, 'user_id');
    const uniqueCode = String(payload.unique_code ?? '').trim();
    if (!uniqueCode) {
      throw new Error('unique_code is required');
    }

    const bound = await this.repository.bindTvLoginCode(uniqueCode, userId);
    if (!bound) {
      return null;
    }

    const user = await this.repository.getUserById(userId);
    if (!user) {
      throw new Error('user_id wrong.');
    }
    return this.enrichUserForApi(user, true);
  }

  async checkTvLogin(payload: GenericRecord): Promise<GenericRecord | null> {
    const uniqueCode = String(payload.unique_code ?? '').trim();
    if (!uniqueCode) {
      throw new Error('unique_code is required');
    }

    const row = await this.repository.getTvLoginByUniqueCode(uniqueCode);
    if (!row || Number(row.status ?? 0) === 0 || Number(row.user_id ?? 0) === 0) {
      return null;
    }
    return row;
  }

  async parentControlCheckPassword(payload: GenericRecord): Promise<boolean> {
    const userId = this.requiredNumber(payload.user_id, 'user_id');
    const password = String(payload.password ?? '');
    if (!password) {
      throw new Error('password is required');
    }

    const user = await this.repository.getUserById(userId);
    return Boolean(user && String(user.parent_control_password ?? '') === password);
  }

  async getDeviceSyncList(payload: GenericRecord): Promise<GenericRecord[]> {
    const userId = this.requiredNumber(payload.user_id, 'user_id');
    return this.repository.getUserDeviceSyncList(userId);
  }

  async logoutDeviceSync(payload: GenericRecord): Promise<void> {
    const deviceSyncId = this.requiredNumber(payload.device_sync_id, 'device_sync_id');
    const deviceId = String(payload.device_id ?? '').trim();
    if (!deviceId) {
      throw new Error('device_id is required');
    }

    await this.repository.deleteDeviceSync(deviceSyncId, deviceId);
  }

  async addRemoveDeviceWatching(payload: GenericRecord): Promise<GenericRecord> {
    const userId = this.requiredNumber(payload.user_id, 'user_id');
    const deviceId = String(payload.device_id ?? '').trim();
    const type = this.requiredNumber(payload.type, 'type');
    if (!deviceId) {
      throw new Error('device_id is required');
    }

    if (type === 1) {
      const packageBuy = await this.repository.hasAnyActivePackage(userId);
      if (!packageBuy) {
        throw new Error('Please get subscription.');
      }

      const limit = await this.repository.getUserPackageDeviceLimit(userId);
      if (!limit || limit <= 0) {
        throw new Error('Please get subscription.');
      }

      const existing = await this.repository.getDeviceWatchingByUserAndDevice(userId, deviceId);
      if (!existing) {
        const watchingList = await this.repository.getDeviceWatchingWithSync(userId);
        if (watchingList.length >= limit) {
          return {
            status: 400,
            message: 'Streaming limit reached.',
            result: watchingList,
          };
        }
        await this.repository.createDeviceWatching(userId, deviceId);
      }

      return { status: 200, message: 'Device add successfully.' };
    }

    if (type === 2) {
      await this.repository.deleteDeviceWatchingByUserAndDevice(userId, deviceId);
      return { status: 200, message: 'Device delete successfully.' };
    }

    throw new Error('Type is wrong.');
  }

  async getGeneralSetting(): Promise<GenericRecord[]> {
    const settings = await this.repository.getGeneralSettings();
    const appLogoStorageType = Number(await this.repository.getGeneralSettingValue('app_logo_storage_type') || 1);

    return settings.map((item) => {
      if (item.key === 'app_logo') {
        return {
          key: item.key,
          value: this.toAssetUrl('app', String(item.value ?? ''), 'normal'),
          storage_type: appLogoStorageType,
        };
      }

      if (item.key === 'powered_by_image') {
        return {
          key: item.key,
          value: this.toAssetUrl('app', String(item.value ?? ''), 'normal'),
          storage_type: 1,
        };
      }

      return {
        key: item.key,
        value: item.value,
      };
    });
  }

  async getPaymentOption(): Promise<Record<string, GenericRecord>> {
    const options = await this.repository.getPaymentOptions();
    const result: Record<string, GenericRecord> = {};
    for (const option of options) {
      const name = String(option.name ?? '');
      result[name] = { ...option };
    }

    return result;
  }

  async getPages(): Promise<GenericRecord[]> {
    const pages = await this.repository.getPages();
    return pages.map((page) => {
      const title = String(page.title ?? '');
      return {
        title,
        url: this.buildPageUrl(title),
        icon: this.toAssetUrl('app', String(page.icon ?? ''), 'normal'),
        page_subtitle: String(page.page_subtitle ?? ''),
      };
    });
  }

  async getSocialLinks(): Promise<GenericRecord[]> {
    const data = await this.repository.getSocialLinks();
    return data.map((item) => ({
      ...item,
      image: this.toAssetUrl('app', String(item.image ?? ''), 'normal'),
    }));
  }

  async getOnboardingScreen(): Promise<GenericRecord[]> {
    const data = await this.repository.getOnboardingScreens();
    return data.map((item) => ({
      ...item,
      image: this.toAssetUrl('app', String(item.image ?? ''), 'normal'),
    }));
  }

  async getAvatar(): Promise<GenericRecord[]> {
    const avatars = await this.repository.getAvatars();
    return avatars.map((item) => ({
      ...item,
      image: this.toAssetUrl('avatar', String(item.image ?? ''), 'profile'),
    }));
  }

  async getCategory(): Promise<GenericRecord[]> {
    const categories = await this.repository.getCategories();
    return categories.map((item) => ({
      ...item,
      image: this.toAssetUrl('category', String(item.image ?? ''), 'normal'),
    }));
  }

  async getLanguage(): Promise<GenericRecord[]> {
    const languages = await this.repository.getLanguages();
    return languages.map((item) => ({
      ...item,
      image: this.toAssetUrl('language', String(item.image ?? ''), 'normal'),
    }));
  }

  async getType(payload: GenericRecord): Promise<GenericRecord[]> {
    const userId = this.optionalNumber(payload.user_id, 0);
    const deviceId = String(payload.device_id ?? '');
    const userParentControlStatus = await this.repository.getUserParentControlStatus(userId, deviceId);
    const types = await this.repository.getTypes(userParentControlStatus);
    return types.map((item) => ({
      ...item,
      icon: this.toAssetUrl('type', String(item.icon ?? ''), 'normal'),
    }));
  }

  async getPackage(payload: GenericRecord): Promise<GenericRecord[]> {
    await this.repository.expirePackageTransactions();
    const userId = this.optionalNumber(payload.user_id, 0);
    const [packages, activeTransaction] = await Promise.all([
      this.repository.getPackages(),
      this.repository.getActiveTransactionByUser(userId),
    ]);
    const activePackageId = Number(activeTransaction?.package_id ?? 0);

    const result: GenericRecord[] = [];
    for (const pkg of packages) {
      const packageId = Number(pkg.id ?? 0);
      const [isBuy, details] = await Promise.all([
        this.repository.hasSuccessfulPackageTransaction(userId, packageId),
        this.repository.getPackageDetails(packageId),
      ]);

      result.push({
        ...pkg,
        is_buy: isBuy ? 1 : 0,
        is_active_plan: isBuy && packageId === activePackageId ? 1 : 0,
        data: details,
      });
    }

    return result;
  }

  async addTransaction(payload: GenericRecord): Promise<GenericRecord> {
    await this.repository.expirePackageTransactions();

    const userId = this.requiredNumber(payload.user_id, 'user_id');
    const packageId = this.requiredNumber(payload.package_id, 'package_id');
    const price = this.requiredNumber(payload.price, 'price');
    const couponCode = String(payload.coupon_code ?? '').trim();
    const transactionId = String(payload.transaction_id ?? '').trim();
    const description = String(payload.description ?? '').trim();

    const packageData = await this.repository.getPackageById(packageId);
    if (!packageData) {
      throw new Error('Please enter right package id.');
    }

    if (Number(packageData.package_type ?? 0) === 2) {
      const claimed = await this.repository.hasAnyPackageTransaction(userId, packageId);
      if (claimed) {
        throw new Error('You have already claimed the free package.');
      }
    }

    const latestSuccessful = await this.repository.getLatestSuccessfulPackageTransaction(userId);
    const baseDate = latestSuccessful?.expiry_date ? new Date(String(latestSuccessful.expiry_date)) : new Date();
    const expiryDate = this.addDuration(baseDate, Number(packageData.time ?? 0), String(packageData.type ?? 'day'));
    const transactionStatus = Number(packageData.package_type ?? 0) === 2 ? 2 : 1;

    const inserted = await this.repository.createTransaction({
      uniqueId: couponCode,
      userId,
      packageId,
      transactionId,
      price,
      description,
      expiryDate: this.formatSqlDate(expiryDate),
      transactionStatus,
      status: 1,
    });

    if (!inserted) {
      throw new Error('Data Not Saved.');
    }

    return inserted;
  }

  async addRentTransaction(payload: GenericRecord): Promise<GenericRecord> {
    const userId = this.requiredNumber(payload.user_id, 'user_id');
    const producerId = this.requiredNumber(payload.producer_id, 'producer_id');
    const videoType = this.requiredNumber(payload.video_type, 'video_type');
    const subVideoType = this.optionalNumber(payload.sub_video_type, 0);
    const videoId = this.requiredNumber(payload.video_id, 'video_id');
    const price = this.requiredNumber(payload.price, 'price');
    const couponCode = String(payload.coupon_code ?? '').trim();
    const transactionId = String(payload.transaction_id ?? '').trim();
    const description = String(payload.description ?? '').trim();

    const rentVideo = await this.repository.getRentContent(videoType, subVideoType, videoId);
    if (!rentVideo) {
      throw new Error('Please enter right rent video.');
    }

    const rentDay = Number(rentVideo.rent_day ?? 0);
    const expiryDate = this.addDuration(new Date(), rentDay, 'day');
    const commission = 0;
    const producerEarning = producerId !== 0 ? price : 0;

    const inserted = await this.repository.createRentTransaction({
      uniqueId: couponCode,
      userId,
      producerId,
      videoType,
      subVideoType,
      videoId,
      price,
      producerEarning,
      commission,
      transactionId,
      description,
      expiryDate: this.formatSqlDate(expiryDate),
      transactionStatus: 1,
      status: 1,
    });

    if (!inserted) {
      throw new Error('Data Not Saved.');
    }

    return inserted;
  }

  async updateTransactionStatus(payload: GenericRecord): Promise<boolean> {
    const type = this.requiredNumber(payload.type, 'type');
    const userId = this.requiredNumber(payload.user_id, 'user_id');
    const transactionId = this.requiredNumber(payload.transaction_id, 'transaction_id');
    const transactionStatus = this.requiredNumber(payload.transaction_status, 'transaction_status');

    return this.repository.updateTransactionStatus(type, userId, transactionId, transactionStatus);
  }

  async getTransactionList(payload: GenericRecord): Promise<{ result: GenericRecord[]; pagination: GenericRecord }> {
    await this.repository.expirePackageTransactions();

    const userId = this.requiredNumber(payload.user_id, 'user_id');
    const pageNo = Math.max(1, this.optionalNumber(payload.page_no, 1));
    const offset = (pageNo - 1) * env.pageLimit;

    const [totalRows, rows, activeData] = await Promise.all([
      this.repository.getTransactionsCount(userId),
      this.repository.getTransactions(userId, offset, env.pageLimit),
      this.repository.getActiveTransactionByUser(userId),
    ]);

    const activeId = Number(activeData?.id ?? 0);
    const result = rows.map((row) => {
      const status = Number(row.status ?? 0);
      const id = Number(row.id ?? 0);
      return {
        ...row,
        is_upcoming: status === 1 && activeId > 0 && id !== activeId ? 1 : 0,
        package_name: String(row.package_name ?? ''),
        package_price: Number(row.package_price ?? 0),
        date: String(row.created_at ?? '').slice(0, 10),
      };
    });

    const totalPage = Math.max(1, Math.ceil(totalRows / env.pageLimit));
    return {
      result,
      pagination: {
        total_rows: totalRows,
        total_page: totalPage,
        current_page: pageNo,
        more_page: pageNo < totalPage,
      },
    };
  }

  async applyCoupon(payload: GenericRecord): Promise<GenericRecord> {
    const applyType = this.requiredNumber(payload.apply_coupon_type, 'apply_coupon_type');
    const userId = this.requiredNumber(payload.user_id, 'user_id');
    const code = String(payload.code ?? '').trim();
    if (!code) {
      throw new Error('code is required');
    }

    if (![1, 2].includes(applyType)) {
      throw new Error('apply_coupon_type must be 1 or 2');
    }

    const coupon = await this.repository.getCouponByUniqueId(code);
    if (!coupon) {
      throw new Error('Coupon id wrong.');
    }

    const today = new Date();
    const startDate = new Date(String(coupon.start_date ?? ''));
    const endDate = new Date(String(coupon.end_date ?? ''));
    const todayStr = this.formatDateOnly(today);
    const startStr = this.formatDateOnly(startDate);
    const endStr = this.formatDateOnly(endDate);

    if (startStr > todayStr) {
      throw new Error('Coupon not start.');
    }
    if (endStr < todayStr) {
      throw new Error('Coupon expiry.');
    }

    const useLimitEnabled = Number(coupon.is_use_limit ?? 0) === 1;
    const useLimit = Number(coupon.use_limit ?? 0);
    if (useLimitEnabled && useLimit > 0) {
      const usedCount = await this.repository.countCouponUsageByUniqueId(code);
      if (usedCount >= useLimit) {
        throw new Error('This coupon reached maximum usage limit.');
      }
    }

    const singleUse = Number(coupon.is_use ?? 0) === 1;
    if (singleUse) {
      const alreadyUsed = await this.repository.userUsedCouponUniqueId(userId, code);
      if (alreadyUsed) {
        throw new Error('Coupon already use.');
      }
    }

    const amountType = Number(coupon.amount_type ?? 1);
    const discountValue = Number(coupon.price ?? 0);

    if (applyType === 1) {
      const packageId = this.requiredNumber(payload.package_id, 'package_id');
      const packageData = await this.repository.getPackageById(packageId);
      if (!packageData) {
        throw new Error('Please enter right package id.');
      }

      const totalAmount = Number(packageData.price ?? 0);
      const discounted = this.calculateDiscountedTotal(totalAmount, amountType, discountValue);
      return {
        id: Number(coupon.id ?? 0),
        code,
        total_amount: totalAmount,
        discount_amount: discounted,
      };
    }

    const videoType = this.requiredNumber(payload.video_type, 'video_type');
    const subVideoType = this.optionalNumber(payload.sub_video_type, 0);
    const videoId = this.requiredNumber(payload.video_id, 'video_id');
    const rentVideo = await this.repository.getRentContent(videoType, subVideoType, videoId);
    if (!rentVideo) {
      throw new Error('Please enter right rent video.');
    }

    const rentPriceIdOrAmount = Number(rentVideo.price ?? 0);
    const rentPriceDetail = await this.repository.getRentPriceDetailById(rentPriceIdOrAmount);
    const totalAmount = rentPriceDetail ? Number(rentPriceDetail.price ?? 0) : rentPriceIdOrAmount;
    const discounted = this.calculateDiscountedTotal(totalAmount, amountType, discountValue);

    return {
      id: Number(coupon.id ?? 0),
      code,
      total_amount: totalAmount,
      discount_amount: discounted,
      is_free: 0,
    };
  }

  async validateCoupon(payload: GenericRecord): Promise<GenericRecord> {
    return this.applyCoupon(payload);
  }

  async getCouponList(payload: GenericRecord): Promise<{ result: GenericRecord[]; pagination: GenericRecord }> {
    const pageNo = Math.max(1, this.optionalNumber(payload.page_no, 1));
    const pageLimit = Math.max(1, this.optionalNumber(payload.min_content, env.pageLimit));
    const today = this.formatDateOnly(new Date());

    const all = await this.repository.getAllActiveCoupons();
    const filtered = all.filter((item) => {
      const start = this.formatDateOnly(new Date(String(item.start_date ?? '1970-01-01')));
      const end = this.formatDateOnly(new Date(String(item.end_date ?? '2999-12-31')));
      return start <= today && end >= today;
    });

    const totalRows = filtered.length;
    const totalPage = Math.max(1, Math.ceil(totalRows / pageLimit));
    const offset = (pageNo - 1) * pageLimit;
    const result = filtered.slice(offset, offset + pageLimit);

    return {
      result,
      pagination: {
        total_rows: totalRows,
        total_page: totalPage,
        current_page: pageNo,
        more_page: pageNo < totalPage,
      },
    };
  }

  async userRentContentList(payload: GenericRecord): Promise<{ result: GenericRecord[]; pagination: GenericRecord }> {
    await this.repository.expireRentTransactions();

    const userId = this.requiredNumber(payload.user_id, 'user_id');
    const isKidsProfile = this.optionalNumber(payload.is_kids_profile, 0);
    const type = this.optionalNumber(payload.type, 0);
    const pageNo = Math.max(1, this.optionalNumber(payload.page_no, 1));

    const rents = await this.repository.getSuccessfulRentTransactionsByUser(userId);
    const videoMap = new Map<number, string>();
    const showMap = new Map<number, string>();

    for (const rent of rents) {
      const videoType = Number(rent.video_type ?? 0);
      const subVideoType = Number(rent.sub_video_type ?? 0);
      const videoId = Number(rent.video_id ?? 0);
      const createdAt = String(rent.created_at ?? '');

      if (videoType === 1 || ([5, 6, 7].includes(videoType) && subVideoType === 1)) {
        if (!videoMap.has(videoId)) {
          videoMap.set(videoId, createdAt);
        }
      } else if (videoType === 2 || ([5, 6, 7].includes(videoType) && subVideoType === 2)) {
        if (!showMap.has(videoId)) {
          showMap.set(videoId, createdAt);
        }
      }
    }

    if (type === 1 || type === 2) {
      const ids = type === 1 ? Array.from(videoMap.keys()) : Array.from(showMap.keys());
      const rows = type === 1 ? await this.repository.getVideosByIds(ids) : await this.repository.getTvShowsByIds(ids);
      const mapped = await Promise.all(
        rows.map(async (row) => {
          const videoType = Number(row.video_type ?? 0);
          const subVideoType = [6, 7].includes(videoType) ? type : 0;
          const content = await this.enrichContentRow(row, userId, isKidsProfile, subVideoType);
          const rentCreatedAt = type === 1 ? videoMap.get(Number(row.id ?? 0)) : showMap.get(Number(row.id ?? 0));
          content.rent_created_at = rentCreatedAt ?? '';
          return content;
        }),
      );

      const paged = this.paginateArray(mapped, pageNo);
      return {
        result: paged.items,
        pagination: paged.pagination,
      };
    }

    const [videoRows, showRows] = await Promise.all([
      this.repository.getVideosByIds(Array.from(videoMap.keys())),
      this.repository.getTvShowsByIds(Array.from(showMap.keys())),
    ]);

    const enrichedVideos = await Promise.all(
      videoRows.map(async (row) => {
        const subVideoType = [6, 7].includes(Number(row.video_type ?? 0)) ? 1 : 0;
        const content = await this.enrichContentRow(row, userId, isKidsProfile, subVideoType);
        content.rent_created_at = videoMap.get(Number(row.id ?? 0)) ?? '';
        return content;
      }),
    );

    const enrichedShows = await Promise.all(
      showRows.map(async (row) => {
        const subVideoType = [6, 7].includes(Number(row.video_type ?? 0)) ? 2 : 0;
        const content = await this.enrichContentRow(row, userId, isKidsProfile, subVideoType);
        content.rent_created_at = showMap.get(Number(row.id ?? 0)) ?? '';
        return content;
      }),
    );

    const merged = [...enrichedVideos, ...enrichedShows].sort((a, b) => {
      const aTime = Date.parse(String(a.created_at ?? '1970-01-01'));
      const bTime = Date.parse(String(b.created_at ?? '1970-01-01'));
      return bTime - aTime;
    });

    const paged = this.paginateArray(merged, pageNo);
    return {
      result: paged.items,
      pagination: paged.pagination,
    };
  }

  async rentContentList(payload: GenericRecord): Promise<{ result: GenericRecord[]; pagination: GenericRecord }> {
    const type = this.optionalNumber(payload.type, 0);
    const userId = this.optionalNumber(payload.user_id, 0);
    const deviceId = String(payload.device_id ?? '');
    const pageNo = Math.max(1, this.optionalNumber(payload.page_no, 1));
    const userParentControlStatus = await this.repository.getUserParentControlStatus(userId, deviceId);

    if (type === 1 || type === 2) {
      const videoTypes = userParentControlStatus === 1
        ? [7]
        : type === 1
          ? [1, 6, 7]
          : [2, 6, 7];

      const [totalRows, rows] = await Promise.all([
        type === 1
          ? this.repository.getRentVideosCount(videoTypes)
          : this.repository.getRentTvShowsCount(videoTypes),
        type === 1
          ? this.repository.getRentVideos(videoTypes, (pageNo - 1) * env.pageLimit, env.pageLimit)
          : this.repository.getRentTvShows(videoTypes, (pageNo - 1) * env.pageLimit, env.pageLimit),
      ]);

      const result = await Promise.all(
        rows.map(async (row) => {
          const vType = Number(row.video_type ?? 0);
          const subVideoType = [5, 6, 7].includes(vType) ? type : 0;
          return this.enrichContentRow(row, userId, userParentControlStatus, subVideoType);
        }),
      );

      const totalPage = Math.max(1, Math.ceil(totalRows / env.pageLimit));
      return {
        result,
        pagination: {
          total_rows: totalRows,
          total_page: totalPage,
          current_page: pageNo,
          more_page: pageNo < totalPage,
        },
      };
    }

    const videoTypesForVideo = userParentControlStatus === 1 ? [7] : [1, 6, 7];
    const videoTypesForShow = userParentControlStatus === 1 ? [7] : [2, 6, 7];
    const [videoRows, showRows] = await Promise.all([
      this.repository.getAllRentVideos(videoTypesForVideo),
      this.repository.getAllRentTvShows(videoTypesForShow),
    ]);

    const enrichedVideos = await Promise.all(
      videoRows.map(async (row) => {
        const subVideoType = [6, 7].includes(Number(row.video_type ?? 0)) ? 1 : 0;
        return this.enrichContentRow(row, userId, userParentControlStatus, subVideoType);
      }),
    );
    const enrichedShows = await Promise.all(
      showRows.map(async (row) => {
        const subVideoType = [6, 7].includes(Number(row.video_type ?? 0)) ? 2 : 0;
        return this.enrichContentRow(row, userId, userParentControlStatus, subVideoType);
      }),
    );

    const merged = [...enrichedVideos, ...enrichedShows].sort((a, b) => {
      const aTime = Date.parse(String(a.created_at ?? '1970-01-01'));
      const bTime = Date.parse(String(b.created_at ?? '1970-01-01'));
      return bTime - aTime;
    });

    const paged = this.paginateArray(merged, pageNo);
    return {
      result: paged.items,
      pagination: paged.pagination,
    };
  }

  async createRazorpayOrder(payload: GenericRecord): Promise<GenericRecord> {
    const price = Number(payload.price);
    if (!Number.isFinite(price) || price < 1) {
      throw new Error('price is required and must be numeric');
    }

    const amount = Math.round(price * 100);
    const payment = await this.repository.getPaymentOptionById(3);
    if (!payment) {
      throw new Error('Data Not Found.');
    }

    const key1 = String(payment.key_1 ?? '');
    const key2 = String(payment.key_2 ?? '');
    if (!key1 || !key2) {
      throw new Error('Failed to create order.');
    }

    const currency = String(await this.repository.getGeneralSettingValue('currency') || 'INR');
    const receipt = `receipt#${Date.now()}`;
    const auth = Buffer.from(`${key1}:${key2}`).toString('base64');

    const response = await fetch('https://api.razorpay.com/v1/orders', {
      method: 'POST',
      headers: {
        Authorization: `Basic ${auth}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        amount,
        currency: currency || 'INR',
        receipt,
        payment_capture: 1,
      }),
    });

    if (!response.ok) {
      throw new Error('Failed to create order.');
    }

    const data = (await response.json()) as GenericRecord;
    return data;
  }

  async getReferEarnHistory(payload: GenericRecord): Promise<{ result: GenericRecord[]; pagination: GenericRecord }> {
    const userId = this.requiredNumber(payload.user_id, 'user_id');
    const pageLimit = Math.max(1, this.optionalNumber(payload.min_content, env.pageLimit));
    const pageNo = Math.max(1, this.optionalNumber(payload.page_no, 1));
    const offset = (pageNo - 1) * pageLimit;

    const hasReferEarnTable = await this.repository.existsTable('tbl_refer_earn');
    if (!hasReferEarnTable) {
      return {
        result: [],
        pagination: {
          total_rows: 0,
          total_page: 1,
          current_page: pageNo,
          more_page: false,
        },
      };
    }

    const [totalRows, rows] = await Promise.all([
      this.repository.getReferEarnHistoryCount(userId),
      this.repository.getReferEarnHistory(userId, offset, pageLimit),
    ]);

    const totalPage = Math.max(1, Math.ceil(totalRows / pageLimit));
    const result = rows.map((row) => ({
      ...row,
      child_user_name: String(row.child_user_name ?? ''),
      child_full_name: String(row.child_full_name ?? ''),
      child_email: String(row.child_email ?? ''),
      child_mobile_number: String(row.child_mobile_number ?? ''),
    }));

    return {
      result,
      pagination: {
        total_rows: totalRows,
        total_page: totalPage,
        current_page: pageNo,
        more_page: pageNo < totalPage,
      },
    };
  }

  async addWalletAmount(payload: GenericRecord): Promise<GenericRecord> {
    const userId = this.requiredNumber(payload.user_id, 'user_id');
    const amount = Number(payload.amount);
    const transactionId = String(payload.transaction_id ?? '').trim();

    if (!Number.isFinite(amount) || amount < 1) {
      throw new Error('amount is required and must be numeric');
    }
    if (!transactionId) {
      throw new Error('transaction_id is required');
    }

    const user = await this.repository.getUserById(userId);
    if (!user) {
      throw new Error('User id wrong.');
    }

    const [hasWalletTransactionTable, hasWalletAmountColumn] = await Promise.all([
      this.repository.existsTable('tbl_wallet_transaction'),
      this.repository.existsColumn('tbl_user', 'wallet_amount'),
    ]);

    if (!hasWalletTransactionTable || !hasWalletAmountColumn) {
      throw new Error('Wallet feature is not available in current database schema.');
    }

    const insertedId = await this.repository.createWalletTransaction({
      userId,
      amount: Math.trunc(amount),
      transactionId,
      description: 'Wallet Topup',
      status: 1,
    });
    if (insertedId <= 0) {
      throw new Error('Data Not Saved.');
    }

    const updatedRows = await this.repository.incrementUserWalletAmount(userId, Math.trunc(amount));
    if (updatedRows <= 0) {
      throw new Error('Data Not Saved.');
    }

    const walletAmount = await this.repository.getUserWalletAmount(userId);
    return {
      wallet_amount: walletAmount,
    };
  }

  async getWalletTransaction(payload: GenericRecord): Promise<{ result: GenericRecord[]; pagination: GenericRecord }> {
    const userId = this.requiredNumber(payload.user_id, 'user_id');
    const pageLimit = Math.max(1, this.optionalNumber(payload.min_content, env.pageLimit));
    const pageNo = Math.max(1, this.optionalNumber(payload.page_no, 1));
    const offset = (pageNo - 1) * pageLimit;

    const hasWalletTransactionTable = await this.repository.existsTable('tbl_wallet_transaction');
    if (!hasWalletTransactionTable) {
      return {
        result: [],
        pagination: {
          total_rows: 0,
          total_page: 1,
          current_page: pageNo,
          more_page: false,
        },
      };
    }

    const [totalRows, rows] = await Promise.all([
      this.repository.getWalletTransactionsCount(userId),
      this.repository.getWalletTransactions(userId, offset, pageLimit),
    ]);

    const totalPage = Math.max(1, Math.ceil(totalRows / pageLimit));
    return {
      result: rows,
      pagination: {
        total_rows: totalRows,
        total_page: totalPage,
        current_page: pageNo,
        more_page: pageNo < totalPage,
      },
    };
  }

  async getVdocipherOtp(payload: GenericRecord): Promise<GenericRecord> {
    const vdocipherId = String(payload.vdocipher_id ?? '').trim();
    if (!vdocipherId) {
      throw new Error('vdocipher_id is required');
    }

    const [statusRaw, apiSecret] = await Promise.all([
      this.repository.getGeneralSettingValue('vdocipher_status'),
      this.repository.getGeneralSettingValue('vdocipher_api_secret_key'),
    ]);

    const status = Number(statusRaw);
    let baseUrl = '';
    if (status === 0) {
      baseUrl = 'https://dev.vdocipher.com/api/videos/';
    } else if (status === 1) {
      baseUrl = 'https://api.vdocipher.com/api/videos/';
    } else {
      throw new Error('Data Not Found.');
    }

    if (!apiSecret) {
      throw new Error('Failed to generate OTP');
    }

    const response = await fetch(`${baseUrl}${vdocipherId}/otp`, {
      method: 'POST',
      headers: {
        Accept: 'application/json',
        Authorization: `Apisecret ${apiSecret}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ ttl: 300 }),
    });

    const jsonData = (await response.json()) as GenericRecord;
    if (!response.ok) {
      throw new Error('Failed to generate OTP');
    }

    return jsonData;
  }

  async getBanner(payload: GenericRecord): Promise<GenericRecord[]> {
    const isHomeScreen = this.requiredNumber(payload.is_home_screen, 'is_home_screen');
    const typeId = this.requiredNumber(payload.type_id, 'type_id');
    const userId = this.optionalNumber(payload.user_id, 0);
    const deviceId = String(payload.device_id ?? '');
    const userParentControlStatus = await this.repository.getUserParentControlStatus(userId, deviceId);
    const banners = await this.repository.getBanners(isHomeScreen, typeId, userParentControlStatus);

    const result: GenericRecord[] = [];
    for (const banner of banners) {
      const videoType = Number(banner.video_type ?? 0);
      const subVideoType = Number(banner.subvideo_type ?? 0);
      const videoId = Number(banner.video_id ?? 0);
      let content: GenericRecord | null = null;

      if (videoType === 1) {
        const row = await this.repository.getVideoByIdAndType(videoId, 1);
        if (row) {
          content = await this.enrichContentRow(row, userId, userParentControlStatus, 0);
        }
      } else if (videoType === 2) {
        const row = await this.repository.getTvShowByIdAndType(videoId, 2);
        if (row) {
          content = await this.enrichContentRow(row, userId, userParentControlStatus, 0);
        }
      } else if ([5, 6, 7].includes(videoType)) {
        if (subVideoType === 1) {
          const row = await this.repository.getVideoByIdAndType(videoId, videoType);
          if (row) {
            content = await this.enrichContentRow(row, userId, userParentControlStatus, 1);
          }
        } else if (subVideoType === 2) {
          const row = await this.repository.getTvShowByIdAndType(videoId, videoType);
          if (row) {
            content = await this.enrichContentRow(row, userId, userParentControlStatus, 2);
          }
        }
      } else if (videoType === 8) {
        const row = await this.repository.getShortByIdAndType(videoId, 8);
        if (row) {
          content = await this.enrichContentRow(row, userId, userParentControlStatus, 0);
        }
      }

      if (content) {
        content.total_language = this.countCsvIds(String(content.language_id ?? ''));
        result.push(content);
      }
    }

    return result;
  }

  async sectionDetail(payload: GenericRecord): Promise<{ result: GenericRecord[]; pagination: GenericRecord } | null> {
    const sectionId = this.requiredNumber(payload.section_id, 'section_id');
    const userId = this.optionalNumber(payload.user_id, 0);
    const pageNo = this.optionalNumber(payload.page_no, 1);
    const deviceId = String(payload.device_id ?? '');
    const section = await this.repository.getHomeSectionById(sectionId);
    if (!section) {
      return null;
    }

    const userParentControlStatus = await this.repository.getUserParentControlStatus(userId, deviceId);
    const videoType = Number(section.video_type ?? 0);

    let rows: GenericRecord[] = [];
    if ([1, 2, 5, 6, 7].includes(videoType)) {
      let sectionForQuery = { ...section } as Record<string, unknown>;
      if (Number(section.section_type ?? 0) === 2) {
        const aiCategoryIds = await this.repository.getAiCategoryIds(userId);
        if (aiCategoryIds.length > 0) {
          const aiContentIds = await this.repository.getAiContentIds(
            videoType,
            Number(section.sub_video_type ?? 0),
            aiCategoryIds,
            5000,
          );
          if (aiContentIds.length > 0) {
            sectionForQuery = {
              ...section,
              section_type: 1,
              content_ids: aiContentIds.join(','),
              premium_video: -1,
              order_by_upload: 0,
              order_by_view: 0,
              no_of_content: 5000,
            };
          } else {
            sectionForQuery = {
              ...section,
              section_type: 0,
              content_ids: '',
              order_by_upload: 0,
              order_by_view: 2,
              premium_video: -1,
              no_of_content: 5000,
            };
          }
        } else {
          sectionForQuery = {
            ...section,
            section_type: 0,
            content_ids: '',
            order_by_upload: 0,
            order_by_view: 2,
            premium_video: -1,
            no_of_content: 5000,
          };
        }
      } else {
        sectionForQuery = {
          ...section,
          no_of_content: 5000,
        };
      }

      const contentRows = await this.repository.getSectionVideoContent(sectionForQuery as Record<string, unknown>);
      rows = await Promise.all(
        contentRows.map(async (row) =>
          this.enrichContentRow(row, userId, userParentControlStatus, Number(sectionForQuery.sub_video_type ?? 0)),
        ),
      );
    } else if (videoType === 3) {
      const sectionType = Number(section.section_type ?? 0);
      const data =
        sectionType === 1
          ? await this.repository.getCategoriesByIds(this.parseIds(String(section.content_ids ?? '')))
          : await this.repository.getCategoriesDynamic(5000);
      rows = data.map((item) => ({
        ...item,
        image: this.toAssetUrl('category', String(item.image ?? ''), 'normal'),
      }));
    } else if (videoType === 4) {
      const sectionType = Number(section.section_type ?? 0);
      const data =
        sectionType === 1
          ? await this.repository.getLanguagesByIds(this.parseIds(String(section.content_ids ?? '')))
          : await this.repository.getLanguagesDynamic(5000);
      rows = data.map((item) => ({
        ...item,
        image: this.toAssetUrl('language', String(item.image ?? ''), 'normal'),
      }));
    } else if (videoType === 8) {
      const sectionForQuery = {
        ...section,
        no_of_content: 5000,
      };
      const data = await this.repository.getSectionShortsContent(sectionForQuery as Record<string, unknown>);
      rows = await Promise.all(data.map(async (row) => this.enrichContentRow(row, userId, userParentControlStatus, 0)));
    } else if (videoType === 101) {
      rows = await this.repository.getContinueWatching(userId, userParentControlStatus);
    } else {
      return {
        result: [],
        pagination: {
          total_rows: 0,
          total_page: 1,
          current_page: pageNo,
          more_page: false,
        },
      };
    }

    const paged = this.paginateArray(rows, pageNo);
    return {
      result: paged.items,
      pagination: paged.pagination,
    };
  }

  async contentByCategory(payload: GenericRecord): Promise<{ result: GenericRecord[]; pagination: GenericRecord }> {
    const categoryId = this.requiredNumber(payload.category_id, 'category_id');
    const userId = this.optionalNumber(payload.user_id, 0);
    const pageNo = this.optionalNumber(payload.page_no, 1);
    const deviceId = String(payload.device_id ?? '');
    const userParentControlStatus = await this.repository.getUserParentControlStatus(userId, deviceId);
    const videoTypesForVideo = userParentControlStatus === 1 ? [7] : [1, 6, 7];
    const videoTypesForShow = userParentControlStatus === 1 ? [7] : [2, 6, 7];

    const [videoRows, showRows] = await Promise.all([
      this.repository.getVideosByCategory(categoryId, videoTypesForVideo),
      this.repository.getTvShowsByCategory(categoryId, videoTypesForShow),
    ]);

    const enrichedVideos = await Promise.all(
      videoRows.map(async (row) => {
        const subType = [6, 7].includes(Number(row.video_type ?? 0)) ? 1 : 0;
        return this.enrichContentRow(row, userId, userParentControlStatus, subType);
      }),
    );
    const enrichedShows = await Promise.all(
      showRows.map(async (row) => {
        const subType = [6, 7].includes(Number(row.video_type ?? 0)) ? 2 : 0;
        return this.enrichContentRow(row, userId, userParentControlStatus, subType);
      }),
    );

    const merged = [...enrichedVideos, ...enrichedShows].sort((a, b) => {
      const aTime = Date.parse(String(a.created_at ?? '1970-01-01'));
      const bTime = Date.parse(String(b.created_at ?? '1970-01-01'));
      return bTime - aTime;
    });

    const paged = this.paginateArray(merged, pageNo);
    return {
      result: paged.items,
      pagination: paged.pagination,
    };
  }

  async contentByLanguage(payload: GenericRecord): Promise<{ result: GenericRecord[]; pagination: GenericRecord }> {
    const languageId = this.requiredNumber(payload.language_id, 'language_id');
    const userId = this.optionalNumber(payload.user_id, 0);
    const pageNo = this.optionalNumber(payload.page_no, 1);
    const deviceId = String(payload.device_id ?? '');
    const userParentControlStatus = await this.repository.getUserParentControlStatus(userId, deviceId);
    const videoTypesForVideo = userParentControlStatus === 1 ? [7] : [1, 6, 7];
    const videoTypesForShow = userParentControlStatus === 1 ? [7] : [2, 6, 7];

    const [videoRows, showRows] = await Promise.all([
      this.repository.getVideosByLanguage(languageId, videoTypesForVideo),
      this.repository.getTvShowsByLanguage(languageId, videoTypesForShow),
    ]);

    const enrichedVideos = await Promise.all(
      videoRows.map(async (row) => {
        const subType = [6, 7].includes(Number(row.video_type ?? 0)) ? 1 : 0;
        return this.enrichContentRow(row, userId, userParentControlStatus, subType);
      }),
    );
    const enrichedShows = await Promise.all(
      showRows.map(async (row) => {
        const subType = [6, 7].includes(Number(row.video_type ?? 0)) ? 2 : 0;
        return this.enrichContentRow(row, userId, userParentControlStatus, subType);
      }),
    );

    const merged = [...enrichedVideos, ...enrichedShows].sort((a, b) => {
      const aTime = Date.parse(String(a.created_at ?? '1970-01-01'));
      const bTime = Date.parse(String(b.created_at ?? '1970-01-01'));
      return bTime - aTime;
    });

    const paged = this.paginateArray(merged, pageNo);
    return {
      result: paged.items,
      pagination: paged.pagination,
    };
  }

  async contentByCast(payload: GenericRecord): Promise<{ result: GenericRecord[]; pagination: GenericRecord }> {
    const castId = this.requiredNumber(payload.cast_id, 'cast_id');
    const userId = this.optionalNumber(payload.user_id, 0);
    const pageNo = this.optionalNumber(payload.page_no, 1);
    const deviceId = String(payload.device_id ?? '');
    const userParentControlStatus = await this.repository.getUserParentControlStatus(userId, deviceId);
    const videoTypesForVideo = userParentControlStatus === 1 ? [7] : [1, 6, 7];
    const videoTypesForShow = userParentControlStatus === 1 ? [7] : [2, 6, 7];

    const [videoRows, showRows] = await Promise.all([
      this.repository.getVideosByCast(castId, videoTypesForVideo),
      this.repository.getTvShowsByCast(castId, videoTypesForShow),
    ]);

    const enrichedVideos = await Promise.all(
      videoRows.map(async (row) => {
        const subType = [6, 7].includes(Number(row.video_type ?? 0)) ? 1 : 0;
        return this.enrichContentRow(row, userId, userParentControlStatus, subType);
      }),
    );
    const enrichedShows = await Promise.all(
      showRows.map(async (row) => {
        const subType = [6, 7].includes(Number(row.video_type ?? 0)) ? 2 : 0;
        return this.enrichContentRow(row, userId, userParentControlStatus, subType);
      }),
    );

    const merged = [...enrichedVideos, ...enrichedShows].sort((a, b) => {
      const aTime = Date.parse(String(a.created_at ?? '1970-01-01'));
      const bTime = Date.parse(String(b.created_at ?? '1970-01-01'));
      return bTime - aTime;
    });

    const paged = this.paginateArray(merged, pageNo);
    return {
      result: paged.items,
      pagination: paged.pagination,
    };
  }

  async searchContent(payload: GenericRecord): Promise<{ result: GenericRecord[]; pagination: GenericRecord }> {
    const name = String(payload.name ?? '');
    const userId = this.optionalNumber(payload.user_id, 0);
    const pageNo = this.optionalNumber(payload.page_no, 1);
    const deviceId = String(payload.device_id ?? '');
    const userParentControlStatus = await this.repository.getUserParentControlStatus(userId, deviceId);
    const [categoryIds, languageIds] = await Promise.all([
      this.repository.getCategoryIdsByExactName(name),
      this.repository.getLanguageIdsByExactName(name),
    ]);

    const videoTypesForVideo = userParentControlStatus === 1 ? [7] : [1, 6, 7];
    const videoTypesForShow = userParentControlStatus === 1 ? [7] : [2, 6, 7];
    const [videoRows, showRows] = await Promise.all([
      this.repository.searchVideosByNameCategoryLanguage(name, categoryIds, languageIds, videoTypesForVideo),
      this.repository.searchTvShowsByNameCategoryLanguage(name, categoryIds, languageIds, videoTypesForShow),
    ]);

    const enrichedVideos = await Promise.all(
      videoRows.map(async (row) => {
        const subType = [6, 7].includes(Number(row.video_type ?? 0)) ? 1 : 0;
        return this.enrichContentRow(row, userId, userParentControlStatus, subType);
      }),
    );
    const enrichedShows = await Promise.all(
      showRows.map(async (row) => {
        const subType = [6, 7].includes(Number(row.video_type ?? 0)) ? 2 : 0;
        return this.enrichContentRow(row, userId, userParentControlStatus, subType);
      }),
    );

    const merged = [...enrichedVideos, ...enrichedShows].sort((a, b) => {
      const aTime = Date.parse(String(a.created_at ?? '1970-01-01'));
      const bTime = Date.parse(String(b.created_at ?? '1970-01-01'));
      return bTime - aTime;
    });

    const paged = this.paginateArray(merged, pageNo);
    return {
      result: paged.items,
      pagination: paged.pagination,
    };
  }

  async getChannelList(): Promise<GenericRecord[]> {
    const channels = await this.repository.getChannels();

    return channels.map((channel) => ({
      ...channel,
      portrait_img: this.toAssetUrl('channel', String(channel.portrait_img ?? ''), 'portrait'),
      landscape_img: this.toAssetUrl('channel', String(channel.landscape_img ?? ''), 'landscape'),
    }));
  }

  async getSectionList(payload: GenericRecord): Promise<{ result: GenericRecord[]; pagination: GenericRecord }> {
    const isHomeScreen = this.requiredNumber(payload.is_home_screen, 'is_home_screen');
    const typeId = this.requiredNumber(payload.type_id, 'type_id');
    const pageNo = this.optionalNumber(payload.page_no, 1);
    const userId = this.optionalNumber(payload.user_id, 0);
    const deviceId = String(payload.device_id ?? '');

    if (![1, 2].includes(isHomeScreen)) {
      throw new Error('is_home_screen must be 1 or 2');
    }

    const userParentControlStatus = await this.repository.getUserParentControlStatus(userId, deviceId);
    const sections = await this.repository.getSections(isHomeScreen, typeId, pageNo, env.pageLimit, userParentControlStatus);
    const totalRows = await this.repository.getSectionsCount(isHomeScreen, typeId, userParentControlStatus);
    const pageSize = Math.max(1, Math.ceil(totalRows / env.pageLimit));
    const pagination = {
      total_rows: totalRows,
      total_page: pageSize,
      current_page: pageNo,
      more_page: pageNo < pageSize,
    };

    const result = await Promise.all(
      sections.map(async (section) => {
        const enrichedSection: GenericRecord = { ...section, data: [] };
        const videoType = Number(section.video_type ?? 0);
        const sectionType = Number(section.section_type ?? 0);
        const sectionSubVideoType = Number(section.sub_video_type ?? 0);
        const sectionNoOfContent = Math.max(1, Number(section.no_of_content ?? env.pageLimit));
        let sectionForQuery = section;

        if ([1, 2, 5, 6, 7].includes(videoType) && sectionType === 2) {
          const aiCategoryIds = await this.repository.getAiCategoryIds(userId);
          if (aiCategoryIds.length > 0) {
            const aiContentIds = await this.repository.getAiContentIds(videoType, sectionSubVideoType, aiCategoryIds, sectionNoOfContent);
            if (aiContentIds.length > 0) {
              sectionForQuery = {
                ...section,
                section_type: 1,
                content_ids: aiContentIds.join(','),
                premium_video: -1,
                order_by_upload: 0,
                order_by_view: 0,
              };
            } else {
              sectionForQuery = {
                ...section,
                section_type: 0,
                content_ids: '',
                order_by_upload: 0,
                order_by_view: 2,
                premium_video: -1,
              };
            }
          } else {
            sectionForQuery = {
              ...section,
              section_type: 0,
              content_ids: '',
              order_by_upload: 0,
              order_by_view: 2,
              premium_video: -1,
            };
          }
        }

        if ([1, 2, 5, 6, 7].includes(videoType)) {
          const content = await this.repository.getSectionVideoContent(sectionForQuery);
          enrichedSection.data = await Promise.all(
            content.map(async (row) => this.enrichContentRow(row, userId, userParentControlStatus, Number(sectionForQuery.sub_video_type ?? 0))),
          );
        } else if (videoType === 3) {
          const sectionTypeValue = Number(sectionForQuery.section_type ?? 0);
          const categories =
            sectionTypeValue === 1
              ? await this.repository.getCategoriesByIds(this.parseIds(String(sectionForQuery.content_ids ?? '')))
              : await this.repository.getCategoriesDynamic(Number(sectionForQuery.no_of_content ?? env.pageLimit));
          enrichedSection.data = categories.map((row) => ({
            ...row,
            image: this.toAssetUrl('category', String(row.image ?? ''), 'normal'),
          }));
        } else if (videoType === 4) {
          const sectionTypeValue = Number(sectionForQuery.section_type ?? 0);
          const languages =
            sectionTypeValue === 1
              ? await this.repository.getLanguagesByIds(this.parseIds(String(sectionForQuery.content_ids ?? '')))
              : await this.repository.getLanguagesDynamic(Number(sectionForQuery.no_of_content ?? env.pageLimit));
          enrichedSection.data = languages.map((row) => ({
            ...row,
            image: this.toAssetUrl('language', String(row.image ?? ''), 'normal'),
          }));
        } else if (videoType === 8) {
          const shorts = await this.repository.getSectionShortsContent(sectionForQuery);
          enrichedSection.data = await Promise.all(shorts.map(async (row) => this.enrichContentRow(row, userId, userParentControlStatus, 0)));
        } else if (videoType === 101) {
          const watched = await this.repository.getContinueWatching(userId, userParentControlStatus);
          enrichedSection.data = watched;
        }

        return enrichedSection;
      }),
    );

    return {
      result,
      pagination,
    };
  }

  async getContentDetail(payload: GenericRecord): Promise<GenericRecord[]> {
    const typeId = this.requiredNumber(payload.type_id, 'type_id');
    const videoType = this.requiredNumber(payload.video_type, 'video_type');
    const videoId = this.requiredNumber(payload.video_id, 'video_id');
    const subVideoType = this.optionalNumber(payload.sub_video_type, 0);
    const userId = this.optionalNumber(payload.user_id, 0);
    const isKidsProfile = this.optionalNumber(payload.is_kids_profile, 0);

    if ((videoType === 5 || videoType === 6 || videoType === 7) && ![1, 2].includes(subVideoType)) {
      return [];
    }

    const content = await this.repository.getContentDetail(videoType, typeId, videoId, subVideoType);
    if (!content) {
      return [];
    }

    const resolvedSubVideoType = videoType === 8 ? 0 : subVideoType;
    const enriched = await this.enrichContentRow(content, userId, isKidsProfile, resolvedSubVideoType);

    const cast = await this.repository.getCastsByIds(String(content.cast_id ?? ''));
    enriched.cast = cast.map((item) => ({
      ...item,
      image: this.toAssetUrl('cast', String(item.image ?? ''), 'profile'),
    }));

    if (enriched.avg_rating === undefined || enriched.avg_rating === null || enriched.avg_rating === '') {
      enriched.avg_rating = 0;
    }

    if (enriched.total_reviews === undefined || enriched.total_reviews === null || enriched.total_reviews === '') {
      enriched.total_reviews = 0;
    }

    enriched.season = [];

    if (videoType === 2 || ((videoType === 5 || videoType === 6 || videoType === 7) && resolvedSubVideoType === 2)) {
      enriched.season = await this.repository.getSeasonsByShowId(Number(content.id));
    }

    if (videoType === 8) {
      enriched.season = await this.repository.getSeasonsByShortsId(Number(content.id));
    }

    return [enriched];
  }

  async getContentByChannel(payload: GenericRecord): Promise<{ result: GenericRecord[]; pagination: GenericRecord }> {
    const channelId = this.requiredNumber(payload.channel_id, 'channel_id');
    const userId = this.optionalNumber(payload.user_id, 0);
    const isKidsProfile = this.optionalNumber(payload.is_kids_profile, 0);
    const pageNo = this.optionalNumber(payload.page_no, 1);

    const content = await this.repository.getChannelContent(channelId);
    const enriched = await Promise.all(
      content.map(async (row) => this.enrichContentRow(row, userId, isKidsProfile, Number(row.sub_video_type ?? 0))),
    );

    enriched.sort((a, b) => {
      const aTime = Date.parse(String(a.created_at ?? '1970-01-01'));
      const bTime = Date.parse(String(b.created_at ?? '1970-01-01'));
      return bTime - aTime;
    });

    const totalRows = enriched.length;
    const pageSize = Math.max(1, Math.ceil(totalRows / env.pageLimit));
    const offset = (pageNo - 1) * env.pageLimit;

    return {
      result: enriched.slice(offset, offset + env.pageLimit),
      pagination: {
        total_rows: totalRows,
        total_page: pageSize,
        current_page: pageNo,
        more_page: pageNo < pageSize,
      },
    };
  }

  async castDetail(payload: GenericRecord): Promise<GenericRecord | null> {
    const castId = this.requiredNumber(payload.cast_id, 'cast_id');
    const data = await this.repository.getCastById(castId);
    if (!data) {
      return null;
    }

    return {
      ...data,
      image: this.toAssetUrl('cast', String(data.image ?? ''), 'profile'),
    };
  }

  async getRelatedContent(payload: GenericRecord): Promise<{ result: GenericRecord[]; pagination: GenericRecord } | null> {
    const typeId = this.requiredNumber(payload.type_id, 'type_id');
    const videoType = this.requiredNumber(payload.video_type, 'video_type');
    const videoId = this.requiredNumber(payload.video_id, 'video_id');
    const subVideoType = this.optionalNumber(payload.sub_video_type, 0);
    const userId = this.optionalNumber(payload.user_id, 0);
    const isKidsProfile = this.optionalNumber(payload.is_kids_profile, 0);
    const pageNo = Math.max(1, this.optionalNumber(payload.page_no, 1));
    const offset = (pageNo - 1) * env.pageLimit;

    let source: GenericRecord | null = null;
    let rows: GenericRecord[] = [];
    let totalRows = 0;
    let resolvedSubType = 0;

    if (videoType === 1) {
      source = await this.repository.getVideoByIdAndType(videoId, videoType);
      if (!source || Number(source.type_id ?? 0) !== typeId) {
        return null;
      }
      const categoryIds = this.parseIds(String(source.category_id ?? ''));
      totalRows = await this.repository.getRelatedVideosByCategoriesCount(videoType, videoId, categoryIds);
      rows = await this.repository.getRelatedVideosByCategories(videoType, videoId, categoryIds, offset, env.pageLimit);
      resolvedSubType = 0;
    } else if (videoType === 2) {
      source = await this.repository.getTvShowByIdAndType(videoId, videoType);
      if (!source || Number(source.type_id ?? 0) !== typeId) {
        return null;
      }
      const categoryIds = this.parseIds(String(source.category_id ?? ''));
      totalRows = await this.repository.getRelatedTvShowsByCategoriesCount(videoType, videoId, categoryIds);
      rows = await this.repository.getRelatedTvShowsByCategories(videoType, videoId, categoryIds, offset, env.pageLimit);
      resolvedSubType = 0;
    } else if ([5, 6, 7].includes(videoType)) {
      if (subVideoType === 1) {
        source = await this.repository.getVideoByIdAndType(videoId, videoType);
        if (!source || Number(source.type_id ?? 0) !== typeId) {
          return null;
        }
        const categoryIds = this.parseIds(String(source.category_id ?? ''));
        totalRows = await this.repository.getRelatedVideosByCategoriesCount(videoType, videoId, categoryIds);
        rows = await this.repository.getRelatedVideosByCategories(videoType, videoId, categoryIds, offset, env.pageLimit);
        resolvedSubType = 1;
      } else if (subVideoType === 2) {
        source = await this.repository.getTvShowByIdAndType(videoId, videoType);
        if (!source || Number(source.type_id ?? 0) !== typeId) {
          return null;
        }
        const categoryIds = this.parseIds(String(source.category_id ?? ''));
        totalRows = await this.repository.getRelatedTvShowsByCategoriesCount(videoType, videoId, categoryIds);
        rows = await this.repository.getRelatedTvShowsByCategories(videoType, videoId, categoryIds, offset, env.pageLimit);
        resolvedSubType = 2;
      } else {
        return null;
      }
    } else {
      return null;
    }

    const result = await Promise.all(rows.map(async (row) => this.enrichContentRow(row, userId, isKidsProfile, resolvedSubType)));
    const totalPage = Math.max(1, Math.ceil(totalRows / env.pageLimit));
    return {
      result,
      pagination: {
        total_rows: totalRows,
        total_page: totalPage,
        current_page: pageNo,
        more_page: pageNo < totalPage,
      },
    };
  }

  async addContinueWatching(payload: GenericRecord): Promise<void> {
    await this.repository.upsertContinueWatching({
      userId: this.requiredNumber(payload.user_id, 'user_id'),
      isKidsProfile: this.requiredNumber(payload.is_kids_profile, 'is_kids_profile'),
      videoType: this.requiredNumber(payload.video_type, 'video_type'),
      subVideoType: this.optionalNumber(payload.sub_video_type, 0),
      videoId: this.requiredNumber(payload.video_id, 'video_id'),
      episodeId: this.optionalNumber(payload.episode_id, 0),
      stopTime: this.requiredNumber(payload.stop_time, 'stop_time'),
    });
  }

  async getVideoBySeasonId(payload: GenericRecord): Promise<{ result: GenericRecord[]; pagination: GenericRecord }> {
    const showId = this.requiredNumber(payload.show_id, 'show_id');
    const seasonId = this.requiredNumber(payload.season_id, 'season_id');
    const userId = this.optionalNumber(payload.user_id, 0);
    const pageNo = this.optionalNumber(payload.page_no, 1);

    const showData = await this.repository.getTvShowById(showId);
    if (!showData) {
      return {
        result: [],
        pagination: { total_rows: 0, total_page: 1, current_page: pageNo, more_page: false },
      };
    }

    const totalRows = await this.repository.getTvShowVideosBySeasonCount(showId, seasonId);
    const totalPage = Math.max(1, Math.ceil(totalRows / env.pageLimit));
    const safePageNo = Math.max(1, pageNo);
    const offset = (safePageNo - 1) * env.pageLimit;
    const rows = await this.repository.getTvShowVideosBySeason(showId, seasonId, offset, env.pageLimit);

    const showVideoType = Number(showData.video_type ?? 0);
    const subVideoType = showVideoType === 2 ? 0 : 2;
    const isBuy = await this.repository.isAnyPackageBuy(userId);
    const rentBuy = await this.repository.isRentBuy(userId, showVideoType, subVideoType, showId);
    const rentExpiryDate = await this.repository.getRentExpiryDate(userId, showVideoType, subVideoType, showId);

    const result = await Promise.all(
      rows.map(async (row) => {
        const episodeId = Number(row.id ?? 0);
        const stopTime = await this.repository.getStopTimeByEpisode(userId, showVideoType, subVideoType, showId, episodeId);
        return {
          ...this.enrichEpisodeRow(row),
          is_buy: isBuy ? 1 : 0,
          is_rent: Number(showData.is_rent ?? 0),
          rent_buy: rentBuy ? 1 : 0,
          rent_expiry_date: rentExpiryDate,
          stop_time: stopTime,
        };
      }),
    );

    return {
      result,
      pagination: {
        total_rows: totalRows,
        total_page: totalPage,
        current_page: safePageNo,
        more_page: safePageNo < totalPage,
      },
    };
  }

  async addVideoView(payload: GenericRecord): Promise<boolean> {
    const userId = this.requiredNumber(payload.user_id, 'user_id');
    const videoType = this.requiredNumber(payload.video_type, 'video_type');
    const videoId = this.requiredNumber(payload.video_id, 'video_id');
    const subVideoType = this.optionalNumber(payload.sub_video_type, 0);
    const episodeId = this.optionalNumber(payload.episode_id, 0);

    const viewed = await this.repository.findViewRecord(userId, videoType, subVideoType, videoId, episodeId);
    if (viewed) {
      return false;
    }

    const insertId = await this.repository.createViewRecord(userId, videoType, subVideoType, videoId, episodeId);
    if (insertId <= 0) {
      throw new Error('Data Not Saved.');
    }

    await this.repository.incrementTotalView(videoType, subVideoType, videoId, episodeId);
    return true;
  }

  async getContinueWatching(payload: GenericRecord): Promise<{ result: GenericRecord[]; pagination: GenericRecord }> {
    const userId = this.requiredNumber(payload.user_id, 'user_id');
    const pageNo = this.optionalNumber(payload.page_no, 1);
    const deviceId = String(payload.device_id ?? '');
    const userParentControlStatus = await this.repository.getUserParentControlStatus(userId, deviceId);
    const watchedRows = await this.repository.getContinueWatchingAll(userId, userParentControlStatus);

    const result: GenericRecord[] = [];
    for (const watched of watchedRows) {
      const videoType = Number(watched.video_type ?? 0);
      const videoId = Number(watched.video_id ?? 0);
      const subVideoType = Number(watched.sub_video_type ?? 0);
      const episodeId = Number(watched.episode_id ?? 0);
      const watchedStopTime = Number(watched.stop_time ?? 0);

      if (videoType === 1) {
        const content = await this.repository.getVideoByIdAndType(videoId, 1);
        if (!content) {
          continue;
        }
        const enriched = await this.enrichContentRow(content, userId, userParentControlStatus, 0);
        enriched.stop_time = watchedStopTime;
        result.push(enriched);
        continue;
      }

      if (videoType === 2) {
        const content = await this.repository.getTvShowByIdAndType(videoId, 2);
        if (!content) {
          continue;
        }
        const enriched = await this.enrichContentRow(content, userId, userParentControlStatus, 0);
        const episode = episodeId > 0 ? await this.repository.getTvShowEpisodeById(videoId, episodeId) : null;
        enriched.stop_time = watchedStopTime;
        enriched.episode = episode ? this.enrichEpisodeRow(episode) : [];
        result.push(enriched);
        continue;
      }

      if ((videoType === 6 || videoType === 7) && subVideoType === 1) {
        const content = await this.repository.getVideoByIdAndType(videoId, videoType);
        if (!content) {
          continue;
        }
        const enriched = await this.enrichContentRow(content, userId, userParentControlStatus, 1);
        enriched.stop_time = watchedStopTime;
        result.push(enriched);
        continue;
      }

      if ((videoType === 6 || videoType === 7) && subVideoType === 2) {
        const content = await this.repository.getTvShowByIdAndType(videoId, videoType);
        if (!content) {
          continue;
        }
        const enriched = await this.enrichContentRow(content, userId, userParentControlStatus, 2);
        const episode = episodeId > 0 ? await this.repository.getTvShowEpisodeById(videoId, episodeId) : null;
        enriched.stop_time = watchedStopTime;
        enriched.episode = episode ? this.enrichEpisodeRow(episode) : [];
        result.push(enriched);
      }
    }

    const paged = this.paginateArray(result, pageNo);
    return {
      result: paged.items,
      pagination: paged.pagination,
    };
  }

  async removeContinueWatching(payload: GenericRecord): Promise<void> {
    const userId = this.requiredNumber(payload.user_id, 'user_id');
    const isKidsProfile = this.requiredNumber(payload.is_kids_profile, 'is_kids_profile');
    const videoType = this.requiredNumber(payload.video_type, 'video_type');
    const videoId = this.requiredNumber(payload.video_id, 'video_id');
    const subVideoType = this.optionalNumber(payload.sub_video_type, 0);
    await this.repository.removeContinueWatching(userId, isKidsProfile, videoType, subVideoType, videoId);
  }

  async getBookmarkVideo(payload: GenericRecord): Promise<{ result: GenericRecord[]; pagination: GenericRecord }> {
    const userId = this.requiredNumber(payload.user_id, 'user_id');
    const pageNo = this.optionalNumber(payload.page_no, 1);
    const deviceId = String(payload.device_id ?? '');
    const userParentControlStatus = await this.repository.getUserParentControlStatus(userId, deviceId);
    const bookmarkRows = await this.repository.getBookmarks(userId, userParentControlStatus);

    const result: GenericRecord[] = [];
    for (const bookmark of bookmarkRows) {
      const videoType = Number(bookmark.video_type ?? 0);
      const videoId = Number(bookmark.video_id ?? 0);
      const subVideoType = Number(bookmark.sub_video_type ?? 0);

      if (videoType === 1) {
        const content = await this.repository.getVideoByIdAndType(videoId, 1);
        if (content) {
          result.push(await this.enrichContentRow(content, userId, userParentControlStatus, 0));
        }
        continue;
      }

      if (videoType === 2) {
        const content = await this.repository.getTvShowByIdAndType(videoId, 2);
        if (content) {
          result.push(await this.enrichContentRow(content, userId, userParentControlStatus, 0));
        }
        continue;
      }

      if ((videoType === 5 || videoType === 6 || videoType === 7) && subVideoType === 1) {
        const content = await this.repository.getVideoByIdAndType(videoId, videoType);
        if (content) {
          result.push(await this.enrichContentRow(content, userId, userParentControlStatus, 1));
        }
        continue;
      }

      if ((videoType === 5 || videoType === 6 || videoType === 7) && subVideoType === 2) {
        const content = await this.repository.getTvShowByIdAndType(videoId, videoType);
        if (content) {
          result.push(await this.enrichContentRow(content, userId, userParentControlStatus, 2));
        }
        continue;
      }

      if (videoType === 8) {
        const content = await this.repository.getShortByIdAndType(videoId, 8);
        if (content) {
          result.push(await this.enrichContentRow(content, userId, userParentControlStatus, 0));
        }
      }
    }

    const paged = this.paginateArray(result, pageNo);
    return {
      result: paged.items,
      pagination: paged.pagination,
    };
  }

  async addComment(payload: GenericRecord): Promise<void> {
    const userId = this.requiredNumber(payload.user_id, 'user_id');
    const videoType = this.requiredNumber(payload.video_type, 'video_type');
    const subVideoType = this.optionalNumber(payload.sub_video_type, 0);
    const videoId = this.requiredNumber(payload.video_id, 'video_id');
    const comment = String(payload.comment ?? '').trim();

    if (!comment) {
      throw new Error('comment is required');
    }

    const insertId = await this.repository.createComment(0, userId, videoType, subVideoType, videoId, comment);
    if (insertId <= 0) {
      throw new Error('Data Not Saved.');
    }
  }

  async editComment(payload: GenericRecord): Promise<boolean> {
    const userId = this.requiredNumber(payload.user_id, 'user_id');
    const commentId = this.requiredNumber(payload.comment_id, 'comment_id');
    const comment = String(payload.comment ?? '').trim();
    if (!comment) {
      throw new Error('comment is required');
    }

    const affected = await this.repository.updateComment(commentId, userId, comment);
    return affected > 0;
  }

  async deleteComment(payload: GenericRecord): Promise<boolean> {
    const userId = this.requiredNumber(payload.user_id, 'user_id');
    const commentId = this.requiredNumber(payload.comment_id, 'comment_id');
    const affected = await this.repository.deleteComment(commentId, userId);
    return affected > 0;
  }

  async getComment(payload: GenericRecord): Promise<{ result: GenericRecord[]; pagination: GenericRecord }> {
    const videoType = this.requiredNumber(payload.video_type, 'video_type');
    const subVideoType = this.optionalNumber(payload.sub_video_type, 0);
    const videoId = this.requiredNumber(payload.video_id, 'video_id');
    const pageNo = Math.max(1, this.optionalNumber(payload.page_no, 1));
    const offset = (pageNo - 1) * env.pageLimit;

    const totalRows = await this.repository.getCommentsCount(videoType, subVideoType, videoId);
    const rows = await this.repository.getComments(videoType, subVideoType, videoId, offset, env.pageLimit);

    const result = await Promise.all(
      rows.map(async (row) => {
        const commentId = Number(row.id ?? 0);
        const imageType = Number(row.user_image_type ?? 0);
        const imageValue = String(row.user_image ?? '');
        const userImage = imageType > 0 ? await this.resolveUserImage(imageType, imageValue) : '';
        const replyCount = await this.repository.getReplyCount(commentId, true);

        return {
          ...row,
          user_name: String(row.user_user_name ?? ''),
          full_name: String(row.user_full_name ?? ''),
          user_image: userImage,
          is_reply: replyCount > 0 ? 1 : 0,
          total_reply: replyCount,
        };
      }),
    );

    const totalPage = Math.max(1, Math.ceil(totalRows / env.pageLimit));
    return {
      result,
      pagination: {
        total_rows: totalRows,
        total_page: totalPage,
        current_page: pageNo,
        more_page: pageNo < totalPage,
      },
    };
  }

  async getReplayComment(payload: GenericRecord): Promise<{ result: GenericRecord[]; pagination: GenericRecord }> {
    const commentId = this.requiredNumber(payload.comment_id, 'comment_id');
    const pageNo = Math.max(1, this.optionalNumber(payload.page_no, 1));
    const offset = (pageNo - 1) * env.pageLimit;

    const totalRows = await this.repository.getReplayCommentsCount(commentId);
    const rows = await this.repository.getReplayComments(commentId, offset, env.pageLimit);

    const result = await Promise.all(
      rows.map(async (row) => {
        const currentId = Number(row.id ?? 0);
        const imageType = Number(row.user_image_type ?? 0);
        const imageValue = String(row.user_image ?? '');
        const userImage = imageType > 0 ? await this.resolveUserImage(imageType, imageValue) : '';
        const replyCount = await this.repository.getReplyCount(currentId, false);

        return {
          ...row,
          user_name: String(row.user_full_name ?? ''),
          user_image: userImage,
          is_reply: replyCount > 0 ? 1 : 0,
          total_reply: replyCount,
        };
      }),
    );

    const totalPage = Math.max(1, Math.ceil(totalRows / env.pageLimit));
    return {
      result,
      pagination: {
        total_rows: totalRows,
        total_page: totalPage,
        current_page: pageNo,
        more_page: pageNo < totalPage,
      },
    };
  }

  async getNotification(payload: GenericRecord): Promise<{ result: GenericRecord[]; pagination: GenericRecord }> {
    const userId = this.requiredNumber(payload.user_id, 'user_id');
    const pageNo = Math.max(1, this.optionalNumber(payload.page_no, 1));
    const offset = (pageNo - 1) * env.pageLimit;
    const totalRows = await this.repository.getUnreadNotificationsCount(userId);
    const rows = await this.repository.getUnreadNotifications(userId, offset, env.pageLimit);

    const result = rows.map((row) => ({
      ...row,
      image: this.toAssetUrl('notification', String(row.image ?? ''), 'normal'),
    }));

    const totalPage = Math.max(1, Math.ceil(totalRows / env.pageLimit));
    return {
      result,
      pagination: {
        total_rows: totalRows,
        total_page: totalPage,
        current_page: pageNo,
        more_page: pageNo < totalPage,
      },
    };
  }

  async readNotification(payload: GenericRecord): Promise<void> {
    const userId = this.requiredNumber(payload.user_id, 'user_id');
    const notificationId = this.requiredNumber(payload.notification_id, 'notification_id');
    await this.repository.markNotificationAsRead(userId, notificationId);
  }

  async addRemoveKidsMode(payload: GenericRecord): Promise<boolean> {
    const userId = this.requiredNumber(payload.user_id, 'user_id');
    const deviceId = String(payload.device_id ?? '').trim();
    const kidsMode = this.requiredNumber(payload.kids_mode, 'kids_mode');
    if (!deviceId) {
      throw new Error('device_id is required');
    }

    const affected = await this.repository.updateKidsMode(userId, deviceId, kidsMode);
    return affected > 0;
  }

  async getShortsList(payload: GenericRecord): Promise<{ result: GenericRecord[]; pagination: GenericRecord }> {
    const shortsId = this.optionalNumber(payload.shorts_id, 0);
    const userId = this.optionalNumber(payload.user_id, 0);
    const pageNo = Math.max(1, this.optionalNumber(payload.page_no, 1));
    const offset = (pageNo - 1) * env.pageLimit;
    const totalRows = await this.repository.getShortsListCount();
    const rows = await this.repository.getShortsList(shortsId, offset, env.pageLimit);

    const result = await Promise.all(
      rows.map(async (row) => {
        const enriched = await this.enrichContentRow(row, userId, 0, 0);
        if (String(row.trailer_type ?? '') === 'server_video') {
          enriched.trailer_url = this.toContentFileUrl(String(row.trailer_url ?? ''));
        }
        return enriched;
      }),
    );

    const totalPage = Math.max(1, Math.ceil(totalRows / env.pageLimit));
    return {
      result,
      pagination: {
        total_rows: totalRows,
        total_page: totalPage,
        current_page: pageNo,
        more_page: pageNo < totalPage,
      },
    };
  }

  async getShortsEpisode(payload: GenericRecord): Promise<GenericRecord[]> {
    const shortsId = this.requiredNumber(payload.shorts_id, 'shorts_id');
    const seasonId = this.optionalNumber(payload.season_id, 0);
    const userId = this.optionalNumber(payload.user_id, 0);
    const rows = await this.repository.getShortsEpisodes(shortsId, seasonId);
    const isBuy = await this.repository.isAnyPackageBuy(userId);

    return rows.map((row) => {
      const videoUploadType = String(row.video_upload_type ?? '');
      const mapped: GenericRecord = {
        ...row,
        thumbnail: this.toAssetUrl('content', String(row.thumbnail ?? ''), 'portrait'),
        is_buy: isBuy ? 1 : 0,
      };

      if (videoUploadType === 'server_video') {
        mapped.video_320 = this.toContentFileUrl(String(row.video_320 ?? ''));
      }

      return mapped;
    });
  }

  async addReview(payload: GenericRecord): Promise<'updated' | 'submitted'> {
    const userId = this.requiredNumber(payload.user_id, 'user_id');
    const videoType = this.requiredNumber(payload.video_type, 'video_type');
    const subVideoType = this.optionalNumber(payload.sub_video_type, 0);
    const videoId = this.requiredNumber(payload.video_id, 'video_id');
    const rating = this.requiredNumber(payload.rating, 'rating');
    const reviewText = String(payload.review_text ?? '').trim();

    if (rating < 1 || rating > 5) {
      throw new Error('rating must be between 1 and 5');
    }

    let content: GenericRecord | null = null;
    if (videoType === 1) {
      content = await this.repository.getVideoByIdAndType(videoId, videoType);
    } else if (videoType === 2) {
      content = await this.repository.getTvShowByIdAndType(videoId, videoType);
    } else if (videoType === 6 || videoType === 7) {
      if (subVideoType === 1) {
        content = await this.repository.getVideoByIdAndType(videoId, videoType);
      } else if (subVideoType === 2) {
        content = await this.repository.getTvShowByIdAndType(videoId, videoType);
      }
    } else if (videoType === 8) {
      content = await this.repository.getShortByIdAndType(videoId, videoType);
    }

    if (!content) {
      throw new Error('Data Not Found.');
    }

    const autoApprove = Number(await this.repository.getGeneralSettingValue('auto_approve_reviews') || 0) === 1;
    const targetStatus = autoApprove ? 1 : 0;
    const existing = await this.repository.getReviewByUserContent(userId, videoType, subVideoType, videoId);
    if (existing) {
      await this.repository.updateReview(Number(existing.id ?? 0), rating, reviewText, targetStatus);
      if (autoApprove) {
        await this.recalculateAvgRating(videoType, subVideoType, videoId);
      }
      return 'updated';
    }

    const createdId = await this.repository.createReview(userId, videoType, subVideoType, videoId, rating, reviewText, targetStatus);
    if (createdId <= 0) {
      throw new Error('Data Not Saved.');
    }

    if (autoApprove) {
      await this.recalculateAvgRating(videoType, subVideoType, videoId);
    }
    return 'submitted';
  }

  async getReviews(payload: GenericRecord): Promise<{ result: GenericRecord; pagination: GenericRecord } | null> {
    const videoType = this.requiredNumber(payload.video_type, 'video_type');
    const videoId = this.requiredNumber(payload.video_id, 'video_id');
    const userId = this.optionalNumber(payload.user_id, 0);
    const subVideoType = this.optionalNumber(payload.sub_video_type, 0);
    const pageLimit = Math.max(1, this.optionalNumber(payload.min_content, env.pageLimit));
    const pageNo = Math.max(1, this.optionalNumber(payload.page_no, 1));
    const offset = (pageNo - 1) * pageLimit;

    const meta = await this.repository.getVideoMetaForReview(videoType, subVideoType, videoId);
    if (!meta) {
      return null;
    }

    const avgRating = Number(meta.avg_rating ?? 0);
    const totalReviews = Number(meta.total_review ?? 0);
    const breakdownRaw = await this.repository.getReviewBreakdown(videoType, subVideoType, videoId);
    const ratingBreakdown: Record<string, number> = {};
    for (let i = 5; i >= 1; i -= 1) {
      const count = Number(breakdownRaw[i] ?? 0);
      ratingBreakdown[String(i)] = totalReviews > 0 ? Math.round((count / totalReviews) * 100) : 0;
    }

    let userReview: GenericRecord | GenericRecord[] = [];
    if (userId > 0) {
      const mine = await this.repository.getReviewByUserContent(userId, videoType, subVideoType, videoId);
      if (mine) {
        const status = Number(mine.status ?? 0);
        const statusLabel = status === 0 ? 'Pending moderation' : status === 1 ? 'Approved' : status === 2 ? 'Rejected' : '';
        userReview = {
          id: Number(mine.id ?? 0),
          rating: Number(mine.rating ?? 0),
          review_text: String(mine.review_text ?? ''),
          status,
          status_label: statusLabel,
          created_at: String(mine.created_at ?? ''),
        };
      }
    }

    const totalRows = await this.repository.getApprovedReviewsCount(videoType, subVideoType, videoId);
    const reviewRows = await this.repository.getApprovedReviews(videoType, subVideoType, videoId, offset, pageLimit);
    const reviews = await Promise.all(
      reviewRows.map(async (row) => {
        const imageType = Number(row.user_image_type ?? 0);
        const imageValue = String(row.user_image ?? '');
        return {
          ...row,
          user_name: String(row.user_full_name ?? ''),
          user_image: imageType > 0 ? await this.resolveUserImage(imageType, imageValue) : '',
        };
      }),
    );

    const totalPage = Math.max(1, Math.ceil(totalRows / pageLimit));
    return {
      result: {
        avg_rating: avgRating,
        total_reviews: totalReviews,
        rating_breakdown: ratingBreakdown,
        user_review: userReview,
        reviews,
      },
      pagination: {
        total_rows: totalRows,
        total_page: totalPage,
        current_page: pageNo,
        more_page: pageNo < totalPage,
      },
    };
  }

  async addRemoveLike(payload: GenericRecord): Promise<boolean> {
    const userId = this.requiredNumber(payload.user_id, 'user_id');
    const videoType = this.requiredNumber(payload.video_type, 'video_type');
    const subVideoType = this.optionalNumber(payload.sub_video_type, 0);
    const videoId = this.requiredNumber(payload.video_id, 'video_id');

    return this.repository.toggleLike(userId, videoType, subVideoType, videoId);
  }

  async addRemoveBookmark(payload: GenericRecord): Promise<boolean> {
    const userId = this.requiredNumber(payload.user_id, 'user_id');
    const isKidsProfile = this.requiredNumber(payload.is_kids_profile, 'is_kids_profile');
    const videoType = this.requiredNumber(payload.video_type, 'video_type');
    const subVideoType = this.optionalNumber(payload.sub_video_type, 0);
    const videoId = this.requiredNumber(payload.video_id, 'video_id');

    return this.repository.toggleBookmark(userId, isKidsProfile, videoType, subVideoType, videoId);
  }

  private async enrichUserForApi(user: {
    id: number;
    user_name: string;
    full_name: string;
    email: string;
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
  }, includePackageMeta: boolean): Promise<GenericRecord> {
    const image = await this.resolveUserImage(user.image_type, user.image);
    const isBuy = await this.repository.isAnyPackageBuy(user.id);
    const enriched: GenericRecord = {
      id: user.id,
      user_name: user.user_name,
      full_name: user.full_name,
      email: user.email,
      mobile_number: user.mobile_number,
      storage_type: user.storage_type,
      image_type: user.image_type,
      image,
      type: user.type,
      parent_control_status: user.parent_control_status,
      parent_control_password: user.parent_control_password,
      status: user.status,
      created_at: user.created_at,
      updated_at: user.updated_at,
      is_buy: isBuy ? 1 : 0,
    };

    if (includePackageMeta) {
      const packageMeta = await this.repository.getActivePackageMeta(user.id);
      enriched.package_name = packageMeta.packageName;
      enriched.expiry_date = packageMeta.expiryDate;
      enriched.upcoming_package = await this.repository.getUpcomingPackages(user.id);
    }

    return enriched;
  }

  private async resolveUserImage(imageType: number, imageValue: string): Promise<string> {
    if (imageType === 2) {
      const avatarId = Number(imageValue);
      const avatar = await this.repository.getAvatarById(avatarId);
      if (!avatar) {
        return '';
      }
      return this.toAssetUrl('avatar', String(avatar.image ?? ''), 'profile');
    }

    return this.toAssetUrl('user', imageValue, 'profile');
  }

  private extractDeviceMeta(payload: GenericRecord): {
    deviceName: string;
    deviceId: string;
    deviceType: number;
    deviceToken: string;
  } {
    return {
      deviceName: String(payload.device_name ?? ''),
      deviceId: String(payload.device_id ?? ''),
      deviceType: this.optionalNumber(payload.device_type, 0),
      deviceToken: String(payload.device_token ?? ''),
    };
  }

  private async syncUserDevice(
    userId: number,
    deviceMeta: {
      deviceName: string;
      deviceId: string;
      deviceType: number;
      deviceToken: string;
    },
  ): Promise<{ device_id: string; device_type: number; device_token: string }> {
    const isBuy = await this.repository.isAnyPackageBuy(userId);
    if (isBuy) {
      const limit = await this.repository.getUserPackageDeviceLimit(userId);
      if (limit === null) {
        throw new Error('Something is wrong.');
      }

      const currentList = await this.repository.getUserDeviceSyncList(userId);
      if (limit > currentList.length) {
        const exists = currentList.some((item) => item.device_id === deviceMeta.deviceId);
        if (!exists) {
          await this.repository.createUserDeviceSync({
            userId,
            deviceName: deviceMeta.deviceName,
            deviceId: deviceMeta.deviceId,
            deviceType: deviceMeta.deviceType,
            deviceToken: deviceMeta.deviceToken,
            kidsMode: 0,
            status: 1,
          });
        }

        return {
          device_id: deviceMeta.deviceId,
          device_type: deviceMeta.deviceType,
          device_token: deviceMeta.deviceToken,
        };
      }

      throw new Error('Your device sync limit is over.');
    }

    const existing = await this.repository.getUserDeviceSyncByDeviceId(userId, deviceMeta.deviceId);
    if (existing) {
      return {
        device_id: existing.device_id,
        device_type: existing.device_type,
        device_token: existing.device_token,
      };
    }

    const created = await this.repository.createUserDeviceSync({
      userId,
      deviceName: deviceMeta.deviceName,
      deviceId: deviceMeta.deviceId,
      deviceType: deviceMeta.deviceType,
      deviceToken: deviceMeta.deviceToken,
      kidsMode: 0,
      status: 1,
    });

    return {
      device_id: String(created?.device_id ?? deviceMeta.deviceId),
      device_type: Number(created?.device_type ?? deviceMeta.deviceType),
      device_token: String(created?.device_token ?? deviceMeta.deviceToken),
    };
  }

  private async createUniqueUserName(seed: string): Promise<string> {
    const cleanedSeed = seed.replace(/[^a-zA-Z0-9_]/g, '').toLowerCase() || 'user';
    for (let attempt = 0; attempt < 20; attempt += 1) {
      const randomPart = Math.floor(Math.random() * 1001);
      const userName = `@user_${cleanedSeed}${randomPart}`;
      const exists = await this.repository.existsUserName(userName);
      if (!exists) {
        return userName;
      }
    }

    return `@user_${cleanedSeed}${Date.now()}`;
  }

  private isValidEmail(value: string): boolean {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value);
  }

  private countCsvIds(value: string): number {
    if (!value.trim()) {
      return 0;
    }

    return value
      .split(',')
      .map((item) => item.trim())
      .filter((item) => item.length > 0).length;
  }

  private generateTvLoginCode(): string {
    return String(Math.floor(100000 + Math.random() * 900000));
  }

  private paginateArray<T>(items: T[], pageNo: number): {
    items: T[];
    pagination: {
      total_rows: number;
      total_page: number;
      current_page: number;
      more_page: boolean;
    };
  } {
    const safePageNo = Math.max(1, pageNo);
    const totalRows = items.length;
    const totalPage = Math.max(1, Math.ceil(totalRows / env.pageLimit));
    const offset = (safePageNo - 1) * env.pageLimit;
    const pagedItems = items.slice(offset, offset + env.pageLimit);

    return {
      items: pagedItems,
      pagination: {
        total_rows: totalRows,
        total_page: totalPage,
        current_page: safePageNo,
        more_page: safePageNo < totalPage,
      },
    };
  }

  private buildPageUrl(title: string): string {
    const encodedTitle = encodeURIComponent(title);
    if (!env.appBaseUrl) {
      return `/page/${encodedTitle}`;
    }

    const base = env.appBaseUrl.replace(/\/$/, '');
    return `${base}/page/${encodedTitle}`;
  }

  private requiredNumber(value: unknown, fieldName: string): number {
    const parsed = Number(value);
    if (!Number.isFinite(parsed)) {
      throw new Error(`${fieldName} is required and must be numeric`);
    }

    return parsed;
  }

  private optionalNumber(value: unknown, fallback: number): number {
    if (value === undefined || value === null || value === '') {
      return fallback;
    }

    const parsed = Number(value);
    return Number.isFinite(parsed) ? parsed : fallback;
  }

  private parseIds(value: string): number[] {
    return value
      .split(',')
      .map((item) => Number(item.trim()))
      .filter((item) => Number.isFinite(item) && item > 0);
  }

  private toAssetUrl(folder: string, fileName: string, variant: string): string {
    if (!fileName) {
      return '';
    }

    if (!env.appBaseUrl) {
      return fileName;
    }

    const base = env.appBaseUrl.replace(/\/$/, '');
    return `${base}/uploads/${folder}/${variant}/${fileName}`;
  }

  private toContentFileUrl(fileName: string): string {
    if (!fileName) {
      return '';
    }

    if (!env.appBaseUrl) {
      return fileName;
    }

    const base = env.appBaseUrl.replace(/\/$/, '');
    return `${base}/uploads/content/${fileName}`;
  }

  private addDuration(baseDate: Date, time: number, type: string): Date {
    const safeTime = Number.isFinite(time) && time > 0 ? time : 0;
    const next = new Date(baseDate.getTime());
    const lower = type.toLowerCase();

    if (lower.includes('year')) {
      next.setFullYear(next.getFullYear() + safeTime);
      return next;
    }
    if (lower.includes('month')) {
      next.setMonth(next.getMonth() + safeTime);
      return next;
    }
    if (lower.includes('week')) {
      next.setDate(next.getDate() + safeTime * 7);
      return next;
    }

    next.setDate(next.getDate() + safeTime);
    return next;
  }

  private formatSqlDate(value: Date): string {
    const yyyy = value.getFullYear();
    const mm = String(value.getMonth() + 1).padStart(2, '0');
    const dd = String(value.getDate()).padStart(2, '0');
    const hh = String(value.getHours()).padStart(2, '0');
    const mi = String(value.getMinutes()).padStart(2, '0');
    const ss = String(value.getSeconds()).padStart(2, '0');
    return `${yyyy}-${mm}-${dd} ${hh}:${mi}:${ss}`;
  }

  private formatDateOnly(value: Date): string {
    const yyyy = value.getFullYear();
    const mm = String(value.getMonth() + 1).padStart(2, '0');
    const dd = String(value.getDate()).padStart(2, '0');
    return `${yyyy}-${mm}-${dd}`;
  }

  private calculateDiscountedTotal(originalPrice: number, amountType: number, discountValue: number): number {
    const total = Number.isFinite(originalPrice) ? originalPrice : 0;
    const discount = Number.isFinite(discountValue) ? discountValue : 0;

    if (amountType === 1) {
      return Math.max(total - discount, 0);
    }

    const deduction = (discount / 100) * total;
    return Math.max(total - deduction, 0);
  }

  private async recalculateAvgRating(videoType: number, subVideoType: number, videoId: number): Promise<void> {
    const aggregate = await this.repository.getApprovedReviewAggregate(videoType, subVideoType, videoId);
    const avg = Number(aggregate.avgRating.toFixed(1));
    await this.repository.updateContentReviewSummary(videoType, subVideoType, videoId, avg, aggregate.totalReview);
  }

  private enrichEpisodeRow(row: GenericRecord): GenericRecord {
    return {
      ...row,
      thumbnail: this.toAssetUrl('content', String(row.thumbnail ?? ''), 'portrait'),
      landscape: this.toAssetUrl('content', String(row.landscape ?? ''), 'landscape'),
    };
  }

  private async enrichContentRow(
    row: GenericRecord,
    userId: number,
    isKidsProfile: number,
    subVideoType: number,
  ): Promise<GenericRecord> {
    const videoType = Number(row.video_type ?? 0);
    const videoId = Number(row.id ?? 0);
    const categoryNames = await this.repository.getCategoryNamesByIds(String(row.category_id ?? ''));
    const languageNames = await this.repository.getLanguageNamesByIds(String(row.language_id ?? ''));
    const isBookmarked = await this.repository.isBookmarked(userId, isKidsProfile, videoType, subVideoType, videoId);
    const isUserLike = await this.repository.isLiked(userId, videoType, subVideoType, videoId);
    const stopTime = await this.repository.getStopTime(userId, videoType, subVideoType, videoId);
    const totalComment = await this.repository.getTotalComment(videoType, subVideoType, videoId);
    const isBuy = await this.repository.isAnyPackageBuy(userId);
    const rentBuy = await this.repository.isRentBuy(userId, videoType, subVideoType, videoId);
    const rentExpiryDate = await this.repository.getRentExpiryDate(userId, videoType, subVideoType, videoId);

    const sourcePrice = Number(row.price ?? 0);
    const rentPriceDetail = await this.repository.getRentPriceDetailById(sourcePrice);
    const rentPriceId = rentPriceDetail ? Number(rentPriceDetail.id ?? 0) : 0;
    const mappedPrice = rentPriceDetail ? Number(rentPriceDetail.price ?? 0) : 0;
    const androidProductPackage = rentPriceDetail ? String(rentPriceDetail.android_product_package ?? '') : '';
    const iosProductPackage = rentPriceDetail ? String(rentPriceDetail.ios_product_package ?? '') : '';
    const webPriceId = rentPriceDetail ? String(rentPriceDetail.web_price_id ?? '') : '';

    let thumbnail = row.thumbnail;
    let landscape = row.landscape;
    if (videoType === 8) {
      thumbnail = this.toAssetUrl('content', String(row.thumbnail ?? ''), 'portrait');
      landscape = row.landscape ?? '';
    } else {
      thumbnail = this.toAssetUrl('content', String(row.thumbnail ?? ''), 'portrait');
      landscape = this.toAssetUrl('content', String(row.landscape ?? ''), 'landscape');
    }

    return {
      ...row,
      thumbnail,
      landscape,
      sub_video_type: subVideoType,
      rent_price_id: rentPriceId,
      price: mappedPrice,
      android_product_package: androidProductPackage,
      ios_product_package: iosProductPackage,
      web_price_id: webPriceId,
      is_buy: isBuy ? 1 : 0,
      rent_buy: rentBuy ? 1 : 0,
      rent_expiry_date: rentExpiryDate,
      is_bookmark: isBookmarked ? 1 : 0,
      is_user_like: isUserLike ? 1 : 0,
      stop_time: stopTime,
      total_comment: totalComment,
      category_name: categoryNames,
      language_name: languageNames,
    };
  }
}
