#requires -Version 7
#requires -PSEdition Core

<#
.SYNOPSIS
    Создаёт локализованные страницы 404 для EN, PL, BY и добавляет
    клиентский редирект на глобальную страницуу 404.

.DESCRIPTION
    Исправления по сравнению с оригиналом:
    - Безопасная вставка скрипта (не первый попавшийся пробел, а перед </script> или </body>)
    - Проверка typeof window !== 'undefined' для SSR-совместимости
    - Пути через Join-Path (кросс-платформенность)
    - Проверка существования src/pages/404.astro
    - Проверка LASTEXITCODE после каждой git-команды
    - Использование маркера ACTA_LOCALIZED_404 для предотвращения дублирования
#>

$ErrorActionPreference = 'Stop'

# ── Определение корня проекта ────────────────────────────────────────────────
$PreferredProject = Join-Path 'X:' 'Общая' '1_Сайт' 'acta-fragilia-astro'
if (Test-Path (Join-Path $PreferredProject 'package.json')) {
    $ProjectRoot = $PreferredProject
}
elseif (Test-Path (Join-Path $PSScriptRoot 'package.json')) {
    $ProjectRoot = $PSScriptRoot
}
else {
    throw 'Не найдена папка проекта acta-fragilia-astro.'
}

Set-Location $ProjectRoot
$Utf8NoBom = [System.Text.UTF8Encoding]::new($false)

# ── Вспомогательные функции ──────────────────────────────────────────────────
function Write-Utf8NoBom {
    param(
        [Parameter(Mandatory)] [string]$RelativePath,
        [Parameter(Mandatory)] [string]$Content
    )

    $FullPath = Join-Path $ProjectRoot $RelativePath
    $Directory = Split-Path $FullPath -Parent
    if (-not (Test-Path $Directory)) {
        New-Item -ItemType Directory -Path $Directory -Force | Out-Null
    }
    [System.IO.File]::WriteAllText($FullPath, $Content, $Utf8NoBom)
    Write-Host "Создано: $RelativePath" -ForegroundColor Green
}

# ── Шаблоны 404-страниц ─────────────────────────────────────────────────────
$English404 = @'
---
import Base from '../../layouts/Base.astro';

const page = {
  title: 'Page not found',
  text: 'The material may have been moved or the link is outdated.',
  home: '← Back to home',
  archive: 'Open archive',
};
---

<Base title={page.title} lang="en">
  <div class="notfound">
    <div class="notfound-code">404</div>
    <h1 class="notfound-title">{page.title}</h1>
    <p class="notfound-text">{page.text}</p>
    <div class="notfound-actions">
      <a href="/en/" class="notfound-link">{page.home}</a>
      <a href="/en/archive/" class="notfound-link notfound-link--muted">{page.archive}</a>
    </div>
  </div>
</Base>

<style>
  .notfound { max-width: 640px; min-height: 620px; margin: 0 auto; padding: 5rem 0; text-align: center; }
  .notfound-code { font-family: var(--font-mono); font-size: clamp(4rem, 12vw, 6rem); font-weight: 500; line-height: 1; color: var(--color-accent); margin-bottom: var(--space-md); letter-spacing: .05em; }
  .notfound-title { font-family: var(--font-serif); font-size: clamp(1.5rem, 4vw, 2.2rem); font-weight: 600; color: var(--color-text); margin-bottom: var(--space-md); }
  .notfound-text { font-family: var(--font-serif); font-size: 1.1rem; color: var(--color-text-secondary); line-height: 1.6; margin-bottom: var(--space-xl); }
  .notfound-actions { display: flex; gap: var(--space-lg); justify-content: center; flex-wrap: wrap; }
  .notfound-link { font-family: var(--font-mono); font-size: .9rem; text-transform: uppercase; letter-spacing: .08em; color: var(--color-accent); text-decoration: none; border-bottom: 1px solid transparent; padding-bottom: 2px; }
  .notfound-link:hover { border-bottom-color: var(--color-accent); }
  .notfound-link--muted { color: var(--color-text-secondary); }
  .notfound-link--muted:hover { border-bottom-color: var(--color-text-secondary); }
