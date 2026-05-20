import bcrypt from 'bcryptjs';
import { BackofficeRepository } from './backoffice.repository';

function normalizeBcryptHash(hash: string): string {
  if (hash.startsWith('$2y$')) {
    return `$2a$${hash.slice(4)}`;
  }

  return hash;
}

export class BackofficeService {
  private readonly repository = new BackofficeRepository();

  private parseSortableIds(ids: string): number[] {
    const parsedIds = ids
      .split(',')
      .map((value) => Number(value.trim()))
      .filter((value) => Number.isFinite(value) && value > 0);

    if (parsedIds.length === 0) {
      throw new Error('ids are required');
    }

    return parsedIds;
  }

  private async ensurePasswordMatch(rawPassword: string, hashedPassword: string): Promise<boolean> {
    return bcrypt.compare(rawPassword, normalizeBcryptHash(hashedPassword));
  }

  async loginAdmin(email: string, password: string): Promise<{ id: number; userName: string } | null> {
    const user = await this.repository.getAdminByEmail(email);
    if (!user || user.status !== 1) {
      return null;
    }

    const verified = await this.ensurePasswordMatch(password, user.password);
    if (!verified) {
      return null;
    }

    return {
      id: user.id,
      userName: user.user_name,
    };
  }

  async loginProducer(email: string, password: string): Promise<{ id: number; userName: string } | null> {
    const user = await this.repository.getProducerByEmail(email);
    if (!user || user.status !== 1) {
      return null;
    }

    const verified = await this.ensurePasswordMatch(password, user.password);
    if (!verified) {
      return null;
    }

    return {
      id: user.id,
      userName: user.user_name,
    };
  }

  getAdminDashboardStats() {
    return this.repository.getAdminDashboardStats();
  }

  async getProducerDashboardStats(producerId: number) {
    const [stats, typeLinks] = await Promise.all([
      this.repository.getProducerDashboardStats(producerId),
      this.repository.getProducerDashboardTypeLinks(),
    ]);

    return {
      ...stats,
      ...typeLinks,
    };
  }

  async getAdminProfile(adminId: number): Promise<{ id: number; userName: string; email: string } | null> {
    const admin = await this.repository.getAdminById(adminId);
    if (!admin) {
      return null;
    }

    return {
      id: admin.id,
      userName: admin.user_name,
      email: admin.email,
    };
  }

  async updateAdminProfile(adminId: number, userName: string, email: string): Promise<void> {
    if (userName.trim().length < 4) {
      throw new Error('user_name must be at least 4 characters');
    }
    if (!email.includes('@')) {
      throw new Error('email must be valid');
    }

    await this.repository.updateAdminProfile(adminId, userName.trim(), email.trim());
  }

  async changeAdminPassword(adminId: number, currentPassword: string, newPassword: string, confirmPassword: string): Promise<void> {
    if (!currentPassword || !newPassword || !confirmPassword) {
      throw new Error('current/new/confirm password are required');
    }
    if (newPassword.length < 4) {
      throw new Error('new_password must be at least 4 characters');
    }
    if (newPassword !== confirmPassword) {
      throw new Error('confirm_password must match new_password');
    }

    const admin = await this.repository.getAdminById(adminId);
    if (!admin) {
      throw new Error('admin not found');
    }

    const verified = await this.ensurePasswordMatch(currentPassword, admin.password);
    if (!verified) {
      throw new Error('please enter right current password');
    }

    const newHash = await bcrypt.hash(newPassword, 10);
    await this.repository.updateAdminPassword(adminId, newHash);
  }

  getAdminVideos() {
    return this.repository.getAdminVideos();
  }

  async toggleAdminVideoStatus(id: number): Promise<void> {
    if (!Number.isFinite(id) || id <= 0) {
      throw new Error('id is invalid');
    }

    const ok = await this.repository.toggleAdminVideoStatus(id);
    if (!ok) {
      throw new Error('video not found');
    }
  }

  getAdminTvShows() {
    return this.repository.getAdminTvShows();
  }

  async toggleAdminTvShowStatus(id: number): Promise<void> {
    if (!Number.isFinite(id) || id <= 0) {
      throw new Error('id is invalid');
    }

    const ok = await this.repository.toggleAdminTvShowStatus(id);
    if (!ok) {
      throw new Error('tvshow not found');
    }
  }

  getAdminShorts() {
    return this.repository.getAdminShorts();
  }

  async toggleAdminShortsStatus(id: number): Promise<void> {
    if (!Number.isFinite(id) || id <= 0) {
      throw new Error('id is invalid');
    }

    const ok = await this.repository.toggleAdminShortsStatus(id);
    if (!ok) {
      throw new Error('shorts not found');
    }
  }

  async getProducerProfile(producerId: number): Promise<{ id: number; userName: string; fullName: string; email: string; mobileNumber: string } | null> {
    const producer = await this.repository.getProducerById(producerId);
    if (!producer) {
      return null;
    }

    return {
      id: producer.id,
      userName: producer.user_name,
      fullName: producer.full_name,
      email: producer.email,
      mobileNumber: producer.mobile_number ?? '',
    };
  }

