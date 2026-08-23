#requires -Version 7
#requires -PSEdition Core

<#
.SYNOPSIS
    Создаёт локализованные RSS-ленты EN/PL/BY, исправляет опечатки,
    добавляет RSS autodiscovery в Base.astro и отправляет изменения в Git.

.DESCRIPTION
    Исправления по сравнению с оригиналом:
    - customData в RSS теперь валидный XML (<language>…</language>)
    - RSS autodiscovery: исправлен пустой тег, добавлены все языки
    - Fix-Typos: замена только в frontmatter (title/description), не в body
    - Добавлена валидация дат перед сортировкой статей
    - Пути через Join-Path (кросс-платформенность)
    - git add только существующих файлов
    - LASTEXITCODE проверяется корректно (без ложных exit)
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
    throw 'Не найдена папка проекта acta-fragilia-astro. Поместите скрипт в корень проекта и запустите снова.'
}

Set-Location $ProjectRoot
$Utf8NoBom = [System.Text.UTF8Encoding]::new($false)

# ── Вспомогательные функции ──────────────────────────────────────────────────
function Write-Utf8NoBom {
    param(
        [Parameter(Mandatory)]
        [string]$RelativePath,

        [Parameter(Mandatory)]
        [string]$Content
    )

    $FullPath = Join-Path $ProjectRoot $RelativePath
    $Directory = Split-Path $FullPath -Parent
    if (-not (Test-Path $Directory)) {
        New-Item -ItemType Directory -Path $Directory -Force | Out-Null
    }
    [System.IO.File]::WriteAllText($FullPath, $Content, $Utf8NoBom)
    Write-Host "Создано/обновлено: $RelativePath" -ForegroundColor Green
}

function Test-GitFileExists {
    param([string]$RelativePath)
    return Test-Path (Join-Path $ProjectRoot $RelativePath)
}

function Fix-Typos {
    param([string]$RelativePath)

    $FullPath = Join-Path $ProjectRoot $RelativePath
    if (-not (Test-Path $FullPath)) {
        Write-Host "Пропущен (отсутствует): $RelativePath" -ForegroundColor Yellow
        return
    }

    $Content = [System.IO.File]::ReadAllText($FullPath)

    # Замена только внутри frontmatter (между --- … ---) — не трогаем тело статьи
    if ($Content -match '^(---\s*\r?\n)([\s\S]*?)(\r?\n---)') {
        $frontmatter = $Matches[2]
        $updatedFm = $frontmatter
            .Replace('расследоваий', 'раследований')
            .Replace('госудрственные', 'государственные')

        if ($updatedFm -ne $frontmatter) {
            $Content = $Content.Replace($Matches[0], $Matches[1] + $updatedFm + $Matches[3])
            [System.IO.File]::WriteAllText($FullPath, $Content, $Utf8NoBom)
            Write-Host "Исправлены опечатки в frontmatter: $RelativePath" -ForegroundColor Green
        }
        else {
            Write-Host "Опечаток в frontmatter нет: $RelativePath" -ForegroundColor DarkGray
        }
    }
    else {
        # Нет frontmatter — заменяем весь файл, но предупреждаем
        $Updated = $Content
            .Replace('расследоваий', 'расследований')
            .Replace('госудрственные', 'государственные')

        if ($Updated -ne $Content) {
            [System.IO.File]::WriteAllText($FullPath, $Updated, $Utf8NoBom)
            Write-Host "Исправлены опечатки (без frontmatter): $RelativePath" -ForegroundColor Yellow
        }
        else {
            Write-Host "Опечаток нет: $RelativePath" -ForegroundColor DarkGray
        }
    }
}

# ── Шаблоны RSS-лент (валидный customData) ──────────────────────────────────
$EnFeed = @'
import rss from '@astrojs/rss';
import { getCollection } from 'astro:content';

