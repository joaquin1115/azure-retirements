# advisor.ps1
# Ejecuta consulta KQL para recomendaciones de advisor

$script:AdvisorRecommendations = @()
$kqlPath = Join-Path $PSScriptRoot "query\resource_list.kql"
$queryText = Get-Content $kqlPath -Raw

$subscriptions = Get-AzSubscription

foreach ($sub in $subscriptions) {
    Set-AzContext -SubscriptionId $sub.Id | Out-Null

    $result = Search-AzGraph -Query $queryText

    foreach ($row in $result) {
        # Extraer el nombre del resource group desde el resourceId
        $resourceIdParts = $row.resourceId -split '/'
        $resourceGroup = ""
        $rgIndex = [Array]::IndexOf($resourceIdParts, "resourceGroups")
        if ($rgIndex -ge 0 -and ($rgIndex + 1) -lt $resourceIdParts.Length) {
            $resourceGroup = $resourceIdParts[$rgIndex + 1]
        }

        $AdvisorRecommendations += [PSCustomObject]@{
            SubscriptionId     = $resourceIdParts[2]
            ResourceGroup      = $resourceGroup
            ResourceId         = $row.resourceId
            Type               = $row.resourceType
            RetiringFeature    = $row.retirementFeatureName
            RetirementDate     = $row.retirementDate
            Source             = "advisor"
            MoreInfo           = $row.shortDescription
        }
    }
}

# Export opcional para debug
$AdvisorRecommendations | Export-Csv "$PSScriptRoot\_advisor_output.csv" -NoTypeInformation
