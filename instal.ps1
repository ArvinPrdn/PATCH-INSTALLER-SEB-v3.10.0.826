@echo off
cls
title SIMPLE INSTALLER
color 0A

echo.
echo ================================
echo     SIMPLE INSTALLER LAUNCHER
echo ================================
echo.

:: Cari file instal.ps1
if exist "instal.ps1" (
    set "PS_FILE=instal.ps1"
    goto RUN_IT
)

:: Cari di folder default
if exist "E:\EL KIRIKS\INSTALL DISINI\instal.ps1" (
    cd /d "E:\EL KIRIKS\INSTALL DISINI"
    set "PS_FILE=instal.ps1"
    goto RUN_IT
)

if exist "D:\EL KIRIKS\INSTALL DISINI\instal.ps1" (
    cd /d "D:\EL KIRIKS\INSTALL DISINI"
    set "PS_FILE=instal.ps1"
    goto RUN_IT
)

if exist "F:\EL KIRIKS\INSTALL DISINI\instal.ps1" (
    cd /d "F:\EL KIRIKS\INSTALL DISINI"
    set "PS_FILE=instal.ps1"
    goto RUN_IT
)

echo ERROR: File instal.ps1 tidak ditemukan!
pause
exit /b 1

:RUN_IT
echo Running: %PS_FILE%
echo.
powershell -ExecutionPolicy Bypass -File "%PS_FILE%"
pause
