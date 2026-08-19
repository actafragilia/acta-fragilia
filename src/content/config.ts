import { defineCollection, z } from 'astro:content';

const articles = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    subtitle: z.string(),
    category: z.enum(['Экономика', 'Общество', 'Медиа', 'Право', 'Конфликт', 'Документ']),
    date: z.date(),
    updated: z.date().optional(),
    author: z.string(),
    readTime: z.number(),
    sources: z.array(z.string()).optional(),
    marginalNote: z.string().optional(),
    draft: z.boolean().default(false),
  }),
});

export const collections = { articles };
