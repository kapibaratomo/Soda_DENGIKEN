for %%F in (
"NEST2025"
"NEST2026"
"RCJ2025"
"RCJ2026"
"kicad ライブラリ"
"Ritsumori cup2026"
) do (
 cd /d "C:\Users\tomo-\Downloads\部活\Soda_DENGIKEN\%%~F"
 git add .
 git commit -m "force resync"
 git push origin HEAD
)