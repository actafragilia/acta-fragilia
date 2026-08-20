$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$PreferredProject = 'X:\Общая\1_Сайт\acta-fragilia-astro'
if (Test-Path (Join-Path $PreferredProject 'package.json')) {
    $ProjectRoot = $PreferredProject
} elseif (Test-Path (Join-Path $PSScriptRoot 'package.json')) {
    $ProjectRoot = $PSScriptRoot
} elseif ((Test-Path (Join-Path (Get-Location) 'package.json')) -and (Test-Path (Join-Path (Get-Location) '.git'))) {
    $ProjectRoot = (Get-Location).Path
} else {
    throw 'Не найдена папка проекта acta-fragilia-astro. Поместите сценарий в корень проекта или проверьте путь X:\Общая\1_Сайт\acta-fragilia-astro.'
}

Set-Location $ProjectRoot
Write-Host "Проект: $ProjectRoot" -ForegroundColor Cyan

if (-not (Test-Path '.git')) { throw 'В папке проекта не найден Git-репозиторий.' }
if (-not (Get-Command node -ErrorAction SilentlyContinue)) { throw 'Не найден Node.js (команда node).' }
if (-not (Get-Command npm -ErrorAction SilentlyContinue)) { throw 'Не найден npm.' }
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw 'Не найден Git.' }

$Branch = (& git branch --show-current).Trim()
if ($LASTEXITCODE -ne 0) { throw 'Не удалось определить текущую ветку Git.' }
if ($Branch -ne 'main') { throw "Ожидалась ветка main, но активна ветка '$Branch'. Переключитесь на main и запустите сценарий снова." }

$TargetFiles = @(
    'src/components/LanguageSwitcher.astro',
    'src/pages/index.astro',
    'src/pages/en/index.astro',
    'src/pages/pl/index.astro',
    'src/pages/by/index.astro',
    'src/pages/en/privacy.astro',
    'src/pages/pl/privacy.astro',
    'src/pages/by/privacy.astro',
    'src/pages/404.astro',
    'src/pages/en/404.astro',
    'src/pages/pl/404.astro',
    'src/pages/by/404.astro',
    'src/pages/en/contacts.astro',
    'src/pages/pl/contacts.astro',
    'src/pages/by/contacts.astro',
    'src/pages/by/about.astro',
    'src/content/articlesBy/bankrotstva-yak-sistema.md',
    'src/content/articlesBy/medyjny-landshaft.md',
    'src/content/articlesBy/novyya-religijnyya-ruhi.md',
    'src/content/articlesPl/nowe-ruchy-religijne.md'
)

$ApplyScript = @'
import fs from 'node:fs';
import path from 'node:path';

const root = process.cwd();
const changed = [];
const warnings = [];

function full(rel) {
  return path.join(root, ...rel.split('/'));
}

function read(rel) {
  const file = full(rel);
  if (!fs.existsSync(file)) throw new Error(`Не найден файл: ${rel}`);
  return fs.readFileSync(file, 'utf8').replace(/^\uFEFF/, '');
}

function write(rel, content) {
  const file = full(rel);
  fs.mkdirSync(path.dirname(file), { recursive: true });
  const normalized = content.replace(/\r\n/g, '\n').replace(/\r/g, '\n');
  const old = fs.existsSync(file) ? fs.readFileSync(file, 'utf8').replace(/^\uFEFF/, '').replace(/\r\n/g, '\n').replace(/\r/g, '\n') : null;
  if (old !== normalized) {
    fs.writeFileSync(file, normalized, 'utf8');
    changed.push(rel);
  }
}

function patch(rel, replacements) {
  let text = read(rel);
  const before = text;
  for (const [from, to, label] of replacements) {
    if (text.includes(from)) {
      text = text.split(from).join(to);
    } else if (!text.includes(to)) {
      warnings.push(`${rel}: не найден фрагмент «${label || from.slice(0, 80)}»`);
    }
  }
  if (text !== before) write(rel, text);
}