  async updateProducerProfile(
    producerId: number,
    userName: string,
    fullName: string,
    email: string,
    mobileNumber: string,
  ): Promise<void> {
    if (userName.trim().length < 1) {
      throw new Error('user_name is required');
    }
    if (fullName.trim().length < 2) {
      throw new Error('full_name must be at least 2 characters');
    }
    if (!email.includes('@')) {
      throw new Error('email must be valid');
    }
    if (!/^\d+$/.test(mobileNumber.trim())) {
      throw new Error('mobile_number must be numeric');
    }

    const [hasUserName, hasEmail, hasMobile] = await Promise.all([
      this.repository.existsProducerUserName(userName.trim(), producerId),
      this.repository.existsProducerEmail(email.trim(), producerId),
      this.repository.existsProducerMobile(mobileNumber.trim(), producerId),
    ]);

    if (hasUserName) {
      throw new Error('user_name already exists');
    }
    if (hasEmail) {
      throw new Error('email already exists');
    }
    if (hasMobile) {
      throw new Error('mobile_number already exists');
    }

    await this.repository.updateProducerProfile(producerId, userName.trim(), fullName.trim(), email.trim(), mobileNumber.trim());
  }

  async changeProducerPassword(
    producerId: number,
    currentPassword: string,
    newPassword: string,
    confirmPassword: string,
  ): Promise<void> {
    if (!currentPassword || !newPassword || !confirmPassword) {
      throw new Error('current/new/confirm password are required');
    }
    if (newPassword.length < 4) {
      throw new Error('new_password must be at least 4 characters');
    }
    if (newPassword !== confirmPassword) {
      throw new Error('confirm_password must match new_password');
    }

    const producer = await this.repository.getProducerById(producerId);
    if (!producer) {
      throw new Error('producer not found');
    }

    const verified = await this.ensurePasswordMatch(currentPassword, producer.password);
    if (!verified) {
      throw new Error('please enter right current password');
    }

    const newHash = await bcrypt.hash(newPassword, 10);
    await this.repository.updateProducerPassword(producerId, newHash);
  }

  getAdminCategories() {
    return this.repository.getAdminCategories();
  }

  getAdminTypes() {
    return this.repository.getAdminTypes();
  }

  async createAdminType(name: string, type: number, icon: string): Promise<void> {
    if (name.trim().length < 2) {
      throw new Error('name must be at least 2 characters');
    }
    if (!Number.isFinite(type) || type <= 0) {
      throw new Error('type is required');
    }

    await this.repository.createAdminType(name.trim(), type, icon.trim());
  }

  async updateAdminType(id: number, name: string, type: number, icon: string): Promise<void> {
    if (!Number.isFinite(id) || id <= 0) {
      throw new Error('id is invalid');
    }
    if (name.trim().length < 2) {
      throw new Error('name must be at least 2 characters');
    }
    if (!Number.isFinite(type) || type <= 0) {
      throw new Error('type is required');
    }

    await this.repository.updateAdminType(id, name.trim(), type, icon.trim());
  }

  async toggleAdminTypeStatus(id: number): Promise<void> {
    if (!Number.isFinite(id) || id <= 0) {
      throw new Error('id is invalid');
    }

    const ok = await this.repository.toggleAdminTypeStatus(id);
    if (!ok) {
      throw new Error('type not found');
    }
  }

  async saveAdminTypeSortOrder(ids: string): Promise<void> {
    const parsedIds = this.parseSortableIds(ids);
    await this.repository.saveAdminTypeSortOrder(parsedIds);
  }

  getAdminAvatars() {
    return this.repository.getAdminAvatars();
  }

  async createAdminAvatar(name: string, image: string): Promise<void> {
    if (name.trim().length < 2) {
      throw new Error('name must be at least 2 characters');
    }

    await this.repository.createAdminAvatar(name.trim(), image.trim());
  }

  async updateAdminAvatar(id: number, name: string, image: string): Promise<void> {
    if (!Number.isFinite(id) || id <= 0) {
      throw new Error('id is invalid');
    }
    if (name.trim().length < 2) {
      throw new Error('name must be at least 2 characters');
    }

    await this.repository.updateAdminAvatar(id, name.trim(), image.trim());
  }

  async toggleAdminAvatarStatus(id: number): Promise<void> {
    if (!Number.isFinite(id) || id <= 0) {
      throw new Error('id is invalid');
    }

    const ok = await this.repository.toggleAdminAvatarStatus(id);
    if (!ok) {
      throw new Error('avatar not found');
    }
  }

  async saveAdminAvatarSortOrder(ids: string): Promise<void> {
    const parsedIds = this.parseSortableIds(ids);
    await this.repository.saveAdminAvatarSortOrder(parsedIds);
  }

  getAdminChannels() {
    return this.repository.getAdminChannels();
  }

  async createAdminChannel(name: string, portraitImg: string, landscapeImg: string, isTitle: number): Promise<void> {
    if (name.trim().length < 2) {
      throw new Error('name must be at least 2 characters');
    }
    if (!Number.isFinite(isTitle)) {
      throw new Error('is_title is required');
    }

    await this.repository.createAdminChannel(name.trim(), portraitImg.trim(), landscapeImg.trim(), isTitle);
  }

  async updateAdminChannel(id: number, name: string, portraitImg: string, landscapeImg: string, isTitle: number): Promise<void> {
    if (!Number.isFinite(id) || id <= 0) {
      throw new Error('id is invalid');
    }
    if (name.trim().length < 2) {
      throw new Error('name must be at least 2 characters');
    }
    if (!Number.isFinite(isTitle)) {
      throw new Error('is_title is required');
    }

    await this.repository.updateAdminChannel(id, name.trim(), portraitImg.trim(), landscapeImg.trim(), isTitle);
  }

  async toggleAdminChannelStatus(id: number): Promise<void> {
    if (!Number.isFinite(id) || id <= 0) {
      throw new Error('id is invalid');
    }

    const ok = await this.repository.toggleAdminChannelStatus(id);
    if (!ok) {
      throw new Error('channel not found');
    }
  }

