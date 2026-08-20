import rss from '@astrojs/rss';
import { getCollection } from 'astro:content';

export async function GET(context) {
  const articles = (await getCollection('articles'))
    .filter(a => !a.data.draft)
    .sort((a, b) => b.data.date.valueOf() - a.data.date.valueOf());

  return rss({
    title: 'ACTA FRAGILIA',
    description: 'Независимая авторская площадка для долгих текстов, анализа документов, расследований и объяснения сложных тем.',
    site: context.site,
    items: articles.map(article => ({
      title: article.data.title,
      description: article.data.subtitle,
      pubDate: article.data.date,
      link: `/article/${article.slug}`,
      author: article.data.author,
    })),
    customData: `<language>ru-RU</language>`,
  });
}
