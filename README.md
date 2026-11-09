# Tin Can Vista

A personal blog built from Markdown with a small Perl script and deployed to Firebase Hosting.

## Write a post

Add a file to `posts/`, such as `posts/2026-11-20-my-title.md`:

```markdown
---
title: My title
date: 2026-11-20
tags: [desert, walks]
summary: Optional one-line summary for the home page.
---

First paragraph.
```

Put photos in `static/images/` and reference them with `![alt](/images/photo.jpg "Caption")`. Add `draft: true` to hide a post from the live site.

## Run it locally

```bash
make install
```

```bash
make serve
```

Then open http://localhost:8000.

## Deploy

Merge to `main` and GitHub Actions publishes the site. Pull requests get a preview link. One-time Google Cloud setup is in [infra/README.md](infra/README.md).
