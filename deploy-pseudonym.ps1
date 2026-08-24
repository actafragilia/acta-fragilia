$projectPath = "C:\1_Сайт\acta-fragilia-astro"
$ruFile = "$projectPath\src\pages\pseudonym.astro"
$byFile = "$projectPath\src\pages\by\pseudonym.astro"

$ruContent = @"'
---
import Base from '../layouts/Base.astro';
---

<Base title="О псевдониме — ACTA FRAGILIA" lang="ru">
  <article class="article-page" style="padding: var(--space-xl) 0;">
    <header class="article-header" style="max-width: 720px; margin: 0 auto var(--space-xl);">
      <h1 class="article-title" style="font-family: var(--font-display); font-size: clamp(1.8rem, 4vw, 2.8rem); font-weight: 600; line-height: 1.15; color: var(--text); margin-bottom: var(--space-lg);">
        О псевдониме
      </h1>
    </header>

    <div class="article-body" style="max-width: 720px; margin: 0 auto; font-family: var(--font-display); font-size: 1.05rem; line-height: 1.75; color: var(--text);">

      <p style="margin-bottom: var(--space-md); color: var(--muted);">
        Автор проекта ACTA FRAGILIA публикуется под именем <strong>Климент Вилейский</strong>.
      </p>

      <p style="margin-bottom: var(--space-md); color: var(--muted);">
        Это выбранное имя. Оно не связано с гражданской идентичностью автора и не отражает его биографию в пряом смысле. Но оно отражает принцип, согласно которому ведётся этот проект: <em>текст несёт ответственность, а не документ</em>. Имя здесь — инструмент фиксации этой ответственности, а не ключ к личной жизни.
      </p>

      <h2 style="font-family: var(--font-display); font-size: 1.4rem; font-weight: 600; margin-top: var(--space-xl); margin-bottom: var(--space-md); color: var(--text);">
        Почему псевдоним
      </h2>

      <p style="margin-bottom: var(--space-md); color: var(--muted);">
        Работа с корпоративными конфликтами, судебными материалами, экономическими механизмами и общественными процессами в условиях, где давление на автора может стать инструментом влияния на содержание, требует разделения между профессиональной деятельностью и личной безопасностью.
      </p>

      <p style="margin-bottom: var(--space-md); color: var(--muted);">
        Псевдоним — не анонимность. Это не скрытность ради скрытности. Это защита условий, при которых текст может быть написан честно.
      </p>

      <p style="margin-bottom: var(--space-md); color: var(--muted);">
        Мы не считаем, что автор должен рисковать семьёй, имуществом или свободой передвижения ради права подписываться настоящим именем. Особенно когда речь идёт о материалах, в которых фигурируют конкретные экономические интересы, судебные решения и корпоративные конфликты.
      </p>

      <h2 style="font-family: var(--font-display); font-size: 1.4rem; font-weight: 600; margin-top: var(--space-xl); margin-bottom: var(--space-md); color: var(--text);">
        Что это меняет для читателя
      </h2>

      <p style="margin-bottom: var(--space-md); color: var(--muted);">
        Ничего. Имя автора — это имя, под которым он берёт на себя ответственность за каждый текст. Проверяемость фактов, ссылки на источники, методология и редакционная политика остаются неизменными.
      </p>

      <p style="margin-bottom: var(--space-md); color: var(--muted);">
        Псевдоним не снижает требований к точности. Он повышает требования к честности — потому что автор не может спрятаться за «я просто журналист», когда его имя — осознанный выбор.
      </p>

      <h2 style="font-family: var(--font-display); font-size: 1.4rem; font-weight: 600; margin-top: var(--space-xl); margin-bottom: var(--space-md); color: var(--text);">
        Мировая практика
      </h2>

      <p style="margin-bottom: var(--space-md); color: var(--muted);">
        Использование выбранного имени в журналистике — обычная практика в условиях политического давления, экономических рисков или работы с чувствительными источниками. Bellingcat, The Intercept, различные региональные редакции — авторы публикуются под именами, которые они выбрали для профессиональной деятельности. Это не делает их тексты менее достоверными. Это делает их работу возможной.
      </p>

      <h2 style="font-family: var(--font-display); font-size: 1.4rem; font-weight: 600; margin-top: var(--space-xl); margin-bottom: var(--space-md); color: var(--text);">
        Документирование
      </h2>

      <p style="margin-bottom: var(--space-md); color: var(--muted);">
        Настоящее имя автора известно редакции и задокументировано в соответствии с внутренней политикой безопасности. Это необходимо для соблюдения принципов прозрачности, которые мы приеняем к другим — и не можем не применять к себе.
      </p>

      <p style="margin-bottom: var(--space-md); color: var(--muted);">
        ACTA FRAGILIA не раскрывает личную информацию авторов и источников без их согласия. Вопросы, касающиеся авторства, можно направлять на <a href="mailto:acta_fragilia@proton.me">acta_fragilia@proton.me</a>.
      </p>

    </div>
  </article>
</Base>
"@

$byContent = @"'
---
import Base from '../../layouts/Base.astro';
---

