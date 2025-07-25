# join.ps1
# Combina los resultados de eol-retirements y advisor en un formato unificado

$consolidatedResults = @()

# Procesar resultados de eol-retirements
foreach ($item in $script:Retirements) {
    $consolidatedItem = [PSCustomObject]@{
        SubscriptionId    = $item.SubscriptionId
        SubscriptionName  = $item.SubscriptionName
        Type             = $item.Type
        ResourceGroup    = $item.ResourceGroup
        Location         = $item.Location
        ResourceId       = $item.ResourceId
        Tags             = $item.Tags
        RetiringFeature  = $item.RetiringFeature
        RetirementDate   = $item.RetirementDate
        Source           = $item.Source
        MoreInfo         = $item.Link  # Para eol-retirements usamos el Link
    }
    $consolidatedResults += $consolidatedItem
}

# Procesar resultados de advisor
foreach ($item in $script:AdvisorRecommendations) {
    $consolidatedItem = [PSCustomObject]@{
        SubscriptionId    = $item.SubscriptionId
        SubscriptionName  = ""  # Advisor no proporciona esta información
        Type             = $item.Type
        ResourceGroup    = $item.ResourceGroup
        Location         = ""  # Advisor no proporciona esta información
        ResourceId       = $item.ResourceId
        Tags             = ""  # Advisor no proporciona esta información
        RetiringFeature  = $item.RetiringFeature
        RetirementDate   = $item.RetirementDate
        Source           = $item.Source
        MoreInfo         = $item.MoreInfo  # Para advisor usamos el shortDescription
    }
    $consolidatedResults += $consolidatedItem
}

# Exportar resultados consolidados
$outputPath = Join-Path (Split-Path -Parent $PSScriptRoot) "consolidated_results.csv"
$consolidatedResults | Export-Csv -Path $outputPath -NoTypeInformation -Encoding UTF8

# Mostrar resumen
Write-Output "Resultados consolidados:"
Write-Output "  - Total registros: $($consolidatedResults.Count)"
Write-Output "  - Archivo generado: $outputPath"

# Mostrar vista previa
$consolidatedResults | Select-Object -First 5 | Format-Table -AutoSize
