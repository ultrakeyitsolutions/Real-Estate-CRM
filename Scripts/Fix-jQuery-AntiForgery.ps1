# Quick fix for jQuery anti-forgery tokens
# This script adds anti-forgery tokens to jQuery POST calls

$files = @(
    "Views\Tasks\Calendar.cshtml",
    "Views\ManageUsers\Index.cshtml", 
    "Views\Settings\Impersonation.cshtml",
    "Views\Shared\_Layout.cshtml",
    "Views\Shared\_WhatsAppModal.cshtml",
    "Views\Expenses\Create.cshtml",
    "Views\Agent\List.cshtml"
)

foreach ($file in $files) {
    $filePath = Join-Path $PSScriptRoot "..\$file"
    if (Test-Path $filePath) {
        $content = Get-Content $filePath -Raw
        
        # Fix $.post() calls
        $content = $content -replace '(\$\.post\([^,]+,\s*)(\{[^}]*\})', '$1{ ...$2, __RequestVerificationToken: $(''input[name="__RequestVerificationToken"]'').val() }'
        
        # Fix $.ajax() calls
        $content = $content -replace '(data:\s*)(\{[^}]*\})', '$1{ ...$2, __RequestVerificationToken: $(''input[name="__RequestVerificationToken"]'').val() }'
        
        Set-Content $filePath $content -Encoding UTF8
        Write-Host "Fixed: $file" -ForegroundColor Green
    }
}