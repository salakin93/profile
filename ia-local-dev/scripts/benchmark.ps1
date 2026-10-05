# Mide la velocidad (tokens/segundo) de cada modelo en este equipo.
# Sirve como evidencia del POC para justificar la compra de GPU.
#   powershell -ExecutionPolicy Bypass -File .\scripts\benchmark.ps1
$modelos = @("qwen2.5-coder:1.5b-base", "dev-coder")
$prompt  = "Escribe una clase Java User con nombre, edad y genero, con getters y setters."
$out = @()
foreach ($m in $modelos) {
    Write-Host "Probando $m ..." -ForegroundColor Cyan
    $body = @{ model = $m; prompt = $prompt; stream = $false } | ConvertTo-Json
    $r = Invoke-RestMethod -Uri "http://localhost:11434/api/generate" -Method Post -Body $body -ContentType "application/json" -TimeoutSec 900
    $tps   = [math]::Round($r.eval_count / ($r.eval_duration / 1e9), 2)
    $total = [math]::Round($r.total_duration / 1e9, 1)
    $out += [pscustomobject]@{ Modelo = $m; TokensGenerados = $r.eval_count; TokensPorSegundo = $tps; SegundosTotales = $total }
}
$out | Format-Table -AutoSize
$out | Export-Csv -NoTypeInformation -Path "benchmark_$(Get-Date -Format yyyyMMdd_HHmm).csv"
