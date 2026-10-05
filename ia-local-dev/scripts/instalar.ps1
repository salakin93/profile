# Instalación del POC de IA local para desarrollo (Windows 10/11, solo CPU).
# Ejecutar en PowerShell desde la carpeta ia-local-dev:
#   powershell -ExecutionPolicy Bypass -File .\scripts\instalar.ps1
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot

Write-Host "== 1/5 Ollama ==" -ForegroundColor Cyan
if (-not (Get-Command ollama -ErrorAction SilentlyContinue)) {
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install --id Ollama.Ollama -e --accept-source-agreements --accept-package-agreements
    } else {
        # Sin winget (comun en equipos corporativos): instalador oficial, por usuario y sin admin.
        $setup = "$env:TEMP\OllamaSetup.exe"
        Write-Host "winget no disponible; descargando instalador oficial..."
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri "https://ollama.com/download/OllamaSetup.exe" -OutFile $setup -UseBasicParsing
        Start-Process -FilePath $setup -ArgumentList "/VERYSILENT", "/NORESTART" -Wait
    }
    $env:Path += ";$env:LOCALAPPDATA\Programs\Ollama"
    if (-not (Get-Command ollama -ErrorAction SilentlyContinue)) {
        throw "No se pudo instalar Ollama. Instalalo manualmente desde https://ollama.com/download y vuelve a ejecutar este script."
    }
    # El servidor de Ollama debe estar corriendo antes de descargar modelos.
    if (-not (Get-Process ollama -ErrorAction SilentlyContinue)) {
        Start-Process ollama -ArgumentList "serve" -WindowStyle Hidden
        Start-Sleep -Seconds 5
    }
} else { Write-Host "Ollama ya instalado." }

Write-Host "== 2/5 Descargando modelos (~6 GB, tarda segun tu red) ==" -ForegroundColor Cyan
ollama pull qwen2.5-coder:7b
ollama pull qwen2.5-coder:1.5b-base
ollama pull nomic-embed-text

Write-Host "== 3/5 Creando modelo dev-coder ==" -ForegroundColor Cyan
ollama create dev-coder -f "$root\ollama\Modelfile"

Write-Host "== 4/5 Extension Continue para VS Code ==" -ForegroundColor Cyan
if (Get-Command code -ErrorAction SilentlyContinue) {
    code --install-extension Continue.continue
} else {
    Write-Warning "No se encontro 'code'. Instala la extension 'Continue' manualmente desde VS Code."
}

Write-Host "== 5/5 Copiando configuracion de Continue ==" -ForegroundColor Cyan
$dest = "$env:USERPROFILE\.continue"
New-Item -ItemType Directory -Force -Path $dest | Out-Null
if (Test-Path "$dest\config.yaml") {
    Copy-Item "$dest\config.yaml" "$dest\config.yaml.bak" -Force
    Write-Host "Respaldo creado: $dest\config.yaml.bak"
}
Copy-Item "$root\continue\config.yaml" "$dest\config.yaml" -Force

Write-Host "`nListo. Abre VS Code, pulsa Ctrl+L para el chat y escribe /crud." -ForegroundColor Green
