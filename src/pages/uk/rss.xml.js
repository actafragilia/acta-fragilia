import rss from '@astrojs/rss';
import { getCollection } from 'astro:content';

export async function GET(context) {
  const articles = await getCollection('articlesUk');
  const sortedArticles = articles.sort(
    (a, b) => new Date(b.data.date).getTime() - new Date(a.data.date).getTime()
  );

  return rss({
    title: 'ACTA FRAGILIA — Українська',
    description: 'Незалежна журналістика та аналіз: право, економіка, корпоративні конфлікти та соціальні процеси.',
    site: context.site ?? 'https://acta-fragilia.com',
    customData: '<language>uk</language>',
    items: sortedArticles.map((article) => ({
      title: article.data.title,
      description: article.data.subtitle,
      pubDate: new Date(article.data.date),
      link: `/uk/article/${article.slug}/`,
      ...(article.data.author ? { author: article.data.author } : {}),
    })),
  });
}
