param(
  [string]$Tag = "latest"
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path

function Invoke-DockerBuild {
  param(
    [string]$Dockerfile,
    [string]$ImageTag,
    [string]$ContextPath
  )

  docker build -f $Dockerfile -t $ImageTag $ContextPath
  if ($LASTEXITCODE -ne 0) {
    throw "Docker build failed for image '$ImageTag'. Ensure Docker Desktop is running and permissions are correct."
  }
}

Write-Host "Building Docker images for integrated project..." -ForegroundColor Cyan

# Healthcare backend
Write-Host "[1/3] Building healthcare-backend:$Tag" -ForegroundColor Yellow
Invoke-DockerBuild -Dockerfile "$Root\healthcare-planner-agent-datagami\Dockerfile" -ImageTag "healthcare-backend:$Tag" -ContextPath "$Root\healthcare-planner-agent-datagami"

# RAG backend
Write-Host "[2/3] Building rag-backend:$Tag" -ForegroundColor Yellow
Invoke-DockerBuild -Dockerfile "$Root\Rag-Chat-Bot\Dockerfile" -ImageTag "rag-backend:$Tag" -ContextPath "$Root\Rag-Chat-Bot"

# Frontend (multi-stage build)
Write-Host "[3/3] Building healthcare-frontend:$Tag" -ForegroundColor Yellow
Invoke-DockerBuild -Dockerfile "$Root\healthcare-planner-agent-datagami\Dockerfile.frontend" -ImageTag "healthcare-frontend:$Tag" -ContextPath "$Root\healthcare-planner-agent-datagami"

Write-Host "Build complete." -ForegroundColor Green
Write-Host "Created images:" -ForegroundColor Green
Write-Host "  - healthcare-backend:$Tag"
Write-Host "  - rag-backend:$Tag"
Write-Host "  - healthcare-frontend:$Tag"
