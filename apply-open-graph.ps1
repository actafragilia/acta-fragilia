$ErrorActionPreference = 'Stop'

$PreferredProject = 'X:\Общая\1_Сайт\acta-fragilia-astro'
if (Test-Path (Join-Path $PreferredProject 'package.json')) {
    $ProjectRoot = $PreferredProject
} elseif (Test-Path (Join-Path $PSScriptRoot 'package.json')) {
    $ProjectRoot = $PSScriptRoot
} else {
    throw 'Не найдена папка проекта acta-fragilia-astro. Поместите скрипт в корень проекта и запустите снова.'
}

Set-Location $ProjectRoot
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
Add-Type -AssemblyName System.Drawing

function Write-Utf8NoBom([string]$Path, [string]$Content) {
    [System.IO.File]::WriteAllText($Path, $Content, $Utf8NoBom)
}

function Get-FrontmatterValue([string]$Content, [string]$Name) {
    $Pattern = '(?m)^' + [regex]::Escape($Name) + ':\s*(.+?)\s*$'
    $Match = [regex]::Match($Content, $Pattern)
    if (-not $Match.Success) { return '' }
    $Value = $Match.Groups[1].Value.Trim()
    if (($Value.StartsWith('"') -and $Value.EndsWith('"')) -or ($Value.StartsWith("'") -and $Value.EndsWith("'"))) {
        $Value = $Value.Substring(1, $Value.Length - 2)
    }
    return $Value
}

