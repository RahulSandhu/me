# me

Personal CV & blog — a Jekyll site, styled after the LaTeX CV.

This repo is the site's source of truth. It is consumed by the **homelab** repo
as the submodule at `docker-host/me`, which builds it and serves it two ways:

- **Tailnet** — `https://docker-host.tail91459b.ts.net/me/`, behind Caddy.
- **Public** — `https://me.tail91459b.ts.net/`, at the domain root, on its own
  funneled tailnet node.

## Prerequisites

- rbenv with Ruby 3.4.9 (pinned in `.ruby-version`)
- Bundler (ships with that Ruby)

## Setup (project-local gems)

Gems install into `./vendor/bundle`, never system-wide:

```sh
bundle config set --local path vendor/bundle
bundle install
```

## Run locally

```sh
bundle exec jekyll serve --livereload
```

Then open <http://127.0.0.1:4000>.

## Build

```sh
bundle exec jekyll build   # output in _site/
```

## Deploy

The `homelab` repo pins a commit of this repo as the submodule `docker-host/me`
and serves it from one source. A multi-stage build (`Dockerfile`) renders Jekyll
and hands the static output to nginx; the build args `JEKYLL_CONFIG` and
`NGINX_CONF` select the deployment:

- **Tailnet** uses `_config_tailnet.yml` (`baseurl: /me`).
- **Public** uses `_config_public.yml` (empty `baseurl` plus the public `url`),
  served at the node root by `nginx.root.conf`.

To publish a change:

```sh
# in this repo
git add -A && git commit -m "..." && git push

# in homelab — bump the pinned commit
git submodule update --remote docker-host/me
git add docker-host/me && git commit -m "chore: bump me submodule"
```

On the `docker-host` VM (the submodule is copied to `/opt/me`):

```sh
cd /opt/me
cp .env.example .env          # fill in TS_AUTHKEY (a reusable Tailscale key)
docker compose up -d --build
docker exec me-ts tailscale funnel --bg --https=443 http://127.0.0.1:80
```

## Editing content

- **CV content:** edit `_data/cv.yml` — `contact`, `profile`, `work`,
  `education`, `publications`, `skills`, `languages`.
- **Blog posts:** add Markdown files to `_posts/` named `YYYY-MM-DD-title.md`;
  permalink is `/blog/:title/`.
- **Styles:** `_sass/*.scss`, compiled through `assets/css/main.scss`.

## Notes

- Internal links use Jekyll's `relative_url`, so the site can move behind a
  subpath without template edits. The `baseurl`/`url` for each deployment live
  in the config overlays (`_config_tailnet.yml`, `_config_public.yml`), not in
  the templates.
- `nginx.conf` serves the `/me` subpath; `nginx.root.conf` serves the public
  root deployment. Both are plain static servers over the same build output.
- `resume` in the top nav downloads `assets/files/resume.pdf` (a copy of the
  compiled LaTeX CV at `~/documents/curriculum_vitae`).
