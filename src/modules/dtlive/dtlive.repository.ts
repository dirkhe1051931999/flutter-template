import { dbPool } from '../../config/database';

export class DtliveRepository {
  async pingTables(): Promise<void> {
    await dbPool.query('SELECT 1');
  }

  // TODO: 逐步迁移 Laravel SQL/Eloquent 逻辑
  // 示例目标表：tbl_channel, tbl_video, tbl_tv_show
}
