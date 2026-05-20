import type Koa from 'koa';
import session from 'koa-session';
import { env } from '../../config/env';
import { ensureRedisConnected, redisClient } from '../../config/redis';

type SessionData = Record<string, unknown>;

const redisSessionStore = {
  async get(key: string): Promise<SessionData | null> {
    await ensureRedisConnected();
    const payload = await redisClient.get(key);

    if (!payload) {
      return null;
    }

    return JSON.parse(payload) as SessionData;
  },

  async set(key: string, sessionValue: SessionData, maxAge: number): Promise<void> {
    await ensureRedisConnected();
    const ttlSeconds = Math.max(1, Math.floor(maxAge / 1000));
    await redisClient.set(key, JSON.stringify(sessionValue), {
      EX: ttlSeconds,
    });
  },

  async destroy(key: string): Promise<void> {
    await ensureRedisConnected();
    await redisClient.del(key);
  },
};

export function applySessionMiddleware(app: Koa): void {
  app.keys = [env.session.secret];
  app.use(
    session(
      {
        key: env.session.key,
        maxAge: env.session.maxAgeMs,
        httpOnly: true,
        signed: true,
        secure: env.session.secure,
        rolling: false,
        renew: false,
        store: redisSessionStore,
      },
      app,
    ),
  );
}
