# Инструкция: одна кнопка

## Шаг 1: Распаковать
Распакуйте содержимое архива в папку проекта (там, где package.json).
Файлы перезапишут старые автоматически.

## Шаг 2: Нажать одну кнопку
В PowerShell выполните:

```powershell
npm run build
```

## Что исправлено
- astro.config.mjs: sitemap теперь работает (добавлен integrations: [sitemap()])
- .gitignore: dist/ и .astro/ больше не попадут в Git
- about.astro: "псвдонимом" → "псевдонимом"
- editorial-policy.astro: 4 опечатки исправлены
- bankrotstvo-kak-sistema.md: 3 опечатки + добавлено readTime: 8

## После сборки
Проверьте, что в dist/ появились:
- sitemap.xml (должен быть XML, не HTML)
- robots.txt
