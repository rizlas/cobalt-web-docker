#!/bin/sh
# Replaces the placeholder API URL baked in at build time with the real
# one, in every static file nginx is about to serve. Runs on every
# container start (nginx's stock docker-entrypoint.sh sources every *.sh
# file in this directory before starting), so the actual backend URL never
# has to be committed to this repo or published in the image.
set -eu

PLACEHOLDER="https://REPLACE-AT-RUNTIME.invalid"

if [ -z "${DEFAULT_API:-}" ]; then
    echo "50-inject-default-api.sh: DEFAULT_API env var is required, but missing." >&2
    exit 1
fi

grep -rlF "$PLACEHOLDER" /usr/share/nginx/html 2>/dev/null | while IFS= read -r file; do
    sed -i "s|$PLACEHOLDER|$DEFAULT_API|g" "$file"
done
