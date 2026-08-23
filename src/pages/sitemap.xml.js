import { getCollection } from 'astro:content';

export const prerender = true;

export async function GET() {
  const site = 'https://acta-fragilia.pages.dev';

  const staticPaths = [
    '', 'about/', 'archive/', 'contacts/', 'editorial-policy/', 'privacy/',
    'en/', 'en/about/', 'en/archive/', 'en/contacts/', 'en/editorial-policy/', 'en/privacy/',
    'pl/', 'pl/about/', 'pl/archive/', 'pl/contacts/', 'pl/editorial-policy/', 'pl/privacy/',
    'by/', 'by/about/', 'by/archive/', 'by/contacts/', 'by/editorial-policy/', 'by/privacy/',
  ];

  const articles = await getCollection('articles');
  const articlePaths = articles.map(a => 'article/' + a.slug + '/');

  const allPaths = [...staticPaths, ...articlePaths];
  const today = new Date().toISOString().split('T')[0];

  let urls = '';
  for (const p of allPaths) {
    urls += '  <url>\n';
    urls += '    <loc>' + site + '/' + p + '</loc>\n';
    urls += '    <lastmod>' + today + '</lastmod>\n';
    urls += '  </url>\n';
  }

  const sitemap = '<?xml version="1.0" encoding="UTF-8"?>\n' +
    '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n' +
    urls +
    '</urlset>';

  return new Response(sitemap, {
    headers: { 'Content-Type': 'application/xml' }
  });
}
