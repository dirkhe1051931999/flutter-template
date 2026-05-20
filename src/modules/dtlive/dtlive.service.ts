import { env } from '../../config/env';
import { DtliveRepository } from './dtlive.repository';

type GenericRecord = Record<string, unknown>;

export class DtliveService {
  private readonly repository = new DtliveRepository();

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
