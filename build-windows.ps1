$ErrorActionPreference = 'Stop'
$projectRoot = $PSScriptRoot
$engineRoot = Join-Path (Split-Path $projectRoot -Parent) 'music-engine'
$expectedEngineVersion = (Get-Content (Join-Path $projectRoot 'windows/engine/VERSION') -Raw).Trim()
Push-Location $engineRoot
try {
    go build -trimpath -o (Join-Path $projectRoot 'windows/engine/engine.exe') ./cmd/agent
    if ($LASTEXITCODE -ne 0) { throw 'No se pudo compilar el Engine.' }
    $actualEngineVersion = (& (Join-Path $projectRoot 'windows/engine/engine.exe') version).Trim()
    if ($LASTEXITCODE -ne 0 -or $actualEngineVersion -ne $expectedEngineVersion) {
        throw "Engine incompatible: se requiere $expectedEngineVersion y se obtuvo $actualEngineVersion."
    }
} finally { Pop-Location }
Push-Location $projectRoot
try {
    flutter build windows --release --dart-define=UTRACK_TEST=false
    if ($LASTEXITCODE -ne 0) { throw 'No se pudo compilar Flutter.' }
} finally { Pop-Location }
