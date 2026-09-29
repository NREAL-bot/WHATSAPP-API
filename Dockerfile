FROM node:22-bookworm-slim

ENV NODE_ENV=production
ENV PUPPETEER_SKIP_DOWNLOAD=true

RUN apt-get update && apt-get install -y --no-install-recommends \
    chromium \
    ca-certificates \
    fonts-liberation \
    fonts-noto-color-emoji \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY package*.json ./
RUN npm install --omit=dev
COPY src ./src
COPY .env.example ./.env.example
RUN mkdir -p /app/data /app/.wwebjs_auth

CMD ["node", "src/index.js"]
