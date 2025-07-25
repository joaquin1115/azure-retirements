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
        $AdvisorRecommendations += [PSCustomObject]@{
            ServiceID               = ""
            SubscriptionId          = ($row.resourceId -split '/')[2]
            Type                    = ""
            ResourceGroup           = ""
            Location                = ""
            ResourceId              = $row.resourceId
            Tags                    = ""
            SubscriptionName        = ""
            RetiringFeature         = $row.retirementFeatureName
            RetirementDate          = $row.retirementDate
            RetirementService       = ""
            Link                    = ""
            Source                  = "advisor"
            ShortDescription        = $row.shortDescription
        }
    }
}

# Export opcional para debug
$AdvisorRecommendations | Export-Csv "$PSScriptRoot\_advisor_output.csv" -NoTypeInformation
