# Verification Script for Anti-Forgery Tokens
# Scans all views for fetch POST calls and checks if they have anti-forgery tokens

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ANTI-FORGERY TOKEN VERIFICATION" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get the project root directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptPath
$viewsPath = Join-Path $projectRoot "Views"

Write-Host "Project root: $projectRoot" -ForegroundColor Gray
Write-Host "Views path: $viewsPath" -ForegroundColor Gray
Write-Host ""

if (-not (Test-Path $viewsPath)) {
    Write-Host "ERROR: Views folder not found at $viewsPath" -ForegroundColor Red
    exit 1
}

$issuesFound = 0
$filesScanned = 0
$fetchCallsFound = 0

Write-Host "Scanning .cshtml files..." -ForegroundColor Gray
Write-Host ""

Get-ChildItem -Path $viewsPath -Filter "*.cshtml" -Recurse | ForEach-Object {
    $file = $_
    $filesScanned++
    $lines = Get-Content $file.FullName
    
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        
        # Check for fetch with POST method
        if ($line -match "fetch\s*\(" -and ($line -match "method.*['\`"]POST['\`"]" -or $line -match "['\`"]POST['\`"].*method")) {
            $fetchCallsFound++
            $hasToken = $false
            
            # Check surrounding 20 lines for token
            $start = [Math]::Max(0, $i-20)
            $end = [Math]::Min($lines.Count-1, $i+20)
            
            for ($j = $start; $j -le $end; $j++) {
                if ($lines[$j] -match "__RequestVerificationToken|RequestVerificationToken") {
                    $hasToken = $true
                    break
                }
            }
            
            if (-not $hasToken) {
                Write-Host "❌ MISSING TOKEN:" -ForegroundColor Red
                Write-Host "   File: $($file.FullName.Replace($projectRoot, '.'))" -ForegroundColor Yellow
                Write-Host "   Line: $($i+1)" -ForegroundColor Yellow
                Write-Host "   Code: $($line.Trim())" -ForegroundColor Gray
                Write-Host ""
                $issuesFound++
            }
        }
    }
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "SCAN COMPLETE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Files scanned: $filesScanned" -ForegroundColor Gray
Write-Host "Fetch POST calls found: $fetchCallsFound" -ForegroundColor Gray
Write-Host ""

if ($issuesFound -eq 0) {
    Write-Host "✓✓✓ SUCCESS! ✓✓✓" -ForegroundColor Green
    Write-Host "All $fetchCallsFound fetch POST calls have anti-forgery tokens!" -ForegroundColor Green
} else {
    Write-Host "⚠ WARNING ⚠" -ForegroundColor Red
    Write-Host "Found $issuesFound fetch POST calls WITHOUT anti-forgery tokens" -ForegroundColor Red
}

Write-Host ""
exit $issuesFound
