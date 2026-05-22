import bcrypt from 'bcryptjs';
import { env } from '../../config/env';
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

  getAdminBanners() {
    return this.repository.getAdminBanners();
  }

  async toggleAdminBannerStatus(id: number): Promise<void> {
    if (!Number.isFinite(id) || id <= 0) {
      throw new Error('id is invalid');
    }

    const ok = await this.repository.toggleAdminBannerStatus(id);
    if (!ok) {
      throw new Error('banner not found');
    }
  }

  async saveAdminBannerSortOrder(ids: string): Promise<void> {
    const parsedIds = this.parseSortableIds(ids);
    await this.repository.saveAdminBannerSortOrder(parsedIds);
  }

  async createAdminBanner(input: {
    isHomeScreen: number; typeId: number; videoType: number; subvideoType: number; videoId: number; sortOrder: number; status: number;
  }): Promise<void> {
    if (input.typeId <= 0 || input.videoId <= 0) throw new Error('type_id and video_id are required');
    await this.repository.createAdminBanner(input);
  }

  async updateAdminBanner(id: number, input: {
    isHomeScreen: number; typeId: number; videoType: number; subvideoType: number; videoId: number; sortOrder: number; status: number;
  }): Promise<void> {
    if (!Number.isFinite(id) || id <= 0) throw new Error('id is invalid');
    if (input.typeId <= 0 || input.videoId <= 0) throw new Error('type_id and video_id are required');
    await this.repository.updateAdminBanner(id, input);
  }

  getAdminHomeSections() {
    return this.repository.getAdminHomeSections();
  }

  async toggleAdminHomeSectionStatus(id: number): Promise<void> {
    if (!Number.isFinite(id) || id <= 0) {
      throw new Error('id is invalid');
    }

    const ok = await this.repository.toggleAdminHomeSectionStatus(id);
    if (!ok) {
      throw new Error('section not found');
    }
  }

  async saveAdminHomeSectionSortOrder(ids: string): Promise<void> {
    const parsedIds = this.parseSortableIds(ids);
    await this.repository.saveAdminHomeSectionSortOrder(parsedIds);
  }

  async getAdminBannerTypeByData(type: number, typeId: number, subvideoType: number) {
    const usedIds = await this.repository.getBannerUsedVideoIdsByType(typeId);
    if (type === 1) return this.repository.getVideoOptionsByType(typeId, usedIds);
    if (type === 2) return this.repository.getTvShowOptionsByType(typeId, usedIds);
    if (type === 8) return this.repository.getShortsOptionsByType(typeId, usedIds);
    if ([5, 6, 7].includes(type)) {
      return subvideoType === 2
        ? this.repository.getTvShowOptionsByType(typeId, usedIds)
        : this.repository.getVideoOptionsByType(typeId, usedIds);
    }
    return [];
  }

  async getAdminBannerList(isHomeScreen: number, typeId: number) {
    const rows = await this.repository.getBannerListByScreenAndType(isHomeScreen, typeId);
    const result = await Promise.all(rows.map(async (row) => {
      const videoType = Number(row.video_type ?? 0);
      const subvideoType = Number(row.subvideo_type ?? 0);
      const videoId = Number(row.video_id ?? 0);
      let videoName = '';
      if (videoType === 1) videoName = await this.repository.getVideoNameById(videoId);
      else if (videoType === 2) videoName = await this.repository.getTvShowNameById(videoId);
      else if (videoType === 8) videoName = await this.repository.getShortsNameById(videoId);
      else if ([5, 6, 7].includes(videoType)) {
        videoName = subvideoType === 2
          ? await this.repository.getTvShowNameById(videoId)
          : await this.repository.getVideoNameById(videoId);
      }
      return {
        ...row,
        type_name: await this.repository.getTypeNameById(Number(row.type_id ?? 0)),
        video: { id: videoId, name: videoName },
      };
    }));
    return result;
  }

  async getAdminSectionData(isHomeScreen: number, topTypeId: number) {
    const rows = await this.repository.getSectionListData(isHomeScreen, topTypeId);
    const categories = await this.repository.getCategoryOptions();
    const languages = await this.repository.getLanguageOptions();
    const channels = await this.repository.getChannelOptions();
    const categoryMap = new Map(categories.map((i) => [i.id, i.name]));
    const languageMap = new Map(languages.map((i) => [i.id, i.name]));
    const channelMap = new Map(channels.map((i) => [i.id, i.name]));

    return rows.map((row) => ({
      ...row,
      type_name: '',
      category_name: categoryMap.get(Number(row.category_id ?? 0)) ?? '',
      language_name: languageMap.get(Number(row.language_id ?? 0)) ?? '',
      channel_name: channelMap.get(Number(row.channel_id ?? 0)) ?? '',
    }));
  }

  async getAdminSectionDataEdit(id: number) {
    const row = await this.repository.getSectionById(id);
    if (!row) return null;
    const content = String(row.content_ids ?? '').trim() ? String(row.content_ids).split(',').map((v) => Number(v)).filter((v) => v > 0) : [];
    const contentData = await this.getAdminSectionContent({
      videoType: Number(row.video_type ?? 0),
      typeId: Number(row.type_id ?? 0),
      subVideoType: Number(row.sub_video_type ?? 0),
      channelId: Number(row.channel_id ?? 0),
      typeType: await this.repository.getTypeTypeById(Number(row.type_id ?? 0)),
    });
    return { ...row, content, content_data: contentData };
  }

  async getAdminSectionSortable(isHomeScreen: number, topTypeId: number) {
    const rows = await this.repository.getSectionListData(isHomeScreen, topTypeId);
    return rows.filter((row) => Number(row.status ?? 0) === 1).map((row) => ({ id: Number(row.id ?? 0), title: String(row.title ?? '') }));
  }

  async getAdminSectionContent(params: { videoType: number; typeId: number; subVideoType: number; channelId: number; typeType: number }) {
    const { videoType, typeId, subVideoType, channelId, typeType } = params;
    if (videoType === 3) return this.repository.getCategoryOptions();
    if (videoType === 4) return this.repository.getLanguageOptions();
    if (videoType === 102) return this.repository.getChannelOptions();
    if (videoType === 8) return this.repository.getShortsOptionsByType(typeId, []);
    if (videoType === 1) return this.repository.getVideoOptionsByType(typeId, []);
    if (videoType === 2) return this.repository.getTvShowOptionsByType(typeId, []);
    if ([5, 6, 7].includes(videoType)) {
      if (subVideoType === 2) return this.repository.getTvShowOptionsByType(typeId, []);
      const list = await this.repository.getVideoOptionsByType(typeId, []);
      if (videoType !== 6 || channelId === 0) return list;
      return list;
    }
    if (videoType === 103) {
      const sourceType = typeType;
      if ([1, 6, 7].includes(sourceType)) {
        return subVideoType === 2
          ? this.repository.getTvShowOptionsByType(typeId, [])
          : this.repository.getVideoOptionsByType(typeId, []);
      }
      if (sourceType === 2) return this.repository.getTvShowOptionsByType(typeId, []);
    }
    return [];
  }

  getAdminNotificationSettings() {
    return this.repository.getNotificationSettings();
  }

  async saveAdminNotificationSettings(data: Record<string, unknown>): Promise<void> {
    await this.repository.saveGeneralSettings(data);
  }

  private async recalculateReviewRating(videoType: number, subVideoType: number, videoId: number): Promise<void> {
    const stats = await this.repository.getApprovedReviewStats(videoType, subVideoType, videoId);
    const avg = Math.round(stats.avg * 10) / 10;
    const total = stats.total;
    if (videoType === 8) {
      await this.repository.updateShortsRating(videoId, avg, total);
      return;
    }
    if (videoType === 1 || ([5, 6, 7].includes(videoType) && subVideoType === 1)) {
      await this.repository.updateVideoRating(videoId, avg, total);
      return;
    }
    if (videoType === 2 || ([5, 6, 7].includes(videoType) && subVideoType === 2)) {
      await this.repository.updateTvShowRating(videoId, avg, total);
    }
  }

  async approveReview(id: number): Promise<void> {
    const review = await this.repository.getReviewById(id);
    if (!review) throw new Error('data not found');
    const current = Number(review.status ?? 0);
    if (![0, 2].includes(current)) throw new Error('invalid action');
    await this.repository.updateReviewStatus(id, 1);
    await this.recalculateReviewRating(Number(review.video_type ?? 0), Number(review.sub_video_type ?? 0), Number(review.video_id ?? 0));
  }

  async rejectReview(id: number): Promise<void> {
    const review = await this.repository.getReviewById(id);
    if (!review) throw new Error('data not found');
    const current = Number(review.status ?? 0);
    if (![0, 1].includes(current)) throw new Error('invalid action');
    await this.repository.updateReviewStatus(id, 2);
    await this.recalculateReviewRating(Number(review.video_type ?? 0), Number(review.sub_video_type ?? 0), Number(review.video_id ?? 0));
  }

  async destroyReview(id: number): Promise<void> {
    const review = await this.repository.getReviewById(id);
    if (review) {
      await this.repository.deleteReviewById(id);
      await this.recalculateReviewRating(Number(review.video_type ?? 0), Number(review.sub_video_type ?? 0), Number(review.video_id ?? 0));
    }
  }

  async destroyCoupon(id: number): Promise<void> {
    await this.repository.deleteCouponById(id);
  }

  async destroyRentPrice(id: number): Promise<void> {
    await this.repository.deleteRentPriceById(id);
  }

  async destroyType(id: number): Promise<void> {
    await this.repository.deleteTypeById(id);
  }

  async destroyCategory(id: number): Promise<void> {
    await this.repository.deleteCategoryById(id);
  }

  async destroyLanguage(id: number): Promise<void> {
    await this.repository.deleteLanguageById(id);
  }

  async destroySeason(id: number): Promise<void> {
    await this.repository.deleteSeasonById(id);
  }

  async destroyAvatar(id: number): Promise<void> {
    await this.repository.deleteAvatarById(id);
  }

  async destroyChannel(id: number): Promise<void> {
    await this.repository.deleteChannelById(id);
  }

  async destroyUser(id: number): Promise<void> {
    await this.repository.deleteUserById(id);
  }

  async destroyProducer(id: number): Promise<void> {
    await this.repository.deleteProducerById(id);
  }

  async destroyCast(id: number): Promise<void> {
    await this.repository.deleteCastById(id);
  }

  async destroySection(id: number): Promise<void> {
    await this.repository.deleteSectionById(id);
  }

  async destroyNotification(id: number): Promise<void> {
    await this.repository.deleteNotificationById(id);
  }

  async getAdminPaymentById(id: number): Promise<Record<string, unknown> | null> {
    if (!Number.isFinite(id) || id <= 0) {
      throw new Error('id is invalid');
    }
    return this.repository.getPaymentOptionById(id);
  }

  getAdminPaymentOptions() {
    return this.repository.getPaymentOptions();
  }

  async updateAdminPayment(payload: {
    id: number; key1: string; key2: string; key3: string; key4: string; visibility: number; isLive: number;
  }): Promise<void> {
    if (!Number.isFinite(payload.id) || payload.id <= 0) {
      throw new Error('id is invalid');
    }
    if (!Number.isFinite(payload.visibility)) {
      throw new Error('visibility is required');
    }
    if (!Number.isFinite(payload.isLive)) {
      throw new Error('is_live is required');
    }

    const exists = await this.repository.getPaymentOptionById(payload.id);
    if (!exists) {
      throw new Error('payment not found');
    }

    await this.repository.updatePaymentOptionById(payload.id, {
      key1: payload.key1,
      key2: payload.key2,
      key3: payload.key3,
      key4: payload.key4,
      visibility: payload.visibility,
      isLive: payload.isLive,
    });
  }

  async destroyTransaction(id: number): Promise<void> {
    await this.repository.deleteTransactionById(id);
  }

  async destroyPackage(id: number): Promise<void> {
    await this.repository.deletePackageById(id);
  }

  async destroyRentTransaction(id: number): Promise<void> {
    await this.repository.deleteRentTransactionById(id);
  }

  async destroyPage(id: number): Promise<void> {
    await this.repository.deletePageById(id);
  }

  async createAdminHomeSection(input: {
    sectionType: number; isHomeScreen: number; videoType: number; subVideoType: number; typeId: number; title: string; shortTitle: string;
    screenLayout: string; contentIds: string; categoryId: number; languageId: number; channelId: number; orderByUpload: number; orderByView: number;
    premiumVideo: number; noOfContent: number; viewAll: number; isTitle: number; sortOrder: number; status: number;
  }): Promise<void> {
    if (!input.title.trim()) throw new Error('title is required');
    if (input.typeId <= 0) throw new Error('type_id is required');
    await this.repository.createAdminHomeSection(input);
  }

  async updateAdminHomeSection(id: number, input: {
    sectionType: number; isHomeScreen: number; videoType: number; subVideoType: number; typeId: number; title: string; shortTitle: string;
    screenLayout: string; contentIds: string; categoryId: number; languageId: number; channelId: number; orderByUpload: number; orderByView: number;
    premiumVideo: number; noOfContent: number; viewAll: number; isTitle: number; sortOrder: number; status: number;
  }): Promise<void> {
    if (!Number.isFinite(id) || id <= 0) throw new Error('id is invalid');
    if (!input.title.trim()) throw new Error('title is required');
    if (input.typeId <= 0) throw new Error('type_id is required');
    await this.repository.updateAdminHomeSection(id, input);
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

  getAdminReferEarnRows() {
    return this.repository.getAdminReferEarnRows();
  }

  getAdminWalletTransactions() {
    return this.repository.getAdminWalletTransactions();
  }

  getAdminWithdrawalRows() {
    return this.repository.getAdminWithdrawalRows();
  }

  getAdminAdmobRows() {
    return this.repository.getAdminAdmobRows();
  }

  async saveAdminAdmob(payload: Record<string, unknown>): Promise<void> {
    const id = Number(payload.id ?? 0);
    if (!Number.isFinite(id) || id <= 0) {
      throw new Error('id is invalid');
    }
    await this.repository.updateAdminAdmobById(id, payload);
  }

  async getAdminSettingsByKeys(keys: string[]): Promise<Record<string, string>> {
    return this.repository.getGeneralSettingsByKeys(keys);
  }

  async saveAdminSettings(data: Record<string, unknown>): Promise<void> {
    await this.repository.saveGeneralSettings(data);
  }

  getAdminNotificationConfigurationRows() {
    return this.repository.getNotificationConfigurationRows();
  }

  async saveAdminNotificationConfiguration(payload: Record<string, unknown>): Promise<void> {
    await this.repository.upsertNotificationConfiguration(payload);
  }

  getAdminReviews() {
    return this.repository.getAdminReviews();
  }

  async searchAdminUsers(keyword: string) {
    return this.repository.searchUsersForAdmin(keyword.trim());
  }

  getAdminCoupons() {
    return this.repository.getAdminCoupons();
  }

  getAdminRentPriceList() {
    return this.repository.getAdminRentPriceList();
  }

  getAdminPackages() {
    return this.repository.getAdminPackages();
  }

  getAdminTransactions() {
    return this.repository.getAdminTransactions();
  }

  getAdminRentTransactions() {
    return this.repository.getAdminRentTransactions();
  }

  getAdminUsers() {
    return this.repository.getAdminUsers();
  }

  getAdminUserDashboard(userId: number) {
    return this.repository.getAdminUserDashboard(userId);
  }

  getAdminProducers() {
    return this.repository.getAdminProducers();
  }

  getAdminCasts() {
    return this.repository.getAdminCasts();
  }

  async destroyTvShow(id: number): Promise<void> {
    await this.repository.deleteTvShowById(id);
  }

  async destroyTvShowEpisode(id: number): Promise<void> {
    await this.repository.deleteTvShowEpisodeById(id);
  }

  async destroyShorts(id: number): Promise<void> {
    await this.repository.deleteShortsById(id);
  }

  async destroyShortsEpisode(id: number): Promise<void> {
    await this.repository.deleteShortsEpisodeById(id);
  }

  async destroyVideo(id: number): Promise<void> {
    await this.repository.deleteVideoById(id);
  }

  async destroyBanner(id: number): Promise<void> {
    await this.repository.deleteBannerById(id);
  }

  async searchAdminVideoNames(txtVal: string) {
    if (txtVal.trim().length < 1) return [];
    return this.repository.searchAdminVideoNames(txtVal.trim());
  }

  async searchAdminTvShowNames(txtVal: string) {
    if (txtVal.trim().length < 1) return [];
    return this.repository.searchAdminTvShowNames(txtVal.trim());
  }

  async searchAdminShortsNames(txtVal: string) {
    if (txtVal.trim().length < 1) return [];
    return this.repository.searchAdminShortsNames(txtVal.trim());
  }

  async getAdminVideoDataForFill(id: number) {
    return this.repository.getAdminVideoById(id);
  }

  async getAdminTvShowDataForFill(id: number) {
    return this.repository.getAdminTvShowById(id);
  }

  async getAdminShortsDataForFill(id: number) {
    return this.repository.getAdminShortsById(id);
  }

  async createAdminVideoCompat(payload: Record<string, unknown>): Promise<number> {
    return this.repository.insertWithPayload('tbl_video', payload);
  }

  async updateAdminVideoCompat(id: number, payload: Record<string, unknown>): Promise<void> {
    await this.repository.updateWithPayloadById('tbl_video', id, payload);
  }

  async createAdminTvShowCompat(payload: Record<string, unknown>): Promise<number> {
    return this.repository.insertWithPayload('tbl_tv_show', payload);
  }

  async updateAdminTvShowCompat(id: number, payload: Record<string, unknown>): Promise<void> {
    await this.repository.updateWithPayloadById('tbl_tv_show', id, payload);
  }

  async createAdminShortsCompat(payload: Record<string, unknown>): Promise<number> {
    return this.repository.insertWithPayload('tbl_shorts', payload);
  }

  async updateAdminShortsCompat(id: number, payload: Record<string, unknown>): Promise<void> {
    await this.repository.updateWithPayloadById('tbl_shorts', id, payload);
  }

  async createAdminTvShowEpisodeCompat(payload: Record<string, unknown>): Promise<number> {
    return this.repository.insertWithPayload('tbl_episode', payload);
  }

  async updateAdminTvShowEpisodeCompat(id: number, payload: Record<string, unknown>): Promise<void> {
    await this.repository.updateWithPayloadById('tbl_episode', id, payload);
  }

  async createAdminShortsEpisodeCompat(payload: Record<string, unknown>): Promise<number> {
    return this.repository.insertWithPayload('tbl_shorts_episode', payload);
  }

  async updateAdminShortsEpisodeCompat(id: number, payload: Record<string, unknown>): Promise<void> {
    await this.repository.updateWithPayloadById('tbl_shorts_episode', id, payload);
  }

  async toggleAdminTvShowEpisodeCompat(id: number): Promise<void> {
    await this.repository.toggleTableStatusById('tbl_episode', id);
  }

  async toggleAdminShortsEpisodeCompat(id: number): Promise<void> {
    await this.repository.toggleTableStatusById('tbl_shorts_episode', id);
  }

  async sortAdminTvShowEpisodes(ids: string): Promise<void> {
    const parsed = this.parseSortableIds(ids);
    await this.repository.saveEpisodeSortOrder('tbl_episode', parsed);
  }

  async sortAdminShortsEpisodes(ids: string): Promise<void> {
    const parsed = this.parseSortableIds(ids);
    await this.repository.saveEpisodeSortOrder('tbl_shorts_episode', parsed);
  }

  async createAdminResourceCompat(table: string, payload: Record<string, unknown>): Promise<number> {
    return this.repository.insertWithPayload(table, payload);
  }

  async updateAdminResourceCompat(table: string, id: number, payload: Record<string, unknown>): Promise<void> {
    await this.repository.updateWithPayloadById(table, id, payload);
  }

  async toggleAdminProducerContentStatus(payload: Record<string, unknown>): Promise<void> {
    const id = Number(payload.id ?? 0);
    const contentType = String(payload.content_type ?? '').trim();
    if (!Number.isFinite(id) || id <= 0) throw new Error('id is invalid');
    const type = contentType.toLowerCase();
    if (type === 'video') {
      await this.toggleAdminVideoStatus(id);
      return;
    }
    if (type === 'tvshow' || type === 'tv_show') {
      await this.toggleAdminTvShowStatus(id);
      return;
    }
    if (type === 'shorts') {
      await this.toggleAdminShortsStatus(id);
      return;
    }
    throw new Error('content_type is invalid');
  }

  async releaseAdminTvShow(payload: Record<string, unknown>): Promise<void> {
    const id = Number(payload.id ?? payload.tvshow_id ?? 0);
    if (!Number.isFinite(id) || id <= 0) throw new Error('id is invalid');
    await this.updateAdminTvShowCompat(id, {
      type_id: Number(payload.type_id ?? 0),
      video_type: Number(payload.video_type ?? 2),
      channel_id: Number(payload.channel_id ?? 0),
    });
  }

  async saveAdminVideoChunk(payload: Record<string, unknown>): Promise<{ chunkStored: boolean; bytes: number }> {
    // Compatibility behavior: accept chunk metadata and validate target exists.
    const videoId = Number(payload.video_id ?? payload.id ?? 0);
    if (Number.isFinite(videoId) && videoId > 0) {
      const row = await this.repository.getVideoById(videoId);
      if (!row) throw new Error('video not found');
    }
    const chunk = String(payload.chunk ?? '');
    return { chunkStored: true, bytes: chunk.length };
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

    const categoryId = this.toCsv(body.category_id);
    const languageId = this.toCsv(body.language_id);
    if (!categoryId) {
      throw new Error('category_id is required');
    }
    if (!languageId) {
      throw new Error('language_id is required');
    }

    const videoUploadType = String(body.video_upload_type ?? '').trim();
    if (!videoUploadType) {
      throw new Error('video_upload_type is required');
    }

    const subtitleType = String(body.subtitle_type ?? '').trim();
    if (!subtitleType) {
      throw new Error('subtitle_type is required');
    }

    const isServerVideo = videoUploadType === 'server_video';
    const video320Server = String(body.video_320 ?? '').trim();
    const video320Url = String(body.video_url_320 ?? body.video_320 ?? '').trim();
    const video480Value = String(body.video_480 ?? body.video_url_480 ?? '').trim();
    const video720Value = String(body.video_720 ?? body.video_url_720 ?? '').trim();
    const video1080Value = String(body.video_1080 ?? body.video_url_1080 ?? '').trim();

    if (isServerVideo) {
      if (!video320Server) {
        throw new Error('video_320 is required');
      }
    } else if (!video320Url) {
      if (videoUploadType === 'live_stream_url') {
        throw new Error('video_url_320 is required for live_stream_url');
      }
      if (videoUploadType === 'vdocipher_id') {
        throw new Error('video_url_320 is required for vdocipher_id');
      }
      throw new Error('video_url_320 is required');
    }

    return {
      id: Number(body.id ?? 0),
      type_id: typeId,
      video_type: videoType,
      channel_id: Number.isFinite(channelId) ? channelId : 0,
      category_id: categoryId,
      language_id: languageId,
      cast_id: this.toCsv(body.cast_id),
      name,
      thumbnail: String(body.thumbnail ?? '').trim(),
      landscape: String(body.landscape ?? '').trim(),
      description: String(body.description ?? '').trim(),
      release_date: String(body.release_date ?? '').trim(),
      is_premium: Number(body.is_premium ?? 0),
      is_title: Number(body.is_title ?? 0),
      is_download: isServerVideo ? Number(body.is_download ?? 0) : 0,
      is_comment: Number(body.is_comment ?? 0),
      is_like: Number(body.is_like ?? 0),
      is_rent: isRent,
      price: isRent === 1 ? price : 0,
      rent_day: isRent === 1 ? rentDay : 0,
      video_upload_type: videoUploadType,
      video_320: isServerVideo ? video320Server : video320Url,
      video_480: video480Value,
      video_720: video720Value,
      video_1080: video1080Value,
      trailer_type: String(body.trailer_type ?? 'external').trim() || 'external',
      trailer_url: String(body.trailer_url ?? '').trim(),
      subtitle_type: subtitleType,
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
    const requestedPage = Number(query.page ?? '1');
    const pageSize = Math.max(1, env.pageLimit);

    const [type, items, channels, releasesTypes] = await Promise.all([
      this.repository.getTypeById(typeId),
      this.repository.getProducerVideos(producerId, typeId, inputSearch, inputRent, inputPremium, inputStatus),
      this.repository.getProducerChannels(''),
      this.repository.getProducerReleasesTypes(),
    ]);

    if (!type) {
      throw new Error('type not found');
    }

    const totalRows = items.length;
    const totalPages = Math.max(1, Math.ceil(totalRows / pageSize));
    const normalizedPage = Number.isFinite(requestedPage) ? Math.floor(requestedPage) : 1;
    const currentPage = Math.min(Math.max(1, normalizedPage), totalPages);
    const startIndex = (currentPage - 1) * pageSize;
    const pageItems = items.slice(startIndex, startIndex + pageSize);
    const startRow = totalRows === 0 ? 0 : startIndex + 1;
    const endRow = Math.min(totalRows, startIndex + pageItems.length);

    return {
      typeId,
      inputSearch,
      inputRent,
      inputPremium,
      inputStatus,
      items: pageItems,
      channels,
      releasesTypes,
      pagination: {
        currentPage,
        totalPages,
        totalRows,
        pageSize,
        startRow,
        endRow,
      },
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
    const requestedPage = Number(query.page ?? '1');
    const pageSize = Math.max(1, env.pageLimit);

    const [type, items, channels, releasesTypes] = await Promise.all([
      this.repository.getTypeById(typeId),
      this.repository.getProducerTvShows(producerId, typeId, inputSearch, inputRent, inputStatus),
      this.repository.getProducerChannels(''),
      this.repository.getProducerReleasesTypes(),
    ]);

    if (!type) {
      throw new Error('type not found');
    }

    const totalRows = items.length;
    const totalPages = Math.max(1, Math.ceil(totalRows / pageSize));
    const normalizedPage = Number.isFinite(requestedPage) ? Math.floor(requestedPage) : 1;
    const currentPage = Math.min(Math.max(1, normalizedPage), totalPages);
    const startIndex = (currentPage - 1) * pageSize;
    const pageItems = items.slice(startIndex, startIndex + pageSize);
    const startRow = totalRows === 0 ? 0 : startIndex + 1;
    const endRow = Math.min(totalRows, startIndex + pageItems.length);

    return {
      typeId,
      inputSearch,
      inputRent,
      inputStatus,
      items: pageItems,
      channels,
      releasesTypes,
      pagination: {
        currentPage,
        totalPages,
        totalRows,
        pageSize,
        startRow,
        endRow,
      },
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
    const requestedPage = Number(query.page ?? '1');
    const pageSize = Math.max(1, env.pageLimit);

    const [type, items, channels, releasesTypes] = await Promise.all([
      this.repository.getTypeById(typeId),
      this.repository.getProducerShorts(producerId, typeId, inputSearch, inputRent, inputStatus),
      this.repository.getProducerChannels(''),
      this.repository.getProducerReleasesTypes(),
    ]);

    if (!type) {
      throw new Error('type not found');
    }

    const totalRows = items.length;
    const totalPages = Math.max(1, Math.ceil(totalRows / pageSize));
    const normalizedPage = Number.isFinite(requestedPage) ? Math.floor(requestedPage) : 1;
    const currentPage = Math.min(Math.max(1, normalizedPage), totalPages);
    const startIndex = (currentPage - 1) * pageSize;
    const pageItems = items.slice(startIndex, startIndex + pageSize);
    const startRow = totalRows === 0 ? 0 : startIndex + 1;
    const endRow = Math.min(totalRows, startIndex + pageItems.length);

    return {
      typeId,
      inputSearch,
      inputRent,
      inputStatus,
      items: pageItems,
      channels,
      releasesTypes,
      pagination: {
        currentPage,
        totalPages,
        totalRows,
        pageSize,
        startRow,
        endRow,
      },
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