const switcher = `---
export interface Props {
  currentLang?: string;
}

type LangCode = 'ru' | 'en' | 'pl' | 'by';
type ArticleSlugs = Record<LangCode, string>;

const { currentLang = 'ru' } = Astro.props;

const languages: Array<{ code: LangCode; label: string }> = [
  { code: 'ru', label: 'RU' },
  { code: 'en', label: 'EN' },
  { code: 'pl', label: 'PL' },
  { code: 'by', label: 'BY' },
];

// Соответствие переводов одной и той же статьи во всех языковых версиях.
const articleSlugGroups: ArticleSlugs[] = [
  {
    ru: 'bankrotstvo-kak-sistema',
    en: 'bankruptcy-as-a-system',
    pl: 'upadlosc-jako-system',
    by: 'bankrotstva-yak-sistema',
  },
  {
    ru: 'novye-religioznye-dvizheniya',
    en: 'new-religious-movements',
    pl: 'nowe-ruchy-religijne',
    by: 'novyya-religijnyya-ruhi',
  },
  {
    ru: 'mediinyi-landshaft',
    en: 'media-landscape',
    pl: 'pejzaz-medialny',
    by: 'medyjny-landshaft',
  },
];

// При статической сборке главная языковая страница может иметь путь /en,
// /pl или /by без завершающего слэша. Поэтому префикс удаляется и перед
// слэшем, и в конце строки.
const normalizedPath = Astro.url.pathname.replace(/\\/+$/, '') || '/';
const pathWithoutLanguage = normalizedPath.replace(/^\\/(en|pl|by)(?=\\/|$)/, '') || '/';

function addLanguagePrefix(langCode: LangCode, cleanPath: string) {
  const safePath = cleanPath.startsWith('/') ? cleanPath : \`/\${cleanPath}\`;
  if (langCode === 'ru') return safePath;
  return safePath === '/' ? \`/\${langCode}/\` : \`/\${langCode}\${safePath}\`;
}

function getLangPath(langCode: LangCode) {
  let translatedPath = pathWithoutLanguage;
  const articleMatch = translatedPath.match(/^\\/article\\/([^/]+)$/);

  if (articleMatch) {
    const currentSlug = articleMatch[1];
    const group = articleSlugGroups.find((slugs) => Object.values(slugs).includes(currentSlug));
    if (group) translatedPath = \`/article/\${group[langCode]}\`;
  }

  return addLanguagePrefix(langCode, translatedPath);
}
---
<div class="language-switcher" aria-label="Переключатель языка">
  {languages.map((lang, index) => (
    <>
      <a
        href={getLangPath(lang.code)}
        class={currentLang === lang.code ? 'active' : ''}
        aria-current={currentLang === lang.code ? 'page' : undefined}
        hreflang={lang.code === 'by' ? 'be' : lang.code}
      >
        {lang.label}
      </a>
      {index < languages.length - 1 && <span class="lang-separator">·</span>}
    </>
  ))}
</div>
<style>
  .language-switcher {
    display: flex;
    align-items: center;
    gap: 0.35rem;
    font-family: 'IBM Plex Mono', monospace;
    font-size: 0.75rem;
    letter-spacing: 0.05em;
  }
  .language-switcher a {
    color: var(--color-text-secondary);
    text-decoration: none;
    padding: 0.2rem 0.4rem;
    border-radius: 3px;
    transition: all 0.2s ease;
  }
  .language-switcher a:hover {
    color: var(--color-accent);
    background: rgba(155, 74, 74, 0.08);
  }
  .language-switcher a.active {
    color: var(--color-accent);
    font-weight: 600;
    background: rgba(155, 74, 74, 0.12);
  }
  .lang-separator {
    color: var(--color-border);
    user-select: none;
  }
</style>
`;

// Здесь экранированные шаблонные строки возвращаются к обычному виду Astro/TypeScript.
write('src/components/LanguageSwitcher.astro', switcher.replaceAll('\`', '`').replaceAll('\${', '${'));

patch('src/pages/index.astro', [
  ['Последние пуликации', 'Последние публикации', 'опечатка в заголовке публикаций'],
]);

