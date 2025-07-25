# eol-retirements.ps1
# Ejecuta consulta KQL para servicios retirados y extiende con información del JSON

$script:Retirements = @()
$kqlPath = Join-Path $PSScriptRoot "query\resource_list.kql"
$jsonPath = Join-Path $PSScriptRoot "query\service_list.json"
$queryText = Get-Content $kqlPath -Raw
$jsonData = (Get-Content $jsonPath -Raw | ConvertFrom-Json).content

$subscriptions = Get-AzSubscription

foreach ($sub in $subscriptions) {
    Set-AzContext -SubscriptionId $sub.Id | Out-Null

    $result = Search-AzGraph -Query $queryText

    foreach ($row in $result) {
        $match = $jsonData | Where-Object { $_.Id -eq [int]$row.ServiceID }
        if ($match) {
            $Retirements += [PSCustomObject]@{
                ServiceID               = $row.ServiceID
                SubscriptionId          = $row.subscriptionId
                Type                    = $row.type
                ResourceGroup           = $row.resourceGroup
                Location                = $row.location
                ResourceId              = $row.id
                Tags                    = $row.tags
                SubscriptionName        = $row.subscriptionName
                RetiringFeature         = $match.RetiringFeature
                RetirementDate          = $match.RetirementDate
                RetirementService       = $match.ServiceName
                Link                    = $match.Link
                Source                  = "eol-retirements"
                ShortDescription        = ""
            }
        }
    }
}

# Export opcional para debug
$Retirements | Export-Csv "$PSScriptRoot\_retirements_output.csv" -NoTypeInformation