  async createAdminCategory(name: string, image: string): Promise<void> {
    if (name.trim().length < 2) {
      throw new Error('name must be at least 2 characters');
    }

    await this.repository.createAdminCategory(name.trim(), image.trim());
  }

  async updateAdminCategory(id: number, name: string, image: string): Promise<void> {
    if (!Number.isFinite(id) || id <= 0) {
      throw new Error('id is invalid');
    }
    if (name.trim().length < 2) {
      throw new Error('name must be at least 2 characters');
    }

    await this.repository.updateAdminCategory(id, name.trim(), image.trim());
  }

  async toggleAdminCategoryStatus(id: number): Promise<void> {
    if (!Number.isFinite(id) || id <= 0) {
      throw new Error('id is invalid');
    }

    const ok = await this.repository.toggleAdminCategoryStatus(id);
    if (!ok) {
      throw new Error('category not found');
    }
  }

  async saveAdminCategorySortOrder(ids: string): Promise<void> {
    const parsedIds = this.parseSortableIds(ids);
    await this.repository.saveAdminCategorySortOrder(parsedIds);
  }

  getAdminLanguages() {
    return this.repository.getAdminLanguages();
  }

  async createAdminLanguage(name: string, image: string): Promise<void> {
    if (name.trim().length < 2) {
      throw new Error('name must be at least 2 characters');
    }

    await this.repository.createAdminLanguage(name.trim(), image.trim());
  }

  async updateAdminLanguage(id: number, name: string, image: string): Promise<void> {
    if (!Number.isFinite(id) || id <= 0) {
      throw new Error('id is invalid');
    }
    if (name.trim().length < 2) {
      throw new Error('name must be at least 2 characters');
    }

    await this.repository.updateAdminLanguage(id, name.trim(), image.trim());
  }

  async toggleAdminLanguageStatus(id: number): Promise<void> {
    if (!Number.isFinite(id) || id <= 0) {
      throw new Error('id is invalid');
    }

    const ok = await this.repository.toggleAdminLanguageStatus(id);
    if (!ok) {
      throw new Error('language not found');
    }
  }

  async saveAdminLanguageSortOrder(ids: string): Promise<void> {
    const parsedIds = this.parseSortableIds(ids);
    await this.repository.saveAdminLanguageSortOrder(parsedIds);
  }

  getAdminSeasons() {
    return this.repository.getAdminSeasons();
  }

  async createAdminSeason(name: string): Promise<void> {
    if (name.trim().length < 2) {
      throw new Error('name must be at least 2 characters');
    }

    await this.repository.createAdminSeason(name.trim());
  }

  async updateAdminSeason(id: number, name: string): Promise<void> {
    if (!Number.isFinite(id) || id <= 0) {
      throw new Error('id is invalid');
    }
    if (name.trim().length < 2) {
      throw new Error('name must be at least 2 characters');
    }

    await this.repository.updateAdminSeason(id, name.trim());
  }

  async saveAdminSeasonSortOrder(ids: string): Promise<void> {
    const parsedIds = this.parseSortableIds(ids);
    await this.repository.saveAdminSeasonSortOrder(parsedIds);
  }

  getProducerWithdrawalSetup(producerId: number) {
    return this.repository.getProducerWithdrawalSetup(producerId);
  }

  async getProducerWithdrawals(producerId: number, inputStatus: string) {
    const normalizedStatus = inputStatus === '0' ? 0 : inputStatus === '1' ? 1 : 'all';
    return this.repository.getProducerWithdrawals(producerId, normalizedStatus);
  }

  async createProducerWithdrawalRequest(producerId: number, priceRaw: string): Promise<void> {
    const price = Number(priceRaw);
    if (!Number.isFinite(price) || price <= 0) {
      throw new Error('price is required');
    }

    const setup = await this.repository.getProducerWithdrawalSetup(producerId);
    if (!setup) {
      throw new Error('producer not found');
    }

    if (price < setup.minWithdrawalAmount) {
      throw new Error(`min withdrawal amount is ${setup.minWithdrawalAmount}`);
    }

    if (setup.wallet < price) {
      throw new Error('withdrawal amount exceeds your available wallet balance');
    }

    const result = await this.repository.createProducerWithdrawalRequest(producerId, price);
    if (!result.ok) {
      if (result.reason === 'producer_not_found') {
        throw new Error('producer not found');
      }
      if (result.reason === 'insufficient_wallet') {
        throw new Error('withdrawal amount exceeds your available wallet balance');
      }
      throw new Error('failed to create withdrawal request');
    }
  }

  async getProducerRentTransactionsViewPayload(producerId: number, inputType: string, inputSearch: string) {
    await this.repository.expireRentTransactions();

    const normalizedType = inputType === 'today' || inputType === 'month' || inputType === 'year' ? inputType : 'all';
    const [yearSummary, monthSummary, todaySummary, items, currencyCode] = await Promise.all([
      this.repository.getProducerRentSummary(producerId, 'year'),
      this.repository.getProducerRentSummary(producerId, 'month'),
      this.repository.getProducerRentSummary(producerId, 'today'),
      this.repository.getProducerRentTransactions(producerId, normalizedType, inputSearch),
      this.repository.getGeneralSettingValue('currency_code'),
    ]);

    return {
      summary: {
        year: yearSummary,
        month: monthSummary,
        today: todaySummary,
      },
      currencyCode: currencyCode || '$',
      items,
      inputType: normalizedType,
      inputSearch,
    };
  }

  async getProducerChannelsViewPayload(inputSearch: string) {
    const normalizedSearch = inputSearch.trim();
    const items = await this.repository.getProducerChannels(normalizedSearch);
    return {
      inputSearch: normalizedSearch,
      items,
    };
  }

