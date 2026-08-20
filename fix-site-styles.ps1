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
$CssPath = Join-Path $ProjectRoot 'src\styles\global.css'
if (-not (Test-Path $CssPath)) { throw 'Не найден src\styles\global.css' }

$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$Original = [System.IO.File]::ReadAllText($CssPath)
$StartMarker = '/* === ACTA DESIGN COMPATIBILITY START === */'
$EndMarker = '/* === ACTA DESIGN COMPATIBILITY END === */'

$Css = $Original
$Pattern = [regex]::Escape($StartMarker) + '(?s).*?' + [regex]::Escape($EndMarker)
$Css = [regex]::Replace($Css, $Pattern, '').TrimEnd()

$Repair = @'

/* === ACTA DESIGN COMPATIBILITY START === */
/* Compatibility aliases for components and article layout */
:root {
  --color-background: var(--bg);
  --color-surface: var(--surface);
  --color-text: var(--ink);
  --color-text-secondary: var(--muted);
  --color-accent: var(--accent);
  --color-border: var(--line-strong);
  --font-serif: var(--font-display);
  --font-sans: var(--font-ui);
}

/* Header used by Base.astro */
.site-header {
  position: sticky;
  top: 0;
  z-index: 100;
  background: color-mix(in oklab, var(--bg) 94%, transparent);
  backdrop-filter: blur(12px);
  border-bottom: 1px solid var(--line);
}

.header-inner {
  min-height: 72px;
  display: grid;
  grid-template-columns: auto auto 1fr;
  align-items: center;
  gap: var(--space-lg);
}

.logo {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  font-family: var(--font-display);
  font-size: var(--step-1);
  font-weight: 600;
  letter-spacing: -0.02em;
  white-space: nowrap;
}

.header-inner > a:not(.logo) {
  font-family: var(--font-ui);
  font-size: var(--step--1);
  font-weight: 500;
  color: var(--muted);
}

.main-nav {
  display: flex;
  justify-content: flex-end;
  align-items: center;
  gap: var(--space-lg);
}

.main-nav > a {
  position: relative;
  font-size: var(--step--1);
  font-weight: 500;
  color: var(--muted);
  transition: color 0.2s ease;
}

.main-nav > a:hover,
.header-inner > a:not(.logo):hover {
  color: var(--accent);
}

/* Homepage hero */
.hero {
  position: relative;
  isolation: isolate;
  overflow: hidden;
  min-height: 510px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  padding: var(--space-2xl) clamp(0rem, 3vw, 2rem);
  border-bottom: 1px solid var(--line-strong);
  background-image:
    linear-gradient(var(--line) 1px, transparent 1px),
    linear-gradient(90deg, var(--line) 1px, transparent 1px);
  background-size: 80px 80px;
}

.hero::before,
.hero::after {
  content: '';
  position: absolute;
  z-index: -1;
  left: -8%;
  width: 116%;
  height: 1px;
  background: color-mix(in oklab, var(--accent) 12%, transparent);
  transform-origin: center;
}

.hero::before { top: 44%; transform: rotate(24deg); }
.hero::after { top: 55%; transform: rotate(-24deg); }

.hero-label {
  margin-bottom: var(--space-lg);
  font-family: var(--font-mono);
  font-size: var(--step--1);
  color: var(--accent);
  text-transform: uppercase;
  letter-spacing: 0.13em;
}

.hero-title {
  max-width: 950px;
  margin-bottom: var(--space-lg);
  font-family: var(--font-display);
  font-size: var(--step-4);
  font-weight: 400;
  line-height: 0.98;
  letter-spacing: -0.045em;
}

.hero-title em { font-weight: 400; }

.hero-lead {
  max-width: 720px;
  margin-bottom: var(--space-xl);
  font-family: var(--font-display);
  font-size: var(--step-1);
  line-height: 1.55;
  color: var(--muted);
}

.hero-tags {
  display: flex;
  flex-wrap: wrap;
  gap: var(--space-lg);
}

.hero-tags .tag {
  position: relative;
  padding-left: 1rem;
  font-family: var(--font-mono);
  font-size: var(--step--1);
  color: var(--muted);
}

.hero-tags .tag::before {
  content: '';
  position: absolute;
  left: 0;
  top: 0.65em;
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: color-mix(in oklab, var(--accent) 65%, transparent);
}

/* Homepage publication list */
.latest {
  padding: var(--space-xl) clamp(0rem, 3vw, 2rem) var(--space-2xl);
}

.section-title {
  display: flex;
  align-items: center;
  gap: var(--space-md);
  margin-bottom: var(--space-lg);
  font-family: var(--font-mono);
  font-size: var(--step--1);
  font-weight: 500;
  color: var(--muted);
  text-transform: uppercase;
  letter-spacing: 0.1em;
}

.section-title::after {
  content: '';
  height: 1px;
  flex: 1;
  background: var(--line-strong);
}

.article-list {
  border-top: 1px solid var(--line-strong);
}

.article-card {
  display: grid;
  grid-template-columns: 150px minmax(0, 1fr);
  gap: var(--space-lg);
  padding: var(--space-xl) 0;
  border-bottom: 1px solid var(--line-strong);
}

.article-card .article-meta {
  padding-right: var(--space-md);
  border-right: 1px solid var(--line);
}

