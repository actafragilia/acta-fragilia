import rss from '@astrojs/rss';
import { getCollection } from 'astro:content';

export async function GET(context) {
  const articles = await getCollection('articlesBy');

  const sortedArticles = articles.sort(
    (a, b) => new Date(b.data.date).getTime() - new Date(a.data.date).getTime()
  );

  return rss({
    title: 'ACTA FRAGILIA — Беларуская',
    description: 'Незалежная журналістыка і аналіз: права, эканоміка, карпаратыўныя канфлікты і грамадскія працэсы.',
    site: context.site ?? 'https://acta-fragilia.pages.dev',
    customData: '<language>be</language>',
    items: sortedArticles.map((article) => ({
      title: article.data.title,
      description: article.data.subtitle,
      pubDate: new Date(article.data.date),
      link: '/by/article/' + article.slug + '/',
    })),
  });
}
