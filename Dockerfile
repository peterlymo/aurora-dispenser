#
# SPDX-FileCopyrightText: 2024-2025 Aurora OSS
# SPDX-License-Identifier: GPL-3.0-or-later
#

# Build natively on the CI host — all deps are pure JS, so the compiled
# output and node_modules are platform-independent.
FROM --platform=$BUILDPLATFORM node:20-alpine AS build
WORKDIR /app
COPY package.json ./
RUN npm install
COPY tsconfig.json google_play.proto ./
COPY src ./src
RUN npx tsc -p . && npm prune --omit=dev

FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production \
    HOST=0.0.0.0 \
    PORT=3000

COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY package.json ./
# Default device profiles only — accounts.txt and blocked_ips.txt are
# excluded via .dockerignore and must be mounted at runtime.
COPY resources ./resources

RUN mkdir -p dist/logs && chown -R node:node /app
USER node

EXPOSE 3000
CMD ["node", "--max-old-space-size=4096", "dist/src/app.js"]
