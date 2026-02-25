# PowerShell Script to Auto-Add [ValidateAntiForgeryToken] to Controllers
# This script scans all controllers and adds the attribute to [HttpPost] methods that are missing it

param(
    [switch]$WhatIf = $false,  # Dry run mode - shows what would be changed without making changes
    [switch]$Backup = $true     # Create backup files before modifying
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Anti-Forgery Token Auto-Fix Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($WhatIf) {
    Write-Host "Running in DRY RUN mode - no files will be modified" -ForegroundColor Yellow
    Write-Host ""
}

# Get the project root directory (parent of Scripts folder)
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptPath
$controllersPath = Join-Path $projectRoot "Controllers"

Write-Host "Project root: $projectRoot" -ForegroundColor Gray
Write-Host "Controllers path: $controllersPath" -ForegroundColor Gray
Write-Host ""

if (-not (Test-Path $controllersPath)) {
    Write-Host "ERROR: Controllers folder not found at $controllersPath" -ForegroundColor Red
    exit 1
}

$totalFixed = 0
$totalSkipped = 0
$filesModified = @()

# Exceptions - methods that should NOT have anti-forgery tokens
$exceptions = @(
    'RazorpayWebhook',  # External webhook
    'FacebookWebhook',   # External webhook
    'WhatsAppWebhook'    # External webhook
)

Get-ChildItem -Path $controllersPath -Filter "*.cs" -Recurse | ForEach-Object {
    $file = $_
    $filePath = $file.FullName
    $content = Get-Content $filePath -Raw
    $lines = Get-Content $filePath
    $modified = $false
    $fixesInFile = 0
    
    Write-Host "Scanning: $($file.Name)" -ForegroundColor Gray
    
    # Create backup if enabled and not in WhatIf mode
    if ($Backup -and -not $WhatIf) {
        $backupPath = "$filePath.backup"
        Copy-Item $filePath $backupPath -Force
    }
    
    $newLines = @()
    $i = 0
    
    while ($i -lt $lines.Count) {
        $line = $lines[$i]
        
        # Check if current line is [HttpPost]
        if ($line -match '^\s*\[HttpPost\]') {
            $hasToken = $false
            $methodName = ""
            
            # Check previous 5 lines for ValidateAntiForgeryToken
            for ($j = [Math]::Max(0, $i-5); $j -lt $i; $j++) {
                if ($lines[$j] -match 'ValidateAntiForgeryToken') {
                    $hasToken = $true
                    break
                }
            }
            
            # Check next line for ValidateAntiForgeryToken
            if ($i+1 -lt $lines.Count -and $lines[$i+1] -match 'ValidateAntiForgeryToken') {
                $hasToken = $true
            }
            
            # Get method name
            $methodLine = $i + 1
            while ($methodLine -lt $lines.Count -and $lines[$methodLine] -notmatch 'public.*\(') {
                $methodLine++
            }
            if ($methodLine -lt $lines.Count) {
                if ($lines[$methodLine] -match 'public\s+\w+\s+(\w+)\s*\(') {
                    $methodName = $matches[1]
                }
            }
            
            # Check if method is in exceptions list
            $isException = $exceptions -contains $methodName
            
            if (-not $hasToken -and -not $isException) {
                # Add the new line
                $newLines += $line
                
                # Get indentation from current line
                $indent = ""
                if ($line -match '^(\s*)') {
                    $indent = $matches[1]
                }
                
                # Add ValidateAntiForgeryToken on next line with same indentation
                $newLines += "$indent[ValidateAntiForgeryToken]"
                
                $fixesInFile++
                $totalFixed++
                
                Write-Host "  ✓ Added token to: $methodName (line $($i+1))" -ForegroundColor Green
                
                $i++
                continue
            }
            elseif ($isException) {
                Write-Host "  ⊘ Skipped (webhook): $methodName" -ForegroundColor DarkYellow
                $totalSkipped++
            }
        }
        
        $newLines += $line
        $i++
    }
    
    # Write modified content back to file if changes were made
    if ($fixesInFile -gt 0) {
        if (-not $WhatIf) {
            $newLines | Set-Content $filePath -Encoding UTF8
            Write-Host "  → Modified $fixesInFile method(s) in $($file.Name)" -ForegroundColor Cyan
        } else {
            Write-Host "  → Would modify $fixesInFile method(s) in $($file.Name)" -ForegroundColor Yellow
        }
        $filesModified += $file.Name
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Methods fixed: $totalFixed" -ForegroundColor Green
Write-Host "Methods skipped (webhooks): $totalSkipped" -ForegroundColor Yellow
Write-Host "Files modified: $($filesModified.Count)" -ForegroundColor Cyan

if ($filesModified.Count -gt 0) {
    Write-Host ""
    Write-Host "Modified files:" -ForegroundColor Cyan
    $filesModified | ForEach-Object {
        Write-Host "  - $_" -ForegroundColor Gray
    }
}

if ($WhatIf) {
    Write-Host ""
    Write-Host "This was a DRY RUN. To apply changes, run without -WhatIf flag:" -ForegroundColor Yellow
    Write-Host "  .\Fix-AntiForgeryTokens.ps1" -ForegroundColor White
}

if ($Backup -and -not $WhatIf -and $filesModified.Count -gt 0) {
    Write-Host ""
    Write-Host "Backup files created with .backup extension" -ForegroundColor Green
    Write-Host "To restore: Get-ChildItem -Filter '*.backup' | ForEach-Object { Move-Item `$_ `$_.FullName.Replace('.backup','') -Force }" -ForegroundColor Gray
}

Write-Host ""
Write-Host "✓ Done!" -ForegroundColor Green
