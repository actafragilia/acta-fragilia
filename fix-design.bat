@echo off
chcp 65001 >nul
echo ========================================
echo   ACTA FRAGILIA - Fix Design v2
echo ========================================
echo.

REM Check if we are in the right folder
if not exist "src\layouts" (
    echo ERROR: src\layouts folder not found.
    echo Please run this script from the project root folder:
    echo C:_Сайтcta-fragilia-astro    pause
    exit /b 1
)

REM Backup existing files
echo [1/5] Creating backups...
if exist "src\layouts\Base.astro" (
    copy "src\layouts\Base.astro" "src\layouts\Base.astro.backup.%date:~-4,4%%date:~-7,2%%date:~-10,2%" >nul
    echo       Base.astro backed up.
)
if exist "publicpp.css" (
    copy "publicpp.css" "publicpp.css.backup.%date:~-4,4%%date:~-7,2%%date:~-10,2%" >nul
    echo       app.css backed up.
)

REM Copy new files
echo [2/5] Copying Base.astro...
copy /Y "Base.astro" "src\layouts\Base.astro" >nul
if errorlevel 1 (
    echo ERROR: Failed to copy Base.astro
    echo Make sure Base.astro is in the same folder as this script.
    pause
    exit /b 1
)

echo [3/5] Copying app.css...
copy /Y "app.css" "publicpp.css" >nul
if errorlevel 1 (
    echo ERROR: Failed to copy app.css
    echo Make sure app.css is in the same folder as this script.
    pause
    exit /b 1
)

REM Git operations
echo [4/5] Git commit and push...
git add src/layouts/Base.astro public/app.css
git commit -m "fix: restore design with cache-busted CSS v2"
git push

if errorlevel 1 (
    echo.
    echo WARNING: Git push may have failed.
    echo Check the error messages above.
) else (
    echo.
    echo [5/5] DONE! Files pushed to GitHub.
)

echo.
echo ========================================
echo   Next steps:
echo   1. Wait 1-2 minutes for Cloudflare
echo   2. Open in incognito: Ctrl+Shift+N
echo   3. Visit: https://acta-fragilia.pages.dev/
echo ========================================
pause
