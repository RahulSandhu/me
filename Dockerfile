# syntax=docker/dockerfile:1

# --- build: render the Jekyll site. The same source is published twice: under
#     the Caddy subpath /me on the tailnet, and at the root of its own public
#     funnel node (me.tail91459b.ts.net). The config overlay (baseurl/url)
#     and the nginx server config are therefore build args. ---
FROM ruby:3.4.9-slim AS build
WORKDIR /site

# eventmachine & friends compile native extensions from source.
RUN apt-get update \
 && apt-get install -y --no-install-recommends build-essential \
 && rm -rf /var/lib/apt/lists/*

# Install gems from the committed lockfile first so source edits reuse the layer.
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3

COPY . .
# _config.yml alone (empty baseurl) is for local `jekyll serve`; each deployment
# overlays one of the extra configs (see _config_tailnet.yml / _config_public.yml).
ARG JEKYLL_CONFIG="_config.yml,_config_tailnet.yml"
RUN bundle exec jekyll build --config "${JEKYLL_CONFIG}"

# --- résumé PDF: print the CV page to _site/resume.pdf. @media print hides the
#     nav and flips to black-on-white (see _sass/_print.scss). Chromium needs a
#     real origin for the absolute asset paths, so build a root-based copy
#     (empty baseurl) and serve it on localhost. ---
RUN apt-get update \
 && apt-get install -y --no-install-recommends chromium python3 \
 && rm -rf /var/lib/apt/lists/*
RUN bundle exec jekyll build --config _config.yml,_config_public.yml --destination /site/_resume
RUN set -eux; \
    python3 -m http.server 8099 --directory /site/_resume >/dev/null 2>&1 & \
    server=$!; \
    sleep 2; \
    chromium --headless --no-sandbox --disable-gpu --disable-dev-shm-usage \
             --hide-scrollbars --no-pdf-header-footer \
             --virtual-time-budget=10000 \
             --print-to-pdf=/site/_site/resume.pdf \
             http://127.0.0.1:8099/ ; \
    kill "$server" 2>/dev/null || true; \
    test -s /site/_site/resume.pdf

# --- runtime: serve the static output behind a proxy (Caddy, or the funnel) ---
FROM nginx:1.29-alpine
ARG NGINX_CONF=nginx.conf
COPY ${NGINX_CONF} /etc/nginx/conf.d/default.conf
COPY --from=build /site/_site /usr/share/nginx/html