function New-OgImage {
    param(
        [Parameter(Mandatory=$true)][string]$OutputPath,
        [Parameter(Mandatory=$true)][string]$Title,
        [string]$Category = '',
        [string]$Language = '',
        [switch]$Default
    )

    $Directory = Split-Path $OutputPath -Parent
    if (-not (Test-Path $Directory)) {
        New-Item -ItemType Directory -Path $Directory -Force | Out-Null
    }

    $Bitmap = [System.Drawing.Bitmap]::new(1200, 630)
    $Graphics = [System.Drawing.Graphics]::FromImage($Bitmap)
    $Graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $Graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $Graphics.Clear([System.Drawing.ColorTranslator]::FromHtml('#F3F0E9'))

    $GridPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(28, 91, 82, 73), 1)
    for ($X = 40; $X -le 1160; $X += 80) { $Graphics.DrawLine($GridPen, $X, 0, $X, 630) }
    for ($Y = 40; $Y -le 600; $Y += 80) { $Graphics.DrawLine($GridPen, 0, $Y, 1200, $Y) }

    $DiagonalPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(22, 155, 74, 74), 1)
    $Graphics.DrawLine($DiagonalPen, 0, 80, 1200, 570)
    $Graphics.DrawLine($DiagonalPen, 0, 570, 1200, 80)

    $TextBrush = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml('#171614'))
    $MutedBrush = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml('#726B62'))
    $AccentBrush = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml('#A34840'))
    $PanelBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(222, 243, 240, 233))
    $Graphics.FillRectangle($PanelBrush, 55, 45, 1090, 540)

    $LogoFont = [System.Drawing.Font]::new('Georgia', 28, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
    $MetaFont = [System.Drawing.Font]::new('Consolas', 20, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
    $SmallFont = [System.Drawing.Font]::new('Consolas', 17, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)

    $Graphics.FillEllipse($AccentBrush, 82, 79, 10, 10)
    $Graphics.DrawString('ACTA FRAGILIA', $LogoFont, $TextBrush, 105, 67)
    $Graphics.DrawString($Language.ToUpperInvariant(), $SmallFont, $MutedBrush, 965, 76)

    if ($Default) {
        $TitleFont = [System.Drawing.Font]::new('Georgia', 78, [System.Drawing.FontStyle]::Italic, [System.Drawing.GraphicsUnit]::Pixel)
        $SubtitleFont = [System.Drawing.Font]::new('Georgia', 30, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
        $Graphics.DrawString('ACTA FRAGILIA', $TitleFont, $TextBrush, [System.Drawing.RectangleF]::new(80, 190, 1040, 110))
        $Graphics.DrawString('Независимая журналистика и анализ', $SubtitleFont, $MutedBrush, [System.Drawing.RectangleF]::new(84, 330, 1000, 70))
        $Graphics.DrawString('ПРАВО  ·  ЭКОНОМИКА  ·  ОБЩЕСТВО  ·  МЕДИА', $MetaFont, $AccentBrush, 84, 455)
    } else {
        if ($Category) { $Graphics.DrawString($Category.ToUpperInvariant(), $MetaFont, $AccentBrush, 82, 132) }

        $FontSize = 52
        if ($Title.Length -gt 82) { $FontSize = 45 }
        elseif ($Title.Length -gt 58) { $FontSize = 48 }
        $TitleFont = [System.Drawing.Font]::new('Georgia', $FontSize, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
        $Format = [System.Drawing.StringFormat]::new()
        $Format.Trimming = [System.Drawing.StringTrimming]::EllipsisWord
        $Format.FormatFlags = [System.Drawing.StringFormatFlags]::LineLimit
        $Graphics.DrawString($Title, $TitleFont, $TextBrush, [System.Drawing.RectangleF]::new(80, 185, 1040, 300), $Format)
        $Graphics.DrawString('acta-fragilia.pages.dev', $SmallFont, $MutedBrush, 82, 530)
        $Format.Dispose()
        $TitleFont.Dispose()
    }

    $Bitmap.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)

    $LogoFont.Dispose(); $MetaFont.Dispose(); $SmallFont.Dispose()
    if ($Default) { $TitleFont.Dispose(); $SubtitleFont.Dispose() }
    $GridPen.Dispose(); $DiagonalPen.Dispose()
    $TextBrush.Dispose(); $MutedBrush.Dispose(); $AccentBrush.Dispose(); $PanelBrush.Dispose()
    $Graphics.Dispose(); $Bitmap.Dispose()
    Write-Host "Создано изображение: $OutputPath" -ForegroundColor Green
}

Write-Host 'Создаю Open Graph изображения 1200 × 630...' -ForegroundColor Cyan
$OgRoot = Join-Path $ProjectRoot 'public\og'
New-OgImage -OutputPath (Join-Path $OgRoot 'default.png') -Title 'ACTA FRAGILIA' -Language 'RU · EN · PL · BY' -Default

$Collections = @(
    @{ Folder = 'src\content\articles';   Lang = 'ru'; Label = 'RU' },
    @{ Folder = 'src\content\articlesEn'; Lang = 'en'; Label = 'EN' },
    @{ Folder = 'src\content\articlesPl'; Lang = 'pl'; Label = 'PL' },
    @{ Folder = 'src\content\articlesBy'; Lang = 'by'; Label = 'BY' }
)

foreach ($Collection in $Collections) {
    $Folder = Join-Path $ProjectRoot $Collection.Folder
    if (-not (Test-Path $Folder)) { throw "Не найдена коллекция: $($Collection.Folder)" }
    foreach ($File in Get-ChildItem $Folder -Filter '*.md' -File) {
        $Markdown = [System.IO.File]::ReadAllText($File.FullName)
        $Title = Get-FrontmatterValue $Markdown 'title'
        $Category = Get-FrontmatterValue $Markdown 'category'
        if (-not $Title) { throw "Не найден title в $($File.FullName)" }
        $Slug = [System.IO.Path]::GetFileNameWithoutExtension($File.Name)
        $Target = Join-Path (Join-Path $OgRoot $Collection.Lang) ($Slug + '.png')
        New-OgImage -OutputPath $Target -Title $Title -Category $Category -Language $Collection.Label
    }
}

$BasePath = Join-Path $ProjectRoot 'src\layouts\Base.astro'
$ArticlePath = Join-Path $ProjectRoot 'src\layouts\ArticleLayout.astro'
if (-not (Test-Path $BasePath)) { throw 'Не найден src\layouts\Base.astro' }
if (-not (Test-Path $ArticlePath)) { throw 'Не найден src\layouts\ArticleLayout.astro' }
$OriginalBase = [System.IO.File]::ReadAllText($BasePath)
$OriginalArticle = [System.IO.File]::ReadAllText($ArticlePath)

$NewBase = @'
---
import "../styles/global.css";
import LanguageSwitcher from '../components/LanguageSwitcher.astro';

export interface Props {
  title: string;
  lang?: string;
  description?: string;
  image?: string;
  type?: 'website' | 'article';
  publishedTime?: Date | string;
  author?: string;
  section?: string;
  canonical?: string;
}

const {
  title,
  lang = 'ru',
  description,
  image = '/og/default.png',
  type = 'website',
  publishedTime,
  author,
  section,
  canonical,
} = Astro.props;

const nav = {
  ru: { materials: 'Материалы', about: 'О проекте', contacts: 'Контакты', archive: 'Архив' },
  en: { materials: 'Materials', about: 'About', contacts: 'Contacts', archive: 'Archive' },
  pl: { materials: 'Materiały', about: 'O projekcie', contacts: 'Kontakt', archive: 'Archiwum' },
  by: { materials: 'Матэрыялы', about: 'Пра праект', contacts: 'Кантакты', archive: 'Архіў' },
};

const footer = {
  ru: { privacy: 'Политика конфиденциальности', rights: 'Независимая журналистика' },
  en: { privacy: 'Privacy Policy', rights: 'Independent Journalism' },
  pl: { privacy: 'Polityka prywatności', rights: 'Niezależne dziennikarstwo' },
  by: { privacy: 'Палітыка прыватнасці', rights: 'Незалежная журналістыка' },
};

const defaultDescriptions: Record<string, string> = {
  ru: 'Независимая журналистика и анализ: право, экономика, корпоративные конфликты и общественные процессы.',
  en: 'Independent journalism and analysis: law, economics, corporate conflicts and social processes.',
  pl: 'Niezależne dziennikarstwo i analiza: prawo, gospodarka, konflikty korporacyjne i procesy społeczne.',
  by: 'Незалежная журналістыка і аналіз: права, эканоміка, карпаратыўныя канфлікты і грамадскія працэсы.',
};

const locales: Record<string, string> = {
  ru: 'ru_RU',
  en: 'en_US',
  pl: 'pl_PL',
  by: 'be_BY',
};

const t = nav[lang] || nav.ru;
const f = footer[lang] || footer.ru;
const prefix = lang === 'ru' ? '' : `/${lang}`;
const htmlLang = lang === 'by' ? 'be' : lang;
const metaDescription = description || defaultDescriptions[lang] || defaultDescriptions.ru;
const siteUrl = Astro.site ?? new URL('https://acta-fragilia.pages.dev');
const canonicalUrl = new URL(canonical || Astro.url.pathname, siteUrl).toString();
const imageUrl = new URL(image, siteUrl).toString();
const publishedIso = publishedTime ? new Date(publishedTime).toISOString() : undefined;
const currentLocale = locales[lang] || locales.ru;
const alternateLocales = Object.values(locales).filter((locale) => locale !== currentLocale);
---
<!DOCTYPE html>
<html lang={htmlLang} prefix="og: https://ogp.me/ns# article: https://ogp.me/ns/article#">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>{title}</title>
  <meta name="description" content={metaDescription} />
  {author && <meta name="author" content={author} />}
  <link rel="canonical" href={canonicalUrl} />

  <meta property="og:site_name" content="ACTA FRAGILIA" />
  <meta property="og:title" content={title} />
  <meta property="og:description" content={metaDescription} />
  <meta property="og:type" content={type} />
  <meta property="og:url" content={canonicalUrl} />
  <meta property="og:locale" content={currentLocale} />
  {alternateLocales.map((locale) => <meta property="og:locale:alternate" content={locale} />)}
  <meta property="og:image" content={imageUrl} />
  <meta property="og:image:secure_url" content={imageUrl} />
  <meta property="og:image:type" content="image/png" />
  <meta property="og:image:width" content="1200" />
  <meta property="og:image:height" content="630" />
  <meta property="og:image:alt" content={title} />
  {type === 'article' && publishedIso && <meta property="article:published_time" content={publishedIso} />}
  {type === 'article' && section && <meta property="article:section" content={section} />}

  <meta name="twitter:card" content="summary_large_image" />
  <meta name="twitter:title" content={title} />
  <meta name="twitter:description" content={metaDescription} />
  <meta name="twitter:image" content={imageUrl} />
  <meta name="twitter:image:alt" content={title} />

  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500&family=Inter:wght@400;500;600&family=Source+Serif+4:ital,opsz,wght@0,8..60,400;0,8..60,600;0,8..60,700;1,8..60,400&display=swap" rel="stylesheet">
  <link
    rel="alternate"
    type="application/rss+xml"
    title="ACTA FRAGILIA RSS"
    href={`${prefix}/rss.xml`}
  />
</head>
<body>
  <header class="site-header">
    <div class="container header-inner">
      <a href={`${prefix}/`} class="logo" aria-label="ACTA FRAGILIA">
        <span class="logo-mark" aria-hidden="true"></span>
        <span class="logo-text">ACTA FRAGILIA</span>
      </a>
      <a href={`${prefix}/archive`}>{t.archive}</a>
      <nav class="main-nav" aria-label="Main navigation">
        <a href={`${prefix}/`}>{t.materials}</a>
        <a href={`${prefix}/about`}>{t.about}</a>
        <a href={`${prefix}/contacts`}>{t.contacts}</a>
        <LanguageSwitcher currentLang={lang} />
      </nav>
    </div>
  </header>
  <main class="container">
    <slot />
  </main>
  <footer class="site-footer">
    <div class="container footer-inner">
      <div class="footer-brand">ACTA FRAGILIA</div>
      <div class="footer-links">
        <a href="mailto:info@acta-fragilia.pages.dev">info@acta-fragilia.pages.dev</a>
        <a href={`${prefix}/rss.xml`}>RSS</a>
        <a href={`${prefix}/privacy`}>{f.privacy}</a>
      </div>
      <div class="footer-copy">
        © 2026 ACTA FRAGILIA. {f.rights}.
      </div>
    </div>
  </footer>
</body>
</html>
'@

$NewArticle = $OriginalArticle
if ($NewArticle -notmatch 'const ogImage') {
    $OgLine = @'
const ogImage = `/og/${lang}/${article.slug}.png`;
'@
    $NewArticle = $NewArticle.Replace(
        "const { title, lang, article } = Astro.props;",
        "const { title, lang, article } = Astro.props;`r`n" + $OgLine.Trim()
    )
}

$OldBaseTag = '<Base title={title} lang={lang}>'
$NewBaseTag = @'
<Base
  title={title}
  lang={lang}
  description={article.data.subtitle}
  image={ogImage}
  type="article"
  publishedTime={article.data.date}
  author={article.data.author}
  section={article.data.category}
>
'@
if ($NewArticle.Contains($OldBaseTag)) {
    $NewArticle = $NewArticle.Replace($OldBaseTag, $NewBaseTag.TrimEnd())
} elseif ($NewArticle -notmatch 'image=\{ogImage\}') {
    throw 'Не удалось автоматически обновить вызов Base в ArticleLayout.astro.'
}

Write-Utf8NoBom $BasePath $NewBase
Write-Utf8NoBom $ArticlePath $NewArticle
Write-Host 'Обновлены Base.astro и ArticleLayout.astro.' -ForegroundColor Green

Write-Host "`nЗапускаю проверочную сборку..." -ForegroundColor Cyan
& npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Utf8NoBom $BasePath $OriginalBase
    Write-Utf8NoBom $ArticlePath $OriginalArticle
    throw 'Сборка завершилась с ошибкой. Base.astro и ArticleLayout.astro восстановлены; изменения не отправлены.'
}

Write-Host "`nДобавляю Open Graph в Git..." -ForegroundColor Cyan
& git add -- 'src/layouts/Base.astro' 'src/layouts/ArticleLayout.astro' 'public/og'
if ($LASTEXITCODE -ne 0) { throw 'git add завершился с ошибкой.' }

& git diff --cached --quiet
if ($LASTEXITCODE -eq 0) {
    Write-Host 'Open Graph уже настроен, новый коммит не требуется.' -ForegroundColor Yellow
    exit 0
}

& git commit -m 'Add Open Graph and social preview images'
if ($LASTEXITCODE -ne 0) { throw 'git commit завершился с ошибкой.' }

& git push origin main
if ($LASTEXITCODE -ne 0) { throw 'git push завершился с ошибкой.' }

Write-Host "`nГотово: Open Graph, Twitter Cards и 13 изображений добавлены; изменения отправлены в GitHub." -ForegroundColor Green