  private toCsv(value: unknown): string {
    if (Array.isArray(value)) {
      return value
        .map((item) => String(item).trim())
        .filter((item) => item.length > 0)
        .join(',');
    }
    return String(value ?? '')
      .split(',')
      .map((item) => item.trim())
      .filter((item) => item.length > 0)
      .join(',');
  }

  private mapProducerVideoPayload(body: Record<string, unknown>, fallbackTypeId = 0) {
    const typeId = Number(body.type_id ?? fallbackTypeId);
    const videoType = Number(body.video_type ?? 1);
    const isRent = Number(body.is_rent ?? 0);
    const price = Number(body.price ?? 0);
    const rentDay = Number(body.rent_day ?? 0);

    if (!Number.isFinite(typeId) || typeId <= 0) {
      throw new Error('type_id is required');
    }
    if (!Number.isFinite(videoType) || videoType <= 0) {
      throw new Error('video_type is required');
    }

    const name = String(body.name ?? '').trim();
    if (name.length < 2) {
      throw new Error('name must be at least 2 characters');
    }

    const channelId = Number(body.channel_id ?? 0);
    if (videoType === 6 && (!Number.isFinite(channelId) || channelId <= 0)) {
      throw new Error('channel_id is required for channel content');
    }

    if (isRent === 1 && (!Number.isFinite(price) || price <= 0 || !Number.isFinite(rentDay) || rentDay <= 0)) {
      throw new Error('price and rent_day are required when is_rent = 1');
    }

    return {
      id: Number(body.id ?? 0),
      type_id: typeId,
      video_type: videoType,
      channel_id: Number.isFinite(channelId) ? channelId : 0,
      category_id: this.toCsv(body.category_id),
      language_id: this.toCsv(body.language_id),
      cast_id: this.toCsv(body.cast_id),
      name,
      thumbnail: String(body.thumbnail ?? '').trim(),
      landscape: String(body.landscape ?? '').trim(),
      description: String(body.description ?? '').trim(),
      release_date: String(body.release_date ?? '').trim(),
      is_premium: Number(body.is_premium ?? 0),
      is_title: Number(body.is_title ?? 0),
      is_download: Number(body.is_download ?? 0),
      is_comment: Number(body.is_comment ?? 0),
      is_like: Number(body.is_like ?? 0),
      is_rent: isRent,
      price: isRent === 1 ? price : 0,
      rent_day: isRent === 1 ? rentDay : 0,
      video_upload_type: String(body.video_upload_type ?? 'external').trim() || 'external',
      video_320: String(body.video_320 ?? '').trim(),
      video_480: String(body.video_480 ?? '').trim(),
      video_720: String(body.video_720 ?? '').trim(),
      video_1080: String(body.video_1080 ?? '').trim(),
      trailer_type: String(body.trailer_type ?? 'external').trim() || 'external',
      trailer_url: String(body.trailer_url ?? '').trim(),
      subtitle_type: String(body.subtitle_type ?? 'external').trim() || 'external',
      subtitle_1: String(body.subtitle_1 ?? '').trim(),
      subtitle_2: String(body.subtitle_2 ?? '').trim(),
      subtitle_3: String(body.subtitle_3 ?? '').trim(),
      subtitle_lang_1: String(body.subtitle_lang_1 ?? '').trim(),
      subtitle_lang_2: String(body.subtitle_lang_2 ?? '').trim(),
      subtitle_lang_3: String(body.subtitle_lang_3 ?? '').trim(),
    };
  }

  async getProducerVideosViewPayload(producerId: number, typeId: number, query: Record<string, string>) {
    const inputSearch = String(query.input_search ?? '').trim();
    const inputRent = String(query.input_rent ?? '0');
    const inputPremium = String(query.input_premium ?? 'all');
    const inputStatus = String(query.input_status ?? 'all');

    const [type, items, channels, releasesTypes] = await Promise.all([
      this.repository.getTypeById(typeId),
      this.repository.getProducerVideos(producerId, typeId, inputSearch, inputRent, inputPremium, inputStatus),
      this.repository.getProducerChannels(''),
      this.repository.getProducerReleasesTypes(),
    ]);

    if (!type) {
      throw new Error('type not found');
    }

    return {
      typeId,
      inputSearch,
      inputRent,
      inputPremium,
      inputStatus,
      items,
      channels,
      releasesTypes,
    };
  }

  async createProducerVideo(producerId: number, body: Record<string, unknown>, fallbackTypeId: number): Promise<void> {
    const payload = this.mapProducerVideoPayload(body, fallbackTypeId);
    await this.repository.createProducerVideo(producerId, payload);
  }

  async updateProducerVideo(producerId: number, videoId: number, body: Record<string, unknown>, fallbackTypeId: number): Promise<void> {
    if (!Number.isFinite(videoId) || videoId <= 0) {
      throw new Error('video_id is invalid');
    }

    const payload = this.mapProducerVideoPayload(body, fallbackTypeId);
    const ok = await this.repository.updateProducerVideo(videoId, producerId, payload);
    if (!ok) {
      throw new Error('video not found');
    }
  }

  async deleteProducerVideo(producerId: number, videoId: number): Promise<void> {
    if (!Number.isFinite(videoId) || videoId <= 0) {
      throw new Error('video_id is invalid');
    }

    const ok = await this.repository.deleteProducerVideo(videoId, producerId);
    if (!ok) {
      throw new Error('video not found');
    }
  }

  async toggleProducerVideoStatus(producerId: number, videoId: number): Promise<void> {
    if (!Number.isFinite(videoId) || videoId <= 0) {
      throw new Error('video_id is invalid');
    }

    const ok = await this.repository.toggleProducerVideoStatus(videoId, producerId);
    if (!ok) {
      throw new Error('video not found');
    }
  }

