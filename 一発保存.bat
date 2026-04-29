@echo off
chcp 65001 > nul
setlocal EnableDelayedExpansion
cd /d %~dp0

set BASE=C:\Users\tomo-\Downloads\部活\Soda_DENGIKEN

echo ==========================================
echo   Parent + Independent Repo Push Start
echo ==========================================

:: --------------------------------
:: [1] 親リポジトリ
:: --------------------------------
echo.
echo ------------------------------------------
echo  [1/4] Soda_DENGIKEN (親)
echo ------------------------------------------

cd /d "%BASE%"
call :PushRepo "Soda_DENGIKEN"

:: --------------------------------
:: 独立リポジトリ3個
:: --------------------------------
set COUNT=2

for %%F in (
    "NEST2026"
    "Ritsumori cup2026"
    "kicad ライブラリ"
) do (

    echo.
    echo ------------------------------------------
    echo  [!COUNT!/4] %%~F
    echo ------------------------------------------

    cd /d "%BASE%\%%~F"

    rem 独立repoか確認（トップ階層一致）
    for /f "delims=" %%T in ('git rev-parse --show-toplevel 2^>nul') do set TOP=%%T

    if /I "!TOP!"=="%BASE%\%%~F" (
        call :PushRepo "%%~F"
    ) else (
        echo 独立repoではないためスキップ
    )

    set /a COUNT+=1
)

echo.
echo ==========================================
echo  Done
echo ==========================================
pause
exit /b


:PushRepo

git add .

git diff --cached --quiet
if errorlevel 1 (

    git commit -m "Auto Backup: %date% %time%"

    if errorlevel 1 (
        echo [ERROR] %~1 commit失敗
        exit /b
    )

    git push origin main

    if errorlevel 1 (
        echo [ERROR] %~1 push失敗
    ) else (
        echo [OK] %~1 完了
    )

) else (
    echo 変更なし。スキップ
)

exit /b