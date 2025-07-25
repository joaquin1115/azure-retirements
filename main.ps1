# main.ps1
# Script principal para ejecutar los análisis de recursos retirados

$basePath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$sourcesPath = Join-Path $basePath "sources"

# Ejecutar ambos módulos
Write-Output "Ejecutando módulo eol-retirements..."
. "$sourcesPath\eol-retirements\eol-retirements.ps1"

Write-Output "Ejecutando módulo advisor..."
. "$sourcesPath\advisor\advisor.ps1"

# Combinar resultados
Write-Output "Combinando resultados..."
. "$sourcesPath\join.ps1"
