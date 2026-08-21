# Редакционная политика ACTA FRAGILIA — FINAL (4 языка)

## Исправления в этой версии

| Файл | Что исправлено |
|------|---------------|
| RU | «добровольне»→«добровольные», «указваются»→«указываются», «лбые»→«любые», «Ораничение»→«Ограничение» |
| EN | Без изменений (текст корректен) |
| PL | Без изменений (текст корректен) |
| BY | Создана новая версия на белорусском языке |

## Установка

1. Распакуйте архив в корень проекта.
2. Убедитесь, что созданы папки:
   - `src/pages/editorial-policy/`
   - `src/pages/en/editorial-policy/`
   - `src/pages/pl/editorial-policy/`
   - `src/pages/by/editorial-policy/`
3. Проверьте пути импорта `Base.astro` (../../ или ../../../ в зависимости от расположения).
4. Соберите: `npm run build`
5. Проверьте:
   - `/editorial-policy/`
   - `/en/editorial-policy/`
   - `/pl/editorial-policy/`
   - `/by/editorial-policy/`
6. Запушьте: `git add -A && git commit -m "Add editorial policy (RU, EN, PL, BY)" && git push`

## Добавление в навигацию (Base.astro)

Добавьте ссылку в меню и подвал:
```astro
<a href={`/${lang === 'ru' ? '' : lang + '/'}editorial-policy/`}>
  {lang === 'ru' ? 'Редакционная политика' : 
   lang === 'en' ? 'Editorial Policy' : 
   lang === 'pl' ? 'Polityka redakcyjna' : 
   'Рэдакцыйная палітыка'}
</a>
```
