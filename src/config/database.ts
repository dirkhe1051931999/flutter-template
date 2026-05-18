import mysql from 'mysql2/promise';
import { env } from './env';

export const dbPool = mysql.createPool({
  host: env.db.host,
  port: env.db.port,
  database: env.db.name,
  user: env.db.user,
  password: env.db.password,
  connectionLimit: env.db.connectionLimit,
  waitForConnections: true,
  queueLimit: 0,
});

export async function checkDatabaseConnection(): Promise<boolean> {
  const connection = await dbPool.getConnection();
  try {
    await connection.ping();
    return true;
  } finally {
    connection.release();
  }
}
