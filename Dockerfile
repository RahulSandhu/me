# syntax=docker/dockerfile:1

FROM ruby:3.4.9-slim AS build
WORKDIR /site

RUN apt-get update \
 && apt-get install -y --no-install-recommends build-essential \
 && rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3

COPY . .
ARG JEKYLL_CONFIG="_config.yml,_config_tailnet.yml"
RUN bundle exec jekyll build --config "${JEKYLL_CONFIG}"

FROM nginx:1.29-alpine
ARG NGINX_CONF=nginx.conf
COPY ${NGINX_CONF} /etc/nginx/conf.d/default.conf
COPY --from=build /site/_site /usr/share/nginx/html
