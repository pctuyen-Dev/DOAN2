@echo off
chcp 65001 >nul
title GitHub Manager - DOAN2

:: Điều hướng đến thư mục chứa file .bat
cd /d "%~dp0"

:: Thử khởi chạy script PowerShell (giao diện màu sắc trực quan)
where powershell.exe >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0git_menu.ps1"
    if %ERRORLEVEL% EQU 0 exit /b 0
)

:: Nếu không có powershell hoặc lỗi, chạy bản batch thuần
call "%~dp0git_menu.bat"
