@echo off
chcp 65001 > nul
setlocal EnableDelayedExpansion
cd /d %~dp0

set BASE=C:\Users\tomo-\Downloads\部活\Soda_DENGIKEN

echo ==========================================
echo  Google Driveの同期完了を待機中...
echo  (50秒後に自動で開始します)
echo ==========================================
timeout /t 50 > nul

echo.
echo ==========================================
echo  Starting GitHub Auto Backup...
echo ==========================================


:: -------------------------------
:: 1. メインリポジトリ
:: -------------------------------
echo.
echo ------------------------------------------
echo  [1/7] Soda_DENGIKEN
echo ------------------------------------------

cd /d "%BASE%" || (
    echo [ERROR] BASEフォルダが見つかりません
    pause
    exit /b
)

call :BackupRepo "Soda_DENGIKEN"

:: -------------------------------
:: 2. 子リポジトリ
:: -------------------------------
set COUNT=2

for %%F in (
    "kicad ライブラリ"
    "NEST2025"
    "NEST2026"
    "RCJ2025"
    "RCJ2026"
    "Ritsumori cup2026"
) do (

    echo.
    echo ------------------------------------------
    echo  [!COUNT!/7] %%~F
    echo ------------------------------------------

    if exist "%BASE%\%%~F" (
        cd /d "%BASE%\%%~F"
        call :BackupRepo "%%~F"
    ) else (
        echo [ERROR] フォルダなし
    )

    set /a COUNT+=1
)

echo.
echo ==========================================
echo  Done!
echo ==========================================
pause
exit /b



:: ==========================================
:: 共通処理
:: ==========================================
:BackupRepo

git add .

git diff --cached --quiet
if not errorlevel 1 (
    echo 変更なし。スキップ
    exit /b
)

git commit -m "Auto Backup: %date% %time%" > nul 2>&1

git push origin HEAD > nul 2>&1
if errorlevel 1 (
    echo [ERROR] %~1 push失敗
) else (
    echo [OK] %~1 完了
)

exit /b