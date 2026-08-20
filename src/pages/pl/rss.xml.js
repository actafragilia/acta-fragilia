import rss from '@astrojs/rss';
import { getCollection } from 'astro:content';

export async function GET(context) {
  const articles = await getCollection('articlesPl');
  const sortedArticles = articles.sort(
    (a, b) => new Date(b.data.date).getTime() - new Date(a.data.date).getTime()
  );

  return rss({
    title: 'ACTA FRAGILIA — Polski',
    description: 'Niezależne dziennikarstwo i analiza: prawo, gospodarka, konflikty korporacyjne i procesy społeczne.',
    site: context.site ?? 'https://acta-fragilia.pages.dev',
    customData: '<language>pl</language>',
    items: sortedArticles.map((article) => ({
      title: article.data.title,
      description: article.data.subtitle,
      pubDate: new Date(article.data.date),
      link: `/pl/article/${article.slug}/`,
      ...(article.data.author ? { author: article.data.author } : {}),
    })),
  });
}