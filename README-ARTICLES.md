# ACTA FRAGILIA — Full Articles (EN/PL/BY)

## What is included

### Articles (3 per language, 12 total)
- **English**: bankruptcy, new religious movements, media landscape
- **Polish**: upadłość, nowe ruchy religijne, pejzaż medialny
- **Belarusian**: банкротства, новыя рэлігійныя рухі, медыйны ландшафт

### Files to integrate into your project

1. **Content collections** (put in `src/content/`):
   - `articles-en/` — English articles
   - `articles-pl/` — Polish articles
   - `articles-by/` — Belarusian articles

2. **Config** (replace `src/content/config.ts`):
   - `config.ts` — updated with multilingual collections

3. **Layouts** (put in `src/layouts/`):
   - `ArticleLayout.astro` — shared article page layout

4. **Utils** (put in `src/utils/`):
   - `date.ts` — date formatting utility

5. **Article pages** (put in `src/pages/`):
   - `article/slug.astro` → rename to `[...slug].astro`
   - `en/article/slug.astro` → rename to `[...slug].astro`
   - `pl/article/slug.astro` → rename to `[...slug].astro`
   - `by/article/slug.astro` → rename to `[...slug].astro`

## How to integrate

1. Copy all folders from this ZIP into your `acta-fragilia-astro` project
2. Rename `article/slug.astro` files to `[...slug].astro` (with brackets):
   - `src/pages/article/slug.astro` → `src/pages/article/[...slug].astro`
   - `src/pages/en/article/slug.astro` → `src/pages/en/article/[...slug].astro`
   - `src/pages/pl/article/slug.astro` → `src/pages/pl/article/[...slug].astro`
   - `src/pages/by/article/slug.astro` → `src/pages/by/article/[...slug].astro`
3. Run `npm run build` locally to test
4. Push to GitHub — Cloudflare Pages will auto-deploy

## Note on file naming

The article page files are named `slug.astro` instead of `[...slug].astro` because some systems have issues with brackets in filenames. Please rename them after extraction.
