# join.ps1
# Combina los resultados de eol-retirements y advisor en un formato unificado con separador ;

function Normalize-RetiringFeature {
    param([string]$feature)

    if ([string]::IsNullOrWhiteSpace($feature)) {
        return ""
    }

    # Pasar a minúsculas, reemplazar " and " por coma
    $normalized = $feature.ToLower() -replace '\s+and\s+', ','

    # Separar por coma, quitar espacios y vacíos
    $parts = $normalized -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }

    # Ordenar y reconstruir
    $sorted = $parts | Sort-Object
    return ($sorted -join ",")
}

$consolidatedResults = @()
$processedItems = @{} # Hashtable para evitar duplicados

# Procesar resultados de eol-retirements primero (tienen prioridad)
foreach ($item in $script:Retirements) {
    $normalizedFeature = Normalize-RetiringFeature $item.RetiringFeature
    $key = "$($item.ResourceId.ToLower())-$normalizedFeature"

    if (-not $processedItems.ContainsKey($key)) {
        $consolidatedItem = [PSCustomObject]@{
            SubscriptionId    = $item.SubscriptionId
            SubscriptionName  = $item.SubscriptionName
            Type              = $item.Type
            ResourceGroup     = $item.ResourceGroup
            Location          = $item.Location
            ResourceId        = $item.ResourceId
            Tags              = $item.Tags
            RetiringFeature   = $item.RetiringFeature
            RetirementDate    = $item.RetirementDate
            Source            = $item.Source
            MoreInfo          = $item.Link
        }
        $consolidatedResults += $consolidatedItem
        $processedItems[$key] = $true
    }
}

# Procesar resultados de advisor (solo si no existen en eol-retirements)
foreach ($item in $script:AdvisorRecommendations) {
    $normalizedFeature = Normalize-RetiringFeature $item.RetiringFeature
    $key = "$($item.ResourceId.ToLower())-$normalizedFeature"

    if (-not $processedItems.ContainsKey($key)) {
        $consolidatedItem = [PSCustomObject]@{
            SubscriptionId    = $item.SubscriptionId
            SubscriptionName  = $item.SubscriptionName
            Type              = $item.Type
            ResourceGroup     = $item.ResourceGroup
            Location          = $item.Location
            ResourceId        = $item.ResourceId
            Tags              = $item.Tags
            RetiringFeature   = $item.RetiringFeature
            RetirementDate    = $item.RetirementDate
            Source            = $item.Source
            MoreInfo          = $item.MoreInfo
        }
        $consolidatedResults += $consolidatedItem
        $processedItems[$key] = $true
    }
}

# Exportar resultados consolidados con separador ;
$outputPath = Join-Path (Split-Path -Parent $PSScriptRoot) "consolidated_results.csv"
$consolidatedResults | Export-Csv -Path $outputPath -NoTypeInformation -Encoding UTF8 -Delimiter ";"

# Mostrar resumen
Write-Output "Resultados consolidados:"
Write-Output "  - Total registros: $($consolidatedResults.Count)"
Write-Output "  - Archivo generado: $outputPath"

# Mostrar vista previa
$consolidatedResults | Select-Object -First 5 | Format-Table -AutoSize
