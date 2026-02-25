# Add PermissionAuthorize attributes to all major controllers
$controllers = @(
    "BookingsController.cs",
    "ExpensesController.cs",
    "InvoicesController.cs", 
    "PaymentsController.cs",
    "QuotationsController.cs",
    "RevenueController.cs",
    "SalesPipelinesController.cs",
    "TasksController.cs"
)

$controllerPath = "C:\Users\aviditej\source\repos\CRM_beforeauth\CRM\CRM\CRM\Controllers"

foreach ($controller in $controllers) {
    $filePath = Join-Path $controllerPath $controller
    if (Test-Path $filePath) {
        Write-Host "Processing $controller..."
        
        $content = Get-Content $filePath -Raw
        
        # Add using statement
        if ($content -notmatch "using CRM\.Attributes;") {
            $content = $content -replace "(using Microsoft\.AspNetCore\.Mvc;)", "`$1`nusing CRM.Attributes;"
        }
        
        # Add PermissionAuthorize to Index actions
        $content = $content -replace "(\s+public IActionResult Index\()", "`n        [PermissionAuthorize(`"View`")]`$1"
        
        Set-Content $filePath $content -Encoding UTF8
        Write-Host "Updated $controller"
    }
}

Write-Host "All controllers updated!"