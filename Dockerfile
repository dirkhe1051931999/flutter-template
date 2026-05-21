FROM node:20-alpine AS build

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY tsconfig.json ./
COPY src ./src
RUN npm run build

FROM node:20-alpine AS runtime

WORKDIR /app

ENV NODE_ENV=production

COPY package*.json ./
RUN npm ci --omit=dev

COPY --from=build /app/dist ./dist
# Templates are loaded from process.cwd()/src/... at runtime.
COPY src/modules/backoffice/templates ./src/modules/backoffice/templates

EXPOSE 9002

CMD ["node", "dist/server.js"]