patch('src/pages/en/index.astro', [
  ["date: '05.07.2026',\n    title: 'Media Landscape: How Information Flows Shape Reality',\n    excerpt: 'Why the speed of information dissemination is not equal to its reliability, and what techniques help the reader separate fact from interpretation and manipulation.'",
   "date: '15.06.2026',\n    title: 'Media Landscape: Who Shapes the Agenda',\n    excerpt: 'An analysis of media market structure, ownership concentration, and mechanisms of agenda-setting in the context of digital transformation.'",
   'метаданные английской статьи о медиа'],
]);

patch('src/pages/pl/index.astro', [
  ["title: 'Nowe ruchy religijne: między osobistym poszukiwaniem a systemami kontroli'", "title: 'Nowe ruchy religijne: między osobistym poszukiwaniem a systemem kontroli'", 'польский заголовок статьи о религиозных движениях'],
  ["date: '05.07.2026',\n    title: 'Pejzaż medialny: jak strumienie informacji kształtują rzeczywistość',\n    excerpt: 'Dlaczego szybkość rozprzestrzeniania się informacji nie równa się jej wiarygodności i jakie techniki pomagają czytelnikowi oddzielić fakt od interpretacji i manipulacji.'",
   "date: '15.06.2026',\n    title: 'Pejzaż medialny: kto kształtuje agendę',\n    excerpt: 'Analiza struktury rynku mediów, koncentracji własności i mechanizmów kształtowania agendy informacyjnej w kontekście transformacji cyfrowej.'",
   'метаданные польской статьи о медиа'],
]);

patch('src/pages/by/index.astro', [
  ['крэдыорамі', 'крэдыторамі', 'крэдыорамі'],
  ['прыкмеы', 'прыкметы', 'прыкмеы'],
  ["date: '05.07.2026',\n    title: 'Медыйны ландшафт: як інфармацыйныя патокі фармуюць карціну рэальнасці',\n    excerpt: 'Чаму хуткасць распаўсюджвання інфармацыі не роўная яе дакладнасці і якія прыёмы дапамагаюць чытачу аддзяліць факт ад інтэрпрэтацыі і маніпуляцыі.'",
   "date: '15.06.2026',\n    title: 'Медыйны ландшафт: хто фарміруе павестку',\n    excerpt: 'Аналіз структуры медыйнага рынку, канцэнтрацыі ўласнасці і механізмаў фарміравання інфармацыйнай павесткі ва ўмовах лічбавай трансфармацыі.'",
   'метаданные белорусской статьи о медиа'],
]);

patch('src/pages/en/contacts.astro', [
  ['href="/rss.xml">RSS feed', 'href="/en/rss.xml">RSS feed', 'английская RSS-ссылка'],
]);
patch('src/pages/pl/contacts.astro', [
  ['href="/rss.xml">kanał RSS', 'href="/pl/rss.xml">kanał RSS', 'польская RSS-ссылка'],
]);
patch('src/pages/by/contacts.astro', [
  ['Па пытаннях запытаў, прапаноў супрацоўніцтва  дасылання крыніц.', 'Па пытаннях, запытах, прапановах аб супрацоўніцтве і дасыланні крыніц.', 'текст белорусской страницы контактов'],
  ['href="/rss.xml">RSS-стужку', 'href="/by/rss.xml">RSS-стужку', 'белорусская RSS-ссылка'],
]);

patch('src/pages/by/about.astro', [
  ['Праерка фактаў', 'Праверка фактаў', 'Праерка фактаў'],
  ['рэгулюючых падачах', 'рэгулятарных дакументах', 'рэгулюючых падачах'],
  ["непасрэных інтэрв'ю", "непасрэдных інтэрв'ю", "непасрэных інтэрв'ю"],
]);

