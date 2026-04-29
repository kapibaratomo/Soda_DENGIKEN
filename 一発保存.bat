@echo off
chcp 65001 > nul
setlocal EnableDelayedExpansion
cd /d %~dp0

set BASE=C:\Users\tomo-\Downloads\部活\Soda_DENGIKEN

echo ==========================================
echo   Parent + Child Repo Push Start
echo ==========================================

:: 親repo
echo.
echo ------------------------------------------
echo [1/4] Soda_DENGIKEN
echo ------------------------------------------
cd /d "%BASE%"
call :PushRepo "Soda_DENGIKEN"

:: 子repo
set COUNT=2

for %%F in (
"NEST2026"
"Ritsumori cup2026"
"kicad ライブラリ"
) do (

 echo.
 echo ------------------------------------------
 echo [!COUNT!/4] %%~F
 echo ------------------------------------------

 if exist "%BASE%\%%~F\.git" (
    cd /d "%BASE%\%%~F"
    call :PushRepo "%%~F"
 ) else (
    echo .git が無いためスキップ
 )

 set /a COUNT+=1
)

echo.
echo ==========================================
echo Done
echo ==========================================
pause
exit /b


:PushRepo
git add .
git diff --cached --quiet

if errorlevel 1 (
    git commit -m "Auto Backup: %date% %time%"
    git push origin main
    echo [OK] %~1 完了
) else (
    echo 変更なし。スキップ
)
exit /b