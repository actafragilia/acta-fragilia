$ErrorActionPreference = 'Stop'

$PreferredProject = 'X:\Общая\1_Сайт\acta-fragilia-astro'
if (Test-Path (Join-Path $PreferredProject 'package.json')) {
    $ProjectRoot = $PreferredProject
} elseif (Test-Path (Join-Path $PSScriptRoot 'package.json')) {
    $ProjectRoot = $PSScriptRoot
} else {
    throw 'Не найдена папка проекта acta-fragilia-astro.'
}

Set-Location $ProjectRoot
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Write-Utf8NoBom([string]$RelativePath, [string]$Content) {
    $FullPath = Join-Path $ProjectRoot $RelativePath
    $Directory = Split-Path $FullPath -Parent
    if (-not (Test-Path $Directory)) {
        New-Item -ItemType Directory -Path $Directory -Force | Out-Null
    }
    [System.IO.File]::WriteAllText($FullPath, $Content, $Utf8NoBom)
    Write-Host "Создано: $RelativePath" -ForegroundColor Green
}

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

<Base title={`${page.title} — ACTA FRAGILIA`} lang="en">
  <section class="notfound">
    <p class="notfound-code">404</p>
    <h1 class="notfound-title">{page.title}</h1>
    <p class="notfound-text">{page.text}</p>
    <div class="notfound-actions">
      <a href="/en/" class="notfound-link">{page.home}</a>
      <a href="/en/archive/" class="notfound-link notfound-link--muted">{page.archive}</a>
    </div>
  </section>
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

<Base title={`${page.title} — ACTA FRAGILIA`} lang="pl">
  <section class="notfound">
    <p class="notfound-code">404</p>
    <h1 class="notfound-title">{page.title}</h1>
    <p class="notfound-text">{page.text}</p>
    <div class="notfound-actions">
      <a href="/pl/" class="notfound-link">{page.home}</a>
      <a href="/pl/archive/" class="notfound-link notfound-link--muted">{page.archive}</a>
    </div>
  </section>
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
  text: 'Магчыма, матэрыял быў перамешчаны або спасылка састарэла.',
  home: '← На галоўную',
  archive: 'Адкрыць архіў',
};
---

<Base title={`${page.title} — ACTA FRAGILIA`} lang="by">
  <section class="notfound">
    <p class="notfound-code">404</p>
    <h1 class="notfound-title">{page.title}</h1>
    <p class="notfound-text">{page.text}</p>
    <div class="notfound-actions">
      <a href="/by/" class="notfound-link">{page.home}</a>
      <a href="/by/archive/" class="notfound-link notfound-link--muted">{page.archive}</a>
    </div>
  </section>
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

Write-Utf8NoBom 'src\pages\en\404.astro' $English404
Write-Utf8NoBom 'src\pages\pl\404.astro' $Polish404
Write-Utf8NoBom 'src\pages\by\404.astro' $Belarusian404

# Глобальная страница 404 определяет языковой префикс исходного ошибочного URL
# и переводит посетителя на соответствующую локализованную страницу.
$Root404Path = Join-Path $ProjectRoot 'src\pages\404.astro'
if (-not (Test-Path $Root404Path)) { throw 'Не найден src\pages\404.astro' }
$Root404 = [System.IO.File]::ReadAllText($Root404Path)
if ($Root404 -notmatch 'ACTA_LOCALIZED_404') {
    $RedirectScript = @'

<script is:inline>
  // ACTA_LOCALIZED_404
  const path = window.location.pathname;
  const target = path.startsWith('/en/')
    ? '/en/404/'
    : path.startsWith('/pl/')
      ? '/pl/404/'
      : path.startsWith('/by/')
        ? '/by/404/'
        : null;

  if (target && path !== target) {
    window.location.replace(target);
  }
</script>
'@
    if ($Root404.Contains('</Base>')) {
        $Root404 = $Root404.Replace('</Base>', $RedirectScript + "`r`n</Base>")
    } else {
        $Root404 = $Root404 + $RedirectScript
    }
    [System.IO.File]::WriteAllText($Root404Path, $Root404, $Utf8NoBom)
    Write-Host 'Обновлена глобальная маршрутизация 404.' -ForegroundColor Green
}

Write-Host "`nЗапускаю проверочную сборку..." -ForegroundColor Cyan
& npm run build
if ($LASTEXITCODE -ne 0) { throw 'Сборка завершилась с ошибкой. Изменения не отправлены.' }

& git add -- 'src/pages/404.astro' 'src/pages/en/404.astro' 'src/pages/pl/404.astro' 'src/pages/by/404.astro'
if ($LASTEXITCODE -ne 0) { throw 'git add завершился с ошибкой.' }

& git commit -m 'Add localized 404 pages for EN PL BY'
if ($LASTEXITCODE -ne 0) { throw 'git commit завершился с ошибкой.' }

& git push origin main
if ($LASTEXITCODE -ne 0) { throw 'git push завершился с ошибкой.' }

Write-Host "`nГотово: локализованные страницы 404 и автоматический выбор языка добавлены для EN, PL и BY." -ForegroundColor Green