patch('src/content/articlesBy/bankrotstva-yak-sistema.md', [
  ['Расійская газета, 26.10.2002, № 127, ст. ВкрФЗ «Аб несапраўднасці (банкротстве)» (Збор РФ, 2002).', 'Федэральны закон ад 26.10.2002 № 127-ФЗ «Аб неплацежаздольнасці (банкруцтве)» (Збор заканадаўства РФ, 2002).', 'повреждённая ссылка на закон № 127-ФЗ'],
  ['па галінох', 'па галінах', 'галінох'],
  ['гэты паказнік', 'гэты паказчык', 'паказнік'],
  ['## Уваходзіна', '## Уводзіны', 'Уваходзіна'],
  ['дзясяткаў і соцен людзей', 'дзясяткаў і сотняў людзей', 'соцен людзей'],
  ['працэдуру взыскання', 'працэдуру спагнання', 'взыскання'],
  ['«Аб несапраўднасці (банкротстве)»', '«Аб неплацежаздольнасці (банкруцтве)»', 'несапраўднасці'],
  ['канкурснае вытворчасць', 'конкурсная вытворчасць', 'канкурснае вытворчасць'],
  ['міровае пагадненне', 'міравое пагадненне', 'міровае пагадненне'],
  ['сутыкальна перавышае', 'істотна перавышае', 'сутыкальна перавышае'],
]);

patch('src/content/articlesBy/medyjny-landshaft.md', [
  ['## Уваходзіна', '## Уводзіны', 'Уваходзіна'],
  ['- "аклад Reuters Institute', '- "Даклад Reuters Institute', 'аклад Reuters'],
  ['Даследаванне «Медиалогии»', 'Даследаванне «Медыялогіі»', 'Медиалогии'],
  ['што траіць у павестку', 'што трапляе ў павестку', 'траіць у павестку'],
  ['эфект фільтравальных бурбалак»', 'эфект «фільтравальных бурбалак»', 'кавычка перад фільтравальнымі бурбалкамі'],
  ['Прамое ці ўскоснае ўплыў', 'Прамы ці ўскосны ўплыў', 'Прамое ці ўскоснае ўплыў'],
]);

patch('src/content/articlesBy/novyya-religijnyya-ruhi.md', [
  ['паміж асабістым пошукам  сістэмай кантролю', 'паміж асабістым пошукам і сістэмай кантролю', 'пропущенный союз в заголовке'],
  ['кал 10%', 'каля 10%', 'кал 10%'],
  ['## Уваходзіна', '## Уводзіны', 'Уваходзіна'],
  ['духоўнага ошуку', 'духоўнага пошуку', 'ошуку'],
  ['дэмнізуюць', 'дэманізуюць', 'дэмнізуюць'],
  ['псіхлагічнага маніпулявання', 'псіхалагічнага маніпулявання', 'псіхлагічнага'],
  ['НРР ўключаны', 'НРР уключаны', 'НРР ўключаны'],
  ['эканамічнага валту', 'эканамічнага гвалту', 'эканамічнага валту'],
  ['Ключавы крытэр:', 'Ключавы крытэрый:', 'Ключавы крытэр'],
]);

patch('src/content/articlesPl/nowe-ruchy-religijne.md', [
  ['załoony przez', 'założony przez', 'załoony'],
  ['znaczną częś dochodu', 'znaczną część dochodu', 'częś dochodu'],
]);

const privacyStyle = `  <style>
    .privacy-hero { padding: var(--space-xl) 0 var(--space-lg); border-bottom: 1px solid var(--color-border); }
    .privacy-hero h1 {
      font-family: var(--font-display); font-size: var(--step-3); font-weight: 600;
      line-height: 1.1; letter-spacing: -0.02em;
    }
    .privacy-content { padding: var(--space-xl) 0 var(--space-2xl); }
    .privacy-text {
      font-family: var(--font-display); font-size: var(--step-0);
      line-height: 1.75; max-width: var(--text-width);
    }
    .privacy-text > * + * { margin-top: var(--space-md); }
    .privacy-text h2 {
      font-family: var(--font-display); font-size: var(--step-2); font-weight: 600;
      line-height: 1.2; letter-spacing: -0.01em;
      margin-top: var(--space-xl); margin-bottom: var(--space-sm);
    }
    .privacy-text ul { padding-left: var(--space-md); }
    .privacy-text li { margin-bottom: var(--space-xs); }
    .privacy-text a { color: var(--color-accent); text-decoration: underline; text-underline-offset: 0.2em; }
    .privacy-text a:hover { text-decoration-thickness: 2px; }
  </style>`;

