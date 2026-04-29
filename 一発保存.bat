@echo off
chcp 65001 > nul
setlocal EnableDelayedExpansion
cd /d %~dp0

:: =====================================
:: 設定
:: =====================================
set BASE=C:\Users\tomo-\Downloads\部活\Soda_DENGIKEN
set LOGDIR=%BASE%\backup_logs

if not exist "%LOGDIR%" mkdir "%LOGDIR%"

set YYYY=%date:~0,4%
set MM=%date:~5,2%
set DD=%date:~8,2%
set HH=%time:~0,2%
if "%HH:~0,1%"==" " set HH=0%HH:~1,1%
set NN=%time:~3,2%
set SS=%time:~6,2%

set LOGFILE=%LOGDIR%\backup_%YYYY%-%MM%-%DD%_%HH%-%NN%-%SS%.txt

set SUCCESS_LIST=

:: =====================================
:: Google Drive待機
:: =====================================
echo ==========================================
echo  Google Driveの同期完了を待機中...
echo  (50秒後に自動で開始します)
echo ==========================================
timeout /t 50 > nul

call :Log ==========================================
call :Log Google Drive wait finished
call :Log ==========================================

echo.
echo ==========================================
echo  Parent + Child Repo Push Start
echo ==========================================
call :Log Parent + Child Repo Push Start

:: =====================================
:: 親repo
:: =====================================
echo.
echo ------------------------------------------
echo [1/4] Soda_DENGIKEN
echo ------------------------------------------

cd /d "%BASE%"
call :PushRepo "Soda_DENGIKEN"

:: =====================================
:: 子repo
:: =====================================
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
        echo スキップ (.gitなし)
        call :Log %%~F skipped (.git not found)
    )

    set /a COUNT+=1
)

:: =====================================
:: 完了表示
:: =====================================
echo.
echo ==========================================
echo Done
echo ==========================================

echo.
echo Pushしたrepo一覧:
echo --------------------------
if defined SUCCESS_LIST (
    for %%A in (!SUCCESS_LIST!) do echo %%~A
) else (
    echo なし
)

call :Log ==========================================
call :Log Done
call :Log ==========================================

pause
exit /b


:: =====================================
:: Push処理
:: =====================================
:PushRepo

git add . >> "%LOGFILE%" 2>&1

git diff --cached --quiet
if errorlevel 1 (

    git commit -m "Auto Backup: %date% %time%" >> "%LOGFILE%" 2>&1

    if errorlevel 1 (
        color 0C
        echo [ERROR] %~1 commit失敗
        call :Log [ERROR] %~1 commit failed
        color 07
        exit /b
    )

    git push origin main >> "%LOGFILE%" 2>&1

    if errorlevel 1 (
        color 0C
        echo [ERROR] %~1 push失敗
        call :Log [ERROR] %~1 push failed
        color 07
    ) else (
        echo [OK] %~1 完了
        call :Log [OK] %~1 success
        set SUCCESS_LIST=!SUCCESS_LIST! "%~1"
    )

) else (
    echo 変更なし。スキップ
    call :Log %~1 no changes
)

exit /b


:: =====================================
:: ログ書き込み
:: =====================================
:Log
echo [%date% %time%] %*>>"%LOGFILE%"
exit /b