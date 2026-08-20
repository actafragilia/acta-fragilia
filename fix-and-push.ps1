
# fix-and-push.ps1
# ACTA FRAGILIA — исправление опечатки и отправка всех изменений

$projectPath = "X:\Общая\1_Сайт\acta-fragilia-astro"

if (-not (Test-Path $projectPath)) {
    Write-Error "Папка проекта не найдена: $projectPath"
    exit 1
}

Set-Location $projectPath
Write-Host "Рабочая папка: $(Get-Location)" -ForegroundColor Cyan

# --- 1. Исправление опечатки «жаклад» → «філіял» ---
$ typoFile = "src\content\articlesBy\medyjny-landshaft.md"
if (Test-Path $typoFile) {
    $content = Get-Content $typoFile -Raw -Encoding UTF8
    if ($content -match 'жаклад') {
        $content = $content -replace 'жаклад', 'філіял'
        Set-Content -Path $typoFile -Value $content -Encoding UTF8
        Write-Host "Исправлена опечатка: жаклад → філіял в $typoFile" -ForegroundColor Green
    } else {
        Write-Host "Опечатка 'жаклад' не найдена — возможно, уже исправлена" -ForegroundColor Yellow
    }
} else {
    Write-Warning "Файл не найден: $typoFile"
}

# --- 2. Сборка ---
Write-Host "`nЗапуск сборки..." -ForegroundColor Cyan
npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Error "ОШИБКА СБОРКИ. Проверьте лог выше."
    exit 1
}
Write-Host "Сборка прошла успешно" -ForegroundColor Green

# --- 3. Git: добавление, коммит, пуш ---
Write-Host "`nОтправка изменений в GitHub..." -ForegroundColor Cyan

# Проверяем, есть ли что коммитить
$status = git status --porcelain
if (-not $status) {
    Write-Host "Нет изменений для коммита. Возможно, всё уже отправлено." -ForegroundColor Yellow
    exit 0
}

git add -A
# Используем UTF-8 для сообщения коммита, чтобы избежать кракозябр
$commitMessage = "Fix multilingual navigation, add localized 404/privacy, fix typos"
git commit -m "$commitMessage"
if ($LASTEXITCODE -ne 0) {
    Write-Error "ОШИБКА COMMIT."
    exit 1
}

git push origin main
if ($LASTEXITCODE -ne 0) {
    Write-Error "ОШИБКА PUSH. Проверьте подключение или конфликты."
    exit 1
}

Write-Host "`nГотово: все исправления отправлены в GitHub." -ForegroundColor Green
Write-Host "Через 1–2 минуты проверьте:" -ForegroundColor White
Write-Host "  https://acta-fragilia.pages.dev/by/article/medyjny-landshaft/" -ForegroundColor White
Write-Host "  https://acta-fragilia.pages.dev/en/" -ForegroundColor White
Write-Host "  https://acta-fragilia.pages.dev/pl/" -ForegroundColor White
Write-Host "  https://acta-fragilia.pages.dev/by/" -ForegroundColor White