write('src/pages/en/privacy.astro', `---
import Base from '../../layouts/Base.astro';
---

<Base
  title="Privacy Policy — ACTA FRAGILIA"
  lang="en"
  description="ACTA FRAGILIA privacy policy."
  canonical="https://acta-fragilia.pages.dev/en/privacy"
>
  <div class="privacy-hero">
    <div class="container"><h1>Privacy Policy</h1></div>
  </div>
  <div class="privacy-content container">
    <div class="privacy-text">
      <p>ACTA FRAGILIA does not collect visitors’ personal data. This site does not use tracking cookies, third-party analytics services, or advertising.</p>
      <h2>What we do not do</h2>
      <ul>
        <li>We do not collect IP addresses for profiling.</li>
        <li>We do not use cookies to track visitor behaviour.</li>
        <li>We do not share data with advertising networks.</li>
        <li>We do not use Google Analytics, Yandex Metrica, or similar services.</li>
      </ul>
      <h2>What is used</h2>
      <p>The site is hosted on Cloudflare Pages. Cloudflare may log IP addresses as part of its infrastructure security measures, including protection against DDoS attacks and bots. Cloudflare processes this data under its own privacy policy; ACTA FRAGILIA does not use it to identify visitors.</p>
      <h2>Contact</h2>
      <p>Questions: <a href="mailto:info@acta-fragilia.pages.dev">info@acta-fragilia.pages.dev</a></p>
    </div>
  </div>
${privacyStyle}
</Base>
`);

write('src/pages/pl/privacy.astro', `---
import Base from '../../layouts/Base.astro';
---

<Base
  title="Polityka prywatności — ACTA FRAGILIA"
  lang="pl"
  description="Polityka prywatności ACTA FRAGILIA."
  canonical="https://acta-fragilia.pages.dev/pl/privacy"
>
  <div class="privacy-hero">
    <div class="container"><h1>Polityka prywatności</h1></div>
  </div>
  <div class="privacy-content container">
    <div class="privacy-text">
      <p>ACTA FRAGILIA nie gromadzi danych osobowych odwiedzających. Witryna nie używa plików cookie do śledzenia, nie korzysta z zewnętrznych usług analitycznych ani nie wyświetla reklam.</p>
      <h2>Czego nie robimy</h2>
      <ul>
        <li>Nie gromadzimy adresów IP do profilowania.</li>
        <li>Nie używamy plików cookie do śledzenia zachowania użytkowników.</li>
        <li>Nie przekazujemy danych sieciom reklamowym.</li>
        <li>Nie korzystamy z Google Analytics, Yandex Metrica ani podobnych usług.</li>
      </ul>
      <h2>Co jest wykorzystywane</h2>
      <p>Witryna jest hostowana w Cloudflare Pages. Cloudflare może rejestrować adresy IP w ramach zabezpieczeń swojej infrastruktury, w tym ochrony przed atakami DDoS i botami. Dane te są przetwarzane przez Cloudflare zgodnie z jego polityką prywatności; ACTA FRAGILIA nie wykorzystuje ich do identyfikowania odwiedzających.</p>
      <h2>Kontakt</h2>
      <p>Pytania: <a href="mailto:info@acta-fragilia.pages.dev">info@acta-fragilia.pages.dev</a></p>
    </div>
  </div>
${privacyStyle}
</Base>
`);

