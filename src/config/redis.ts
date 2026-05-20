import { createClient } from 'redis';
import { env } from './env';

const hasPassword = env.redis.password.trim().length > 0;

export const redisClient = createClient({
  socket: {
    host: env.redis.host,
    port: env.redis.port,
  },
  password: hasPassword ? env.redis.password : undefined,
  database: env.redis.db,
});

redisClient.on('error', (error: unknown) => {
  const message = error instanceof Error ? error.message : String(error);
  console.error('Redis client error:', message);
});

let connectPromise: Promise<unknown> | null = null;

export async function ensureRedisConnected(): Promise<void> {
  if (redisClient.isOpen) {
    return;
  }

  if (!connectPromise) {
    connectPromise = redisClient.connect();
  }

  await connectPromise;
}
