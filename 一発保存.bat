@echo off
cd /d %~dp0

echo ==========================================
echo  Starting GitHub Auto Backup...
echo ==========================================

:: 1. 全ファイルを登録
git add .

:: 2. 英語でコミット（これで文字化けエラーを回避）
git commit -m "Auto Backup: %date% %time%"

:: 3. 送信
git push origin HEAD

echo ==========================================
echo  Done!
echo ==========================================
pause