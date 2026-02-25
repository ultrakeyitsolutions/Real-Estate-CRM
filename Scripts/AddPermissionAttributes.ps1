# PowerShell script to add PermissionAuthorize attributes to controllers
$controllers = @(
    "BookingsController.cs",
    "ExpensesController.cs", 
    "InvoicesController.cs",
    "PaymentsController.cs",
    "PropertiesController.cs",
    "QuotationsController.cs",
    "RevenueController.cs",
    "SalesPipelinesController.cs",
    "TasksController.cs",
    "WebhookLeadsController.cs"
)

$controllerPath = "C:\Users\aviditej\source\repos\CRM_beforeauth\CRM\CRM\CRM\Controllers"

foreach ($controller in $controllers) {
    $filePath = Join-Path $controllerPath $controller
    if (Test-Path $filePath) {
        Write-Host "Processing $controller..."
        
        $content = Get-Content $filePath -Raw
        
        # Add using statement if not present
        if ($content -notmatch "using CRM\.Attributes;") {
            $content = $content -replace "(using Microsoft\.AspNetCore\.Mvc;)", "`$1`nusing CRM.Attributes;"
        }
        
        # Add PermissionAuthorize to Index actions
        $content = $content -replace "(\s+public IActionResult Index\()", "`n        [PermissionAuthorize(`"View`")]`$1"
        
        # Add PermissionAuthorize to Create actions
        $content = $content -replace "(\s+public IActionResult Create\()", "`n        [PermissionAuthorize(`"Create`")]`$1"
        $content = $content -replace "(\s+\[HttpPost\][\s\S]*?public (?:async )?(?:Task<)?IActionResult Create\()", "`n        [PermissionAuthorize(`"Create`")]`$1"
        
        # Add PermissionAuthorize to Edit actions
        $content = $content -replace "(\s+public IActionResult Edit\()", "`n        [PermissionAuthorize(`"Edit`")]`$1"
        $content = $content -replace "(\s+\[HttpPost\][\s\S]*?public (?:async )?(?:Task<)?IActionResult Edit\()", "`n        [PermissionAuthorize(`"Edit`")]`$1"
        
        # Add PermissionAuthorize to Delete actions
        $content = $content -replace "(\s+public IActionResult Delete\()", "`n        [PermissionAuthorize(`"Delete`")]`$1"
        $content = $content -replace "(\s+\[HttpPost\][\s\S]*?public (?:async )?(?:Task<)?IActionResult Delete\()", "`n        [PermissionAuthorize(`"Delete`")]`$1"
        
        Set-Content $filePath $content -Encoding UTF8
        Write-Host "Updated $controller"
    }
}

Write-Host "Permission attributes added to all controllers!"