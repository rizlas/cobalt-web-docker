# cobalt-web-docker

Unofficial Docker image for the [cobalt](https://github.com/imputnet/cobalt)
web frontend (`web/`), which upstream only ships as a static site meant for
Cloudflare Pages (`wrangler.jsonc`), with no Docker image of its own.

This repo has no vendored copy of cobalt's source. A daily GitHub Action
resolves the latest commit on `imputnet/cobalt`'s `main` branch, checks it
out fresh, builds it with the [Dockerfile](Dockerfile) (`pnpm build` +
static `nginx`), and pushes the result to
`ghcr.io/<owner>/cobalt-web:<upstream-commit-sha>` (plus a `latest` tag).
No patch is applied: cobalt's frontend already builds as a static site via
`@sveltejs/adapter-static`, it's just not distributed as an image.

The default API URL cobalt's frontend calls (`WEB_DEFAULT_API`, required by
its build) is a placeholder in the image, not a real domain: the required
`DEFAULT_API` environment variable is substituted into the built static
files at container **startup** (see
[docker-entrypoint.d/50-inject-default-api.sh](docker-entrypoint.d/50-inject-default-api.sh)),
so your own API's URL never has to be committed here or baked into a
published image. Viewers can still override it per-browser from
**Settings → Instances** in the running app.

```yaml
services:
  cobalt-web:
    image: ghcr.io/<owner>/cobalt-web:<tag>
    environment:
      DEFAULT_API: "https://api.your-domain.example"
```

cobalt's web UI is licensed CC-BY-NC-SA-4.0 by imputnet: non-commercial use
only, keep the branding if you don't modify the code (this image doesn't).
