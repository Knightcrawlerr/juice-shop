FROM node:22-slim AS builder
WORKDIR /juice-shop

# Copy app source
COPY . .

# Install dependencies (no dev dependencies for runtime)
RUN npm ci --omit=dev --unsafe-perm && npm dedupe --omit=dev

RUN npm install --no-save typescript ts-node \
 && npm prune --omit=dev \
 && rm -rf frontend/node_modules frontend/.angular frontend/src/assets \
 && rm -f data/chatbot/botDefaultTrainingData.json ftp/legal.md i18n/*.json \
 && mkdir -p logs \
 && chown -R 65532 logs \
 && chgrp -R 0 ftp/ frontend/dist/ logs/ data/ i18n/ \
 && chmod -R g=u ftp/ frontend/dist/ logs/ data/ i18n/


# Build the app
FROM gcr.io/distroless/nodejs22:nonroot
WORKDIR /juice-shop

COPY --from=builder --chown=65532:65532 /juice-shop ./

EXPOSE 3000 
CMD ["/juice-shop/build/app.js"]
