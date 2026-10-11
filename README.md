# me

My personal website — a Jekyll CV + blog. It's also a template: fork it, edit
the content below, and point the config at yourself.

## Configuration

**Content**
- `_data/cv.yml` — everything personal: contact, profile, work, education,
  publications, skills, languages.
- `_posts/YYYY-MM-DD-title.md` — blog posts (permalink `/blog/:title/`).
- `index.html`, `404.html` — the pages.

**Look & settings**
- `_config.yml` — title, author, nav, plugins.
- `_sass/` (compiled via `assets/css/main.scss`), `_layouts/`, `_includes/`.
  The palette is the Framework 12 "Sage" scheme (`_sass/_variables.scss`).

**Run locally**
```sh
bundle install
bundle exec jekyll serve   # http://127.0.0.1:4000
```

**Deploy**
Built by `Dockerfile` (Jekyll → nginx) and run with `compose.yaml`. The build
also prints the CV page to `resume.pdf` — what the `resume` nav link downloads;
`@media print` in `_sass/_print.scss` hides the nav. The baseurl/url come
from `_config_tailnet.yml` (served under `/me/`) or `_config_public.yml` (served
at the root), selected by build args; `nginx.conf` and `nginx.root.conf` serve
them.

```sh
cp .env.example .env        # TS_AUTHKEY for the public Tailscale node
docker compose up -d --build
```
