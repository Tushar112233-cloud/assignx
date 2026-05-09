Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Invoke-Step {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command
    )

    Write-Host ">> $Command" -ForegroundColor Cyan
    Invoke-Expression $Command
    if ($LASTEXITCODE -ne 0) {
        throw "Command failed with exit code $LASTEXITCODE: $Command"
    }
}

function Build-App {
    param(
        [Parameter(Mandatory = $true)]
        [string]$AppName
    )

    $workspaceRoot = Split-Path -Parent $PSScriptRoot
    if (-not $workspaceRoot) {
        $workspaceRoot = $PSScriptRoot
    }

    $appPath = Join-Path $PSScriptRoot $AppName
    if (-not (Test-Path $appPath)) {
        throw "App folder not found: $appPath"
    }

    Write-Host ""
    Write-Host "===== Building $AppName =====" -ForegroundColor Yellow

    Push-Location $appPath
    try {
        Invoke-Step "flutter clean"
        Invoke-Step "flutter pub get"
        Invoke-Step "flutter build apk --release"
        Invoke-Step "flutter build appbundle --release"
    }
    finally {
        Pop-Location
    }

    $apkSource = Join-Path $appPath "build/app/outputs/flutter-apk/app-release.apk"
    $aabSource = Join-Path $appPath "build/app/outputs/bundle/release/app-release.aab"
    if (-not (Test-Path $apkSource)) {
        throw "APK not found for $AppName at $apkSource"
    }
    if (-not (Test-Path $aabSource)) {
        throw "AAB not found for $AppName at $aabSource"
    }

    $releaseDir = Join-Path $PSScriptRoot "release/$AppName"
    New-Item -ItemType Directory -Force -Path $releaseDir | Out-Null

    $apkTarget = Join-Path $releaseDir "app-release.apk"
    $aabTarget = Join-Path $releaseDir "app-release.aab"

    Copy-Item $apkSource $apkTarget -Force
    Copy-Item $aabSource $aabTarget -Force

    Write-Host "Saved artifacts:" -ForegroundColor Green
    Write-Host "  $apkTarget"
    Write-Host "  $aabTarget"
}

try {
    Write-Host "Starting release builds for all apps..." -ForegroundColor Magenta
    Build-App -AppName "user_app"
    Build-App -AppName "doer_app"
    Build-App -AppName "superviser_app"
    Write-Host ""
    Write-Host "All builds completed successfully." -ForegroundColor Green
    Write-Host "Artifacts are available under: $PSScriptRoot/release"
}
catch {
    Write-Host ""
    Write-Host "Build failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
