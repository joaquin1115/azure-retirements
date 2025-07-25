# join.ps1
# Une resultados de eol-retirements y advisor, eliminando duplicados

if (-not ($script:Retirements -and $script:AdvisorRecommendations)) {
    Write-Error "No se encontraron variables globales Retirements o AdvisorRecommendations."
    return
}

# Unir ambos conjuntos
$combined = $script:Retirements + $script:AdvisorRecommendations

# Agrupar por combinación RetiringFeature + ResourceId
$grouped = $combined | Group-Object { "$($_.RetiringFeature)|$($_.ResourceId)" }

# Seleccionar el registro con más campos llenos en cada grupo
$final = foreach ($group in $grouped) {
    $group.Group | Sort-Object {
        ($_.RetirementService, $_.Link, $_.ShortDescription) -join ""
    } -Descending | Select-Object -First 1
}

# Ruta de salida
$outputPath = Join-Path $PSScriptRoot "..\..\output\combined_results.csv"
$outputDir = Split-Path $outputPath
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
}

# Exportar
$final | Export-Csv $outputPath -NoTypeInformation -Encoding UTF8
Write-Host "Resultados exportados a $outputPath"
