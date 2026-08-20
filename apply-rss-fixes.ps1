$ErrorActionPreference = 'Stop'

$PreferredProject = 'X:\Общая\1_Сайт\acta-fragilia-astro'
if (Test-Path (Join-Path $PreferredProject 'package.json')) {
    $ProjectRoot = $PreferredProject
} elseif (Test-Path (Join-Path $PSScriptRoot 'package.json')) {
    $ProjectRoot = $PSScriptRoot
} else {
    throw 'Не найдена папка проекта acta-fragilia-astro. Поместите этот файл в корень проекта и запустите снова.'
}

Set-Location $ProjectRoot
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Write-Utf8NoBom([string]$Path, [string]$Content) {
    $FullPath = Join-Path $ProjectRoot $Path
    $Directory = Split-Path $FullPath -Parent
    if (-not (Test-Path $Directory)) {
        New-Item -ItemType Directory -Path $Directory -Force | Out-Null
    }
    [System.IO.File]::WriteAllText($FullPath, $Content, $Utf8NoBom)
    Write-Host "Обновлён: $Path" -ForegroundColor Green
}

function Fix-Typos([string]$Path) {
    $FullPath = Join-Path $ProjectRoot $Path
    if (-not (Test-Path $FullPath)) {
        Write-Host "Пропущен отсутствующий файл: $Path" -ForegroundColor Yellow
        return
    }
    $Content = [System.IO.File]::ReadAllText($FullPath)
    $Updated = $Content.Replace('расследоваий', 'расследований').Replace('госудрственные', 'государственные')
    if ($Updated -ne $Content) {
        [System.IO.File]::WriteAllText($FullPath, $Updated, $Utf8NoBom)
        Write-Host "Исправлены опечатки: $Path" -ForegroundColor Green
    } else {
        Write-Host "Опечаток нет: $Path" -ForegroundColor DarkGray
    }
}

$EnFeed = @'
import rss from '@astrojs/rss';
import { getCollection } from 'astro:content';

export async function GET(context) {
  const articles = await getCollection('articlesEn');
  const sortedArticles = articles.sort(
    (a, b) => new Date(b.data.date).getTime() - new Date(a.data.date).getTime()
  );

  return rss({
    title: 'ACTA FRAGILIA — English',
    description: 'Independent journalism and analysis: law, economics, corporate conflicts and social processes.',
    site: context.site ?? 'https://acta-fragilia.pages.dev',
    customData: '<language>en</language>',
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
  const sortedArticles = articles.sort(
    (a, b) => new Date(b.data.date).getTime() - new Date(a.data.date).getTime()
  );

  return rss({
    title: 'ACTA FRAGILIA — Polski',
    description: 'Niezależne dziennikarstwo i analiza: prawo, gospodarka, konflikty korporacyjne i procesy społeczne.',
    site: context.site ?? 'https://acta-fragilia.pages.dev',
    customData: '<language>pl</language>',
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
  const sortedArticles = articles.sort(
    (a, b) => new Date(b.data.date).getTime() - new Date(a.data.date).getTime()
  );

  return rss({
    title: 'ACTA FRAGILIA — Беларуская',
    description: 'Незалежная журналістыка і аналіз: права, эканоміка, карпаратыўныя канфлікты і грамадскія працэсы.',
    site: context.site ?? 'https://acta-fragilia.pages.dev',
    customData: '<language>be</language>',
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

Write-Utf8NoBom 'src\pages\en\rss.xml.js' $EnFeed
Write-Utf8NoBom 'src\pages\pl\rss.xml.js' $PlFeed
Write-Utf8NoBom 'src\pages\by\rss.xml.js' $ByFeed

Fix-Typos 'src\pages\rss.xml.js'
Fix-Typos 'src\content\articles\bankrotstvo-kak-sistema.md'

$BasePath = Join-Path $ProjectRoot 'src\layouts\Base.astro'
if (-not (Test-Path $BasePath)) {
    throw 'Не найден src\layouts\Base.astro'
}

$Base = [System.IO.File]::ReadAllText($BasePath)
$Base = $Base.Replace('href="/rss.xml"', 'href={`${prefix}/rss.xml`}')
$Base = $Base.Replace("href='/rss.xml'", 'href={`${prefix}/rss.xml`}')

if (($Base -notmatch 'rel=["'']alternate["'']') -or ($Base -notmatch 'application/rss\+xml')) {
    $AutoDiscovery = @'
  <link
    rel="alternate"
    type="application/rss+xml"
    title="ACTA FRAGILIA RSS"
    href={`${prefix}/rss.xml`}
  />
'@
    if ($Base -notmatch '</head>') {
        throw 'В Base.astro не найден закрывающий тег </head>.'
    }
    $Base = $Base.Replace('</head>', $AutoDiscovery + '</head>')
}

[System.IO.File]::WriteAllText($BasePath, $Base, $Utf8NoBom)
Write-Host 'Обновлён: src\layouts\Base.astro' -ForegroundColor Green

Write-Host "`nЗапускаю проверочную сборку..." -ForegroundColor Cyan
& npm run build
if ($LASTEXITCODE -ne 0) {
    throw 'Сборка завершилась с ошибкой. Изменения не отправлены.'
}

Write-Host "`nДобавляю изменения в Git..." -ForegroundColor Cyan
& git add -- 'src/pages/en/rss.xml.js' 'src/pages/pl/rss.xml.js' 'src/pages/by/rss.xml.js' 'src/pages/rss.xml.js' 'src/content/articles/bankrotstvo-kak-sistema.md' 'src/layouts/Base.astro'
if ($LASTEXITCODE -ne 0) { throw 'git add завершился с ошибкой.' }

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
