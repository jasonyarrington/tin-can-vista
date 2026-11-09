# Tin Can Vista

A personal blog. Posts are written in Markdown, built into a static site by a Perl script, and deployed through GitHub Actions to Firebase Hosting on Google Cloud.

## Layout

- `posts/*.md`: blog posts. Front matter: `title`, `date` (YYYY-MM-DD), `tags`, optional `summary`, optional `draft: true`. The URL slug is the filename minus the date.
- `pages/*.md`: standalone pages (About, 404). Front matter: `title`, optional `section`, optional `path`.
- `static/`: files copied as-is into the site, such as `static/images/`.
- `site.yml`: site title, tagline and author.
- `site/templates/*.tt`: Template Toolkit templates. `site/static/css/site.css`: page layout CSS.
- `bin/build.pl`: the generator. Reads Markdown with Markdown::Perl, renders templates, writes `output/`.
- `design-system/`: the design system. `tokens.json` is the source; `tokens.css` is generated.
- `infra/`: Terraform for the GCP project, Firebase Hosting and keyless GitHub deploy access. See `infra/README.md`.
- `.github/workflows/`: `pr.yml` (build and preview), `deploy.yml` (deploy on merge to `main`), `infra.yml` (Terraform checks).
- `firebase.json`: Hosting config. Serves `output/` with clean URLs and trailing slashes.

## Commands

- `make install`: install Perl dependencies into `./local` (no root).
- `make build`: regenerate `design-system/tokens.css`, then build the site into `output/`.
- `make serve`: build and preview at http://localhost:8000.
- `perl bin/build.pl --drafts`: include draft posts.

## Design system

Read `design-system/README.md` first. It is published as a private artifact at https://claude.ai/artifact/WRGz7BAgvBJfqh6UaAiPb3.

- Use `design-system/tokens.css` for all colors, fonts, spacing and radii, as CSS variables. After editing `design-system/tokens.json`, run `perl design-system/build-tokens.pl`; never edit `tokens.css` by hand.
- Use the classes in `design-system/components/bundle.css`: `aw-btn`, `aw-tag`, `aw-card`, `aw-header`, `aw-prose`. Each component's `README.md` and `preview.html` show the markup.
- Page layout that the design system does not cover goes in `site/static/css/site.css`, using tokens only.

Rules:

- Style only with the tokens. Never hard-code a color, font, spacing or radius.
- Square corners, `hairline` borders, no shadows or gradients.
- The site name is typeset text in Big Shoulders Stencil Display. No logo, no background art.
- `display`, `h1` and `h2` use the stencil face; everything else uses Archivo.
- Photos go inside articles as a Markdown image on its own line, with the title text as the caption: `![alt](/images/x.jpg "Caption")`. The generator turns it into a `figure` with a `figcaption`. No frame, overlay or filter.
- Links and buttons use the `action` color. Never use `rust`, `gold`, `sage` or `sky` for small text.
- Light and dark themes both work; `tokens.css` follows the OS setting.
- Voice: first person, plain, sentence case, dates as `2026-11-09`, no emoji.

## Pipeline and hosting

- Pull requests: build the site. PRs from this repo also get a 7-day Firebase preview channel, linked in a PR comment.
- Merge to `main`: build and deploy to Firebase Hosting.
- GitHub Actions authenticates with Workload Identity Federation. There are no stored keys. It needs three repository variables: `GCP_PROJECT_ID`, `GCP_WORKLOAD_IDENTITY_PROVIDER`, `GCP_SERVICE_ACCOUNT` (Terraform outputs).
- Google Cloud changes are made in `infra/` and applied by hand with `terraform apply`. Nothing about the hosting should exist only in a console.
- The Google Cloud project is `tin-can-vista-blog` (organization fastforward.sh), unbilled on Firebase's free Spark plan. Terraform state is local and git-ignored (`infra/terraform.tfstate`).
- Live at https://tin-can-vista-blog.web.app. The custom domain `tincanvista.com` is registered at GoDaddy and declared in `infra/main.tf`; its DNS records are set by hand at GoDaddy (see `infra/README.md`).
