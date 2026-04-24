@echo off
chcp 65001 > nul
setlocal EnableDelayedExpansion
cd /d %~dp0

set BASE=C:\Users\tomo-\Downloads\部活\Soda_DENGIKEN

echo ==========================================
echo  Google Driveの同期完了を待機中...
echo  (50秒後に自動で開始します)
echo ==========================================
timeout /t 50

echo.
echo ==========================================
echo  Starting GitHub Auto Backup...
echo ==========================================


:: ▼ Soda_DENGIKEN本体（originのみ）
echo.
echo ------------------------------------------
echo  [1/7] Soda_DENGIKEN
echo ------------------------------------------
cd /d "%BASE%"

git add .

git diff --cached --quiet
if errorlevel 1 (
    git commit -m "Auto Backup: %date% %time%"
    if errorlevel 1 (
        echo  [ERROR] commit失敗
    ) else (
        git push origin HEAD
        if errorlevel 1 (
            echo  [ERROR] origin push失敗
        ) else (
            echo  [OK] Soda_DENGIKEN 完了
        )
    )
) else (
    echo  変更なし。スキップ
)


:: ▼ 個別リポジトリ6個（originのみ）
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

    cd /d "%BASE%\%%~F"

    git add .

    git diff --cached --quiet
    if errorlevel 1 (

        git commit -m "Auto Backup: %date% %time%"

        if errorlevel 1 (
            echo  [ERROR] %%~F commit失敗
        ) else (

            git push origin HEAD

            if errorlevel 1 (
                echo  [ERROR] %%~F push失敗
            ) else (
                echo  [OK] %%~F 完了
            )
        )

    ) else (
        echo  変更なし。スキップ
    )

    set /a COUNT+=1
)

echo.
echo ==========================================
echo  Done!
echo ==========================================
pause