  async releaseProducerVideo(producerId: number, videoId: number, typeId: number, channelId: number): Promise<void> {
    if (!Number.isFinite(videoId) || videoId <= 0) {
      throw new Error('video id is required');
    }
    if (!Number.isFinite(typeId) || typeId <= 0) {
      throw new Error('type_id is required');
    }

    const type = await this.repository.getTypeById(typeId);
    if (!type) {
      throw new Error('type not found');
    }

    if (type.type === 6 && (!Number.isFinite(channelId) || channelId <= 0)) {
      throw new Error('channel_id is required');
    }

    const ok = await this.repository.releaseProducerVideo(videoId, producerId, type.id, type.type, type.type === 6 ? channelId : 0);
    if (!ok) {
      throw new Error('video not found');
    }
  }

  async searchProducerVideoNames(producerId: number, txtVal: string) {
    if (txtVal.trim().length < 1) {
      return [];
    }

    return this.repository.searchProducerVideoNames(producerId, txtVal.trim());
  }

  async getProducerVideoDataForFill(producerId: number, videoId: number) {
    if (!Number.isFinite(videoId) || videoId <= 0) {
      throw new Error('video_id is invalid');
    }

    return this.repository.getProducerVideoDataForFill(producerId, videoId);
  }

  private mapProducerTvShowPayload(body: Record<string, unknown>, fallbackTypeId = 0) {
    const typeId = Number(body.type_id ?? fallbackTypeId);
    const videoType = Number(body.video_type ?? 2);
    const isRent = Number(body.is_rent ?? 0);
    const price = Number(body.price ?? 0);
    const rentDay = Number(body.rent_day ?? 0);

    if (!Number.isFinite(typeId) || typeId <= 0) {
      throw new Error('type_id is required');
    }
    if (!Number.isFinite(videoType) || videoType <= 0) {
      throw new Error('video_type is required');
    }

    const name = String(body.name ?? '').trim();
    if (name.length < 2) {
      throw new Error('name must be at least 2 characters');
    }

    const channelId = Number(body.channel_id ?? 0);
    if (videoType === 6 && (!Number.isFinite(channelId) || channelId <= 0)) {
      throw new Error('channel_id is required for channel content');
    }

    if (isRent === 1 && (!Number.isFinite(price) || price <= 0 || !Number.isFinite(rentDay) || rentDay <= 0)) {
      throw new Error('price and rent_day are required when is_rent = 1');
    }

    return {
      id: Number(body.id ?? 0),
      type_id: typeId,
      video_type: videoType,
      channel_id: Number.isFinite(channelId) ? channelId : 0,
      category_id: this.toCsv(body.category_id),
      language_id: this.toCsv(body.language_id),
      cast_id: this.toCsv(body.cast_id),
      name,
      thumbnail: String(body.thumbnail ?? '').trim(),
      landscape: String(body.landscape ?? '').trim(),
      trailer_type: String(body.trailer_type ?? 'external').trim() || 'external',
      trailer_url: String(body.trailer_url ?? '').trim(),
      description: String(body.description ?? '').trim(),
      release_date: String(body.release_date ?? '').trim(),
      is_title: Number(body.is_title ?? 0),
      is_comment: Number(body.is_comment ?? 1),
      is_like: Number(body.is_like ?? 1),
      is_rent: isRent,
      price: isRent === 1 ? price : 0,
      rent_day: isRent === 1 ? rentDay : 0,
    };
  }

  private mapProducerShortsPayload(body: Record<string, unknown>, fallbackTypeId = 0) {
    const typeId = Number(body.type_id ?? fallbackTypeId);
    const videoType = Number(body.video_type ?? 8);

    if (!Number.isFinite(typeId) || typeId <= 0) {
      throw new Error('type_id is required');
    }
    if (!Number.isFinite(videoType) || videoType <= 0) {
      throw new Error('video_type is required');
    }

    const name = String(body.name ?? '').trim();
    if (name.length < 2) {
      throw new Error('name must be at least 2 characters');
    }

    return {
      id: Number(body.id ?? 0),
      type_id: typeId,
      video_type: videoType,
      channel_id: 0,
      category_id: this.toCsv(body.category_id),
      language_id: this.toCsv(body.language_id),
      cast_id: this.toCsv(body.cast_id),
      name,
      thumbnail: String(body.thumbnail ?? '').trim(),
      landscape: '',
      trailer_type: String(body.trailer_type ?? 'external').trim() || 'external',
      trailer_url: String(body.trailer_url ?? '').trim(),
      description: String(body.description ?? '').trim(),
      release_date: '',
      is_title: Number(body.is_title ?? 0),
      is_comment: Number(body.is_comment ?? 1),
      is_like: Number(body.is_like ?? 1),
      is_rent: 0,
      price: 0,
      rent_day: 0,
    };
  }

  async getProducerTvShowsViewPayload(producerId: number, typeId: number, query: Record<string, string>) {
    const inputSearch = String(query.input_search ?? '').trim();
    const inputRent = String(query.input_rent ?? '0');
    const inputStatus = String(query.input_status ?? 'all');

    const [type, items, channels, releasesTypes] = await Promise.all([
      this.repository.getTypeById(typeId),
      this.repository.getProducerTvShows(producerId, typeId, inputSearch, inputRent, inputStatus),
      this.repository.getProducerChannels(''),
      this.repository.getProducerReleasesTypes(),
    ]);

    if (!type) {
      throw new Error('type not found');
    }

    return {
      typeId,
      inputSearch,
      inputRent,
      inputStatus,
      items,
      channels,
      releasesTypes,
    };
  }

