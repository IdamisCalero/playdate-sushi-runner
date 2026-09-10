@echo off
REM Playdate Sushi Runner Build and Launch Script

setlocal enabledelayedexpansion

REM Set the path to your Playdate SDK
set "SDK_PATH=C:\Users\Idamis Calero\Documents\PlaydateSDK"
set "PDC_PATH=!SDK_PATH!\bin\pdc.exe"
set "SIMULATOR_PATH=!SDK_PATH!\bin\PlaydateSimulator.exe"

REM Check if pdc exists
if not exist "!PDC_PATH!" (
    echo Error: pdc not found at !PDC_PATH!
    echo Please update the SDK_PATH in this script to match your Playdate SDK location.
    pause
    exit /b 1
)

REM Build the game
echo Compiling Sushi Runner...
"!PDC_PATH!" -sdkpath "!SDK_PATH!" source SushiRunner.pdx

if %errorlevel% equ 0 (
    echo Build successful! SushiRunner.pdx created.
    echo.
    
    REM Launch simulator with the game
    if exist "!SIMULATOR_PATH!" (
        echo Launching Playdate Simulator...
        start "" "!SIMULATOR_PATH!" SushiRunner.pdx
    )
) else (
    echo Build failed with error code %errorlevel%
)

pause
