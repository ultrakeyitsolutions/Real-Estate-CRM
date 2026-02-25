# PowerShell Script to Add CSRF Token Protection to All POST/PUT/DELETE Endpoints
# This script adds [ValidateAntiForgeryToken] attribute to all unprotected endpoints

$controllerPath = "C:\Users\aviditej\source\CRM\CRM\CRM\Controllers"
$controllerFiles = Get-ChildItem -Path $controllerPath -Filter "*.cs" -Recurse

$totalFixed = 0
$processedFiles = @()

Write-Host "Starting CSRF Token Protection Implementation..." -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green

foreach ($file in $controllerFiles) {
    Write-Host "`nProcessing: $($file.Name)" -ForegroundColor Cyan
    
    $content = Get-Content $file.FullName -Raw
    $originalContent = $content
    $fileChanged = $false
    $fixCount = 0
    
    # Pattern 1: [HttpPost] without [ValidateAntiForgeryToken]
    $pattern1 = '(\r?\n\s*)\[HttpPost\](\r?\n\s*)(public |private |protected |internal )'
    if ($content -match $pattern1) {
        $matches = [regex]::Matches($content, $pattern1)
        foreach ($match in $matches) {
            # Check if ValidateAntiForgeryToken is not already present in the next 2 lines
            $nextLines = $content.Substring($match.Index, [Math]::Min(200, $content.Length - $match.Index))
            if ($nextLines -notmatch '\[ValidateAntiForgeryToken\]') {
                $content = $content.Replace($match.Value, "$($match.Groups[1].Value)[HttpPost]$($match.Groups[2].Value)[ValidateAntiForgeryToken]$($match.Groups[2].Value)$($match.Groups[3].Value)")
                $fixCount++
                $fileChanged = $true
            }
        }
    }
    
    # Pattern 2: [HttpPut] without [ValidateAntiForgeryToken]
    $pattern2 = '(\r?\n\s*)\[HttpPut\](\r?\n\s*)(public |private |protected |internal )'
    if ($content -match $pattern2) {
        $matches = [regex]::Matches($content, $pattern2)
        foreach ($match in $matches) {
            $nextLines = $content.Substring($match.Index, [Math]::Min(200, $content.Length - $match.Index))
            if ($nextLines -notmatch '\[ValidateAntiForgeryToken\]') {
                $content = $content.Replace($match.Value, "$($match.Groups[1].Value)[HttpPut]$($match.Groups[2].Value)[ValidateAntiForgeryToken]$($match.Groups[2].Value)$($match.Groups[3].Value)")
                $fixCount++
                $fileChanged = $true
            }
        }
    }
    
    # Pattern 3: [HttpDelete] without [ValidateAntiForgeryToken]
    $pattern3 = '(\r?\n\s*)\[HttpDelete\](\r?\n\s*)(public |private |protected |internal )'
    if ($content -match $pattern3) {
        $matches = [regex]::Matches($content, $pattern3)
        foreach ($match in $matches) {
            $nextLines = $content.Substring($match.Index, [Math]::Min(200, $content.Length - $match.Index))
            if ($nextLines -notmatch '\[ValidateAntiForgeryToken\]') {
                $content = $content.Replace($match.Value, "$($match.Groups[1].Value)[HttpDelete]$($match.Groups[2].Value)[ValidateAntiForgeryToken]$($match.Groups[2].Value)$($match.Groups[3].Value)")
                $fixCount++
                $fileChanged = $true
            }
        }
    }
    
    if ($fileChanged) {
        Set-Content -Path $file.FullName -Value $content -NoNewline
        Write-Host "  ✅ Fixed $fixCount endpoints" -ForegroundColor Green
        $totalFixed += $fixCount
        $processedFiles += @{
            File = $file.Name
            Count = $fixCount
        }
    } else {
        Write-Host "  ℹ️  No unprotected endpoints found" -ForegroundColor Gray
    }
}

Write-Host "`n============================================" -ForegroundColor Green
Write-Host "CSRF Token Protection Implementation Complete!" -ForegroundColor Green
Write-Host "Total endpoints protected: $totalFixed" -ForegroundColor Yellow
Write-Host "`nFiles Modified:" -ForegroundColor Cyan
foreach ($file in $processedFiles) {
    Write-Host "  - $($file.File): $($file.Count) endpoints" -ForegroundColor White
}
Write-Host "`n⚠️  IMPORTANT: Review the changes and test thoroughly!" -ForegroundColor Yellow
Write-Host "⚠️  Make sure to add @Html.AntiForgeryToken() in corresponding views!" -ForegroundColor Yellow
