import { defineCollection, z } from 'astro:content';

const articleSchema = z.object({
  title: z.string(),
  subtitle: z.string(),
  category: z.string(),
  date: z.date(),
  author: z.string(),
  readTime: z.number(),
  sources: z.array(z.string()).optional(),
  marginalNote: z.string().optional(),
});

export const collections = {
  articles: defineCollection({ schema: articleSchema }),
  articlesEn: defineCollection({ schema: articleSchema }),
  articlesPl: defineCollection({ schema: articleSchema }),
  articlesBy: defineCollection({ schema: articleSchema }),
  articlesUk: defineCollection({ schema: articleSchema }),
};

// rebuild trigger 2026-08-25 16:09:55
