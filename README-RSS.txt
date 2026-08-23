README-RSS.txt
==============

Используйте apply-rss-fixes.ps1 для создания RSS-лент EN/PL/BY.

Исправления в этой версии:
- customData теперь валидный XML (<language>…</language>)
- Добавлена валидация дат перед сортировкой статей
- Fix-Typos заменяет только внутри frontmatter
- RSS autodiscovery добавлен для всех языков

Проверка после запуска:
  npm run build

RSS должны быть доступны по:
  /rss.xml
  /en/rss.xml
  /pl/rss.xml
  /by/rss.xml
