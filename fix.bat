@echo off
chcp 65001 >nul
title Авто-фикс ACTA FRAGILIA
echo.
echo [1/4] Ищу файл макета...
if not exist "src\layouts\Base.astro" (
    echo Ошибка: Файл src\layouts\Base.astro не найден.
    echo Убедитесь, что вы положили этот файл в корневую папку проекта.
    pause
    exit /b
)
echo Файл найден. Исправляю email и favicon...
powershell -Command "(Get-Content 'src\layouts\Base.astro' -Raw) -replace 'info@acta-fragilia.pages.dev', 'acta_fragilia@proton.me' -replace 'favicon.ico', 'favicon.svg' | Set-Content 'src\layouts\Base.astro' -NoNewline"
echo Email и favicon обновлены.

echo.
echo [2/4] Устанавливаю библиотеку для sitemap...
call npm install @astrojs/sitemap
if errorlevel 1 (
    echo Ошибка установки. Проверьте интернет или Node.js.
    pause
    exit /b
)
echo Библиотека установлена.

echo.
echo [3/4] Настраиваю astro.config.mjs...
powershell -Command "$config = Get-Content 'astro.config.mjs' -Raw; if ($config -notmatch 'import sitemap') { $config = $config -replace \"import { defineConfig } from 'astro/config';\", \"import { defineConfig } from 'astro/config';\nimport sitemap from '@astrojs/sitemap';\" }; if ($config -notmatch 'integrations:') { $config = $config -replace \"export default defineConfig({\", \"export default defineConfig({\n  integrations: [sitemap()],\" }; Set-Content 'astro.config.mjs' -Value $config -NoNewline"
echo Конфигурация обновлена.

echo.
echo [4/4] Запускаю сборку проекта (проверка)...
call npm run build
if errorlevel 1 (
    echo Ошибка сборки. Посмотрите сообщения выше.
    pause
    exit /b
)

echo.
echo ========================================
echo Готово! Все ошибки исправлены.
echo Проверьте файлы: sitemap.xml, favicon и email.
echo ========================================
pause