write('src/pages/by/privacy.astro', `---
import Base from '../../layouts/Base.astro';
---

<Base
  title="Палітыка прыватнасці — ACTA FRAGILIA"
  lang="by"
  description="Палітыка прыватнасці ACTA FRAGILIA."
  canonical="https://acta-fragilia.pages.dev/by/privacy"
>
  <div class="privacy-hero">
    <div class="container"><h1>Палітыка прыватнасці</h1></div>
  </div>
  <div class="privacy-content container">
    <div class="privacy-text">
      <p>ACTA FRAGILIA не збірае персанальныя даныя наведвальнікаў. Сайт не выкарыстоўвае файлы cookie для адсочвання, не падключае староннія аналітычныя сэрвісы і не размяшчае рэкламу.</p>
      <h2>Чаго мы не робім</h2>
      <ul>
        <li>Не збіраем IP-адрасы для прафілявання.</li>
        <li>Не выкарыстоўваем файлы cookie для адсочвання паводзінаў.</li>
        <li>Не перадаём даныя рэкламным сеткам.</li>
        <li>Не выкарыстоўваем Google Analytics, Яндэкс.Метрыку і падобныя сэрвісы.</li>
      </ul>
      <h2>Што выкарыстоўваецца</h2>
      <p>Сайт размешчаны на Cloudflare Pages. Cloudflare можа запісваць IP-адрасы ў межах абароны сваёй інфраструктуры, у тым ліку ад DDoS-атак і ботаў. Гэтыя даныя апрацоўваюцца Cloudflare паводле ўласнай палітыкі прыватнасці; ACTA FRAGILIA не выкарыстоўвае іх для ідэнтыфікацыі наведвальнікаў.</p>
      <h2>Кантакт</h2>
      <p>Пытанні: <a href="mailto:info@acta-fragilia.pages.dev">info@acta-fragilia.pages.dev</a></p>
    </div>
  </div>
${privacyStyle}
</Base>
`);

const notFoundStyle = `
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
</style>`;

function localized404(lang, title, text, home, archive) {
  const prefix = `/${lang}`;
  return `---
import Base from '../../layouts/Base.astro';
---

<Base title="${title} — ACTA FRAGILIA" lang="${lang}">
  <section class="notfound">
    <p class="notfound-code">404</p>
    <h1 class="notfound-title">${title}</h1>
    <p class="notfound-text">${text}</p>
    <div class="notfound-actions">
      <a href="${prefix}/" class="notfound-link">${home}</a>
      <a href="${prefix}/archive/" class="notfound-link notfound-link--muted">${archive}</a>
    </div>
  </section>
${notFoundStyle}
</Base>
`;
}

write('src/pages/en/404.astro', localized404(
  'en', 'Page not found',
  'The material may have been moved or the link is outdated.',
  '← Back to home', 'Open archive'
));
write('src/pages/pl/404.astro', localized404(
  'pl', 'Strona nie znaleziona',
  'Materiał mógł zostać przeniesiony lub link jest nieaktualny.',
  '← Strona główna', 'Otwórz archiwum'
));
write('src/pages/by/404.astro', localized404(
  'by', 'Старонка не знойдзена',
  'Магчыма, матэрыял быў перамешчаны або спасылка састарэла.',
  '← На галоўную', 'Адкрыць архіў'
));

let root404 = read('src/pages/404.astro');
if (!root404.includes('ACTA_LOCALIZED_404')) {
  const localizedRedirect = `
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

  if (target && path !== target) window.location.replace(target);
</script>`;
  root404 = root404.includes('</Base>')
    ? root404.replace('</Base>', `${localizedRedirect}\n</Base>`)
    : `${root404}\n${localizedRedirect}\n`;
  write('src/pages/404.astro', root404);
}

console.log(`Изменено файлов: ${changed.length}`);
for (const file of changed) console.log(`  + ${file}`);
if (warnings.length) {
  console.log('\nПредупреждения (возможно, фрагменты уже были исправлены вручную):');
  for (const warning of warnings) console.log(`  ! ${warning}`);
}
'@

$QaScript = @'
import fs from 'node:fs';
import path from 'node:path';

const root = process.cwd();
const errors = [];