export async function GET(context) {
  const articles = await getCollection('articlesEn');

  const sortedArticles = articles
    .filter((a) => {
      const d = new Date(a.data.date);
      return a.data.date && !Number.isNaN(d.getTime());
    })
    .sort((a, b) => new Date(b.data.date).getTime() - new Date(a.data.date).getTime());

  return rss({
    title: 'ACTA FRAGILIA — English',
    description: 'Independent journalism and analysis: law, economics, corporate conflicts and social processes.',
    site: context.site ?? 'https://acta-fragilia.pages.dev',
    customData: `<language>en</language>`,
    items: sortedArticles.map((article) => ({
      title: article.data.title,
      description: article.data.subtitle,
      pubDate: new Date(article.data.date),
      link: `/en/article/${article.slug}/`,
      ...(article.data.author ? { author: article.data.author } : {}),
    })),
  });
}
'@

$PlFeed = @'
import rss from '@astrojs/rss';
import { getCollection } from 'astro:content';

export async function GET(context) {
  const articles = await getCollection('articlesPl');

  const sortedArticles = articles
    .filter((a) => {
      const d = new Date(a.data.date);
      return a.data.date && !Number.isNaN(d.getTime());
    })
    .sort((a, b) => new Date(b.data.date).getTime() - new Date(a.data.date).getTime());

  return rss({
    title: 'ACTA FRAGILIA — Polski',
    description: 'Niezależne dziennikarstwo i analiza: prawo, gospodarka, konflikty korporacyjne i procesy społeczne.',
    site: context.site ?? 'https://acta-fragilia.pages.dev',
    customData: `<language>pl</language>`,
    items: sortedArticles.map((article) => ({
      title: article.data.title,
      description: article.data.subtitle,
      pubDate: new Date(article.data.date),
      link: `/pl/article/${article.slug}/`,
      ...(article.data.author ? { author: article.data.author } : {}),
    })),
  });
}
'@

$ByFeed = @'
import rss from '@astrojs/rss';
import { getCollection } from 'astro:content';

export async function GET(context) {
  const articles = await getCollection('articlesBy');

  const sortedArticles = articles
    .filter((a) => {
      const d = new Date(a.data.date);
      return a.data.date && !Number.isNaN(d.getTime());
    })
    .sort((a, b) => new Date(b.data.date).getTime() - new Date(a.data.date).getTime());

  return rss({
    title: 'ACTA FRAGILIA — Беларуская',
    description: 'Незалежная журналістыка і аналіз: права, эканоміка, карпаратыўныя канфлікты і грамадскія працэсы.',
    site: context.site ?? 'https://acta-fragilia.pages.dev',
    customData: `<language>be</language>`,
    items: sortedArticles.map((article) => ({
      title: article.data.title,
      description: article.data.subtitle,
      pubDate: new Date(article.data.date),
      link: `/by/article/${article.slug}/`,
      ...(article.data.author ? { author: article.data.author } : {}),
    })),
  });
}
'@

# ── Запись RSS-файлов ────────────────────────────────────────────────────────
Write-Utf8NoBom -RelativePath (Join-Path 'src' 'pages' 'en' 'rss.xml.js') -Content $EnFeed
Write-Utf8NoBom -RelativePath (Join-Path 'src' 'pages' 'pl' 'rss.xml.js') -Content $PlFeed
Write-Utf8NoBom -RelativePath (Join-Path 'src' 'pages' 'by' 'rss.xml.js') -Content $ByFeed

# ── Исправление опечаток ─────────────────────────────────────────────────────
Fix-Typos -RelativePath (Join-Path 'src' 'pages' 'rss.xml.js')
Fix-Typos -RelativePath (Join-Path 'src' 'content' 'articles' 'bankrotstvo-kak-sistema.md')

# ── Обновление Base.astro: RSS autodiscovery ─────────────────────────────────
$BasePath = Join-Path $ProjectRoot 'src' 'layouts' 'Base.astro'
if (-not (Test-Path $BasePath)) {
    throw 'Не найден src/layouts/Base.astro'
}

