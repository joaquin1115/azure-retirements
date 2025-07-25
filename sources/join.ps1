# Rutas de entrada/salida
$jsonPath = ".\eol-retirements.json"
$csvPath = ".\avisor.csv"
$outputPath = "..\..\output\combined_results.csv"

# Cargar y procesar el JSON
$jsonContent = Get-Content $jsonPath -Raw | ConvertFrom-Json
$jsonData = $jsonContent.content | ForEach-Object {
    [PSCustomObject]@{
        RetiringFeature = $_.RetiringFeature
        RetirementDate  = [datetime]$_.RetirementDate
        MoreInfo        = $_.Link
    }
}

# Cargar y procesar el CSV
$csvData = Import-Csv $csvPath | ForEach-Object {
    $resourceGroup = ($_."resourceId" -split "/")[4]
    [PSCustomObject]@{
        RetiringFeature = $_.retirementFeatureName
        RetirementDate  = [datetime]$_.retirementDate
        ResourceId      = $_.resourceId
        ResourceType    = $_.resourceType
        ResourceGroup   = $resourceGroup
        MoreInfo        = $_.shortDescription
    }
}

# Combinar datos: unir por RetiringFeature y RetirementDate
$combined = foreach ($item in $csvData) {
    $match = $jsonData | Where-Object {
        $_.RetiringFeature -eq $item.RetiringFeature -and $_.RetirementDate -eq $item.RetirementDate
    }

    if ($match) {
        # Si hay match, usar el Link del JSON como MoreInfo
        [PSCustomObject]@{
            RetiringFeature = $item.RetiringFeature
            RetirementDate  = $item.RetirementDate
            ResourceId      = $item.ResourceId
            ResourceType    = $item.ResourceType
            ResourceGroup   = $item.ResourceGroup
            MoreInfo        = $match.MoreInfo
        }
    } else {
        # Si no hay match, usar la descripción corta del CSV
        $item
    }
}

# Ordenar y exportar
$final = $combined | Sort-Object RetiringFeature, ResourceId -Unique
$final | Export-Csv $outputPath -NoTypeInformation -Encoding UTF8
Write-Host "Resultados exportados a $outputPath"