  async createProducerTvShow(producerId: number, body: Record<string, unknown>, fallbackTypeId: number): Promise<void> {
    const payload = this.mapProducerTvShowPayload(body, fallbackTypeId);
    await this.repository.createProducerTvShow(producerId, payload);
  }

  async updateProducerTvShow(producerId: number, tvShowId: number, body: Record<string, unknown>, fallbackTypeId: number): Promise<void> {
    if (!Number.isFinite(tvShowId) || tvShowId <= 0) {
      throw new Error('tvshow_id is invalid');
    }

    const payload = this.mapProducerTvShowPayload(body, fallbackTypeId);
    const ok = await this.repository.updateProducerTvShow(tvShowId, producerId, payload);
    if (!ok) {
      throw new Error('tvshow not found');
    }
  }

  async deleteProducerTvShow(producerId: number, tvShowId: number): Promise<void> {
    if (!Number.isFinite(tvShowId) || tvShowId <= 0) {
      throw new Error('tvshow_id is invalid');
    }

    const ok = await this.repository.deleteProducerTvShow(tvShowId, producerId);
    if (!ok) {
      throw new Error('tvshow not found');
    }
  }

  async toggleProducerTvShowStatus(producerId: number, tvShowId: number): Promise<void> {
    if (!Number.isFinite(tvShowId) || tvShowId <= 0) {
      throw new Error('tvshow_id is invalid');
    }

    const ok = await this.repository.toggleProducerTvShowStatus(tvShowId, producerId);
    if (!ok) {
      throw new Error('tvshow not found');
    }
  }

  async releaseProducerTvShow(producerId: number, tvShowId: number, typeId: number, channelId: number): Promise<void> {
    if (!Number.isFinite(tvShowId) || tvShowId <= 0) {
      throw new Error('tvshow id is required');
    }
    if (!Number.isFinite(typeId) || typeId <= 0) {
      throw new Error('type_id is required');
    }

    const type = await this.repository.getTypeById(typeId);
    if (!type) {
      throw new Error('type not found');
    }

    if (type.type === 6 && (!Number.isFinite(channelId) || channelId <= 0)) {
      throw new Error('channel_id is required');
    }

    const ok = await this.repository.releaseProducerTvShow(tvShowId, producerId, type.id, type.type, type.type === 6 ? channelId : 0);
    if (!ok) {
      throw new Error('tvshow not found');
    }
  }

  async searchProducerTvShowNames(producerId: number, txtVal: string) {
    if (txtVal.trim().length < 1) {
      return [];
    }

    return this.repository.searchProducerTvShowNames(producerId, txtVal.trim());
  }

  async getProducerTvShowDataForFill(producerId: number, tvShowId: number) {
    if (!Number.isFinite(tvShowId) || tvShowId <= 0) {
      throw new Error('tvshow_id is invalid');
    }

    return this.repository.getProducerTvShowDataForFill(producerId, tvShowId);
  }

  private mapProducerTvShowEpisodePayload(body: Record<string, unknown>, fallbackShowId = 0) {
    const showId = Number(body.show_id ?? fallbackShowId);
    const seasonId = Number(body.season_id ?? 0);
    const name = String(body.name ?? '').trim();
    const videoUploadType = String(body.video_upload_type ?? 'external').trim() || 'external';
    const subtitleType = String(body.subtitle_type ?? '').trim();
    const video320 = String(body.video_320 ?? '').trim();

    if (!Number.isFinite(showId) || showId <= 0) {
      throw new Error('show_id is required');
    }
    if (!Number.isFinite(seasonId) || seasonId <= 0) {
      throw new Error('season_id is required');
    }
    if (name.length < 1) {
      throw new Error('name is required');
    }
    if (subtitleType.length < 1) {
      throw new Error('subtitle_type is required');
    }
    if (videoUploadType === 'server_video' && video320.length < 1) {
      throw new Error('video_320 is required');
    }

    return {
      id: Number(body.id ?? 0),
      show_id: showId,
      season_id: seasonId,
      name,
      thumbnail: String(body.thumbnail ?? '').trim(),
      landscape: String(body.landscape ?? '').trim(),
      description: String(body.description ?? '').trim(),
      video_upload_type: videoUploadType,
      video_320: video320,
      video_480: String(body.video_480 ?? '').trim(),
      video_720: String(body.video_720 ?? '').trim(),
      video_1080: String(body.video_1080 ?? '').trim(),
      subtitle_type: subtitleType,
      subtitle_1: String(body.subtitle_1 ?? '').trim(),
      subtitle_2: String(body.subtitle_2 ?? '').trim(),
      subtitle_3: String(body.subtitle_3 ?? '').trim(),
      subtitle_lang_1: String(body.subtitle_lang_1 ?? '').trim(),
      subtitle_lang_2: String(body.subtitle_lang_2 ?? '').trim(),
      subtitle_lang_3: String(body.subtitle_lang_3 ?? '').trim(),
      is_premium: Number(body.is_premium ?? 0),
      is_title: Number(body.is_title ?? 0),
      is_download: videoUploadType === 'server_video' ? Number(body.is_download ?? 0) : 0,
    };
  }