</style>
'@

$Polish404 = @'
---
import Base from '../../layouts/Base.astro';

const page = {
  title: 'Strona nie znaleziona',
  text: 'Materiał mógł zostać przeniesiony lub link jest nieaktualny.',
  home: '← Strona główna',
  archive: 'Otwórz archiwum',
};
---

<Base title={page.title} lang="pl">
  <div class="notfound">
    <div class="notfound-code">404</div>
    <h1 class="notfound-title">{page.title}</h1>
    <p class="notfound-text">{page.text}</p>
    <div class="notfound-actions">
      <a href="/pl/" class="notfound-link">{page.home}</a>
      <a href="/pl/archive/" class="notfound-link notfound-link--muted">{page.archive}</a>
    </div>
  </div>
</Base>

<style>
  .notfound { max-width: 640px; min-height: 620px; margin: 0 auto; padding: 5rem 0; text-align: center; }
  .notfound-code { font-family: var(--font-mono); font-size: clamp(4rem, 12vw, 6rem); font-weight: 500; line-height: 1; color: var(--color-accent); margin-bottom: var(--space-md); letter-spacing: .05em; }
  .notfound-title { font-family: var(--font-serif); font-size: clamp(1.5rem, 4vw, 2.2rem); font-weight: 600; color: var(--color-text); margin-bottom: var(--space-md); }
  .notfound-text { font-family: var(--font-serif); font-size: 1.1rem; color: var(--color-text-secondary); line-height: 1.6; margin-bottom: var(--space-xl); }
  .notfound-actions { display: flex; gap: var(--space-lg); justify-content: center; flex-wrap: wrap; }
  .notfound-link { font-family: var(--font-mono); font-size: .9rem; text-transform: uppercase; letter-spacing: .08em; color: var(--color-accent); text-decoration: none; border-bottom: 1px solid transparent; padding-bottom: 2px; }
  .notfound-link:hover { border-bottom-color: var(--color-accent); }
  .notfound-link--muted { color: var(--color-text-secondary); }
  .notfound-link--muted:hover { border-bottom-color: var(--color-text-secondary); }
</style>
'@

$Belarusian404 = @'
---
import Base from '../../layouts/Base.astro';

const page = {
  title: 'Старонка не знойдзена',
  text: 'Магчыма, матэрыял быў перамешчаны або спасыла састарэла.',
  home: '← На галоўную',
  archive: 'Адкрыць архіў',
};
---

<Base title={page.title} lang="be">
  <div class="notfound">
    <div class="notfound-code">404</div>
    <h1 class="notfound-title">{page.title}</h1>
    <p class="notfound-text">{page.text}</p>
    <div class="notfound-actions">
      <a href="/by/" class="notfound-link">{page.home}</a>
      <a href="/by/archive/" class="notfound-link notfound-link--muted">{page.archive}</a>
    </div>
  </div>
</Base>

<style>
  .notfound { max-width: 640px; min-height: 620px; margin: 0 auto; padding: 5rem 0; text-align: center; }
  .notfound-code { font-family: var(--font-mono); font-size: clamp(4rem, 12vw, 6rem); font-weight: 500; line-height: 1; color: var(--color-accent); margin-bottom: var(--space-md); letter-spacing: .05em; }
  .notfound-title { font-family: var(--font-serif); font-size: clamp(1.5rem, 4vw, 2.2rem); font-weight: 600; color: var(--color-text); margin-bottom: var(--space-md); }
  .notfound-text { font-family: var(--font-serif); font-size: 1.1rem; color: var(--color-text-secondary); line-height: 1.6; margin-bottom: var(--space-xl); }
  .notfound-actions { display: flex; gap: var(--space-lg); justify-content: center; flex-wrap: wrap; }
  .notfound-link { font-family: var(--font-mono); font-size: .9rem; text-transform: uppercase; letter-spacing: .08em; color: var(--color-accent); text-decoration: none; border-bottom: 1px solid transparent; padding-bottom: 2px; }
  .notfound-link:hover { border-bottom-color: var(--color-accent); }
  .notfound-link--muted { color: var(--color-text-secondary); }
  .notfound-link--muted:hover { border-bottom-color: var(--color-text-secondary); }
