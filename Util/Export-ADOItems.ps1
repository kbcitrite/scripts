param (
    $Organization,
    $OutPath = ".\output",
    $PAT,
    $Project
)
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($PAT)"))
$headers = @{
    "Authorization" = "Basic $base64AuthInfo"
    "Content-Type"  = "application/json-patch+json"
}
$Query = @{
    "query" = "SELECT [System.Id], [System.Title], [System.State], [System.AssignedTo] FROM workitems WHERE [System.TeamProject] = '$Project' AND [System.State] not IN ('Closed', 'Resolved')"
} | ConvertTo-Json
$queryUrl = "https://dev.azure.com/$Organization/$Project/_apis/wit/wiql?api-version=6.0"
$queryResponse = Invoke-RestMethod -Uri $queryUrl -Method Post -Body $Query -Headers $headers -ContentType "application/json"
$workItemIds = $queryResponse.workitems.id 
foreach ($workItemId in $workItemIds) {
    if (!(Test-Path "$OutPath\$workItemId")) {
        New-Item -Path "$OutPath\$workItemId" -ItemType Directory -Force | Out-Null
    }
    $workItemUrl = "https://dev.azure.com/$Organization/$Project/_apis/wit/workitems/$($workItemId)?`$expand=Relations&api-version=6.9"
    $workItemResponse = Invoke-RestMethod -Uri $workItemUrl -Method Get -Headers $headers 
    if ($null -ne $workItemResponse.relations) {
        if ($null -ne $attachmentResponse) {
            foreach ($attachment in $workItemResponse.relations | Where-Object { $_.rel -eq "AttachedFile" }) {
                $attachmentUrl = $attachment.uri
                $attachmentResponse = Invoke-RestMethod -Uri $attachmentUrl -Method Get -Headers $headers -OutFile "$OutPath\$workItemId\$($attachment.attributes.name)"
            }
        }
    }
    [PSCustomObject]@{
        AssignedTo  = $workItemResponse.fields.'System.AssignedTo'
        Title       = $workItemResponse.fields.'System.Title'
        Description = $workItemResponse.fields.'System.Description'
        Id          = $workItemId
        State       = $workItemResponse.fields.'System.State'
        LastUpdate  = $workItemResponse.fields.'System.ChangedDate'
    } | ConvertTo-Json | Out-File "$OutPath\$workItemId\$workItemId.json" -Encoding utf8
}