  private mapProducerShortsEpisodePayload(body: Record<string, unknown>, fallbackShowId = 0) {
    const showId = Number(body.show_id ?? fallbackShowId);
    const seasonId = Number(body.season_id ?? 0);
    const name = String(body.name ?? '').trim();
    const videoUploadType = String(body.video_upload_type ?? 'external').trim() || 'external';
    const video320 = String(body.video_320 ?? '').trim();

    if (!Number.isFinite(showId) || showId <= 0) {
      throw new Error('show_id is required');
    }
    if (!Number.isFinite(seasonId) || seasonId <= 0) {
      throw new Error('season_id is required');
    }
    if (name.length < 1) {
      throw new Error('name is required');
    }
    if (videoUploadType === 'server_video' && video320.length < 1) {
      throw new Error('video_320 is required');
    }

    return {
      id: Number(body.id ?? 0),
      show_id: showId,
      season_id: seasonId,
      name,
      thumbnail: String(body.thumbnail ?? '').trim(),
      landscape: '',
      description: String(body.description ?? '').trim(),
      video_upload_type: videoUploadType,
      video_320: video320,
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
      is_premium: Number(body.is_premium ?? 0),
      is_title: Number(body.is_title ?? 0),
      is_download: 0,
    };
  }

  private async ensureProducerTvShowOwned(producerId: number, showId: number): Promise<void> {
    if (!Number.isFinite(showId) || showId <= 0) {
      throw new Error('show_id is invalid');
    }

    const tvShow = await this.repository.getProducerTvShowById(showId, producerId);
    if (!tvShow) {
      throw new Error('tvshow not found');
    }
  }

  private async ensureProducerShortsOwned(producerId: number, showId: number): Promise<void> {
    if (!Number.isFinite(showId) || showId <= 0) {
      throw new Error('show_id is invalid');
    }

    const shorts = await this.repository.getProducerShortsById(showId, producerId);
    if (!shorts) {
      throw new Error('shorts not found');
    }
  }

  async getProducerTvShowEpisodesViewPayload(producerId: number, showId: number, typeId: number, query: Record<string, string>) {
    await this.ensureProducerTvShowOwned(producerId, showId);

    const inputSearch = String(query.input_search ?? '').trim();
    const inputSeason = String(query.input_season ?? '0');

    const [seasons, items] = await Promise.all([
      this.repository.getProducerSeasons(),
      this.repository.getProducerTvShowEpisodes(producerId, showId, inputSearch, inputSeason),
    ]);

    return {
      showId,
      typeId,
      inputSearch,
      inputSeason,
      seasons,
      items,
    };
  }

  async createProducerTvShowEpisode(producerId: number, body: Record<string, unknown>, fallbackShowId: number): Promise<void> {
    const payload = this.mapProducerTvShowEpisodePayload(body, fallbackShowId);
    await this.ensureProducerTvShowOwned(producerId, payload.show_id);
    await this.repository.createProducerTvShowEpisode(payload);
  }

  async updateProducerTvShowEpisode(producerId: number, episodeId: number, body: Record<string, unknown>, fallbackShowId: number): Promise<void> {
    if (!Number.isFinite(episodeId) || episodeId <= 0) {
      throw new Error('episode_id is invalid');
    }

    const payload = this.mapProducerTvShowEpisodePayload(body, fallbackShowId);
    const belongsToShow = await this.repository.doesProducerTvShowEpisodeBelongToShow(producerId, episodeId, payload.show_id);
    if (!belongsToShow) {
      throw new Error('episode not found');
    }

    const ok = await this.repository.updateProducerTvShowEpisode(episodeId, producerId, payload);
    if (!ok) {
      throw new Error('episode not found');
    }
  }

  async deleteProducerTvShowEpisode(producerId: number, showId: number, episodeId: number): Promise<void> {
    if (!Number.isFinite(showId) || showId <= 0) {
      throw new Error('show_id is invalid');
    }
    if (!Number.isFinite(episodeId) || episodeId <= 0) {
      throw new Error('episode_id is invalid');
    }

    const ok = await this.repository.deleteProducerTvShowEpisode(producerId, showId, episodeId);
    if (!ok) {
      throw new Error('episode not found');
    }
  }

  async toggleProducerTvShowEpisodeStatus(producerId: number, episodeId: number): Promise<void> {
    if (!Number.isFinite(episodeId) || episodeId <= 0) {
      throw new Error('episode_id is invalid');
    }

    const ok = await this.repository.toggleProducerTvShowEpisodeStatus(producerId, episodeId);
    if (!ok) {
      throw new Error('episode not found');
    }
  }

  async saveProducerTvShowEpisodeSortOrder(producerId: number, showId: number, ids: string): Promise<void> {
    if (!Number.isFinite(showId) || showId <= 0) {
      throw new Error('show_id is invalid');
    }

    const parsedIds = this.parseSortableIds(ids);
    const ok = await this.repository.saveProducerTvShowEpisodeSortOrder(producerId, showId, parsedIds);
    if (!ok) {
      throw new Error('ids are invalid');
    }
  }

  async getProducerShortsViewPayload(producerId: number, typeId: number, query: Record<string, string>) {
    const inputSearch = String(query.input_search ?? '').trim();
    const inputRent = String(query.input_rent ?? '0');
    const inputStatus = String(query.input_status ?? 'all');

    const [type, items, channels, releasesTypes] = await Promise.all([
      this.repository.getTypeById(typeId),
      this.repository.getProducerShorts(producerId, typeId, inputSearch, inputRent, inputStatus),
      this.repository.getProducerChannels(''),
      this.repository.getProducerReleasesTypes(),
    ]);

    if (!type) {
      throw new Error('type not found');
    }

    return {
      typeId,
      inputSearch,
      inputRent,
      inputStatus,
      items,
      channels,
      releasesTypes,
    };
  }

  async createProducerShorts(producerId: number, body: Record<string, unknown>, fallbackTypeId: number): Promise<void> {
    const payload = this.mapProducerShortsPayload(body, fallbackTypeId);
    await this.repository.createProducerShorts(producerId, payload);
  }