function fail(message) { errors.push(message); }
function full(rel) { return path.join(root, ...rel.split('/')); }
function exists(rel) { return fs.existsSync(full(rel)); }
function read(rel) {
  if (!exists(rel)) { fail(`Не найден: ${rel}`); return '';
  }
  return fs.readFileSync(full(rel), 'utf8');
}
function routeFile(route) {
  const clean = route.replace(/^\/+|\/+$/g, '');
  return clean ? `dist/${clean}/index.html` : 'dist/index.html';
}
function assertContains(rel, needle, label) {
  const text = read(rel);
  if (text && !text.includes(needle)) fail(`${rel}: отсутствует ${label || needle}`);
}
function assertNotContains(rel, needle, label) {
  const text = read(rel);
  if (text.includes(needle)) fail(`${rel}: найден запрещённый фрагмент ${label || needle}`);
}

const homeRoutes = ['/', '/en/', '/pl/', '/by/'];
const homeSwitchLinks = ['href="/"', 'href="/en/"', 'href="/pl/"', 'href="/by/"'];
for (const route of homeRoutes) {
  const rel = routeFile(route);
  read(rel);
  for (const link of homeSwitchLinks) assertContains(rel, link, `языковая ссылка ${link}`);
}

const badRootLinks = [
  '/en/en', '/pl/en', '/by/en',
  '/en/pl', '/pl/pl', '/by/pl',
  '/en/by', '/pl/by', '/by/by'
];
for (const route of homeRoutes) {
  const rel = routeFile(route);
  for (const bad of badRootLinks) assertNotContains(rel, `href="${bad}`, `ошибочная ссылка ${bad}`);
}

const groups = [
  { ru: 'bankrotstvo-kak-sistema', en: 'bankruptcy-as-a-system', pl: 'upadlosc-jako-system', by: 'bankrotstva-yak-sistema' },
  { ru: 'novye-religioznye-dvizheniya', en: 'new-religious-movements', pl: 'nowe-ruchy-religijne', by: 'novyya-religijnyya-ruhi' },
  { ru: 'mediinyi-landshaft', en: 'media-landscape', pl: 'pejzaz-medialny', by: 'medyjny-landshaft' },
];
const prefix = { ru: '', en: '/en', pl: '/pl', by: '/by' };
for (const group of groups) {
  for (const current of Object.keys(prefix)) {
    const rel = routeFile(`${prefix[current]}/article/${group[current]}`);
    read(rel);
    for (const target of Object.keys(prefix)) {
      const expected = `href="${prefix[target]}/article/${group[target]}"`;
      assertContains(rel, expected, `перевод статьи ${target}: ${expected}`);
    }
  }
}

const privacyChecks = [
  ['dist/en/privacy/index.html', 'Privacy Policy'],
  ['dist/pl/privacy/index.html', 'Polityka prywatności'],
  ['dist/by/privacy/index.html', 'Палітыка прыватнасці'],
];
for (const [rel, text] of privacyChecks) assertContains(rel, text, `заголовок ${text}`);

const localized404 = [
  ['dist/en/404/index.html', 'Page not found'],
  ['dist/pl/404/index.html', 'Strona nie znaleziona'],
  ['dist/by/404/index.html', 'Старонка не знойдзена'],
];
for (const [rel, text] of localized404) assertContains(rel, text, `локализованная 404: ${text}`);

const sourceFiles = [
  'src/pages/index.astro',
  'src/pages/by/index.astro',
  'src/pages/by/about.astro',
  'src/pages/by/contacts.astro',
  'src/content/articlesBy/bankrotstva-yak-sistema.md',
  'src/content/articlesBy/medyjny-landshaft.md',
  'src/content/articlesBy/novyya-religijnyya-ruhi.md',
  'src/content/articlesPl/nowe-ruchy-religijne.md',
];
const forbiddenTypos = [
  'Последние пуликации', 'крэдыорамі', 'прыкмеы', 'Праерка фактаў',
  'непасрэных інтэрв\'ю', 'ВкрФЗ', 'галінох', 'взыскання',
  'канкурснае вытворчасць', 'сутыкальна перавышае', 'аклад Reuters',
  'траіць у павестку', 'Прамое ці ўскоснае ўплыў', 'духоўнага ошуку',
  'дэмнізуюць', 'псіхлагічнага', 'эканамічнага валту',
  'załoony przez', 'znaczną częś dochodu'
];
for (const rel of sourceFiles) {
  for (const typo of forbiddenTypos) assertNotContains(rel, typo, `опечатка «${typo}»`);
}