</style>
'@

# ── Создание локализованных 404 ──────────────────────────────────────────────
Write-Utf8NoBom -RelativePath (Join-Path 'src' 'pages' 'en' '404.astro') -Content $English404
Write-Utf8NoBom -RelativePath (Join-Path 'src' 'pages' 'pl' '404.astro') -Content $Polish404
Write-Utf8NoBom -RelativePath (Join-Path 'src' 'pages' 'by' '404.astro') -Content $Belarusian404

# ── Обновление глобальной 404.astro ──────────────────────────────────────────
$Root404Path = Join-Path $ProjectRoot 'src' 'pages' '404.astro'
if (-not (Test-Path $Root404Path)) {
    throw 'Не найден src/pages/404.astro'
}

$Root404 = [System.IO.File]::ReadAllText($Root404Path)

# Преотвращаем дублирование по маркеру
if ($Root404 -match 'ACTA_LOCALIZED_404') {
    Write-Host 'Редирект 404 уже настроен. Пропускаю.' -ForegroundColor DarkGray
}
else {
    $RedirectScript = @'

<script is:inline>
  // ACTA_LOCALIZED_404
  if (typeof window !== 'undefined') {
    const path = window.location.pathname;
    const target = path.startsWith('/en/') ? '/en/404/'
                 : path.startsWith('/pl/') ? '/pl/404/'
                 : path.startsWith('/by/') ? '/by/404/'
                 : null;

    if (target && path !== target) {
      window.location.replace(target);
    }
  }
</script>

'@

    # Безопасная вставка: сначала перед </script>, иначе перед </body>
    if ($Root404 -match '</script>') {
        # Вставляем после последнего </script>
        $lastScript = $Root404.LastIndexOf('</script>')
        if ($lastScript -ge 0) {
            $Root404 = $Root404.Insert($lastScript + 9, "`r`n" + $RedirectScript)
        }
    }
    elseif ($Root404 -match '</body>') {
        $Root404 = $Root404.Replace('</body>', $RedirectScript + '</body>')
    }
    else {
        Write-Host "ПРЕДУПРЕЖДЕНИЕ: не найден </script> или </body> в 404.astro. Редирект не добавлен." -ForegroundColor Yellow
    }

    [System.IO.File]::WriteAllText($Root404Path, $Root404, $Utf8NoBom)
    Write-Host 'Обновлена глобальная маршрутизация 404.' -ForegroundColor Green
}

# ── Сборка и деплой ────────────────────────────────────────────────────────────
Write-Host "`nЗапускаю проверочную сборку..." -ForegroundColor Cyan
& npm run build
if ($LASTEXITCODE -ne 0) {
    throw 'Сборка завершилась с ошибкой. Изменения не отправлены.'
}

$gitFiles = @(
    (Join-Path 'src' 'pages' '404.astro'),
    (Join-Path 'src' 'pages' 'en' '404.astro'),
    (Join-Path 'src' 'pages' 'pl' '404.astro'),
    (Join-Path 'src' 'pages' 'by' '404.astro')
) | Where-Object { Test-Path (Join-Path $ProjectRoot $_) }

if ($gitFiles.Count -eq 0) {
    Write-Host 'Нет файлов для добавления в Git.' -ForegroundColor Yellow
    exit 0
}

& git add -- $gitFiles
if ($LASTEXITCODE -ne 0) { throw 'git add завершился с ошибкой.' }

& git diff --cached --quiet
if ($LASTEXITCODE -eq 0) {
    Write-Host 'Все изменения уже присуттвуют. Новый коммит не требуется.' -ForegroundColor Yellow
    exit 0
}

& git commit -m 'Add localized 404 pages for EN PL BY'
if ($LASTEXITCODE -ne 0) { throw 'git commit завершился с ошибкой.' }

& git push origin main
if ($LASTEXITCODE -ne 0) { throw 'git push завершился с ошибкой.' }

Write-Host "`nГотово: локализованные страницы 404 и автоматический выбор языка добавлены для EN, PL и BY." -ForegroundColor Green