$Base = [System.IO.File]::ReadAllText($BasePath)

# 1. Исправляем href RSS (был жёсткий /rss.xml → динамический с префиксом)
$Base = $Base.Replace('href="/rss.xml"', 'href={`${prefix}/rss.xml`}')
$Base = $Base.Replace("href='/rss.xml'", 'href={`${prefix}/rss.xml`}')

# 2. Добавляем autodiscovery для всех языков (если ещё нет)
$hasAutodiscovery = ($Base -match 'rel=["'']alternate["'']') -and ($Base -match 'application/rss\+xml')

if (-not $hasAutodiscovery) {
    $AutoDiscovery = @'

  <!-- RSS autodiscovery -->
  <link rel="alternate" type="application/rss+xml" title={`RSS ${lang.toUpperCase()}`} href={`${prefix}/rss.xml`} />

'@

    # Безопасная вставка: ищем </head>, если нет — перед первым <body>
    if ($Base -match '</head>') {
        $Base = $Base.Replace('</head>', $AutoDiscovery + '</head>')
    }
    elseif ($Base -match '<body') {
        $Base = $Base -replace '(<body[^>]*>)', "`$1`r`n$AutoDiscovery"
    }
    else {
        throw 'В Base.astro не найден закрывающий </head> или открывающий <body>.'
    }

    Write-Host 'Добавлен RSS autodiscovery в Base.astro' -ForegroundColor Green
}
else {
    Write-Host 'RSS autodiscovery уже присутствует в Base.astro' -ForegroundColor DarkGray
}

[System.IO.File]::WriteAllText($BasePath, $Base, $Utf8NoBom)
Write-Host 'Обновлён: src/layouts/Base.astro' -ForegroundColor Green

# ── Сборка ─────────────────────────────────────────────────────────────────
Write-Host "`nЗапускаю проверочную сборку..." -ForegroundColor Cyan
& npm run build
if ($LASTEXITCODE -ne 0) {
    throw 'Сборка завершилась с ошибкой. Изменения не отправлены.'
}

# ── Git: добавляем только существующие файлы ─────────────────────────────────
Write-Host "`nДобавляю изменения в Git..." -ForegroundColor Cyan

$gitFiles = @(
    (Join-Path 'src' 'pages' 'en' 'rss.xml.js'),
    (Join-Path 'src' 'pages' 'pl' 'rss.xml.js'),
    (Join-Path 'src' 'pages' 'by' 'rss.xml.js'),
    (Join-Path 'src' 'pages' 'rss.xml.js'),
    (Join-Path 'src' 'content' 'articles' 'bankrotstvo-kak-sistema.md'),
    (Join-Path 'src' 'layouts' 'Base.astro')
) | Where-Object { Test-GitFileExists $_ }

if ($gitFiles.Count -eq 0) {
    Write-Host 'Нет файлов для добавления в Git.' -ForegroundColor Yellow
    exit 0
}

& git add -- $gitFiles
if ($LASTEXITCODE -ne 0) { throw 'git add завершился с ошибкой.' }

# Проверяем, есть ли staged зменения
& git diff --cached --quiet
if ($LASTEXITCODE -eq 0) {
    Write-Host 'Все исправления уже присутствуют. Новый коммит не требуется.' -ForegroundColor Yellow
    exit 0
}

& git commit -m 'Add localized RSS feeds and fix RSS metadata'
if ($LASTEXITCODE -ne 0) { throw 'git commit завершился с ошибкой.' }

& git push origin main
if ($LASTEXITCODE -ne 0) { throw 'git push завершился с ошибкой.' }

Write-Host "`nГотово: RSS EN/PL/BY обновлены, опечатки исправлены, autodiscovery добавлен, изменения отправлены в GitHub." -ForegroundColor Green
