$ErrorActionPreference = 'Stop'
$projectRoot = $PSScriptRoot
$engineRoot = Join-Path (Split-Path $projectRoot -Parent) 'music-engine'
Push-Location $engineRoot
try {
    go build -trimpath -o (Join-Path $projectRoot 'windows/engine/engine.exe') ./cmd/agent
    if ($LASTEXITCODE -ne 0) { throw 'No se pudo compilar el Engine.' }
} finally { Pop-Location }
Push-Location $projectRoot
try {
    flutter build windows --release
    if ($LASTEXITCODE -ne 0) { throw 'No se pudo compilar Flutter.' }
} finally { Pop-Location }
