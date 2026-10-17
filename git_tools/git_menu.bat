@echo off
chcp 65001 >nul
title GitHub Manager (CMD) - DOAN2

:: Chuyen ve thu muc goc cua du an
cd /d "%~dp0\.."

:MENU
cls
echo ==================================================================
echo                 TOOL QUAN LY GITHUB TU DONG (CMD)
echo ==================================================================
for /f "tokens=*" %%i in ('git branch --show-current 2^>nul') do set CURRENT_BRANCH=%%i
if "%CURRENT_BRANCH%"=="" set CURRENT_BRANCH=main

for /f "tokens=*" %%i in ('git remote get-url origin 2^>nul') do set REMOTE_URL=%%i
if "%REMOTE_URL%"=="" set REMOTE_URL=Chua cau hinh remote

echo  [Thu muc du an] : %CD%
echo  [Nhanh hien tai]: %CURRENT_BRANCH%
echo  [Remote URL]   : %REMOTE_URL%
echo ==================================================================
echo.
echo Vui long chon mot thao tac:
echo.
echo   [1] Day toan bo thay doi len GitHub (Add + Commit + Push)
echo   [2] Khoi phuc du an ve giong GitHub (Reset Hard + Discard Changes)
echo   [3] Keo cap nhat moi nhat tu GitHub (Git Pull)
echo   [4] Kiem tra trang thai Git (Git Status)
echo   [5] Xem lich su 10 commit gan nhat (Git Log)
echo   [6] Luu tam thay doi (Git Stash / Pop)
echo   [0] Thoat
echo.
echo ==================================================================
choice /c 1234560 /n /m "Nhap lua chon [0-6]: "

if errorlevel 7 goto EXIT_TOOL
if errorlevel 6 goto STASH_GIT
if errorlevel 5 goto LOG_GIT
if errorlevel 4 goto STATUS_GIT
if errorlevel 3 goto PULL_GIT
if errorlevel 2 goto RESTORE_GIT
if errorlevel 1 goto PUSH_ALL

goto MENU

:PUSH_ALL
cls
echo ==================================================================
echo [CHUC NANG 1]: DAY TOAN BO CODE LEN GITHUB
echo ==================================================================
echo Kiem tra cac file thay doi:
git status -s
echo.
set "COMMIT_MSG="
set /p COMMIT_MSG="Nhap noi dung commit (Enter de dung mac dinh 'Auto update'): "
if "%COMMIT_MSG%"=="" set COMMIT_MSG=Auto update: %DATE% %TIME%

echo.
echo [1/3] Dang them file (git add .)...
git add .
echo [2/3] Dang tao commit...
git commit -m "%COMMIT_MSG%"
echo [3/3] Dang day len GitHub (%CURRENT_BRANCH%)...
git push origin %CURRENT_BRANCH%

echo.
echo Hoan tat!
pause
goto MENU

:RESTORE_GIT
cls
echo ==================================================================
echo [CHUC NANG 2]: KHOI PHUC DU AN VE GIONG GITHUB (RESET HARD)
echo ==================================================================
echo CANH BAO:
echo - Thao tac nay se XOA HET cac thay doi chua commit tren may cuc bo.
echo - Dua toan bo ma nguon ve dung phien ban moi nhat tren GitHub.
echo ==================================================================
echo.
set /p CONFIRM="Ban co CHAC CHAN muon khoi phuc khong? (Go 'YES' de tiep tuc): "
if /i not "%CONFIRM%"=="YES" (
    echo Da huy thao tac!
    pause
    goto MENU
)

echo.
echo [1/3] Dang tai du lieu moi nhat (git fetch origin)...
git fetch origin
echo [2/3] Dang reset code ve commit moi nhat (git reset --hard origin/%CURRENT_BRANCH%)...
git reset --hard origin/%CURRENT_BRANCH%
echo [3/3] Dang don dep cac file untracked thua thai (git clean -fd)...
git clean -fd

echo.
echo Da khoi phuc hoan tat!
pause
goto MENU

:PULL_GIT
cls
echo ==================================================================
echo [CHUC NANG 3]: KEO CAP NHAT MOI NHAT TU GITHUB (PULL)
echo ==================================================================
git pull origin %CURRENT_BRANCH%
echo.
pause
goto MENU

:STATUS_GIT
cls
echo ==================================================================
echo [CHUC NANG 4]: KIEM TRA TRANG THAI GIT (STATUS)
echo ==================================================================
git status
echo.
pause
goto MENU

:LOG_GIT
cls
echo ==================================================================
echo [CHUC NANG 5]: XEM 10 COMMIT GAN NHAT (LOG)
echo ==================================================================
git log -n 10 --oneline --graph --decorate
echo.
pause
goto MENU

:STASH_GIT
cls
echo ==================================================================
echo [CHUC NANG 6]: LUU TAM THAY DOI (GIT STASH)
echo ==================================================================
echo 1. Luu tam thay doi hien tai (git stash)
echo 2. Lay lai thay doi da luu tam (git stash pop)
echo 3. Xem danh sach stash (git stash list)
echo 0. Quay lai
echo.
choice /c 1230 /n /m "Chon thao tac [0-3]: "
if errorlevel 4 goto MENU
if errorlevel 3 git stash list
if errorlevel 2 git stash pop
if errorlevel 1 git stash
pause
goto MENU

:EXIT_TOOL
cls
echo Tam biet!
exit /b 0