assertContains('src/pages/en/contacts.astro', 'href="/en/rss.xml"', 'локализованная EN RSS-ссылка');
assertContains('src/pages/pl/contacts.astro', 'href="/pl/rss.xml"', 'локализованная PL RSS-ссылка');
assertContains('src/pages/by/contacts.astro', 'href="/by/rss.xml"', 'локализованная BY RSS-ссылка');

if (errors.length) {
  console.error('\nПРОВЕРКА НЕ ПРОЙДЕНА:');
  for (const error of errors) console.error(`  - ${error}`);
  process.exit(1);
}

console.log('Автоматическая проверка пройдена: главные страницы, переключатель языков, 12 статей, privacy, 404, RSS и исправления текста.');
'@

$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$ApplyPath = Join-Path $env:TEMP 'acta-apply-multilingual-fixes.mjs'
$QaPath = Join-Path $env:TEMP 'acta-check-multilingual-fixes.mjs'
[System.IO.File]::WriteAllText($ApplyPath, $ApplyScript, $Utf8NoBom)
[System.IO.File]::WriteAllText($QaPath, $QaScript, $Utf8NoBom)

try {
    Write-Host "`n1/5 — Внесение исправлений..." -ForegroundColor Cyan
    & node $ApplyPath
    if ($LASTEXITCODE -ne 0) { throw 'Не удалось применить исправления.' }

    Write-Host "`n2/5 — Проверка Git diff..." -ForegroundColor Cyan
    & git diff --check -- $TargetFiles
    if ($LASTEXITCODE -ne 0) { throw 'git diff --check обнаружил ошибки пробелов или конфликтные маркеры.' }

    Write-Host "`n3/5 — Сборка Astro..." -ForegroundColor Cyan
    & npm run build
    if ($LASTEXITCODE -ne 0) { throw 'Сборка завершилась с ошибкой. Коммит и push не выполнялись.' }

    Write-Host "`n4/5 — Автоматическая проверка языковых маршрутов..." -ForegroundColor Cyan
    & node $QaPath
    if ($LASTEXITCODE -ne 0) { throw 'Автоматическая проверка не пройдена. Коммит и push не выполнялись.' }

    Write-Host "`n5/5 — Коммит и отправка в GitHub..." -ForegroundColor Cyan
    & git add -- $TargetFiles
    if ($LASTEXITCODE -ne 0) { throw 'git add завершился с ошибкой.' }

    & git diff --cached --check
    if ($LASTEXITCODE -ne 0) { throw 'Проверка подготовленного коммита завершилась с ошибкой.' }

    & git diff --cached --quiet
    $HasChanges = ($LASTEXITCODE -ne 0)

    if ($HasChanges) {
        & git commit -m 'Fix multilingual navigation, privacy pages and translations'
        if ($LASTEXITCODE -ne 0) { throw 'git commit завершился с ошибкой.' }
    } else {
        Write-Host 'Все исправления уже присутствуют — новый коммит не требуется.' -ForegroundColor Yellow
    }

    & git push origin main
    if ($LASTEXITCODE -ne 0) { throw 'git push завершился с ошибкой.' }

    Write-Host "`nГОТОВО." -ForegroundColor Green
    Write-Host 'Исправлены языковые ссылки главных страниц и 12 статей.' -ForegroundColor Green
    Write-Host 'Добавлены локализованные страницы privacy для EN, PL и BY.' -ForegroundColor Green
    Write-Host 'Синхронизированы даты и заголовки, исправлены RSS-ссылки и найденные опечатки.' -ForegroundColor Green
    Write-Host 'Сборка и автоматические проверки пройдены, изменения отправлены в main.' -ForegroundColor Green
}
finally {
    Remove-Item $ApplyPath -Force -ErrorAction SilentlyContinue
    Remove-Item $QaPath -Force -ErrorAction SilentlyContinue
}
