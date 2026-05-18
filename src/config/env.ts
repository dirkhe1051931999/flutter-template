import dotenv from 'dotenv';

dotenv.config();

function getEnv(key: string, fallback?: string): string {
  const value = process.env[key] ?? fallback;
  if (value === undefined) {
    throw new Error(`Missing required env: ${key}`);
  }
  return value;
}

export const env = {
  nodeEnv: getEnv('NODE_ENV', 'development'),
  port: Number(getEnv('PORT', '8080')),
  db: {
    host: getEnv('DB_HOST', '127.0.0.1'),
    port: Number(getEnv('DB_PORT', '3306')),
    name: getEnv('DB_NAME', 'dtlive'),
    user: getEnv('DB_USER', 'root'),
    password: getEnv('DB_PASSWORD', ''),
    connectionLimit: Number(getEnv('DB_CONNECTION_LIMIT', '10')),
  },
};
