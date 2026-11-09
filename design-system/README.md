# Tin Can Vista

A small design system for a personal blog: technical, industrial and sun-baked. Its colors come from two sources: the intentionally rusted fences of New Mexico, and one desert photo of sunlit granite, pine, prickly pear and sky.

The site name is just typeset in the stencil display face. There is no logo mark and no background art; photos live in the articles themselves. The typeset name is the logo.

## Content fundamentals

- Write in first person, like a field note. "I walked out before sunset" beats "The author visited."
- Short titles, concrete nouns: "Granite and prickly pear", not "Thoughts on outdoor spaces".
- Sentence case in headings and buttons. Uppercase appears only in the small `eyebrow` tag label.
- Dates read `2026-11-09`. Reading time reads `4 min read`.
- No exclamation marks, no emoji.

## Visual foundations

- **Two themes, one system.** *Sky and granite* (light) and *Steel and rust* (dark). A Light / Dark / System switcher chooses; System follows the OS.
  - **Sky and granite:** a cool sky-white page, near-black ink, solid rust header, steel footer.
  - **Steel and rust:** a weathered steel page, warm-white ink, the same rust header deepened, a near-black footer.
- **No neutral tan or cream.** The page is cool, the color comes from the photo and the fence.
- **Color goes in three places.** A solid rust header band, tinted post cards with a solid top band, and a solid steel footer band. Everything else stays quiet, so color reads as structure.
- **Card colors.** Cards cycle through four families, each a solid band, a pale panel and a deep text color: rust, sky, sage and gold. Pair a panel only with `ink` and `ink-muted` text.
- **Links and buttons** use `action`, a deep rust in the light theme and a bright rust orange in the dark theme. Put `on-action` on a filled button.
- **Tags** are outlined, with no fill, in the deep color of their family: `rust-deep`, `pine`, `sky-deep` or `gold-deep`.
- **Type.** Big Shoulders Stencil Display, a condensed stencil, for the site name and the big headings (`display`, `h1`, `h2`). Archivo for everything else: card titles, reading text, nav, tags, dates and captions. Keep stencil to short titles; it is loud. Body text is 16px on 26px leading, at about 65 characters per line.
- **Shape.** Square corners (`radius-sm` is 0; `radius-md` and `radius-lg` are 2px and 4px). Separate things with `hairline` borders, never shadows or gradients.
- **Images.** Photos sit in articles with a small caption underneath. No frames, overlays or filters.
- **Contrast.** Every pairing named in the tokens' usage notes passes 4.5:1 in both themes. The bright fill colors (`rust`, `gold`, `sage`, `sky`) are for bands, blocks and top edges, never for small text.

## Iconography

Almost none. Use words, and a plain `->` for "next". The one exception is the theme switcher: a sun, a moon and a monitor, drawn as 2-unit square-ended outlines on a 24 grid (1.5px at 16px) in `currentColor`. Any new icon should match that style.

## Components

Five small pieces, built as plain CSS classes in `components/bundle.css`: **Button**, **Tag**, **PostCard**, **SiteHeader** (header, switcher and footer) and **Prose** (the article body). Load `tokens.css` and then `bundle.css`, and use the class names shown in each component's guidelines.
