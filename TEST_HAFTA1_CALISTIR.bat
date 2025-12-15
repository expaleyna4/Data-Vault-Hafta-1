@echo off
chcp 65001 >nul
color 0B
echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║          DATA VAULT - HAFTA 1 TEST (WSL)                     ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.
echo ⏱️  Test başlatılıyor...
echo.
pause

wsl -d Ubuntu -- bash ~/test-hafta1.sh

pause
