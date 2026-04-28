# Start all backends and frontend as background jobs in the SAME terminal (no new windows)
# Usage: .\start_all_single.ps1
# All output goes to log files; use Get-Job and Stop-Job to manage

$ErrorActionPreference = 'Continue'
$Root = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Starting AgenticAI Integrated System" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Create logs directory
$LogsDir = Join-Path $Root "logs"
if (-not (Test-Path $LogsDir)) { New-Item -ItemType Directory -Path $LogsDir | Out-Null }

# Clear old logs
Get-Item "$LogsDir\*.log" -ErrorAction SilentlyContinue | Remove-Item | Out-Null

# Healthcare backend (port 8000)
Write-Host "[1/3] Starting Healthcare Backend (port 8000)..." -ForegroundColor Yellow
$job1 = Start-Job -ScriptBlock {
  cd "$using:Root\healthcare-planner-agent-datagami\backend"
  $logFile = "$using:LogsDir\healthcare_backend.log"
  Write-Output "[$(Get-Date)] Healthcare backend starting..." | Out-File $logFile -Append
  try {
    uvicorn api:app --host 0.0.0.0 --port 8000 --reload 2>&1 | Tee-Object -FilePath $logFile -Append
  } catch {
    $_ | Out-File $logFile -Append
  }
}

# RAG backend (port 8001)
Write-Host "[2/3] Starting RAG Backend (port 8001)..." -ForegroundColor Yellow
$job2 = Start-Job -ScriptBlock {
  cd "$using:Root\Rag-Chat-Bot\backend"
  $logFile = "$using:LogsDir\rag_backend.log"
  Write-Output "[$(Get-Date)] RAG backend starting..." | Out-File $logFile -Append
  try {
    uvicorn main:app --host 0.0.0.0 --port 8001 --reload 2>&1 | Tee-Object -FilePath $logFile -Append
  } catch {
    $_ | Out-File $logFile -Append
  }
}

# Frontend (port 5173)
Write-Host "[3/3] Starting Frontend (port 5173)..." -ForegroundColor Yellow
$job3 = Start-Job -ScriptBlock {
  cd "$using:Root\healthcare-planner-agent-datagami\frontend"
  $logFile = "$using:LogsDir\frontend.log"
  Write-Output "[$(Get-Date)] Frontend starting..." | Out-File $logFile -Append
  try {
    npm run dev 2>&1 | Tee-Object -FilePath $logFile -Append
  } catch {
    $_ | Out-File $logFile -Append
  }
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Green
Write-Host "All services started in background!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""
Write-Host "Background Job IDs:" -ForegroundColor Cyan
Write-Host "  Healthcare Backend: $($job1.Id)" -ForegroundColor White
Write-Host "  RAG Backend:        $($job2.Id)" -ForegroundColor White
Write-Host "  Frontend:           $($job3.Id)" -ForegroundColor White
Write-Host ""
Write-Host "Log files location: $LogsDir\" -ForegroundColor Gray
Write-Host ""
Write-Host "Useful commands:" -ForegroundColor Cyan
Write-Host "  Get-Job                              # List all running jobs"
Write-Host "  Get-Job -Id 1 | Receive-Job -Wait   # View and wait for job output"
Write-Host "  Tail-Object -Path logs\*.log         # Tail all logs (if available)"
Write-Host "  Stop-Job -Id 1,2,3                  # Stop all services"
Write-Host ""
Write-Host "Expected URLs:" -ForegroundColor Green
Write-Host "  Frontend:        http://localhost:5173"
Write-Host "  Healthcare API:  http://localhost:8000"
Write-Host "  RAG API:         http://localhost:8001"
Write-Host ""

# Keep PowerShell window open and show job status
Write-Host "Monitor status - Services initializing (~10-30 seconds)..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

while ($true) {
  $jobStatus = @()
  Get-Job | ForEach-Object {
    $state = $_.State
    if ($state -eq "Running") { $state = "Running" }
    $jobStatus += "$($_.Id): $state"
  }
  
  Write-Host "`r[$(Get-Date -Format 'HH:mm:ss')] Jobs: $($jobStatus -join ' | ')" -NoNewline
  Start-Sleep -Seconds 5
}