  async updateProducerShorts(producerId: number, shortsId: number, body: Record<string, unknown>, fallbackTypeId: number): Promise<void> {
    if (!Number.isFinite(shortsId) || shortsId <= 0) {
      throw new Error('shorts_id is invalid');
    }

    const payload = this.mapProducerShortsPayload(body, fallbackTypeId);
    const ok = await this.repository.updateProducerShorts(shortsId, producerId, payload);
    if (!ok) {
      throw new Error('shorts not found');
    }
  }

  async deleteProducerShorts(producerId: number, shortsId: number): Promise<void> {
    if (!Number.isFinite(shortsId) || shortsId <= 0) {
      throw new Error('shorts_id is invalid');
    }

    const ok = await this.repository.deleteProducerShorts(shortsId, producerId);
    if (!ok) {
      throw new Error('shorts not found');
    }
  }

  async toggleProducerShortsStatus(producerId: number, shortsId: number): Promise<void> {
    if (!Number.isFinite(shortsId) || shortsId <= 0) {
      throw new Error('shorts_id is invalid');
    }

    const ok = await this.repository.toggleProducerShortsStatus(shortsId, producerId);
    if (!ok) {
      throw new Error('shorts not found');
    }
  }

  async releaseProducerShorts(producerId: number, shortsId: number, typeId: number, channelId: number): Promise<void> {
    if (!Number.isFinite(shortsId) || shortsId <= 0) {
      throw new Error('shorts id is required');
    }
    if (!Number.isFinite(typeId) || typeId <= 0) {
      throw new Error('type_id is required');
    }

    const type = await this.repository.getTypeById(typeId);
    if (!type) {
      throw new Error('type not found');
    }

    if (type.type === 6 && (!Number.isFinite(channelId) || channelId <= 0)) {
      throw new Error('channel_id is required');
    }

    const ok = await this.repository.releaseProducerShorts(shortsId, producerId, type.id, type.type, type.type === 6 ? channelId : 0);
    if (!ok) {
      throw new Error('shorts not found');
    }
  }

  async searchProducerShortsNames(producerId: number, txtVal: string) {
    if (txtVal.trim().length < 1) {
      return [];
    }

    return this.repository.searchProducerShortsNames(producerId, txtVal.trim());
  }

  async getProducerShortsDataForFill(producerId: number, shortsId: number) {
    if (!Number.isFinite(shortsId) || shortsId <= 0) {
      throw new Error('shorts_id is invalid');
    }

    return this.repository.getProducerShortsDataForFill(producerId, shortsId);
  }

  async getProducerShortsEpisodesViewPayload(producerId: number, showId: number, typeId: number, query: Record<string, string>) {
    await this.ensureProducerShortsOwned(producerId, showId);

    const inputSearch = String(query.input_search ?? '').trim();
    const inputSeason = String(query.input_season ?? '0');

    const [seasons, items] = await Promise.all([
      this.repository.getProducerSeasons(),
      this.repository.getProducerShortsEpisodes(producerId, showId, inputSearch, inputSeason),
    ]);

    return {
      showId,
      typeId,
      inputSearch,
      inputSeason,
      seasons,
      items,
    };
  }

  async createProducerShortsEpisode(producerId: number, body: Record<string, unknown>, fallbackShowId: number): Promise<void> {
    const payload = this.mapProducerShortsEpisodePayload(body, fallbackShowId);
    await this.ensureProducerShortsOwned(producerId, payload.show_id);
    await this.repository.createProducerShortsEpisode(payload);
  }

  async updateProducerShortsEpisode(producerId: number, episodeId: number, body: Record<string, unknown>, fallbackShowId: number): Promise<void> {
    if (!Number.isFinite(episodeId) || episodeId <= 0) {
      throw new Error('episode_id is invalid');
    }

    const payload = this.mapProducerShortsEpisodePayload(body, fallbackShowId);
    const belongsToShow = await this.repository.doesProducerShortsEpisodeBelongToShow(producerId, episodeId, payload.show_id);
    if (!belongsToShow) {
      throw new Error('episode not found');
    }

    const ok = await this.repository.updateProducerShortsEpisode(episodeId, producerId, payload);
    if (!ok) {
      throw new Error('episode not found');
    }
  }

  async deleteProducerShortsEpisode(producerId: number, showId: number, episodeId: number): Promise<void> {
    if (!Number.isFinite(showId) || showId <= 0) {
      throw new Error('show_id is invalid');
    }
    if (!Number.isFinite(episodeId) || episodeId <= 0) {
      throw new Error('episode_id is invalid');
    }

    const ok = await this.repository.deleteProducerShortsEpisode(producerId, showId, episodeId);
    if (!ok) {
      throw new Error('episode not found');
    }
  }

  async toggleProducerShortsEpisodeStatus(producerId: number, episodeId: number): Promise<void> {
    if (!Number.isFinite(episodeId) || episodeId <= 0) {
      throw new Error('episode_id is invalid');
    }

    const ok = await this.repository.toggleProducerShortsEpisodeStatus(producerId, episodeId);
    if (!ok) {
      throw new Error('episode not found');
    }
  }

  async saveProducerShortsEpisodeSortOrder(producerId: number, showId: number, ids: string): Promise<void> {
    if (!Number.isFinite(showId) || showId <= 0) {
      throw new Error('show_id is invalid');
    }

    const parsedIds = this.parseSortableIds(ids);
    const ok = await this.repository.saveProducerShortsEpisodeSortOrder(producerId, showId, parsedIds);
    if (!ok) {
      throw new Error('ids are invalid');
    }
  }
}
