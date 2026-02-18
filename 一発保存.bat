@echo off
cd /d %~dp0

echo ==========================================
echo  Google Driveの同期完了を待機中...
echo  (50秒後に自動で開始します)
echo ==========================================

:: ▼ここで10秒カウントダウンします（何かキーを押すとスキップ可能）
timeout /t 50

echo.
echo ==========================================
echo  Starting GitHub Auto Backup...
echo ==========================================

git add .
git commit -m "Auto Backup: %date% %time%"
git push origin HEAD

echo ==========================================
echo  Done!
echo ==========================================
pause