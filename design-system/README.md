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

- **Color.** Pale oxide-stone `surface` and near-black `ink` carry the page. The fence gives the accents: `rust`, `rust-deep` and `steel`. The photo gives `gold` (granite), `sage` and `pine` (cactus and pine) and `sky`. Use `rust`, `steel`, `gold`, `sage` and `sky` as flat blocks or rules, never as small text.
- **Links and buttons** use `action`, a deep rust, because the bright `rust` fails contrast as text. Put `on-action` on top of it.
- **Tinted tags** pair a `*-tint` background with its deep text color: `rust-tint` with `rust-deep`, `sage-tint` with `pine`.
- **Type.** Big Shoulders Stencil Display, a condensed stencil, for the site name and the big headings (`display`, `h1`, `h2`). Archivo for everything else: card titles, reading text, nav, tags, dates and captions. Keep stencil to short titles; it is loud. Body text is 16px on 26px leading, at about 65 characters per line.
- **Shape.** Square corners (`radius-sm` is 0; `radius-md` and `radius-lg` are 2px and 4px). Separate things with `hairline` borders, never shadows or gradients.
- **Images.** Photos sit in articles with a small caption underneath. No frames, overlays or filters.
- **Themes.** Light is oxide-stone and near-black; dark is blackened steel with the rust lightened. Every pairing in the tokens' usage notes passes 4.5:1 in both.

## Iconography

None needed. Use words, and a plain `->` for "next". If you add icons later, draw them as 1.5px outlines in `ink`.

## Components

Five small pieces, built as plain CSS classes in `components/bundle.css`: **Button**, **Tag**, **PostCard**, **SiteHeader** and **Prose** (the article body). Load `tokens.css` and then `bundle.css`, and use the class names shown in each component's guidelines.
