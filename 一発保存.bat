@echo off
chcp 65001 > nul
cd /d %~dp0

echo ==========================================
echo  Google Driveの同期完了を待機中...
echo  (50秒後に自動で開始します)
echo ==========================================
timeout /t 50

echo.
echo ==========================================
echo  Starting GitHub Auto Backup...
echo ==========================================

git add .
git commit -m "Auto Backup: %date% %time%"

:: ▼ 個人用（origin）に送信！
echo  Pushing to Personal (origin)...
git push origin HEAD

:: ▼ チーム用（team）にも送信！
echo  Pushing to Team (team)...
git push team HEAD

echo ==========================================
echo  Done!
echo ==========================================
pause