# join.ps1
# Une resultados de eol-retirements y advisor, eliminando duplicados

if (-not ($script:Retirements -and $script:AdvisorRecommendations)) {
    Write-Error "No se encontraron variables globales Retirements o AdvisorRecommendations."
    return
}

# Unir ambos conjuntos
$combined = $script:Retirements + $script:AdvisorRecommendations

# Eliminar duplicados basados en combinación RetiringFeature + ResourceId
$final = $combined | Sort-Object RetiringFeature, ResourceId -Unique -Property @{
    Expression = { "$($_.RetiringFeature)|$($_.ResourceId)" }
}

# Exportar resultados combinados
$outputPath = Join-Path $PSScriptRoot "..\..\output\combined_results.csv"
$outputDir = Split-Path $outputPath
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
}

$final | Export-Csv $outputPath -NoTypeInformation -Encoding UTF8
Write-Host "Resultados exportados a $outputPath"
