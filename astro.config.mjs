import { defineConfig } from 'astro/config';

export default defineConfig({
  site: 'https://acta-fragilia.pages.dev',
  i18n: {
    defaultLocale: 'ru',
    locales: ['ru', 'en', 'pl', 'by'],
    routing: {
      prefixDefaultLocale: false,
    },
  },
});
