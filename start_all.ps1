# Start both backends and the frontend in separate PowerShell windows (Windows)
# Run this from workspace root: .\start_all.ps1

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent

Write-Host "Starting healthcare backend (port 8000)..."
Start-Process powershell -ArgumentList "-NoProfile","-NoExit","-Command","cd '$Root\\healthcare-planner-agent-datagami\\backend'; `$env:PYTHONIOENCODING='utf-8'; `$env:PYTHONUTF8='1'; uvicorn api:app --host 0.0.0.0 --port 8000 --reload"

Write-Host "Starting RAG backend (port 8001)..."
Start-Process powershell -ArgumentList "-NoProfile","-NoExit","-Command","cd '$Root\\Rag-Chat-Bot\\backend'; `$env:PYTHONIOENCODING='utf-8'; `$env:PYTHONUTF8='1'; uvicorn main:app --host 0.0.0.0 --port 8001 --reload"

Write-Host "Starting frontend (Vite) in healthcare frontend..."
Start-Process powershell -ArgumentList "-NoProfile","-NoExit","-Command","cd '$Root\\healthcare-planner-agent-datagami\\frontend'; npm run dev"

Write-Host "All processes started. Check the new windows for logs."
