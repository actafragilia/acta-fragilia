import rss from '@astrojs/rss';
import { getCollection } from 'astro:content';

export async function GET(context) {
  const articles = await getCollection('articlesEn');
  const sortedArticles = articles.sort(
    (a, b) => new Date(b.data.date).getTime() - new Date(a.data.date).getTime()
  );

  return rss({
    title: 'ACTA FRAGILIA — English',
    description: 'Independent journalism and analysis: law, economics, corporate conflicts and social processes.',
    site: context.site ?? 'https://acta-fragilia.pages.dev',
    customData: '<language>en</language>',
    items: sortedArticles.map((article) => ({
      title: article.data.title,
      description: article.data.subtitle,
      pubDate: new Date(article.data.date),
      link: `/en/article/${article.slug}/`,
      ...(article.data.author ? { author: article.data.author } : {}),
    })),
  });
}