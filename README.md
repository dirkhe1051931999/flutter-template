# flutter-template server (Koa2 scaffold)

This repository now contains a Koa2 + TypeScript backend scaffold for migrating DTLive Laravel APIs.

## What is included

- Koa2 application skeleton with middleware pipeline
- MySQL connection pool setup (`mysql2`)
- DTLive-compatible API placeholders
- Health check endpoint
- Environment variable template

## Endpoints (placeholder)

- `GET /health`
- `POST /api/get_channel`
- `POST /api/section_list`
- `POST /api/content_detail`
- `POST /api/content_by_channel`
- `POST /api/add_continue_watching`
- `POST /api/add_remove_like`
- `POST /api/add_remove_bookmark`

## Quick start

1. Install dependencies:

```bash
npm install
```

## Local access

- API base URL: `http://localhost:9002`
- Admin login: `http://localhost:9002/admin/login`
- Producer login: `http://localhost:9002/producer/login`

## Default backoffice accounts

- Admin: `admin@admin.com` / `Hejian@123`
- Producer: `producer@test.com` / `123456`

2. Create env file:

```bash
copy .env.example .env
```

3. Run dev server:

```bash
npm run dev
```

4. Build for production:

```bash
npm run build
npm run start
```

## Quality tools

```bash
npm run lint
npm run lint:fix
npm run format
npm run format:check
```

## Next step

Implement the placeholders by porting behavior from:

- `DTLive/ServerCode/admin_panel/routes/api.php`
- `DTLive/ServerCode/admin_panel/app/Http/Controllers/Api/HomeController.php`
- `DTLive/ServerCode/admin_panel/app/Models/Common.php`
