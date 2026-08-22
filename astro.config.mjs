import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';

export default defineConfig({
  site: 'https://acta-fragilia.pages.dev',
  integrations: [sitemap()]
});