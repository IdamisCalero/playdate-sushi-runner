#!/usr/bin/env powershell

# Playdate Sushi Runner Build and Launch Script
# This script compiles and runs your game in the Playdate simulator

param(
    [string]$SDKPath = "C:\Users\Idamis Calero\Documents\PlaydateSDK"
)

$PDCPath = Join-Path $SDKPath "bin\pdc.exe"
$SimulatorPath = Join-Path $SDKPath "bin\PlaydateSimulator.exe"

# Check if pdc exists
if (-not (Test-Path $PDCPath)) {
    Write-Host "Error: pdc not found at $PDCPath" -ForegroundColor Red
    Write-Host "Please update the SDK_PATH to match your Playdate SDK location." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Check if simulator exists
if (-not (Test-Path $SimulatorPath)) {
    Write-Host "Warning: PlaydateSimulator not found at $SimulatorPath" -ForegroundColor Yellow
}

Write-Host "Compiling Sushi Runner..." -ForegroundColor Green

# Build the game
& $PDCPath -sdkpath $SDKPath source SushiRunner.pdx

if ($LASTEXITCODE -eq 0) {
    Write-Host "Build successful! SushiRunner.pdx created." -ForegroundColor Green
    
    # Launch simulator with the game
    if (Test-Path $SimulatorPath) {
        Write-Host "Launching Playdate Simulator..." -ForegroundColor Green
        Start-Process -FilePath $SimulatorPath -ArgumentList "SushiRunner.pdx"
    }
} else {
    Write-Host "Build failed with error code $LASTEXITCODE" -ForegroundColor Red
}

Read-Host "Press Enter to close"
