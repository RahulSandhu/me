# me

Live at <https://me.tail91459b.ts.net>.

My personal website made with Jekyll. It's also a template: fork it, edit the
content below, and point the config at yourself.

## Configuration

### Content

- `_data/cv.yml` — everything personal: contact, profile, work, education,
  publications, skills, languages.
- `_posts/YYYY-MM-DD-title.md` — blog posts (permalink `/blog/:title/`).
- `index.html`, `404.html` — the pages.

### Settings

- `_config.yml` — title, author, nav, plugins. The `resume` nav entry points at
  an external public download (a Filebrowser share on a `fileshare` node), not a
  file in this repo.
- `_sass/` (compiled via `assets/css/main.scss`), `_layouts/`, `_includes/`.
  The palette is the Framework 12 "Sage" scheme (`_sass/_variables.scss`).

### Run locally

```sh
bundle install
bundle exec jekyll serve # http://127.0.0.1:4000
```
