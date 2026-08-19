# ACTA FRAGILIA

Независимая авторская площадка для долгих текстов, анализа документов, расследований и объяснения сложных тем.

## Стек

- **Astro** — статический генератор
- **Markdown** — формат статей
- **Cloudflare Pages** — хостинг и CDN
- **Source Serif 4 + Inter + IBM Plex Mono** — типографика

## Структура

```
├── src/
│   ├── content/
│   │   ├─ articles/          # Статьи в Markdown
│   │   └── config.ts          # Схема данных статей
│   ├── layouts/
│   │   ├── Base.astro         # Базовый шаблон (nav, footer, head)
│   │   └── Article.astro      # Шаблон страницы статьи
│   ├── pages/
│   │   ├── index.astro        # Главная страница
│   │   ├── article/
│   │   │   └── [...slug].astro # Динамические страницы статей
│   │   ├── about.astro        # О проекте
│   │   ├── contacts.astro     # Контакты
│   │   ├── privacy.astro      # Политика конфиденциальности
│   │   └── rss.xml.js         # RSS-лента
│   └── styles/
│       └── global.css         # Глобальные стили, CSS-переменные
├── public/
│   ├── favicon.svg            # Фавикон
│   ├── robots.txt             # Для поисковиков
│   └── _headers               # HTTP-заголовки Cloudflare
├── astro.config.mjs
├── package.json
└── tsconfig.json
```

## Как добавить статью

1. Создайте файл `src/content/articles/название-статьи.md`
2. Добавьте frontmatter:

```yaml
---
title: "Заголовок статьи"
subtitle: "Краткое описание для анонса"
category: "Экономика"  # или: Общество, Медиа, Право, Конфликт, Документ
date: 2026-08-20       # YYYY-MM-DD
updated: 2026-08-22    # опционально
author: "А. В."
readTime: 15           # минут чтения
sources:
  - "Источник 1"
  - "Источник 2"
marginalNote: "Контекстная заметка для боковой колонки"
---

Текст статьи в Markdown...
```

3. Закоммитьте и запушьте — Cloudflare Pages пересоберёт сайт автоматически.

## Локальная разработка

```bash
# Установка зависимотей
npm install

# Запуск dev-сервера
npm run dev

# Сборка
npm run build

# Превью сборки
npm run preview
```

## Деплой на Cloudflare Pages

### Вариант 1: Git-интеграция (рекомендуется)

1. Создайте репозиторий на GitHub и запушьте проект.
2. В Cloudflare Dashboard перейдите в Pages → Create a project.
3. Подключите GitHub-репозиторий.
4. Настройк сборки:
   - **Build command:** `npm run build`
   - **Build output directory:** `dist`
5. Нажмите Save and Deploy.

### Вариант 2: Direct Upload

1. Соберите проект: `npm run build`
2. В Cloudflare Dashboard: Pages → Create a project → Upload assets.
3. Загрузите содержимое папки `dist/`.

## Настройка домена

1. В Cloudflare Dashboard добавьте свой домен в Pages project.
2. Обновите `site` в `astro.config.mjs` на ваш домен.
3. Обновите URL в `robots.txt` и `public/_headers`.

## Дизайн

- **Палитра:** архивный картон `#F0EDE7`, уголь `#1C1C1C`, приглушённый терракотовый `#9B4A4A`
- **Шрифты:** Source Serif 4 (текст), Inter (интерфейс), IBM Plex Mono (метаданные)
- **Сигнатурный элемент:** маргиналии слева от карточек статей и в боковой колонке лонгрида
- **Тёмная тема:** автоматическая через `prefers-color-scheme`

## Лицензия

Материалы сайта распространяются под CC BY-NC-SA 4.0.
