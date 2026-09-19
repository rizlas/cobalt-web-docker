FROM node:24-alpine AS build
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
WORKDIR /app

# Baked in at build time as a placeholder only: the real API URL is
# injected at container startup (see docker-entrypoint.d/50-inject-default-api.sh),
# so it never has to be committed to this repo or published in the image.
ENV WEB_DEFAULT_API="https://REPLACE-AT-RUNTIME.invalid"

COPY . /app

RUN corepack enable
RUN apk add --no-cache python3 alpine-sdk

RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
    pnpm install --frozen-lockfile

RUN pnpm --filter=@imput/cobalt-web build

FROM nginx:alpine AS runtime
COPY --from=build /app/web/build /usr/share/nginx/html
COPY docker-entrypoint.d/50-inject-default-api.sh /docker-entrypoint.d/50-inject-default-api.sh
RUN chmod +x /docker-entrypoint.d/50-inject-default-api.sh
EXPOSE 80