.article-card .article-category,
.article-card .article-date {
  display: block;
  font-family: var(--font-mono);
  font-size: 0.78rem;
}

.article-card .article-category {
  margin-bottom: var(--space-xs);
  color: var(--accent);
  text-transform: uppercase;
  letter-spacing: 0.06em;
}

.article-card .article-date { color: var(--muted); }

.article-card .article-title {
  margin-bottom: var(--space-sm);
  font-family: var(--font-display);
  font-size: var(--step-2);
  font-weight: 600;
  line-height: 1.2;
  letter-spacing: -0.02em;
}

.article-card .article-title a {
  text-decoration-color: transparent;
  text-underline-offset: 0.16em;
  transition: color 0.2s ease, text-decoration-color 0.2s ease;
}

.article-card .article-title a:hover {
  color: var(--accent);
  text-decoration: underline;
  text-decoration-color: color-mix(in oklab, var(--accent) 45%, transparent);
}

.article-card .article-excerpt {
  max-width: var(--text-width);
  margin-bottom: var(--space-md);
  color: var(--muted);
  line-height: 1.65;
}

.article-card .read-more {
  font-family: var(--font-mono);
  font-size: 0.78rem;
  color: var(--accent);
  text-transform: uppercase;
  letter-spacing: 0.09em;
}

main.container { min-height: 55vh; }

@media (max-width: 820px) {
  .header-inner {
    grid-template-columns: 1fr auto;
    gap: var(--space-sm) var(--space-md);
    padding-block: var(--space-sm);
  }

  .header-inner > a:not(.logo) { justify-self: end; }

  .main-nav {
    grid-column: 1 / -1;
    justify-content: flex-start;
    flex-wrap: wrap;
    gap: var(--space-sm) var(--space-md);
  }

  .hero { min-height: 440px; }
}

@media (max-width: 640px) {
  .hero { min-height: 400px; padding-block: var(--space-xl); }
  .article-card { grid-template-columns: 1fr; gap: var(--space-md); }
  .article-card .article-meta {
    display: flex;
    align-items: center;
    gap: var(--space-sm);
    border-right: 0;
    padding-right: 0;
  }
  .article-card .article-category { margin-bottom: 0; }
}
/* === ACTA DESIGN COMPATIBILITY END === */
'@

$Updated = $Css + $Repair
[System.IO.File]::WriteAllText($CssPath, $Updated, $Utf8NoBom)
Write-Host 'Стили ACTA FRAGILIA восстановлены.' -ForegroundColor Green

function Replace-Slugs([string]$RelativePath, [hashtable]$Map) {
    $FullPath = Join-Path $ProjectRoot $RelativePath
    if (-not (Test-Path $FullPath)) { throw "Не найден $RelativePath" }
    $Content = [System.IO.File]::ReadAllText($FullPath)
    foreach ($Old in $Map.Keys) { $Content = $Content.Replace($Old, $Map[$Old]) }
    [System.IO.File]::WriteAllText($FullPath, $Content, $Utf8NoBom)
    Write-Host "Исправлены ссылки: $RelativePath" -ForegroundColor Green
}

Replace-Slugs 'src\pages\en\index.astro' @{
    "slug: 'bankrotstvo-kak-sistema'" = "slug: 'bankruptcy-as-a-system'"
    "slug: 'novye-religioznye-dvizheniya'" = "slug: 'new-religious-movements'"
    "slug: 'mediinyi-landshaft'" = "slug: 'media-landscape'"
}
Replace-Slugs 'src\pages\pl\index.astro' @{
    "slug: 'bankrotstvo-kak-sistema'" = "slug: 'upadlosc-jako-system'"
    "slug: 'novye-religioznye-dvizheniya'" = "slug: 'nowe-ruchy-religijne'"
    "slug: 'mediinyi-landshaft'" = "slug: 'pejzaz-medialny'"
}
Replace-Slugs 'src\pages\by\index.astro' @{
    "slug: 'bankrotstvo-kak-sistema'" = "slug: 'bankrotstva-yak-sistema'"
    "slug: 'novye-religioznye-dvizheniya'" = "slug: 'novyya-religijnyya-ruhi'"
    "slug: 'mediinyi-landshaft'" = "slug: 'medyjny-landshaft'"
}

Write-Host "`nЗапускаю проверочную сборку..." -ForegroundColor Cyan
& npm run build
if ($LASTEXITCODE -ne 0) {
    [System.IO.File]::WriteAllText($CssPath, $Original, $Utf8NoBom)
    throw 'Сборка завершилась с ошибкой. Исходный global.css восстановлен.'
}

& git add -- 'src/styles/global.css' 'src/pages/en/index.astro' 'src/pages/pl/index.astro' 'src/pages/by/index.astro'
if ($LASTEXITCODE -ne 0) { throw 'git add завершился с ошибкой.' }

& git commit -m 'Fix global styles and localized article links'
if ($LASTEXITCODE -ne 0) { throw 'git commit завершился с ошибкой.' }

& git push origin main
if ($LASTEXITCODE -ne 0) { throw 'git push завершился с ошибкой.' }

Write-Host "`nГотово: дизайн восстановлен, языковые ссылки исправлены, Open Graph сохранён." -ForegroundColor Green
