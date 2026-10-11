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

# --- runtime: serve the static output behind a proxy (Caddy, or the funnel) ---
FROM nginx:1.29-alpine
ARG NGINX_CONF=nginx.conf
COPY ${NGINX_CONF} /etc/nginx/conf.d/default.conf
COPY --from=build /site/_site /usr/share/nginx/html
