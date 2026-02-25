# Remove all ValidateAntiForgeryToken attributes from controllers
$controllerPath = "c:\Users\aviditej\source\CRM\CRM\CRM\Controllers"
$files = Get-ChildItem -Path $controllerPath -Filter "*.cs"

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $newContent = $content -replace '\s*\[ValidateAntiForgeryToken\]\s*\r?\n', "`n"
    Set-Content -Path $file.FullName -Value $newContent -NoNewline
    Write-Host "Processed: $($file.Name)"
}

Write-Host "All ValidateAntiForgeryToken attributes removed from controllers."