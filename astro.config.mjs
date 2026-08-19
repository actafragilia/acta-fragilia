import { defineConfig } from 'astro/config';
import rss from '@astrojs/rss';

export default defineConfig({
  output: 'static',
  trailingSlash: 'never',
  site: 'https://acta-fragilia.pages.dev',
  integrations: []
});
