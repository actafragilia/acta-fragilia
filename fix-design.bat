@echo off
echo === ACTA FRAGILIA Design Restore ===

if not exist "astro.config.mjs" (
    echo ERROR: Run this from project root folder
    pause
    exit /b 1
)

if not exist "Base.astro" (
    echo ERROR: Base.astro not found. Download it and place next to this .bat file.
    pause
    exit /b 1
)

if exist "src\layouts\Base.astro" (
    copy "src\layouts\Base.astro" "src\layouts\Base.astro.backup" >nul
    echo Backup created: src\layouts\Base.astro.backup
)

copy /Y "Base.astro" "src\layouts\Base.astro" >nul
echo Base.astro restored successfully.

git add src/layouts/Base.astro
git commit -m "fix: restore design in Base.astro"
git push

echo.
echo === DONE! Check your site in 1-2 minutes ===
echo https://acta-fragilia.pages.dev/
pause