<Base title="Пра псеўданім — ACTA FRAGILIA" lang="by">
  <article class="article-page" style="padding: var(--space-xl) 0;">
    <header class="article-header" style="max-width: 720px; margin: 0 auto var(--space-xl);">
      <h1 class="article-title" style="font-family: var(--font-display); font-size: clamp(1.8rem, 4vw, 2.8rem); font-weight: 600; line-height: 1.15; color: var(--text); margin-bottom: var(--space-lg);">
        Пра псеўданім
      </h1>
    </header>

    <div class="article-body" style="max-width: 720px; margin: 0 auto; font-family: var(--font-display); font-size: 1.05rem; line-height: 1.75; color: var(--text);">

      <p style="margin-bottom: var(--space-md); color: var(--muted);">
        Аўтар праекта ACTA FRAGILIA публікуецца пад імем <strong>Клімент Вілейскі</strong>.
      </p>

      <p style="margin-bottom: var(--space-md); color: var(--muted);">
        Гэта выбранае імя. Яно не звязана з грамадзянскай ідэнтычнасцю аўтара і не адлюстроўвае яго біяграфію ў прамым сэнсе. Але яно адлюстроўвае прынцып, паводле якога вядзецца гэты праект: <em>тэкст нясе адказнасць, а не дакумент</em>. Імя тут — інструмент фіксацыі гэтай адказнасці, а не ключ да асабістага жыцця.
      </p>

      <h2 style="font-family: var(--font-display); font-size: 1.4rem; font-weight: 600; margin-top: var(--space-xl); margin-bottom: var(--space-md); color: var(--text);">
        Чаму псеўданім
      </h2>

      <p style="margin-bottom: var(--space-md); color: var(--muted);">
        Праца з карпаратыўныі канфліктамі, судовымі матэрыяламі, эканамічнымі механізмамі і грамадскімі працэсамі ва ўмовах, дзе ціск на аўтара можа стаць інструментам уплыву на змест, патрабуе размежавання паміж прафесійнай дзейнасцю і асабістай бяспекай.
      </p>

      <p style="margin-bottom: var(--space-md); color: var(--muted);">
        Псеўданім — не ананімнасць. Гэта не схаванасць дзеля схаванасці. Гэта абарона ўмоў, пры якіх тэкст можа быць напісаны шчыра.
      </p>

      <p style="margin-bottom: var(--space-md); color: var(--muted);">
        Мы не лічым, што аўтар павінен рызыкаваць сям'ёй, маёмасцю ці свабодай перамяшчэння дзеля права падпісвацца сапраўдным імем. Асабліва калі гаворка ідзе пра матэрыялы, у якіх фігуруюць канкрэтныя эканамічныя інтарэсы, судовыя рашэнні і карпаратыўныя канфлікты.
      </p>

      <h2 style="font-family: var(--font-display); font-size: 1.4rem; font-weight: 600; margin-top: var(--space-xl); margin-bottom: var(--space-md); color: var(--text);">
        Што гэта мяняе для чытача
      </h2>

      <p style="margin-bottom: var(--space-md); color: var(--muted);">
        Нічога. Імя аўтара — гэта імя, пад якім ён бярэ на сябе адказнасць за кожны тэкст. Правяральнасць фактаў, спасылкі на крыніцы, методыка і рэдакцыйная палітыка застаюцца нязменнымі.
      </p>

      <p style="margin-bottom: var(--space-md); color: var(--muted);">
        Псеўданім не паніжае патрабаванняў да дакладнасці. Ён павышае патрабаванні да шчырасці — таму што аўтар не можа схавацца за «я проста журналіст», калі яго імя — свядомы выбар.
      </p>

      <h2 style="font-family: var(--font-display); font-size: 1.4rem; font-weight: 600; margin-top: var(--space-xl); margin-bottom: var(--space-md); color: var(--text);">
        Сусветная практыка
      </h2>

      <p style="margin-bottom: var(--space-md); color: var(--muted);">
        Выкарыстанне выбранага імя ў журналістыцы — звычайная практыка ва ўмовах палітычнага ціску, эканамічных рызыкаў ці працы з чувлівымі крыніцамі. Bellingcat, The Intercept, розныя рэгіянальныя рэдакцыі — аўтары публікуюцца пад імёнамі, якія яны выбралі для прафесійнай дзейнасці. Гэта не робіць іх тэксты меней даставернымі. Гэта робіць іх працу магчымай.
      </p>

      <h2 style="font-family: var(--font-display); font-size: 1.4rem; font-weight: 600; margin-top: var(--space-xl); margin-bottom: var(--space-md); color: var(--text);">
        Дакументаванне
      </h2>

      <p style="margin-bottom: var(--space-md); color: var(--muted);">
        Сапраўднае імя аўтара вядома рэдакцыі і задакументавана ў адпаведнасці з уутранай палітыкай бяспекі. Гэта неабходна для выканання прынцыпаў празрыстасці, якія мы ўжываем да іншых — і не можам не ўжываць да сябе.
      </p>

      <p style="margin-bottom: var(--space-md); color: var(--muted);">
        ACTA FRAGILIA не раскрывае асабістую інфармацыю аўтараў і крыніц без іх згоды. Пытанні, якія датычацца аўтарства, можна накіроўваць на <a href="mailto:acta_fragilia@proton.me">acta_fragilia@proton.me</a>.
      </p>

    </div>
  </article>
</Base>
"@

# Записываем файлы
$ruContent | Set-Content $ruFile -Encoding UTF8
$byContent | Set-Content $byFile -Encoding UTF8

Write-Host "Файлы созданы:" -ForegroundColor Green
Write-Host "  $ruFile" -ForegroundColor Green
Write-Host "  $byFile" -ForegroundColor Green

# Git
Set-Location $projectPath
git add src/pages/pseudonym.astro src/pages/by/pseudonym.astro
git commit -m "content: add pseudonym explanation page (RU + BY)"
git push

Write-Host "Готово! Деплой через 1-2 минуты." -ForegroundColor Green
Write-Host "https://acta-fragilia.pages.dev/pseudonym/" -ForegroundColor Cyan
Write-Host "https://acta-fragilia.pages.dev/by/pseudonym/" -ForegroundColor Cyan
