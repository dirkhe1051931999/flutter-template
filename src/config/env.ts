import dotenv from 'dotenv';

dotenv.config();

function getEnv(key: string, fallback?: string): string {
  const value = process.env[key] ?? fallback;
  if (value === undefined) {
    throw new Error(`Missing required env: ${key}`);
  }
  return value;
}

function getNumberEnv(key: string, fallback: string): number {
  const rawValue = getEnv(key, fallback);
  const parsed = Number(rawValue);
  if (Number.isNaN(parsed)) {
    throw new Error(`Invalid number env: ${key}`);
  }

  return parsed;
}

function getBooleanEnv(key: string, fallback: string): boolean {
  const rawValue = getEnv(key, fallback).toLowerCase();
  return rawValue === '1' || rawValue === 'true' || rawValue === 'yes';
}

export const env = {
  nodeEnv: getEnv('NODE_ENV', 'development'),
  port: getNumberEnv('PORT', '8080'),
  pageLimit: getNumberEnv('PAGE_LIMIT', '10'),
  apiToken: getEnv('API_TOKEN', ''),
  appBaseUrl: getEnv('APP_BASE_URL', ''),
  purchaseCodeEnabled: getBooleanEnv('PURCHASE_CODE_ENABLED', 'false'),
  db: {
    host: getEnv('DB_HOST'),
    port: getNumberEnv('DB_PORT', '3306'),
    name: getEnv('DB_NAME'),
    user: getEnv('DB_USER'),
    password: getEnv('DB_PASSWORD'),
    connectionLimit: getNumberEnv('DB_CONNECTION_LIMIT', '10'),
  },
  redis: {
    host: getEnv('REDIS_HOST'),
    port: getNumberEnv('REDIS_PORT', '6379'),
    password: getEnv('REDIS_PASSWORD', ''),
    db: getNumberEnv('REDIS_DB', '12'),
    keyPrefix: getEnv('REDIS_KEY_PREFIX', 'dtlive:'),
  },
  session: {
    key: getEnv('SESSION_KEY', 'dtlive.sid'),
    secret: getEnv('SESSION_SECRET', 'replace-me-in-production'),
    maxAgeMs: getNumberEnv('SESSION_MAX_AGE_MS', '1209600000'),
    secure: getBooleanEnv('SESSION_SECURE', 'false'),
  },
};
