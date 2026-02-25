# Extended Verification Script - Checks multiple POST patterns
# Looks for: fetch(), $.ajax(), $.post(), FormData usage

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "EXTENDED ANTI-FORGERY TOKEN VERIFICATION" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptPath
$viewsPath = Join-Path $projectRoot "Views"

$patterns = @{
    "fetch POST" = "fetch.*method.*POST|POST.*method"
    "$.ajax POST" = "\`$.ajax.*type.*POST|POST.*type"
    "$.post" = "\`$.post\s*\("
    "FormData POST" = "new FormData.*fetch|FormData.*method.*POST"
}

$totalIssues = 0
$totalCalls = 0

foreach ($patternName in $patterns.Keys) {
    $pattern = $patterns[$patternName]
    Write-Host "Checking for $patternName..." -ForegroundColor Cyan
    
    $found = 0
    $missingToken = 0
    
    Get-ChildItem -Path $viewsPath -Filter "*.cshtml" -Recurse | ForEach-Object {
        $file = $_
        $lines = Get-Content $file.FullName
        
        for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($lines[$i] -match $pattern) {
                $found++
                $totalCalls++
                
                # Check surrounding lines for token
                $hasToken = $false
                $start = [Math]::Max(0, $i-20)
                $end = [Math]::Min($lines.Count-1, $i+20)
                
                for ($j = $start; $j -le $end; $j++) {
                    if ($lines[$j] -match "__RequestVerificationToken|RequestVerificationToken") {
                        $hasToken = $true
                        break
                    }
                }
                
                if (-not $hasToken) {
                    if ($missingToken -eq 0) {
                        Write-Host ""
                    }
                    Write-Host "  ❌ $($file.Name):$($i+1)" -ForegroundColor Red
                    $missingToken++
                    $totalIssues++
                }
            }
        }
    }
    
    if ($found -gt 0) {
        $status = if ($missingToken -eq 0) { "✓" } else { "✗" }
        $color = if ($missingToken -eq 0) { "Green" } else { "Red" }
        Write-Host "$status Found $found calls, $missingToken missing tokens" -ForegroundColor $color
    } else {
        Write-Host "  No calls found" -ForegroundColor Gray
    }
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Total POST calls found: $totalCalls" -ForegroundColor Gray
if ($totalIssues -eq 0) {
    Write-Host "✓✓✓ ALL POST CALLS HAVE TOKENS! ✓✓✓" -ForegroundColor Green
} else {
    Write-Host "Issues found: $totalIssues" -ForegroundColor Red
}
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
